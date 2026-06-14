--!nonstrict
-- WeaponController
-- Logique d'arme côté client : équipement, tir (raycast + dispersion), recul,
-- rechargement, visée (ADS), changement d'arme, effets visuels et son.
-- Envoie les tirs validables au serveur via le remote FireWeapon.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponConfig = require(Shared.WeaponConfig)
local RaycastUtil = require(Shared.RaycastUtil)
local Net = require(Shared.Net)

local CameraController = require(script.Parent.CameraController)
local Hud = require(script.Parent.Hud)

local WeaponController = {}

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ───────────────────────────── État ─────────────────────────────

local loadout = WeaponConfig.DefaultLoadout
local clientAmmo = {} -- weaponId -> { mag, reserve }
local current = nil -- { id, cfg }
local equippedSlot = "Primary"

local firing = false -- gâchette maintenue
local ads = false -- visée
local reloading = false
local switching = false
local lastShot = 0
local spreadCurrent = 0
local semiLatch = false -- empêche l'auto-fire des armes Semi

-- ───────────────────────────── Munitions ─────────────────────────────

local function resetAmmo()
	clientAmmo = {}
	for slot, id in loadout do
		local cfg = WeaponConfig.get(id)
		if cfg then
			clientAmmo[id] = { mag = cfg.MagSize, reserve = cfg.ReserveAmmo }
		end
	end
end

local function updateAmmoHud()
	if current then
		local ammo = clientAmmo[current.id]
		Hud.setAmmo(ammo.mag, ammo.reserve)
	end
end

-- ───────────────────────────── Effets ─────────────────────────────

local function spawnTracer(origin: Vector3, hitPos: Vector3)
	local distance = (hitPos - origin).Magnitude
	if distance < 1 then
		return
	end
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 225, 140)
	part.Size = Vector3.new(0.08, 0.08, distance)
	part.CFrame = CFrame.lookAt(origin, hitPos) * CFrame.new(0, 0, -distance / 2)
	part.Parent = Workspace
	Debris:AddItem(part, 0.06)
end

local function spawnImpact(hitPos: Vector3, normal: Vector3, onCharacter: boolean)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.Size = Vector3.new(0.3, 0.3, 0.3)
	part.Material = Enum.Material.Neon
	part.Color = onCharacter and Color3.fromRGB(200, 40, 40) or Color3.fromRGB(180, 180, 160)
	part.CFrame = CFrame.new(hitPos, hitPos + normal)
	part.Parent = Workspace
	Debris:AddItem(part, 0.4)
end

-- ───────────────────────────── Tir ─────────────────────────────

local function getIgnoreList(): { Instance }
	local list = { camera }
	if player.Character then
		table.insert(list, player.Character)
	end
	return list
end

local function computeSpread(cfg): number
	-- Dispersion de base + état
	local moving = false
	local char = player.Character
	if char then
		local hum = char:FindFirstChildWhichIsA("Humanoid")
		if hum and hum.MoveDirection.Magnitude > 0.1 then
			moving = true
		end
	end
	local spread = spreadCurrent + cfg.SpreadBase
	if moving then
		spread += cfg.SpreadMoving
	end
	if ads then
		spread *= cfg.AdsSpreadMultiplier
	end
	return spread
end

local function fire()
	if not current then
		return
	end
	local cfg = current.cfg
	local char = player.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildWhichIsA("Humanoid")
	if not hum or hum.Health <= 0 then
		return
	end
	if reloading or switching then
		return
	end

	local now = os.clock()
	if now - lastShot < 60 / cfg.RPM then
		return
	end

	local ammo = clientAmmo[current.id]
	if ammo.mag <= 0 then
		-- Recharge auto si la gâchette est tirée à vide
		WeaponController.reload()
		return
	end

	lastShot = now
	ammo.mag -= 1
	updateAmmoHud()

	local origin = camera.CFrame.Position
	local baseDir = camera.CFrame.LookVector
	local spread = computeSpread(cfg)
	local ignore = getIgnoreList()
	local params = RaycastUtil.makeParams(ignore)

	local serverShots = {}
	local hitCharacter, headHint = false, false

	for _ = 1, cfg.BulletsPerShot do
		local dir = RaycastUtil.applySpread(baseDir, spread) * cfg.Range
		local result = Workspace:Raycast(origin, dir, params)
		local endPos = result and result.Position or (origin + dir)

		spawnTracer(origin + Vector3.new(0, -0.4, 0), endPos)

		if result then
			local humanoid, model = RaycastUtil.getHumanoidFromHit(result.Instance)
			local onChar = humanoid ~= nil
			spawnImpact(result.Position, result.Normal, onChar)

			if humanoid and model then
				-- N'envoie au serveur que les impacts sur des personnages
				table.insert(serverShots, { part = result.Instance, pos = result.Position })
				hitCharacter = true
				headHint = headHint or RaycastUtil.isHeadshot(result.Instance)
			end
		end
	end

	-- Déclare CHAQUE tir au serveur (pour la validation munitions/cadence),
	-- en joignant les impacts sur des personnages à valider pour les dégâts.
	Net.get("FireWeapon"):FireServer({
		weaponId = current.id,
		origin = origin,
		shots = serverShots,
	})

	-- Hitmarker prédictif immédiat (le serveur confirmera les kills)
	if hitCharacter then
		Hud.showHitmarker(false, headHint)
	end

	-- Recul + dispersion
	local yaw = (math.random() - 0.5) * 2 * cfg.RecoilHorizontal
	CameraController.addRecoil(cfg.RecoilVertical, yaw)
	spreadCurrent = math.min(spreadCurrent + cfg.SpreadPerShot, cfg.SpreadMax)

	-- Armes Semi : verrouille jusqu'au relâchement
	if cfg.FireMode == "Semi" then
		semiLatch = true
	end
