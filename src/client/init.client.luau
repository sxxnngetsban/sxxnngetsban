--!nonstrict
-- FPSClient (bootstrap)
-- Point d'entrée client : démarre la caméra, le HUD, les armes et branche
-- les retours serveur (vie, scores, killfeed).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Net = require(Shared.Net)

local CameraController = require(script.CameraController)
local Hud = require(script.Hud)
local WeaponController = require(script.WeaponController)
local MovementController = require(script.MovementController)
local ViewModelController = require(script.ViewModelController)
local SettingsController = require(script.SettingsController)
local MobileController = require(script.MobileController)
local MenuController = require(script.MenuController)

local player = Players.LocalPlayer

-- Vue à la première personne verrouillée (souris au centre)
player.CameraMode = Enum.CameraMode.LockFirstPerson

-- Démarrage des contrôleurs
SettingsController.start() -- avant les armes (groupe de son)
CameraController.start()
ViewModelController.start()
Hud.start()
WeaponController.start()
MovementController.start()
MobileController.start()
MenuController.start()

-- Suivi de la vie du joueur -> HUD
local function bindHealth(character)
	local humanoid = character:WaitForChild("Humanoid")
	Hud.setHealth(humanoid.Health, humanoid.MaxHealth)
	humanoid.HealthChanged:Connect(function(health)
		Hud.setHealth(health, humanoid.MaxHealth)
	end)
	humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(function()
		Hud.setHealth(humanoid.Health, humanoid.MaxHealth)
	end)
end

player.CharacterAdded:Connect(bindHealth)
if player.Character then
	bindHealth(player.Character)
end

-- Retours serveur globaux
Net.get("ScoreUpdate").OnClientEvent:Connect(function(payload)
	Hud.updateScores(payload)
end)

Net.get("Killfeed").OnClientEvent:Connect(function(entry)
	Hud.addKillfeed(entry)
end)

print("[FPS] Client initialisé — mode:", GameConfig.Mode)
