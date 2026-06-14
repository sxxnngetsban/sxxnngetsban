--!nonstrict
-- WeaponConfig
-- Toutes les statistiques des armes. Ajoute/édite des armes ici.
--
-- Champs importants :
--   Slot                : "Primary" / "Secondary" / "Melee"
--   FireMode            : "Auto" (maintenu) / "Semi" (clic par clic) / "Burst"
--   Damage              : dégâts de base au corps
--   HeadshotMultiplier  : multiplicateur sur la tête
--   Falloff             : { {distanceStuds, multiplicateurDégâts}, ... } interpolé
--   RPM                 : cadence (rounds per minute)
--   MagSize / ReserveAmmo / ReloadTime
--   Range               : portée max du raycast (studs)
--   Recoil*             : intensité du recul vertical/horizontal + récupération
--   Spread*             : dispersion en degrés (hanche, déplacement, par tir, max, récup)
--   AdsSpreadMultiplier : réduction de dispersion en visée
--   AdsFov / HipFov     : champ de vision visée / hanche
--   BulletsPerShot      : >1 pour fusils à pompe
--   FireSoundId         : "rbxassetid://..." du son de tir (vide = pas de son)
--
-- 🔊 POUR AJOUTER UN SON : ouvre la Boîte à outils dans Studio → onglet "Audio" →
--    cherche "gun shot" → clique sur un son gratuit → copie son ID (clic droit > Copier l'ID)
--    et colle-le dans FireSoundId ci-dessous (format "rbxassetid://CHIFFRES").

local WeaponConfig = {}

WeaponConfig.DefaultLoadout = {
	Primary = "AssaultRifle",
	Secondary = "Pistol",
}

WeaponConfig.Weapons = {
	AssaultRifle = {
		DisplayName = "AK-77",
		Slot = "Primary",
		FireMode = "Auto",
		Damage = 26,
		HeadshotMultiplier = 2.0,
		Falloff = { { 70, 1.0 }, { 150, 0.7 }, { 280, 0.5 } },
		RPM = 600,
		MagSize = 30,
		ReserveAmmo = 120,
		ReloadTime = 2.2,
		Range = 1200,
		BulletsPerShot = 1,
		FireSoundId = "",
		-- recul (réduit pour être contrôlable)
		RecoilVertical = 0.5,
		RecoilHorizontal = 0.16,
		RecoilRecovery = 15,
		-- dispersion (resserrée)
		SpreadBase = 0.25,
		SpreadMoving = 1.4,
		SpreadPerShot = 0.16,
		SpreadMax = 2.4,
		SpreadRecovery = 9,
		AdsSpreadMultiplier = 0.1,
		AdsFov = 55,
		HipFov = 70,
		AdsSpeed = 12,
		EquipTime = 0.4,
	},

	SMG = {
		DisplayName = "MP-9",
		Slot = "Primary",
		FireMode = "Auto",
		Damage = 18,
		HeadshotMultiplier = 1.7,
		Falloff = { { 40, 1.0 }, { 95, 0.65 }, { 160, 0.45 } },
		RPM = 850,
		MagSize = 25,
		ReserveAmmo = 150,
		ReloadTime = 1.9,
		Range = 600,
		BulletsPerShot = 1,
		FireSoundId = "",
		RecoilVertical = 0.36,
		RecoilHorizontal = 0.2,
		RecoilRecovery = 17,
		SpreadBase = 0.5,
		SpreadMoving = 1.5,
		SpreadPerShot = 0.15,
		SpreadMax = 2.8,
		SpreadRecovery = 11,
		AdsSpreadMultiplier = 0.2,
		AdsFov = 60,
		HipFov = 72,
		AdsSpeed = 16,
		EquipTime = 0.3,
	},

	Sniper = {
		DisplayName = "Intervention",
		Slot = "Primary",
		FireMode = "Semi",
		Damage = 95,
		HeadshotMultiplier = 2.2, -- one-shot tête
		Falloff = { { 1000, 1.0 } }, -- pas de chute, fusil de précision
		RPM = 50,
		MagSize = 5,
		ReserveAmmo = 25,
		ReloadTime = 3.0,
		Range = 3000,
		BulletsPerShot = 1,
		FireSoundId = "",
		RecoilVertical = 1.8,
		RecoilHorizontal = 0.28,
		RecoilRecovery = 8,
		SpreadBase = 0.0, -- précis à l'arrêt en visée
		SpreadMoving = 4.5, -- imprécis en mouvement
		SpreadPerShot = 0.0,
		SpreadMax = 5.0,
		SpreadRecovery = 5,
		AdsSpreadMultiplier = 0.02,
		AdsFov = 25, -- zoom lunette
		HipFov = 70,
		AdsSpeed = 9,
		EquipTime = 0.55,
	},

	Shotgun = {
		DisplayName = "Brèche-12",
		Slot = "Primary",
		FireMode = "Semi",
		Damage = 11, -- par plomb
		HeadshotMultiplier = 1.5,
		Falloff = { { 22, 1.0 }, { 45, 0.55 }, { 70, 0.2 } },
		RPM = 95,
		MagSize = 6,
		ReserveAmmo = 36,
		ReloadTime = 2.8,
		Range = 120,
		BulletsPerShot = 9, -- 9 plombs
		FireSoundId = "",
		RecoilVertical = 1.5,
		RecoilHorizontal = 0.4,
		RecoilRecovery = 9,
		SpreadBase = 2.8,
		SpreadMoving = 4.0,
		SpreadPerShot = 0.0,
		SpreadMax = 5.0,
		SpreadRecovery = 6,
		AdsSpreadMultiplier = 0.6,
		AdsFov = 62,
		HipFov = 72,
		AdsSpeed = 12,
		EquipTime = 0.4,
	},

	Pistol = {
		DisplayName = "G-18",
		Slot = "Secondary",
		FireMode = "Semi",
		Damage = 22,
		HeadshotMultiplier = 1.9,
		Falloff = { { 45, 1.0 }, { 95, 0.65 }, { 160, 0.5 } },
		RPM = 400,
		MagSize = 17,
		ReserveAmmo = 68,
		ReloadTime = 1.5,
		Range = 500,
		BulletsPerShot = 1,
		FireSoundId = "",
		RecoilVertical = 0.45,
		RecoilHorizontal = 0.14,
		RecoilRecovery = 19,
		SpreadBase = 0.35,
		SpreadMoving = 1.4,
		SpreadPerShot = 0.22,
		SpreadMax = 2.2,
		SpreadRecovery = 11,
		AdsSpreadMultiplier = 0.25,
		AdsFov = 62,
		HipFov = 72,
		AdsSpeed = 18,
		EquipTime = 0.25,
	},
}

-- Renvoie la config d'une arme ou nil
function WeaponConfig.get(weaponId: string)
	return WeaponConfig.Weapons[weaponId]
end

-- Calcule le multiplicateur de dégâts selon la distance (interpolation linéaire)
function WeaponConfig.getFalloffMultiplier(weapon, distance: number): number
	local falloff = weapon.Falloff
	if not falloff or #falloff == 0 then
		return 1.0
	end

	-- Avant le premier point
	if distance <= falloff[1][1] then
		return falloff[1][2]
	end
	-- Après le dernier point
	local last = falloff[#falloff]
	if distance >= last[1] then
		return last[2]
	end
	-- Interpolation entre deux points
	for i = 1, #falloff - 1 do
		local a, b = falloff[i], falloff[i + 1]
		if distance >= a[1] and distance <= b[1] then
			local alpha = (distance - a[1]) / (b[1] - a[1])
			return a[2] + (b[2] - a[2]) * alpha
		end
	end
	return last[2]
end

return WeaponConfig
