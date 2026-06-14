--!nonstrict
-- DataService
-- Sauvegarde persistante des joueurs via DataStoreService.
-- Stocke : XP, monnaie, déblocages, stats, gamepasses connus.
--
-- ⚠️ IMPORTANT : pour que la sauvegarde fonctionne, active dans Studio :
--    Fichier → Paramètres du jeu → Sécurité → « Activer l'accès de Studio aux services API ».
--    En test Studio sans ça (ou hors d'un jeu publié), les données ne se sauvegardent pas
--    réellement — c'est normal, ça marchera une fois le jeu publié.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

local DataService = {}

local STORE_NAME = "PlayerData_v1" -- ⚠️ change le suffixe (_v2...) si tu modifies la structure
local store = DataStoreService:GetDataStore(STORE_NAME)

local sessions = {} -- player -> data (cache en mémoire pendant la session)

-- Données par défaut d'un nouveau joueur
local function defaultData()
	return {
		xp = 0,
		coins = 500,
		unlocks = {}, -- { weaponId = true }
		stats = { kills = 0, deaths = 0, wins = 0, losses = 0, bestStreak = 0, playtime = 0 },
		loadout = nil, -- défini par WeaponConfig.DefaultLoadout si nil
		settings = {}, -- sensibilité, FOV, etc. (Phase 2)
		lastLogin = 0,
		loginStreak = 0,
	}
end

-- Lecture avec retries (anti-erreur réseau DataStore)
local function loadAsync(key: string)
	local attempts = 0
	while attempts < 4 do
		attempts += 1
		local ok, result = pcall(function()
			return store:GetAsync(key)
		end)
		if ok then
			return result
		end
		warn("[DataService] Échec lecture (essai " .. attempts .. ") : " .. tostring(result))
		task.wait(2 ^ attempts) -- backoff : 2s, 4s, 8s...
	end
	return nil
end

-- Écriture avec retries (UpdateAsync = plus sûr contre les écrasements)
local function saveAsync(key: string, data)
	local attempts = 0
	while attempts < 4 do
		attempts += 1
		local ok, err = pcall(function()
			store:UpdateAsync(key, function()
				return data
			end)
		end)
		if ok then
			return true
		end
		warn("[DataService] Échec sauvegarde (essai " .. attempts .. ") : " .. tostring(err))
		task.wait(2 ^ attempts)
	end
	return false
end

local function keyFor(player: Player): string
	return "player_" .. player.UserId
end

-- Charge (ou crée) les données d'un joueur. Renvoie la table de données.
function DataService.load(player: Player)
	local saved = loadAsync(keyFor(player))
	local data = saved or defaultData()
	-- Fusion défensive : ajoute les champs manquants si la structure a évolué
	local defaults = defaultData()
	for k, v in defaults do
		if data[k] == nil then
			data[k] = v
		end
	end
	if data.stats then
		for k, v in defaults.stats do
			if data.stats[k] == nil then
				data.stats[k] = v
			end
		end
	end
	sessions[player] = data
	return data
end

-- Renvoie les données en cache (rapide, sans relire le DataStore)
function DataService.get(player: Player)
	return sessions[player]
end

-- Sauvegarde les données en cache du joueur
function DataService.save(player: Player): boolean
	local data = sessions[player]
	if not data then
		return false
	end
	if RunService:IsStudio() then
		-- En Studio sans API services, on évite de spammer les erreurs
		local ok = pcall(function()
			return saveAsync(keyFor(player), data)
		end)
		return ok
	end
	return saveAsync(keyFor(player), data)
end

function DataService.init()
	Players.PlayerRemoving:Connect(function(player)
		DataService.save(player)
		sessions[player] = nil
	end)

	-- Sauvegarde tout le monde à l'arrêt du serveur (anti-perte de données)
	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			task.spawn(DataService.save, player)
		end
		task.wait(3) -- laisse le temps aux écritures
	end)
end

return DataService
