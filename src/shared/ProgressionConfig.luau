--!nonstrict
-- ProgressionConfig
-- Réglages de la progression : XP, niveaux, récompenses, monnaie.

local ProgressionConfig = {}

-- Récompenses (XP et monnaie « Crédits »)
ProgressionConfig.Rewards = {
	Kill = { xp = 100, coins = 25 },
	Headshot = { xp = 50, coins = 15 }, -- bonus en plus du kill
	Assist = { xp = 40, coins = 10 },
	Win = { xp = 500, coins = 150 },
	Loss = { xp = 200, coins = 50 },
	DailyLogin = { xp = 0, coins = 250 }, -- ⚠️ utilisé en Phase 4
}

-- Courbe de niveau : XP nécessaire pour passer du niveau L au niveau L+1.
-- Progressive : plus on monte, plus il faut d'XP (boucle de rétention).
function ProgressionConfig.xpForLevel(level: number): number
	return math.floor(500 + (level - 1) * 350)
end

-- Calcule le niveau et l'XP restante à partir d'un total d'XP cumulée.
function ProgressionConfig.levelFromTotalXp(totalXp: number): (number, number, number)
	local level = 1
	local remaining = totalXp
	while remaining >= ProgressionConfig.xpForLevel(level) do
		remaining -= ProgressionConfig.xpForLevel(level)
		level += 1
	end
	return level, remaining, ProgressionConfig.xpForLevel(level)
end

ProgressionConfig.MaxLevel = 100

return ProgressionConfig
