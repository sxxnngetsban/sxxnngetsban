--!nonstrict
-- MenuController
-- Menu principal en jeu : Loadout (choix d'armes), Boutique (gamepasses + crédits),
-- Stats, Paramètres. Ouvre/ferme avec la touche M ou le bouton MENU.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local WeaponConfig = require(Shared.WeaponConfig)
local MonetizationConfig = require(Shared.MonetizationConfig)
local Net = require(Shared.Net)

local SettingsController = require(script.Parent.SettingsController)

local MenuController = {}
local player = Players.LocalPlayer

local profile = nil -- dernier DataSync reçu
local gui, panel, content, coinsLabel
local currentTab = "Loadout"
local isOpen = false

-- ───────────────────────────── Helpers UI ─────────────────────────────

local function make(class, props, parent)
	local i = Instance.new(class)
	for k, v in props do
		i[k] = v
	end
	if parent then
		i.Parent = parent
	end
	return i
end

local function button(text, parent, height)
	local b = make("TextButton", {
		Size = UDim2.new(1, 0, 0, height or 36),
		BackgroundColor3 = Color3.fromRGB(45, 45, 55),
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = text,
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
		AutoButtonColor = true,
	}, parent)
	make("UICorner", { CornerRadius = UDim.new(0, 5) }, b)
	return b
end

-- ───────────────────────────── Onglets ─────────────────────────────

local function clearContent()
	for _, c in content:GetChildren() do
		if not c:IsA("UIListLayout") then
			c:Destroy()
		end
	end
end

local function buildLoadout()
	clearContent()
	if not profile then
		return
	end
	local function slotSection(slot, title)
		make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			Font = Enum.Font.GothamBold,
			Text = title,
			TextColor3 = Color3.fromRGB(255, 210, 120),
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, content)
		-- Liste triée
		local ids = {}
		for id, w in WeaponConfig.Weapons do
			if w.Slot == slot then
				table.insert(ids, id)
			end
		end
		table.sort(ids)
		for _, id in ipairs(ids) do
			local w = WeaponConfig.get(id)
			local unlocked = (w.UnlockLevel and w.UnlockLevel <= 0) or (profile.unlocks and profile.unlocks[id])
			local equipped = profile.loadout and profile.loadout[slot] == id
			local label = string.format("%s  (%s)", w.DisplayName, w.Category)
			local b = button(label, content, 34)
			if equipped then
				b.BackgroundColor3 = Color3.fromRGB(60, 130, 70)
				b.Text = label .. "   ✔ Équipée"
			elseif unlocked then
				b.Text = label .. "   — Équiper"
				b.Activated:Connect(function()
					Net.get("SetLoadout"):FireServer({ [slot] = id })
				end)
			else
				b.BackgroundColor3 = Color3.fromRGB(60, 45, 45)
				b.Text = label .. string.format("   🔒 %d crédits (niv. %d)", w.Price or 0, w.UnlockLevel or 0)
				b.Activated:Connect(function()
					Net.get("BuyItem"):FireServer({ weaponId = id })
				end)
			end
		end
		make("Frame", { Size = UDim2.new(1, 0, 0, 8), BackgroundTransparency = 1 }, content)
	end
	slotSection("Primary", "ARME PRINCIPALE")
	slotSection("Secondary", "ARME SECONDAIRE")
end

local function buildShop()
	clearContent()
	make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "PASSES (avantages permanents)",
		TextColor3 = Color3.fromRGB(255, 210, 120),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, content)
	for name, pass in MonetizationConfig.Gamepasses do
		local owned = profile and profile.gamepasses and profile.gamepasses[name]
		local b = button(pass.name .. " — " .. pass.desc, content, 44)
		if owned then
			b.BackgroundColor3 = Color3.fromRGB(60, 130, 70)
			b.Text = pass.name .. "   ✔ Possédé"
		elseif pass.id ~= 0 then
			b.Activated:Connect(function()
				MarketplaceService:PromptGamePassPurchase(player, pass.id)
			end)
		else
			b.Text = pass.name .. "   ⚠️ ID à configurer"
		end
	end

	make("Frame", { Size = UDim2.new(1, 0, 0, 10), BackgroundTransparency = 1 }, content)
	make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "CRÉDITS & BOOSTS",
		TextColor3 = Color3.fromRGB(255, 210, 120),
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, content)
	for _, prod in MonetizationConfig.Products do
		local b = button(prod.name, content, 38)
		if prod.id ~= 0 then
			b.Activated:Connect(function()
				MarketplaceService:PromptProductPurchase(player, prod.id)
			end)
		else
			b.Text = prod.name .. "   ⚠️ ID à configurer"
		end
	end
