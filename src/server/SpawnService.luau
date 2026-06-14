--!nonstrict
-- SpawnService
-- Gère la réapparition des joueurs, les points de spawn et l'attribution du loadout.
--
-- Points de spawn : place des parts dans ta map et tague-les avec le tag
-- CollectionService "FPSSpawn" (via le Tag Editor de Studio).
-- Sinon, le service utilise les SpawnLocation existants, ou (0, 50, 0) par défaut.

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local WeaponConfig = require(Shared.WeaponConfig)
local Net = require(Shared.Net)

local SPAWN_TAG = "FPSSpawn"

local SpawnService = {}
local services

local function getSpawnPoints(): { BasePart }
	local points = {}
	for _, inst in ipairs(CollectionService:GetTagged(SPAWN_TAG)) do
		if inst:IsA("BasePart") then
			table.insert(points, inst)
		end
	end
	if #points == 0 then
		-- Fallback : SpawnLocation de la map
		for _, inst in ipairs(Workspace:GetDescendants()) do
			if inst:IsA("SpawnLocation") then
				table.insert(points, inst)
			end
		end
	end
	return points
end

local function choosePosition(): CFrame
	local points = getSpawnPoints()
	if #points == 0 then
		return CFrame.new(0, 50, 0)
	end
	local point = points[math.random(1, #points)]
	-- Lève un peu + oriente comme le point de spawn
	return point.CFrame + Vector3.new(0, 4, 0)
end

local function applyLoadout(player: Player)
	-- Utilise le loadout sauvegardé du joueur (ou défaut)
	local loadout
	if services and services.Loadout then
		loadout = services.Loadout.getLoadout(player)
	else
		loadout = {
			Primary = WeaponConfig.DefaultLoadout.Primary,
			Secondary = WeaponConfig.DefaultLoadout.Secondary,
		}
	end
	Net.get("PlayerLoadout"):FireClient(player, loadout)
end

local function onCharacterAdded(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.MaxHealth = GameConfig.MaxHealth
	humanoid.Health = GameConfig.MaxHealth

	-- Téléporte au point de spawn une fois le HRP prêt
	local hrp = character:WaitForChild("HumanoidRootPart")
	character:PivotTo(choosePosition())

	-- Mort -> réapparition après délai
	humanoid.Died:Once(function()
		task.delay(GameConfig.RespawnTime, function()
			if player.Parent and services.GameMode.isRoundActive() then
				player:LoadCharacter()
			end
		end)
	end)

	-- Petit délai pour laisser le client charger ses scripts
	task.wait(0.3)
	applyLoadout(player)
end

function SpawnService.init(svc)
	services = svc

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			onCharacterAdded(player, character)
		end)
		-- Si le perso existe déjà
		if player.Character then
			onCharacterAdded(player, player.Character)
		end
	end)
end

return SpawnService
