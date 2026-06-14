--!nonstrict
-- Net
-- Centralise la création et l'accès aux RemoteEvents.
-- Le serveur appelle Net.setup() au démarrage ; client et serveur utilisent Net.get(name).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = {}

local FOLDER_NAME = "FPSRemotes"

-- Définition des remotes : nom -> ClassName
local DEFINITIONS = {
	FireWeapon = "RemoteEvent", -- client -> serveur : déclaration de tir
	Reload = "RemoteEvent", -- client -> serveur : rechargement
	EquipWeapon = "RemoteEvent", -- client -> serveur : changement d'arme
	CombatFeedback = "RemoteEvent", -- serveur -> client : hitmarker / kill confirm
	Killfeed = "RemoteEvent", -- serveur -> tous : journal des éliminations
	ScoreUpdate = "RemoteEvent", -- serveur -> tous : scores / état de manche
	PlayerLoadout = "RemoteEvent", -- serveur -> client : loadout au spawn
	ProgressionUpdate = "RemoteEvent", -- serveur -> client : XP / niveau / monnaie gagnés
	DataSync = "RemoteEvent", -- serveur -> client : profil complet (coins, unlocks, stats, settings, loadout)
	SetLoadout = "RemoteEvent", -- client -> serveur : choix d'armes
	BuyItem = "RemoteEvent", -- client -> serveur : achat avec monnaie in-game
	SaveSettings = "RemoteEvent", -- client -> serveur : sauvegarde des réglages
	Notify = "RemoteEvent", -- serveur -> client : message court (toast)
}

-- Serveur uniquement : crée le dossier et tous les remotes
function Net.setup()
	assert(RunService:IsServer(), "Net.setup() doit être appelé sur le serveur")

	local folder = ReplicatedStorage:FindFirstChild(FOLDER_NAME)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = FOLDER_NAME
		folder.Parent = ReplicatedStorage
	end

	for name, className in DEFINITIONS do
		if not folder:FindFirstChild(name) then
			local remote = Instance.new(className)
			remote.Name = name
			remote.Parent = folder
		end
	end

	return folder
end

-- Renvoie un remote par son nom (attend qu'il existe)
function Net.get(name: string): RemoteEvent
	local folder = ReplicatedStorage:WaitForChild(FOLDER_NAME)
	return folder:WaitForChild(name)
end

return Net
