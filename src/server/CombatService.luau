--!nonstrict
-- CombatService
-- Reçoit les tirs des clients, les VALIDE côté serveur (anti-triche), applique
-- les dégâts, gère les munitions serveur et attribue les éliminations.
--
-- Modèle : "client raycast + validation serveur". Le client annonce ce qu'il a
-- touché (réactivité), le serveur vérifie la plausibilité avant d'appliquer les dégâts.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local WeaponConfig = require(Shared.WeaponConfig)
local RaycastUtil = require(Shared.RaycastUtil)
local Net = require(Shared.Net)

local CombatService = {}
local services

-- État de combat par joueur
local state = {} -- player -> { equipped, weapons = {id = {mag, reserve}}, lastFire, reloading }
-- Dernier attaquant par victime (pour créditer le kill)
local lastAttacker = {} -- victim(Player) -> { killer, weaponId, headshot, time }

local KILL_CREDIT_WINDOW = 8 -- secondes

-- ───────────────────────────── État joueur ─────────────────────────────

local function ensureState(player: Player)
	if not state[player] then
		state[player] = {
			equipped = nil,
			slot = nil,
			weapons = {},
			lastFire = 0,
			reloading = false,
			reloadToken = 0,
		}
	end
	return state[player]
end

local function ensureWeaponAmmo(player: Player, weaponId: string)
	local s = ensureState(player)
	local cfg = WeaponConfig.get(weaponId)
	if not cfg then
		return nil
	end
	if not s.weapons[weaponId] then
		s.weapons[weaponId] = { mag = cfg.MagSize, reserve = cfg.ReserveAmmo }
	end
	return s.weapons[weaponId]
end

-- ───────────────────────────── Équipement ─────────────────────────────

local function onEquip(player: Player, weaponId: string)
	if typeof(weaponId) ~= "string" then
		return
	end
	local cfg = WeaponConfig.get(weaponId)
	if not cfg then
		return
	end
	local s = ensureState(player)
	s.equipped = weaponId
	s.slot = cfg.Slot
	s.reloading = false
	ensureWeaponAmmo(player, weaponId)
end

-- ───────────────────────────── Rechargement ─────────────────────────────

local function onReload(player: Player)
	local s = ensureState(player)
	local weaponId = s.equipped
	if not weaponId then
		return
	end
	local cfg = WeaponConfig.get(weaponId)
	local ammo = ensureWeaponAmmo(player, weaponId)
	if not cfg or not ammo then
		return
	end
	if s.reloading or ammo.mag >= cfg.MagSize or ammo.reserve <= 0 then
		return
	end

	s.reloading = true
	s.reloadToken += 1
	local token = s.reloadToken

	task.delay(cfg.ReloadTime, function()
		-- Annulé si le joueur a changé d'arme / rechargé entre-temps
		if not state[player] or s.reloadToken ~= token then
			return
		end
		local needed = cfg.MagSize - ammo.mag
		local taken = math.min(needed, ammo.reserve)
		ammo.mag += taken
		ammo.reserve -= taken
		s.reloading = false
	end)
end

-- ───────────────────────────── Dégâts & kills ─────────────────────────────

local function applyDamage(shooter: Player, victimPlayer: Player, humanoid: Humanoid, amount: number, weaponId: string, headshot: boolean)
	if humanoid.Health <= 0 then
		return
	end
	lastAttacker[victimPlayer] = {
		killer = shooter,
		weaponId = weaponId,
		headshot = headshot,
		time = os.clock(),
	}
	humanoid:TakeDamage(amount)

	-- Retour au tireur : hitmarker + confirmation de kill
	Net.get("CombatFeedback"):FireClient(shooter, {
		hit = true,
		headshot = headshot,
		killed = humanoid.Health <= 0,
		damage = amount,
		victim = victimPlayer.Name,
	})
end

local function onHumanoidDied(victimPlayer: Player, weaponContext: string?)
	local info = lastAttacker[victimPlayer]
	local killer, weaponId, headshot = nil, weaponContext or "Inconnu", false
	if info and (os.clock() - info.time) <= KILL_CREDIT_WINDOW then
		killer = info.killer
		weaponId = info.weaponId
		headshot = info.headshot
	end
	lastAttacker[victimPlayer] = nil
	services.GameMode.registerKill(killer, victimPlayer, weaponId, headshot)
end

-- ───────────────────────────── Validation des tirs ─────────────────────────────

