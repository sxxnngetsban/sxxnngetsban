--!nonstrict
-- ProgressionService
-- XP, niveaux, monnaie et stats persistantes. S'appuie sur DataService pour la sauvegarde.
-- Crée les leaderstats (Niveau / Kills / Deaths) + la monnaie (Crédits).

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ProgressionConfig = require(Shared.ProgressionConfig)
local WeaponConfig = require(Shared.WeaponConfig)
local Net = require(Shared.Net)

local ProgressionService = {}
local services

-- Met à jour les valeurs visibles (leaderstats + monnaie) depuis les données
local function syncValues(player: Player)
	local data = services.Data.get(player)
	if not data then
		return
	end
	local level = ProgressionConfig.levelFromTotalXp(data.xp)
	local stats = player:FindFirstChild("leaderstats")
	if stats then
		if stats:FindFirstChild("Niveau") then
			stats.Niveau.Value = level
		end
	end
	local coins = player:FindFirstChild("Coins")
	if coins then
		coins.Value = data.coins
	end
end

-- Crée les objets visibles pour un joueur
local function setupPlayer(player: Player)
	local data = services.Data.load(player) -- charge (yield) ou crée les données

	-- Débloque automatiquement les armes du niveau atteint
	ProgressionService.refreshUnlocks(player)

	-- leaderstats (apparaît dans la liste des joueurs)
	local stats = player:FindFirstChild("leaderstats")
	if not stats then
		stats = Instance.new("Folder")
		stats.Name = "leaderstats"
		stats.Parent = player
	end
	local function ensure(name)
		local v = stats:FindFirstChild(name)
		if not v then
			v = Instance.new("IntValue")
			v.Name = name
			v.Parent = stats
		end
		return v
	end
	ensure("Niveau")
	ensure("Kills") -- réinitialisé par manche (GameModeService)
	ensure("Deaths")

	-- Monnaie (hors leaderstats pour ne pas surcharger la liste)
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = data.coins
	coins.Parent = player

	syncValues(player)
end

-- Débloque les armes dont le niveau requis est atteint
function ProgressionService.refreshUnlocks(player: Player)
	local data = services.Data.get(player)
	if not data then
		return
	end
	local level = ProgressionConfig.levelFromTotalXp(data.xp)
	for id, weapon in WeaponConfig.Weapons do
		if weapon.UnlockLevel and weapon.UnlockLevel <= level then
			data.unlocks[id] = true
		end
	end
end

-- Vérifie si un joueur a débloqué une arme (niveau OU achat)
function ProgressionService.hasUnlocked(player: Player, weaponId: string): boolean
	local data = services.Data.get(player)
	if not data then
		return false
	end
	local weapon = WeaponConfig.get(weaponId)
	if not weapon then
		return false
	end
	if weapon.UnlockLevel and weapon.UnlockLevel <= 0 then
		return true
	end
	return data.unlocks[weaponId] == true
end

-- Ajoute de l'XP + des crédits, gère la montée de niveau
function ProgressionService.award(player: Player, xp: number, coins: number)
	local data = services.Data.get(player)
	if not data then
		return
	end
	-- Multiplicateur d'XP (gamepasses VIP/DoubleXP, boosts)
	if services.Monetization then
		xp = math.floor(xp * services.Monetization.getXpMultiplier(player))
	end

	local oldLevel = ProgressionConfig.levelFromTotalXp(data.xp)
	data.xp += xp
	data.coins += coins
	local newLevel = ProgressionConfig.levelFromTotalXp(data.xp)

	if newLevel > oldLevel then
		ProgressionService.refreshUnlocks(player)
		-- ⚠️ ASSET À AJOUTER : son / effet de level-up (Phase 4 « juice »)
	end

	syncValues(player)

	-- Rafraîchit le profil complet côté client (menus : coins, niveau…)
	if services.Loadout then
		services.Loadout.sync(player)
	end

	-- Notifie le client (pour l'UI / le « juice »)
	Net.get("ProgressionUpdate"):FireClient(player, {
		xp = data.xp,
		coins = data.coins,
		level = newLevel,
		leveledUp = newLevel > oldLevel,
		gainedXp = xp,
		gainedCoins = coins,
	})
end

-- Appelé par GameModeService à chaque élimination
function ProgressionService.onKill(killer: Player?, victim: Player, headshot: boolean)
	-- Stats persistantes de la victime
	local vData = services.Data.get(victim)
	if vData then
		vData.stats.deaths += 1
		vData.stats.streak = 0
	end

	if killer and killer ~= victim then
		local kData = services.Data.get(killer)
		if kData then
			kData.stats.kills += 1
			kData.stats.streak = (kData.stats.streak or 0) + 1
			if kData.stats.streak > (kData.stats.bestStreak or 0) then
				kData.stats.bestStreak = kData.stats.streak
			end
		end
		local r = ProgressionConfig.Rewards
		local xp = r.Kill.xp + (headshot and r.Headshot.xp or 0)
		local coins = r.Kill.coins + (headshot and r.Headshot.coins or 0)
		ProgressionService.award(killer, xp, coins)
	end
end

-- Appelé en fin de manche par GameModeService
function ProgressionService.onRoundEnd(winners: { Player })
	local winnerSet = {}
	for _, p in ipairs(winners) do
		winnerSet[p] = true
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local data = services.Data.get(player)
		if data then
			if winnerSet[player] then
				data.stats.wins += 1
				ProgressionService.award(player, ProgressionConfig.Rewards.Win.xp, ProgressionConfig.Rewards.Win.coins)
			else
				data.stats.losses += 1
				ProgressionService.award(player, ProgressionConfig.Rewards.Loss.xp, ProgressionConfig.Rewards.Loss.coins)
			end
		end
	end
end

function ProgressionService.init(svc)
	services = svc

	Players.PlayerAdded:Connect(function(player)
		-- setupPlayer yield (DataStore) : on l'isole dans une task
		task.spawn(setupPlayer, player)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(setupPlayer, player)
	end
end

return ProgressionService
