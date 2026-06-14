--!nonstrict
-- Hud
-- Construit l'interface du FPS par code : viseur dynamique, munitions, barre de vie,
-- hitmarker, killfeed, infos de manche et tableau des scores (Tab).

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Hud = {}

local player = Players.LocalPlayer
local gui
local elements = {}
local crosshairLines = {}

local CROSSHAIR_BASE_GAP = 4 -- pixels au centre
local CROSSHAIR_LENGTH = 8

-- ───────────────────────────── Helpers ─────────────────────────────

local function make(className, props, parent)
	local inst = Instance.new(className)
	for k, v in props do
		inst[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

-- ───────────────────────────── Construction ─────────────────────────────

local function buildCrosshair()
	local container = make("Frame", {
		Name = "Crosshair",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(2, 2),
		BackgroundTransparency = 1,
	}, gui)

	-- Point central
	make("Frame", {
		Name = "Dot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, container)

	local dirs = {
		{ name = "Top", anchor = Vector2.new(0.5, 1), pos = Vector2.new(0.5, 0), vertical = true },
		{ name = "Bottom", anchor = Vector2.new(0.5, 0), pos = Vector2.new(0.5, 1), vertical = true },
		{ name = "Left", anchor = Vector2.new(1, 0.5), pos = Vector2.new(0, 0.5), vertical = false },
		{ name = "Right", anchor = Vector2.new(0, 0.5), pos = Vector2.new(1, 0.5), vertical = false },
	}
	for _, d in dirs do
		local line = make("Frame", {
			Name = d.name,
			AnchorPoint = d.anchor,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Size = d.vertical and UDim2.fromOffset(2, CROSSHAIR_LENGTH) or UDim2.fromOffset(CROSSHAIR_LENGTH, 2),
		}, container)
		crosshairLines[d.name] = { line = line, dir = d }
	end
	elements.crosshair = container
end

local function buildAmmo()
	local frame = make("Frame", {
		Name = "AmmoFrame",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -24, 1, -24),
		Size = UDim2.fromOffset(220, 60),
		BackgroundTransparency = 1,
	}, gui)

	elements.weaponName = make("TextLabel", {
		Name = "WeaponName",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(220, 22),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = Color3.fromRGB(220, 220, 220),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, frame)

	elements.ammo = make("TextLabel", {
		Name = "Ammo",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 0, 1, 0),
		Size = UDim2.fromOffset(220, 36),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "0 / 0",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 30,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, frame)
end

local function buildHealth()
	local frame = make("Frame", {
		Name = "HealthFrame",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 24, 1, -24),
		Size = UDim2.fromOffset(260, 24),
		BackgroundColor3 = Color3.fromRGB(25, 25, 25),
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
	}, gui)
	make("UICorner", { CornerRadius = UDim.new(0, 4) }, frame)

	elements.healthBar = make("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.fromRGB(70, 200, 90),
		BorderSizePixel = 0,
	}, frame)
	make("UICorner", { CornerRadius = UDim.new(0, 4) }, elements.healthBar)

	elements.healthText = make("TextLabel", {
		Name = "HealthText",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "100",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
	}, frame)
end

local function buildHitmarker()
	local container = make("Frame", {
		Name = "Hitmarker",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		Visible = false,
	}, gui)
	-- 4 traits en diagonale
	local marks = {
		{ rot = 45, pos = Vector2.new(0.2, 0.2) },
		{ rot = -45, pos = Vector2.new(0.8, 0.2) },
		{ rot = -45, pos = Vector2.new(0.2, 0.8) },
		{ rot = 45, pos = Vector2.new(0.8, 0.8) },
	}
	for i, m in marks do
		make("Frame", {
			Name = "Mark" .. i,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(m.pos.X, m.pos.Y),
			Size = UDim2.fromOffset(7, 2),
			Rotation = m.rot,
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		}, container)
	end
	elements.hitmarker = container
end

local function buildKillfeed()
	elements.killfeed = make("Frame", {
		Name = "Killfeed",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 80),
		Size = UDim2.fromOffset(360, 200),
		BackgroundTransparency = 1,
	}, gui)
	make("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, elements.killfeed)
end

local function buildRoundInfo()
	elements.roundInfo = make("TextLabel", {
		Name = "RoundInfo",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 12),
		Size = UDim2.fromOffset(420, 30),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 20,
		TextStrokeTransparency = 0.6,
	}, gui)
end