end

local function buildStats()
	clearContent()
	if not profile then
		return
	end
	local s = profile.stats or {}
	local kd = (s.deaths or 0) > 0 and string.format("%.2f", (s.kills or 0) / s.deaths) or tostring(s.kills or 0)
	local lines = {
		"Niveau : " .. (profile.level or 1),
		"Crédits : " .. (profile.coins or 0),
		"Éliminations : " .. (s.kills or 0),
		"Morts : " .. (s.deaths or 0),
		"Ratio K/D : " .. kd,
		"Victoires : " .. (s.wins or 0),
		"Défaites : " .. (s.losses or 0),
		"Meilleure série : " .. (s.bestStreak or 0),
	}
	for _, line in ipairs(lines) do
		make("TextLabel", {
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = Color3.fromRGB(40, 40, 50),
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Text = "  " .. line,
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, content)
	end
end

local function settingRow(label, getValue, step, minV, maxV, apply)
	local row = make("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Color3.fromRGB(40, 40, 50),
		BorderSizePixel = 0,
	}, content)
	make("UICorner", { CornerRadius = UDim.new(0, 5) }, row)
	local valueLabel = make("TextLabel", {
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.fromOffset(10, 0),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)
	local function refresh()
		valueLabel.Text = string.format("%s : %.2f", label, getValue())
	end
	local minus = make("TextButton", {
		Size = UDim2.fromOffset(44, 30),
		Position = UDim2.new(1, -100, 0.5, -15),
		BackgroundColor3 = Color3.fromRGB(70, 70, 85),
		Text = "–", TextColor3 = Color3.new(1, 1, 1), TextSize = 22, Font = Enum.Font.GothamBold,
	}, row)
	make("UICorner", { CornerRadius = UDim.new(0, 4) }, minus)
	local plus = make("TextButton", {
		Size = UDim2.fromOffset(44, 30),
		Position = UDim2.new(1, -50, 0.5, -15),
		BackgroundColor3 = Color3.fromRGB(70, 70, 85),
		Text = "+", TextColor3 = Color3.new(1, 1, 1), TextSize = 22, Font = Enum.Font.GothamBold,
	}, row)
	make("UICorner", { CornerRadius = UDim.new(0, 4) }, plus)
	minus.Activated:Connect(function()
		apply(math.clamp(getValue() - step, minV, maxV))
		refresh()
	end)
	plus.Activated:Connect(function()
		apply(math.clamp(getValue() + step, minV, maxV))
		refresh()
	end)
	refresh()
end

local function buildSettings()
	clearContent()
	local s = SettingsController.current
	settingRow("Sensibilité", function() return s.sensitivity end, 0.05, 0.1, 2.0, function(v)
		SettingsController.set({ sensitivity = v })
	end)
	settingRow("FOV (+/-)", function() return s.fov end, 5, -10, 30, function(v)
		SettingsController.set({ fov = v })
	end)
	settingRow("Volume", function() return s.volume end, 0.1, 0, 1, function(v)
		SettingsController.set({ volume = v })
	end)
end

local TABS = {
	{ id = "Loadout", label = "🎒 Loadout", build = buildLoadout },
	{ id = "Shop", label = "🛒 Boutique", build = buildShop },
	{ id = "Stats", label = "📊 Stats", build = buildStats },
	{ id = "Settings", label = "⚙️ Paramètres", build = buildSettings },
}

local function showTab(id)
	currentTab = id
	for _, tab in TABS do
		if tab.id == id then
			tab.build()
		end
	end
end

-- ───────────────────────────── Ouverture / fermeture ─────────────────────────────

function MenuController.setOpen(open)
	isOpen = open
	panel.Visible = open
	if open then
		player.CameraMode = Enum.CameraMode.Classic -- libère la souris pour cliquer
		showTab(currentTab)
	else
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end

local function refreshCoins()
	if coinsLabel and profile then
		coinsLabel.Text = "💰 " .. (profile.coins or 0) .. "   |   Niv. " .. (profile.level or 1)
	end
end

-- ───────────────────────────── Construction ─────────────────────────────

function MenuController.start()
	gui = make("ScreenGui", {
		Name = "FPSMenu",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, player:WaitForChild("PlayerGui"))

	-- Bouton MENU (toujours visible)
	local openBtn = make("TextButton", {
		Name = "Open",
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromOffset(12, 12),
		Size = UDim2.fromOffset(90, 34),
		BackgroundColor3 = Color3.fromRGB(30, 30, 40),
		BackgroundTransparency = 0.2,
		Font = Enum.Font.GothamBold,
		Text = "☰ MENU",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 15,
	}, gui)
	make("UICorner", { CornerRadius = UDim.new(0, 5) }, openBtn)
	openBtn.Activated:Connect(function()
		MenuController.setOpen(not isOpen)
	end)

	-- Panneau principal
	panel = make("Frame", {
		Name = "Panel",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(640, 460),
		BackgroundColor3 = Color3.fromRGB(22, 22, 28),
		BorderSizePixel = 0,
		Visible = false,
	}, gui)
	make("UICorner", { CornerRadius = UDim.new(0, 10) }, panel)

	-- Entête (crédits + fermer)
	coinsLabel = make("TextLabel", {
		Position = UDim2.fromOffset(16, 10),
		Size = UDim2.fromOffset(300, 26),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "💰 0",
		TextColor3 = Color3.fromRGB(255, 220, 130),
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, panel)
	local closeBtn = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 10),
		Size = UDim2.fromOffset(80, 28),
		BackgroundColor3 = Color3.fromRGB(180, 60, 60),
		Font = Enum.Font.GothamBold,
		Text = "✕ JOUER",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 14,
	}, panel)
	make("UICorner", { CornerRadius = UDim.new(0, 5) }, closeBtn)
	closeBtn.Activated:Connect(function()
		MenuController.setOpen(false)
	end)

	-- Barre d'onglets (gauche)
	local tabBar = make("Frame", {
		Position = UDim2.fromOffset(12, 48),
		Size = UDim2.fromOffset(150, 400),
		BackgroundTransparency = 1,
	}, panel)
	make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tabBar)
	for _, tab in TABS do
		local b = button(tab.label, tabBar, 40)
		b.Activated:Connect(function()
			showTab(tab.id)
		end)
	end

	-- Zone de contenu (droite, scrollable)
	local scroll = make("ScrollingFrame", {
		Position = UDim2.fromOffset(174, 48),
		Size = UDim2.fromOffset(452, 400),
		BackgroundColor3 = Color3.fromRGB(28, 28, 36),
		BorderSizePixel = 0,
		ScrollBarThickness = 6,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, panel)
	make("UICorner", { CornerRadius = UDim.new(0, 8) }, scroll)
	make("UIPadding", {
		PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
	}, scroll)
	make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
	content = scroll

	-- Touche M pour ouvrir/fermer
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == Enum.KeyCode.M then
			MenuController.setOpen(not isOpen)
		end
	end)

	-- Réception du profil
	local appliedSettings = false
	Net.get("DataSync").OnClientEvent:Connect(function(data)
		profile = data
		refreshCoins()
		-- Applique les réglages sauvegardés une seule fois (au chargement)
		if not appliedSettings and data.settings and next(data.settings) then
			appliedSettings = true
			SettingsController.apply(data.settings)
		end
		if isOpen then
			showTab(currentTab)
		end
	end)

	-- Messages courts (toast) du serveur
	Net.get("Notify").OnClientEvent:Connect(function(text)
		local toast = make("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 60),
			Size = UDim2.fromOffset(360, 36),
			BackgroundColor3 = Color3.fromRGB(30, 30, 40),
			BackgroundTransparency = 0.1,
			Font = Enum.Font.GothamBold,
			Text = tostring(text),
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 15,
		}, gui)
		make("UICorner", { CornerRadius = UDim.new(0, 6) }, toast)
		task.delay(3, function()
			toast:Destroy()
		end)
	end)
end

return MenuController
