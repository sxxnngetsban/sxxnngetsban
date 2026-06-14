--!nonstrict
-- MonetizationService
-- Gère gamepasses (perks permanents) et produits consommables (crédits, boosts).
-- Autorité serveur : c'est ici qu'on accorde les avantages, jamais le client.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local MonetizationConfig = require(Shared.MonetizationConfig)

local MonetizationService = {}
local services

-- Cache des gamepasses possédés : player -> { [name] = true }
local ownedCache = {}

-- Vérifie (et met en cache) la possession d'un gamepass
local function checkGamepass(player: Player, name: string): boolean
	local pass = MonetizationConfig.Gamepasses[name]
	if not pass or pass.id == 0 then
		return false
	end
	local ok, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, pass.id)
	end)
	return ok and owns == true
end

local function refreshOwnership(player: Player)
	ownedCache[player] = {}
	for name in MonetizationConfig.Gamepasses do
		ownedCache[player][name] = checkGamepass(player, name)
	end
end

function MonetizationService.hasGamepass(player: Player, name: string): boolean
	return ownedCache[player] and ownedCache[player][name] == true
end

-- Multiplicateur d'XP total du joueur (gamepasses + boost temporaire actif)
function MonetizationService.getXpMultiplier(player: Player): number
	local owned = ownedCache[player] or {}
	local activeBoost = 1.0
	local data = services.Data.get(player)
	if data and data.boostExpiry and os.time() < data.boostExpiry then
		activeBoost = data.boostMultiplier or 1.0
	end
	return MonetizationConfig.getXpMultiplier(owned, activeBoost)
end

-- Bonus VIP quotidien (crédits)
local function grantVipDaily(player: Player)
	if not MonetizationService.hasGamepass(player, "VIP") then
		return
	end
	local data = services.Data.get(player)
	if not data then
		return
	end
	local today = math.floor(os.time() / 86400)
	if data.lastVipDay ~= today then
		data.lastVipDay = today
		data.coins += MonetizationConfig.Gamepasses.VIP.dailyCoins
		if services.Loadout then
			services.Loadout.sync(player)
		end
	end
end

-- Traitement des achats de produits consommables (crédits, boosts)
local function processReceipt(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if not player then
		-- Joueur parti : on demande à réessayer plus tard
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local data = services.Data.get(player)
	if not data then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Trouve le produit correspondant
	for _, product in MonetizationConfig.Products do
		if product.id == info.ProductId and product.id ~= 0 then
			if product.coins then
				data.coins += product.coins
			end
			if product.boost then
				data.boostMultiplier = product.boost
				data.boostExpiry = os.time() + (product.duration or 3600)
			end
			-- Sauvegarde immédiate (achat = critique)
			local ok = pcall(function()
				services.Data.save(player)
			end)
			if services.Loadout then
				services.Loadout.sync(player)
			end
			return ok and Enum.ProductPurchaseDecision.PurchaseGranted
				or Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted -- produit inconnu : on n'insiste pas
end

function MonetizationService.init(svc)
	services = svc

	Players.PlayerAdded:Connect(function(player)
		refreshOwnership(player)
		task.wait(1)
		grantVipDaily(player)
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		refreshOwnership(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		ownedCache[player] = nil
	end)

	-- Recharge la possession si un gamepass est acheté en jeu
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
		if wasPurchased then
			refreshOwnership(player)
			grantVipDaily(player)
		end
	end)

	MarketplaceService.ProcessReceipt = processReceipt
end

return MonetizationService
