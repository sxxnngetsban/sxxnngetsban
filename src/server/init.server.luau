-- Script PRINCIPAL du serveur.
-- Comme ce fichier s'appelle "init.server.luau", c'est le dossier "Server" lui-même
-- qui devient un Script (il s'exécute tout seul au démarrage du serveur).
--
-- Il orchestre tout le côté serveur :
--   1) crée le RemoteEvent pour parler au client,
--   2) fait apparaître les pièces,
--   3) gère le ramassage (Touched) et met à jour le total,
--   4) charge / sauvegarde via DataService quand un joueur arrive / part.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Settings"))
local DataService = require(script.DataService)

-- 1) RemoteEvent : le "fil" par lequel le serveur dit au client
-- "ton total de pièces a changé, voici la nouvelle valeur".
-- On le crée côté serveur, dans ReplicatedStorage (visible client ET serveur).
local remote = Instance.new("RemoteEvent")
remote.Name = Settings.RemoteName
remote.Parent = ReplicatedStorage

-- Dossier qui contiendra toutes les pièces (pour ranger proprement le Workspace).
local coinsFolder = Instance.new("Folder")
coinsFolder.Name = "Coins"
coinsFolder.Parent = workspace

-- Envoie à UN joueur son total, pour que son interface l'affiche.
-- FireClient = "envoie cet événement à ce client précis".
local function pushCount(player)
	remote:FireClient(player, DataService.Get(player))
end

-- Crée UNE pièce à une position aléatoire dans la zone définie.
local function spawnCoin()
	local coin = Instance.new("Part")
	coin.Name = "Coin"
	coin.Shape = Enum.PartType.Cylinder
	coin.Size = Vector3.new(0.4, 3, 3) -- un disque fin (épaisseur 0.4, diamètre 3)
	coin.Color = Color3.fromRGB(255, 215, 0) -- doré
	coin.Material = Enum.Material.Neon
	coin.Anchored = true -- la pièce ne tombe pas, elle reste en place
	coin.CanCollide = false -- on passe à travers pour la ramasser (pas un mur)

	-- Position aléatoire en X et Z, hauteur fixe en Y.
	local range = Settings.SpawnRange
	local x = math.random(-range, range)
	local z = math.random(-range, range)
	coin.Position = Vector3.new(x, Settings.CoinHeight, z)
	-- On couche le cylindre pour qu'il flotte à plat comme une pièce.
	coin.Orientation = Vector3.new(0, 0, 90)

	coin.Parent = coinsFolder

	-- "collected" évite de compter deux fois si plusieurs membres du corps
	-- touchent la pièce dans le même instant.
	local collected = false
	coin.Touched:Connect(function(otherPart)
		if collected then
			return
		end

		-- Est-ce le corps d'un joueur ? On remonte de la pièce touchée au
		-- personnage, puis du personnage au joueur.
		local character = otherPart.Parent
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return -- ce n'était pas un joueur (ex: une autre pièce)
		end

		collected = true
		coin:Destroy() -- la pièce disparaît

		-- +CoinValue au total du joueur, puis on prévient son interface.
		DataService.Add(player, Settings.CoinValue)
		pushCount(player)

		-- On en refait apparaître une autre pour que le jeu continue.
		task.wait(0.5)
		spawnCoin()
	end)
end

-- 2) On fait apparaître le nombre de pièces voulu au démarrage du serveur.
for _ = 1, Settings.CoinCount do
	spawnCoin()
end

-- 3) Communication client -> serveur : quand le client est prêt, il demande son
-- total de départ. On le lui (re)pousse. Ça garantit que l'affichage est correct
-- dès l'arrivée, même si le client a fini de charger après le serveur.
remote.OnServerEvent:Connect(function(player)
	pushCount(player)
end)

-- 4) Quand un joueur REJOINT : on charge son total sauvegardé.
Players.PlayerAdded:Connect(function(player)
	DataService.Load(player)
	pushCount(player)
end)

-- Quand un joueur PART : on sauvegarde son total.
Players.PlayerRemoving:Connect(function(player)
	DataService.Save(player)
end)

-- Quand le SERVEUR se ferme (dernier joueur parti ou arrêt du jeu) : on sauvegarde
-- tout le monde encore présent, pour ne rien perdre.
game:BindToClose(function()
	for _, player in Players:GetPlayers() do
		DataService.Save(player)
	end
end)
