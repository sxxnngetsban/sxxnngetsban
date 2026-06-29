-- DataService : s'occupe UNIQUEMENT de sauvegarder / charger les pièces des joueurs.
--
-- Il vit côté serveur (ServerScriptService) car les DataStore ne sont accessibles
-- QUE depuis le serveur. Si le client pouvait écrire dans le DataStore, n'importe
-- quel joueur pourrait se donner 1 million de pièces : ce serait trichable.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Settings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Settings"))

-- GetDataStore renvoie toujours le même "magasin" pour un nom donné, dans toutes
-- les sessions du jeu. C'est lui qui garde les données entre deux visites.
local store = DataStoreService:GetDataStore(Settings.DataStoreName)

local DataService = {}

-- Cache en mémoire : pendant qu'un joueur joue, on garde son total ici.
-- C'est instantané (pas d'appel réseau à chaque pièce). On n'écrit dans le
-- DataStore que lorsqu'il part : c'est plus rapide et ça économise le quota.
local coinsByUserId = {}

-- Construit la "clé" unique d'un joueur. On se base sur son UserId (un nombre qui
-- ne change JAMAIS), pas sur son pseudo (qui, lui, peut changer).
local function keyFor(player)
	return "Player_" .. player.UserId
end

-- Charge le total d'un joueur depuis le DataStore (appelé quand il rejoint).
function DataService.Load(player)
	local userId = player.UserId

	-- pcall = "protected call". Si le DataStore est indisponible (coupure réseau,
	-- quota dépassé...), le jeu ne plante pas : on récupère l'erreur dans "result".
	local ok, result = pcall(function()
		return store:GetAsync(keyFor(player))
	end)

	if ok then
		-- result peut être nil si le joueur n'a JAMAIS joué : dans ce cas, 0.
		coinsByUserId[userId] = result or 0
	else
		-- Lecture échouée : on affiche 0 en mémoire, mais on fera attention à NE PAS
		-- écraser les vraies données plus tard (voir le commentaire dans Save).
		warn("[DataService] Échec du chargement pour " .. player.Name .. " : " .. tostring(result))
		coinsByUserId[userId] = 0
	end

	return coinsByUserId[userId]
end

-- Renvoie le total actuel (depuis le cache mémoire).
function DataService.Get(player)
	return coinsByUserId[player.UserId] or 0
end

-- Ajoute des pièces au total en mémoire et renvoie le nouveau total.
function DataService.Add(player, amount)
	local userId = player.UserId
	coinsByUserId[userId] = (coinsByUserId[userId] or 0) + amount
	return coinsByUserId[userId]
end

-- Sauvegarde le total d'un joueur dans le DataStore.
-- Appelé quand il part (PlayerRemoving) et à la fermeture du serveur (BindToClose).
function DataService.Save(player)
	local userId = player.UserId
	local amount = coinsByUserId[userId]
	if amount == nil then
		return -- rien à sauvegarder (joueur jamais chargé)
	end

	-- On utilise UpdateAsync plutôt que SetAsync (explication détaillée dans le chat).
	-- En bref : UpdateAsync LIT l'ancienne valeur puis ÉCRIT, de façon atomique
	-- (lecture + écriture indivisibles). On reçoit l'ancienne valeur "oldValue" et
	-- on décide quoi garder, ce qui évite d'écraser bêtement des données.
	local ok, err = pcall(function()
		store:UpdateAsync(keyFor(player), function(oldValue)
			-- oldValue = ce qui est DÉJÀ stocké dans le DataStore.
			-- Dans ce petit jeu les pièces ne font qu'augmenter, donc on garde le
			-- plus grand des deux : filet de sécurité contre une écriture en retard.
			local previous = oldValue or 0
			return math.max(previous, amount)
		end)
	end)

	if not ok then
		warn("[DataService] Échec de la sauvegarde pour " .. player.Name .. " : " .. tostring(err))
	end

	-- On nettoie le cache mémoire pour ce joueur.
	coinsByUserId[userId] = nil
end

return DataService
