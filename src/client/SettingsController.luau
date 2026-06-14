--!nonstrict
-- SettingsController
-- Réglages joueur : sensibilité, FOV, volume. Applique + renvoie au serveur (sauvegarde).

local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Net = require(Shared.Net)

local CameraController = require(script.Parent.CameraController)

local SettingsController = {}

-- Réglages par défaut
SettingsController.current = {
	sensitivity = 0.4, -- 0.1 (lent) à 1.5 (rapide)
	fov = 0, -- décalage de FOV : -10 à +30
	volume = 0.5, -- 0 à 1
	adsToggle = false, -- visée en maintien (false) ou bascule (true)
}

local soundGroup

-- Applique un réglage immédiatement
function SettingsController.apply(settings)
	if typeof(settings) ~= "table" then
		return
	end
	for k, v in settings do
		SettingsController.current[k] = v
	end
	local s = SettingsController.current
	UserInputService.MouseDeltaSensitivity = math.clamp(s.sensitivity, 0.1, 3)
	CameraController.setFovBoost(s.fov)
	if soundGroup then
		soundGroup.Volume = math.clamp(s.volume, 0, 1)
	end
end

-- Applique + sauvegarde côté serveur
function SettingsController.set(settings)
	SettingsController.apply(settings)
	Net.get("SaveSettings"):FireServer(SettingsController.current)
end

function SettingsController.start()
	-- Groupe de son maître (pour le réglage de volume)
	soundGroup = SoundService:FindFirstChild("Master")
	if not soundGroup then
		soundGroup = Instance.new("SoundGroup")
		soundGroup.Name = "Master"
		soundGroup.Parent = SoundService
	end
	SettingsController.apply(SettingsController.current)
end

return SettingsController