end

-- ───────────────────────────── Rechargement ─────────────────────────────

function WeaponController.reload()
	if not current or reloading then
		return
	end
	local cfg = current.cfg
	local ammo = clientAmmo[current.id]
	if ammo.mag >= cfg.MagSize or ammo.reserve <= 0 then
		return
	end

	reloading = true
	Hud.setWeaponName(cfg.DisplayName .. "  (rechargement…)")
	Net.get("Reload"):FireServer()

	task.delay(cfg.ReloadTime, function()
		if not current or current.cfg ~= cfg then
			return
		end
		local needed = cfg.MagSize - ammo.mag
		local taken = math.min(needed, ammo.reserve)
		ammo.mag += taken
		ammo.reserve -= taken
		reloading = false
		Hud.setWeaponName(cfg.DisplayName)
		updateAmmoHud()
	end)
end

-- ───────────────────────────── Équipement ─────────────────────────────

function WeaponController.equip(slot: string)
	local id = loadout[slot]
	if not id then
		return
	end
	local cfg = WeaponConfig.get(id)
	if not cfg then
		return
	end
	if current and current.id == id then
		return
	end

	switching = true
	reloading = false
	equippedSlot = slot
	current = { id = id, cfg = cfg }
	spreadCurrent = 0

	CameraController.setRecoilRecovery(cfg.RecoilRecovery)
	CameraController.setFov(cfg.HipFov, cfg.AdsSpeed)
	Hud.setWeaponName(cfg.DisplayName)
	updateAmmoHud()
	Net.get("EquipWeapon"):FireServer(id)

	task.delay(cfg.EquipTime, function()
		if current and current.id == id then
			switching = false
		end
	end)
end

-- ───────────────────────────── Boucle ─────────────────────────────

local function update(dt: number)
	if not current then
		return
	end
	local cfg = current.cfg

	-- Tir continu (Auto) ou unique (Semi)
	if firing and not semiLatch then
		fire()
	end

	-- Récupération de dispersion
	spreadCurrent = math.max(0, spreadCurrent - cfg.SpreadRecovery * dt)
	Hud.setCrosshairSpread(computeSpread(cfg))

	-- FOV selon visée
	local targetFov = ads and cfg.AdsFov or cfg.HipFov
	CameraController.setFov(targetFov, cfg.AdsSpeed)
	Hud.setCrosshairVisible(not ads or cfg.AdsFov > 40)
end

-- ───────────────────────────── Entrées ─────────────────────────────

local function bindInput()
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			firing = true
			semiLatch = false
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			ads = true
		elseif input.KeyCode == Enum.KeyCode.R then
			WeaponController.reload()
		elseif input.KeyCode == Enum.KeyCode.One then
			WeaponController.equip("Primary")
		elseif input.KeyCode == Enum.KeyCode.Two then
			WeaponController.equip("Secondary")
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			firing = false
			semiLatch = false
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			ads = false
		end
	end)
end

-- ───────────────────────────── Réseau / spawn ─────────────────────────────

local function onLoadout(newLoadout)
	if typeof(newLoadout) == "table" then
		loadout = newLoadout
	end
	resetAmmo()
	current = nil
	WeaponController.equip("Primary")
end

local function onCombatFeedback(data)
	if typeof(data) ~= "table" then
		return
	end
	if data.hit then
		Hud.showHitmarker(data.killed == true, data.headshot == true)
	end
end

local function onCharacterAdded()
	resetAmmo()
	current = nil
	reloading = false
	firing = false
	ads = false
	task.wait(0.2)
	WeaponController.equip("Primary")
end

function WeaponController.start()
	resetAmmo()
	bindInput()

	Net.get("PlayerLoadout").OnClientEvent:Connect(onLoadout)
	Net.get("CombatFeedback").OnClientEvent:Connect(onCombatFeedback)

	player.CharacterAdded:Connect(onCharacterAdded)
	if player.Character then
		task.spawn(onCharacterAdded)
	end

	RunService.RenderStepped:Connect(update)
end

return WeaponController