local function buildScoreboard()
	elements.scoreboard = make("Frame", {
		Name = "Scoreboard",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(480, 360),
		BackgroundColor3 = Color3.fromRGB(20, 20, 24),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Visible = false,
	}, gui)
	make("UICorner", { CornerRadius = UDim.new(0, 8) }, elements.scoreboard)
	make("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
	}, elements.scoreboard)
	elements.scoreboardList = make("Frame", {
		Name = "List",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
	}, elements.scoreboard)
	make("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, elements.scoreboardList)
end

-- ───────────────────────────── API publique ─────────────────────────────

function Hud.setWeaponName(name: string)
	if elements.weaponName then
		elements.weaponName.Text = name
	end
end

function Hud.setAmmo(mag: number, reserve: number)
	if elements.ammo then
		elements.ammo.Text = string.format("%d / %d", mag, reserve)
		elements.ammo.TextColor3 = mag == 0 and Color3.fromRGB(230, 80, 80) or Color3.new(1, 1, 1)
	end
end

function Hud.setHealth(health: number, maxHealth: number)
	if not elements.healthBar then
		return
	end
	local ratio = math.clamp(health / maxHealth, 0, 1)
	elements.healthBar.Size = UDim2.fromScale(ratio, 1)
	elements.healthBar.BackgroundColor3 = Color3.fromRGB(
		math.floor(220 * (1 - ratio)) + 30,
		math.floor(200 * ratio) + 20,
		60
	)
	elements.healthText.Text = tostring(math.ceil(health))
end

-- Met à jour l'écart du viseur en fonction de la dispersion (degrés)
function Hud.setCrosshairSpread(spreadDegrees: number)
	local gap = CROSSHAIR_BASE_GAP + spreadDegrees * 6
	for _, entry in crosshairLines do
		local d = entry.dir
		if d.vertical then
			entry.line.Position = UDim2.new(0.5, 0, d.pos.Y, d.pos.Y == 0 and -gap or gap)
		else
			entry.line.Position = UDim2.new(d.pos.X, d.pos.X == 0 and -gap or gap, 0.5, 0)
		end
	end
end

function Hud.setCrosshairVisible(visible: boolean)
	if elements.crosshair then
		elements.crosshair.Visible = visible
	end
end

local hitmarkerToken = 0
function Hud.showHitmarker(killed: boolean, headshot: boolean)
	local hm = elements.hitmarker
	if not hm then
		return
	end
	local color = killed and Color3.fromRGB(255, 70, 70)
		or headshot and Color3.fromRGB(255, 210, 80)
		or Color3.new(1, 1, 1)
	for _, m in hm:GetChildren() do
		if m:IsA("Frame") then
			m.BackgroundColor3 = color
		end
	end
	hm.Visible = true
	hitmarkerToken += 1
	local token = hitmarkerToken
	task.delay(killed and 0.25 or 0.12, function()
		if token == hitmarkerToken then
			hm.Visible = false
		end
	end)
end

local function teamColor(teamName)
	if not teamName then
		return Color3.fromRGB(220, 220, 220)
	end
	-- Couleurs cohérentes avec GameConfig (rouge/bleu)
	if teamName:find("ttaq") then
		return Color3.fromRGB(235, 90, 90)
	elseif teamName:find("éfens") or teamName:find("efens") then
		return Color3.fromRGB(90, 140, 235)
	end
	return Color3.fromRGB(220, 220, 220)
end

function Hud.addKillfeed(entry)
	if not elements.killfeed then
		return
	end
	local label = make("TextLabel", {
		Size = UDim2.fromOffset(360, 22),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		Font = Enum.Font.GothamMedium,
		Text = string.format(
			"%s  ❯%s  %s",
			entry.killer or "???",
			entry.headshot and " ✪" or "",
			entry.victim or "???"
		),
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Right,
		LayoutOrder = os.clock() * 1000,
	}, elements.killfeed)
	make("UICorner", { CornerRadius = UDim.new(0, 3) }, label)
	make("UIPadding", { PaddingRight = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8) }, label)
	task.delay(5, function()
		label:Destroy()
	end)
end

function Hud.updateScores(payload)
	if not payload then
		return
	end
	-- Bandeau du haut
	if elements.roundInfo then
		if payload.roundActive == false and payload.winner then
			elements.roundInfo.Text = "🏆 " .. tostring(payload.winner) .. " gagne la manche !"
		elseif payload.mode == "TDM" and payload.teams then
			local parts = {}
			for name, score in payload.teams do
				table.insert(parts, string.format("%s %d", name, score))
			end
			elements.roundInfo.Text = table.concat(parts, "   |   ")
				.. (payload.timeLeft and string.format("   ⏱ %02d:%02d", math.floor(payload.timeLeft / 60), payload.timeLeft % 60) or "")
		elseif payload.timeLeft then
			elements.roundInfo.Text = string.format("⏱ %02d:%02d", math.floor(payload.timeLeft / 60), payload.timeLeft % 60)
		end
	end

	-- Tableau des scores
	if elements.scoreboardList and payload.players then
		for _, child in elements.scoreboardList:GetChildren() do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
		local sorted = {}
		for name, data in payload.players do
			table.insert(sorted, { name = name, data = data })
		end
		table.sort(sorted, function(a, b)
			return (a.data.kills or 0) > (b.data.kills or 0)
		end)
		for i, entry in ipairs(sorted) do
			local row = make("TextLabel", {
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = teamColor(entry.data.team),
				BackgroundTransparency = 0.75,
				Font = Enum.Font.GothamMedium,
				Text = string.format("  %-22s   K %d   D %d", entry.name, entry.data.kills or 0, entry.data.deaths or 0),
				TextColor3 = Color3.new(1, 1, 1),
				TextSize = 15,
				TextXAlignment = Enum.TextXAlignment.Left,
				LayoutOrder = i,
			}, elements.scoreboardList)
			make("UICorner", { CornerRadius = UDim.new(0, 3) }, row)
		end
	end
end

function Hud.setScoreboardVisible(visible: boolean)
	if elements.scoreboard then
		elements.scoreboard.Visible = visible
	end
end

function Hud.start()
	gui = make("ScreenGui", {
		Name = "FPSHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, player:WaitForChild("PlayerGui"))

	buildHealth()
	buildAmmo()
	buildKillfeed()
	buildRoundInfo()
	buildScoreboard()
	buildCrosshair()
	buildHitmarker()

	-- Tab = tableau des scores
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == Enum.KeyCode.Tab then
			Hud.setScoreboardVisible(true)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.Tab then
			Hud.setScoreboardVisible(false)
		end
	end)
end

return Hud