-- Vérifie qu'un tir est plausible côté serveur.
local function validateAndApply(shooter: Player, payload)
	if not services.GameMode.isRoundActive() then
		return
	end
	if typeof(payload) ~= "table" then
		return
	end

	local character = shooter.Character
	if not character then
		return
	end
	local shooterHum = character:FindFirstChildWhichIsA("Humanoid")
	local shooterHRP = character:FindFirstChild("HumanoidRootPart")
	if not shooterHum or shooterHum.Health <= 0 or not shooterHRP then
		return
	end

	local s = ensureState(shooter)
	local weaponId = payload.weaponId
	if weaponId ~= s.equipped then
		return -- arme non équipée côté serveur
	end
	local cfg = WeaponConfig.get(weaponId)
	if not cfg then
		return
	end

	-- Cadence de tir
	local now = os.clock()
	local minInterval = (60 / cfg.RPM) * GameConfig.Security.FireRateTolerance
	if now - s.lastFire < minInterval then
		return -- tir trop rapide -> rejeté
	end

	-- Munitions
	local ammo = ensureWeaponAmmo(shooter, weaponId)
	if s.reloading or ammo.mag <= 0 then
		return
	end

	s.lastFire = now
	ammo.mag -= 1

	-- Origine plausible (proche du joueur)
	local origin = payload.origin
	if typeof(origin) ~= "Vector3" then
		return
	end
	if (origin - shooterHRP.Position).Magnitude > 12 then
		return -- origine trop loin du joueur -> rejeté
	end

	-- Traite chaque plomb / balle annoncé
	local shots = payload.shots
	if typeof(shots) ~= "table" then
		return
	end

	local maxRange = cfg.Range + GameConfig.Security.MaxRangeTolerance

	for _, shot in ipairs(shots) do
		local hitPart = shot.part
		local hitPos = shot.pos
		if typeof(hitPart) ~= "Instance" or typeof(hitPos) ~= "Vector3" then
			continue
		end

		local humanoid, targetModel = RaycastUtil.getHumanoidFromHit(hitPart)
		if not humanoid or not targetModel then
			continue
		end
		local victimPlayer = Players:GetPlayerFromCharacter(targetModel)

		-- Pas de tir ami
		if victimPlayer and not GameConfig.FriendlyFire and services.GameMode.areAllies(shooter, victimPlayer) then
			continue
		end

		-- Distance dans la portée
		local distance = (hitPos - origin).Magnitude
		if distance > maxRange then
			continue
		end

		-- La position annoncée correspond-elle à la vraie position de la partie ?
		if (hitPart.Position - hitPos).Magnitude > GameConfig.Security.MaxHitDeviation then
			continue
		end

		-- Ligne de vue : le mur ne bloque pas le tir ?
		local params = RaycastUtil.makeParams({ character, targetModel })
		local losResult = Workspace:Raycast(origin, (hitPos - origin), params)
		if losResult then
			-- Un obstacle du monde est sur le trajet avant la cible -> mur -> rejeté
			if (losResult.Position - origin).Magnitude < distance - 2 then
				continue
			end
		end

		-- Dégâts validés
		local headshot = RaycastUtil.isHeadshot(hitPart)
		local falloff = WeaponConfig.getFalloffMultiplier(cfg, distance)
		local damage = cfg.Damage * falloff
		if headshot then
			damage = damage * cfg.HeadshotMultiplier
		end

		if victimPlayer then
			applyDamage(shooter, victimPlayer, humanoid, damage, weaponId, headshot)
		else
			-- Cible PNJ / dummy
			humanoid:TakeDamage(damage)
			Net.get("CombatFeedback"):FireClient(shooter, {
				hit = true,
				headshot = headshot,
				killed = humanoid.Health <= 0,
				damage = damage,
			})
		end
	end
end

-- ───────────────────────────── Cycle de vie ─────────────────────────────

local function onCharacterAdded(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid")
	-- Réinitialise les munitions au spawn
	local s = ensureState(player)
	s.weapons = {}
	s.reloading = false
	humanoid.Died:Once(function()
		onHumanoidDied(player, s.equipped)
	end)
end

function CombatService.init(svc)
	services = svc

	Net.get("FireWeapon").OnServerEvent:Connect(validateAndApply)
	Net.get("Reload").OnServerEvent:Connect(onReload)
	Net.get("EquipWeapon").OnServerEvent:Connect(onEquip)

	Players.PlayerAdded:Connect(function(player)
		ensureState(player)
		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		state[player] = nil
		lastAttacker[player] = nil
	end)
end

return CombatService
