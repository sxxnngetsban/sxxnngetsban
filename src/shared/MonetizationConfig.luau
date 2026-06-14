--!nonstrict
-- MonetizationConfig
-- Configuration de la monétisation (éthique, cosmétique + confort, jamais pay-to-win abusif).
--
-- ⚠️ ID À CONFIGURER : crée tes gamepasses et produits sur le tableau de bord Roblox
--    (create.roblox.com → ton expérience → Monétisation), puis colle leurs IDs ici.
--    Tant qu'un ID vaut 0, l'article est affiché mais l'achat ne se déclenchera pas.

local MonetizationConfig = {}

-- Gamepasses (achat unique, permanent)
MonetizationConfig.Gamepasses = {
	VIP = {
		id = 0, -- ⚠️ ID À CONFIGURER
		name = "VIP",
		desc = "+25% XP, badge exclusif, bonus de crédits quotidien",
		xpMultiplier = 1.25,
		dailyCoins = 500,
	},
	DoubleXP = {
		id = 0, -- ⚠️ ID À CONFIGURER
		name = "Double XP",
		desc = "XP doublée en permanence",
		xpMultiplier = 2.0,
	},
	Radar = {
		id = 0, -- ⚠️ ID À CONFIGURER
		name = "Radar",
		desc = "Indicateur léger des ennemis proches (à doser)",
	},
}

-- Produits consommables (Developer Products, achetables plusieurs fois)
MonetizationConfig.Products = {
	Coins1000 = { id = 0, name = "1 000 crédits", coins = 1000 }, -- ⚠️ ID À CONFIGURER
	Coins5000 = { id = 0, name = "5 500 crédits", coins = 5500 }, -- ⚠️ ID À CONFIGURER
	Coins15000 = { id = 0, name = "17 000 crédits", coins = 17000 }, -- ⚠️ ID À CONFIGURER
	XPBoost1h = { id = 0, name = "Boost XP 1h", boost = 2.0, duration = 3600 }, -- ⚠️ ID À CONFIGURER
}

-- Renvoie le multiplicateur d'XP total d'un joueur selon ses gamepasses possédés.
-- ownedGamepasses : { [name] = true }
function MonetizationConfig.getXpMultiplier(ownedGamepasses, activeBoost: number?): number
	local mult = 1.0
	for name, pass in MonetizationConfig.Gamepasses do
		if ownedGamepasses[name] and pass.xpMultiplier then
			mult *= pass.xpMultiplier
		end
	end
	if activeBoost and activeBoost > 1 then
		mult *= activeBoost
	end
	return mult
end

return MonetizationConfig
