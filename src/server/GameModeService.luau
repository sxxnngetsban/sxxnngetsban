--!nonstrict
-- GameModeService
-- Gère les modes de jeu (TDM / FFA), les équipes, les scores et la condition de victoire.

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared.GameConfig)
local Net = require(Shared.Net)

local GameModeService = {}

local services
local teamObjects = {} -- index -> Team
local teamScores = {} -- teamName -> score
local roundActive = true
local roundEndTime = 0

-- ───────────────────────────── Équipes ─────────────────────────────

local function setupTeams()
	if GameConfig.Mode ~= "TDM" then
		return
	end
	for index, def in ipairs(GameConfig.Teams) do
		local team = Instance.new("Team")
		team.Name = def.Name
		team.TeamColor = BrickColor.new(def.Color)
		team.AutoAssignable = false
		team.Parent = Teams
		teamObjects[index] = team
		teamScores[def.Name] = 0
	end
end

-- Renvoie l'équipe la moins remplie (équilibrage)
local function getSmallestTeam(): Team?
	if #teamObjects == 0 then
		return nil
	end
	local best, bestCount
	for _, team in ipairs(teamObjects) do
		local count = #team:GetPlayers()
		if not bestCount or count < bestCount then
			best, bestCount = team, count
		end
	end
	return best
end

function GameModeService.assignTeam(player: Player)
	if GameConfig.Mode == "TDM" then
		player.Team = getSmallestTeam()
		player.Neutral = false
	else
		player.Team = nil
		player.Neutral = true
	end
end

-- Deux joueurs sont-ils alliés ? (pour le tir ami)
function GameModeService.areAllies(playerA: Player, playerB: Player): boolean
	if playerA == playerB then
		return true
	end
	if GameConfig.Mode ~= "TDM" then
		return false
	end
	return playerA.Team ~= nil and playerA.Team == playerB.Team
end

-- ───────────────────────────── Scores ─────────────────────────────

local function broadcastScores()
	local payload = {
		mode = GameConfig.Mode,
		roundActive = roundActive,
		timeLeft = math.max(0, math.floor(roundEndTime - os.clock())),
		scoreToWin = GameConfig.ScoreToWin,
		teams = {},
		players = {},
	}
	for name, score in teamScores do
		payload.teams[name] = score
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local stats = player:FindFirstChild("leaderstats")
		payload.players[player.Name] = {
			kills = stats and stats:FindFirstChild("Kills") and stats.Kills.Value or 0,
			deaths = stats and stats:FindFirstChild("Deaths") and stats.Deaths.Value or 0,
			team = player.Team and player.Team.Name or nil,
		}
	end
	Net.get("ScoreUpdate"):FireAllClients(payload)
end

local function setupLeaderstats(player: Player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	local kills = Instance.new("IntValue")
	kills.Name = "Kills"
	kills.Parent = stats
	local deaths = Instance.new("IntValue")
	deaths.Name = "Deaths"
	deaths.Parent = stats
	stats.Parent = player
end

-- Appelé par CombatService lors d'une élimination
function GameModeService.registerKill(killer: Player?, victim: Player, weaponId: string, headshot: boolean)
	-- Stats victime
	local vStats = victim:FindFirstChild("leaderstats")
	if vStats and vStats:FindFirstChild("Deaths") then
		vStats.Deaths.Value += 1
	end

	-- Stats tueur (si différent de la victime et pas un suicide allié)
	if killer and killer ~= victim then
		local kStats = killer:FindFirstChild("leaderstats")
		if kStats and kStats:FindFirstChild("Kills") then
			kStats.Kills.Value += 1
		end
		if GameConfig.Mode == "TDM" and killer.Team then
			teamScores[killer.Team.Name] = (teamScores[killer.Team.Name] or 0) + 1
		end
	end

	-- Killfeed pour tous
	Net.get("Killfeed"):FireAllClients({
		killer = killer and killer.Name or nil,
		killerTeam = killer and killer.Team and killer.Team.Name or nil,
		victim = victim.Name,
		victimTeam = victim.Team and victim.Team.Name or nil,
		weaponId = weaponId,
		headshot = headshot,
	})

	GameModeService.checkWinCondition()
	broadcastScores()
end

function GameModeService.checkWinCondition()
	if not roundActive then
		return
	end
	if GameConfig.Mode == "TDM" then
		for name, score in teamScores do
			if score >= GameConfig.ScoreToWin then
				GameModeService.endRound(name)
				return
			end
		end
	else
		for _, player in ipairs(Players:GetPlayers()) do
			local stats = player:FindFirstChild("leaderstats")
			if stats and stats:FindFirstChild("Kills") and stats.Kills.Value >= GameConfig.ScoreToWin then
				GameModeService.endRound(player.Name)
				return
			end
		end
	end
end

function GameModeService.endRound(winner: string)
	roundActive = false
	Net.get("ScoreUpdate"):FireAllClients({
		mode = GameConfig.Mode,
		roundActive = false,
		winner = winner,
	})
	task.delay(8, GameModeService.startRound)
end

function GameModeService.startRound()
	roundActive = true
	roundEndTime = os.clock() + GameConfig.RoundTime
	for name in teamScores do
		teamScores[name] = 0
	end
	for _, player in ipairs(Players:GetPlayers()) do
		local stats = player:FindFirstChild("leaderstats")
		if stats then
			if stats:FindFirstChild("Kills") then
				stats.Kills.Value = 0
			end
			if stats:FindFirstChild("Deaths") then
				stats.Deaths.Value = 0
			end
		end
		player:LoadCharacter()
	end
	broadcastScores()
end

function GameModeService.isRoundActive(): boolean
	return roundActive
end

-- ───────────────────────────── Init ─────────────────────────────

function GameModeService.init(svc)
	services = svc
	setupTeams()
	roundEndTime = os.clock() + GameConfig.RoundTime

	Players.PlayerAdded:Connect(function(player)
		setupLeaderstats(player)
		GameModeService.assignTeam(player)
		task.wait(0.5)
		broadcastScores()
	end)

	Players.PlayerRemoving:Connect(function()
		task.defer(broadcastScores)
	end)

	-- Diffusion régulière du temps restant
	task.spawn(function()
		while true do
			task.wait(1)
			if roundActive then
				broadcastScores()
				if os.clock() >= roundEndTime then
					-- Fin au temps : meilleur score gagne
					GameModeService.endRound("Temps écoulé")
				end
			end
		end
	end)
end

return GameModeService
