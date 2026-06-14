--!nonstrict
-- GameConfig
-- Réglages globaux du jeu. Modifie ces valeurs pour adapter ton FPS.

local GameConfig = {}

-- Mode de jeu actif : "TDM" (Team Deathmatch) ou "FFA" (Free-For-All)
GameConfig.Mode = "TDM"

-- Vie
GameConfig.MaxHealth = 100
GameConfig.RespawnTime = 4 -- secondes avant réapparition

-- Conditions de victoire
GameConfig.ScoreToWin = 40 -- éliminations pour gagner (par équipe en TDM, par joueur en FFA)
GameConfig.RoundTime = 600 -- durée max d'une manche en secondes

-- Tir ami
GameConfig.FriendlyFire = false

-- Équipes (utilisées seulement en mode "TDM")
GameConfig.Teams = {
	{ Name = "Attaquants", Color = Color3.fromRGB(225, 70, 70) },
	{ Name = "Défenseurs", Color = Color3.fromRGB(70, 120, 225) },
}

-- Anti-triche : tolérance serveur
GameConfig.Security = {
	-- Marge ajoutée à la portée de l'arme avant de rejeter un tir (studs)
	MaxRangeTolerance = 20,
	-- Distance max autorisée entre la position de hit annoncée par le client
	-- et la position réelle de la cible côté serveur (studs)
	MaxHitDeviation = 12,
	-- Tolérance sur la cadence de tir (multiplicateur ; 0.85 = 15% de marge)
	FireRateTolerance = 0.85,
}

return GameConfig
