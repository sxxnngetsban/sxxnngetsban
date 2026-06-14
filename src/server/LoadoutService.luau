--!nonstrict
-- LoadoutService
-- Choix d'armes du joueur, achats avec la monnaie in-game, réglages,
-- et synchronisation du profil complet vers le client (pour les menus).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponConfig = require(Shared.WeaponConfig)
local ProgressionConfig = require(Shared.ProgressionConfig)
local MonetizationConfig = require(Shared.MonetizationConfig)
local Net = require(Shared.Net)

local LoadoutService = {}
local services

local function notify(player: Player, text: string)
	Net.get("Notify"):FireClient(player, text)
end

-- Renvoie le loadout courant (ou par défaut)
function LoadoutService.getLoadout(player: Player)
	local data = services.Data.get(player)
	if data and data.loadout and data.loadout.Primary and data.loadout.Secondary then
		return data.loadout
	end
	return { Primary = WeaponConfig.DefaultLoadout.Primary, Secondary = WeaponConfig.DefaultLoadout.Secondary }
end

-- Envoie le profil complet au client (pour les menus)
function LoadoutService.sync(player: Player)
	local data = services.Data.get(player)
	if not data then
		return
	end
	local level, levelXp, nextXp = ProgressionConfig.levelFromTotalXp(data.xp)

	local gamepasses = {}
	if services.Monetization then
		for name in MonetizationConfig.Gamepasses do
			gamepasses[name] = services.Monetization.hasGamepass(player, name)
		end
	end

	Net.get("DataSync"):FireClient(player, {
		coins = data.coins,
		xp = data.xp,
		level = level,
		levelXp = levelXp,
		nextLevelXp = nextXp,
		stats = data.stats,
		unlocks = data.unlocks,
		loadout = LoadoutService.getLoadout(player),
		settings = data.settings,
		gamepasses = gamepasses,
	})
end

-- Choix d'armes (validation : existe + bon slot + débloqué)
local function onSetLoadout(player: Player, payload)
	if typeof(payload) ~= "table" then
		return
	end
	local data = services.Data.get(player)
	if not data then
		return
	end
	local function validate(id: string, slot: string): boolean
		local w = WeaponConfig.get(id)
		if not w or w.Slot ~= slot then
			return false
		end
		return services.Progression.hasUnlocked(player, id)
	end

	local newLoadout = LoadoutService.getLoadout(player)
	if typeof(payload.Primary) == "string" and validate(payload.Primary, "Primary") then
		newLoadout.Primary = payload.Primary
	end
	if typeof(payload.Secondary) == "string" and validate(payload.Secondary, "Secondary") then
		newLoadout.Secondary = payload.Secondary
	end
	data.loadout = newLoadout

	-- Applique tout de suite côté client (rééquipe l'arme)
	Net.get("PlayerLoadout"):FireClient(player, newLoadout)
	LoadoutService.sync(player)
end

-- Achat d'une arme avec la monnaie in-game
local function onBuyItem(player: Player, payload)
	if typeof(payload) ~= "table" or typeof(payload.weaponId) ~= "string" then
		return
	end
	local data = services.Data.get(player)
	local weapon = WeaponConfig.get(payload.weaponId)
	if not data or not weapon then
		return
	end
	if data.unlocks[payload.weaponId] then
		notify(player, "Tu possèdes déjà cette arme.")
		return
	end
	local price = weapon.Price or 0
	if price <= 0 then
		data.unlocks[payload.weaponId] = true
		LoadoutService.sync(player)
		return
	end
	if data.coins < price then
		notify(player, "Pas assez de crédits (" .. price .. " requis).")
		return
	end
	data.coins -= price
	data.unlocks[payload.weaponId] = true
	notify(player, weapon.DisplayName .. " débloquée !")
	LoadoutService.sync(player)
end

-- Sauvegarde des réglages (sensibilité, FOV, volume…)
local function onSaveSettings(player: Player, payload)
	if typeof(payload) ~= "table" then
		return
	end
	local data = services.Data.get(player)
	if not data then
		return
	end
	data.settings = payload
end

function LoadoutService.init(svc)
	services = svc

	Net.get("SetLoadout").OnServerEvent:Connect(onSetLoadout)
	Net.get("BuyItem").OnServerEvent:Connect(onBuyItem)
	Net.get("SaveSettings").OnServerEvent:Connect(onSaveSettings)

	-- Première synchro quand les données sont prêtes
	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			-- Attend que DataService ait chargé le profil
			for _ = 1, 60 do
				if services.Data.get(player) then
					break
				end
				task.wait(0.2)
			end
			LoadoutService.sync(player)
		end)
	end)
end

return LoadoutService
