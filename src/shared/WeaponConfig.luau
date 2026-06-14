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
		Damage = 28,
		HeadshotMultiplier = 2.0,
		Falloff = { { 60, 1.0 }, { 140, 0.65 }, { 280, 0.45 } },
		RPM = 600,
		MagSize = 30,
		ReserveAmmo = 120,
		ReloadTime = 2.4,
		Range = 1200,
		BulletsPerShot = 1,
		RecoilVertical = 1.05,
		RecoilHorizontal = 0.35,
		RecoilRecovery = 11,
		SpreadBase = 0.5,
		SpreadMoving = 2.2,
		SpreadPerShot = 0.32,
		SpreadMax = 4.0,
		SpreadRecovery = 6,
		AdsSpreadMultiplier = 0.12,
		AdsFov = 55,
		HipFov = 70,
		AdsSpeed = 12,
		EquipTime = 0.45,
	},

	SMG = {
		DisplayName = "MP-9",
		Slot = "Primary",
		FireMode = "Auto",
		Damage = 20,
		HeadshotMultiplier = 1.7,
		Falloff = { { 35, 1.0 }, { 90, 0.6 }, { 160, 0.4 } },
		RPM = 850,
		MagSize = 25,
		ReserveAmmo = 150,
		ReloadTime = 2.0,
		Range = 600,
		BulletsPerShot = 1,
		RecoilVertical = 0.7,
		RecoilHorizontal = 0.45,
		RecoilRecovery = 14,
		SpreadBase = 0.9,
		SpreadMoving = 2.0,
		SpreadPerShot = 0.28,
		SpreadMax = 4.5,
		SpreadRecovery = 8,
		AdsSpreadMultiplier = 0.25,
		AdsFov = 60,
		HipFov = 72,
		AdsSpeed = 16,
		EquipTime = 0.35,
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
		ReloadTime = 3.2,
		Range = 3000,
		BulletsPerShot = 1,
		RecoilVertical = 3.5,
		RecoilHorizontal = 0.6,
		RecoilRecovery = 6,
		SpreadBase = 0.0, -- précis à l'arrêt en visée
		SpreadMoving = 6.0, -- très imprécis en mouvement
		SpreadPerShot = 0.0,
		SpreadMax = 6.0,
		SpreadRecovery = 4,
		AdsSpreadMultiplier = 0.02,
		AdsFov = 25, -- zoom lunette
		HipFov = 70,
		AdsSpeed = 9,
		EquipTime = 0.6,
	},

	Shotgun = {
		DisplayName = "Brèche-12",
		Slot = "Primary",
		FireMode = "Semi",
		Damage = 12, -- par plomb
		HeadshotMultiplier = 1.5,
		Falloff = { { 20, 1.0 }, { 45, 0.5 }, { 70, 0.15 } },
		RPM = 90,
		MagSize = 6,
		ReserveAmmo = 36,
		ReloadTime = 3.0,
		Range = 120,
		BulletsPerShot = 9, -- 9 plombs
		RecoilVertical = 2.6,
		RecoilHorizontal = 0.7,
		RecoilRecovery = 7,
		SpreadBase = 3.5,
		SpreadMoving = 5.0,
		SpreadPerShot = 0.0,
		SpreadMax = 6.0,
		SpreadRecovery = 5,
		AdsSpreadMultiplier = 0.6,
		AdsFov = 62,
		HipFov = 72,
		AdsSpeed = 12,
		EquipTime = 0.45,
	},

	Pistol = {
		DisplayName = "G-18",
		Slot = "Secondary",
		FireMode = "Semi",
		Damage = 24,
		HeadshotMultiplier = 1.9,
		Falloff = { { 40, 1.0 }, { 90, 0.6 }, { 160, 0.45 } },
		RPM = 400,
		MagSize = 17,
		ReserveAmmo = 68,
		ReloadTime = 1.6,
		Range = 500,
		BulletsPerShot = 1,
		RecoilVertical = 0.9,
		RecoilHorizontal = 0.3,
		RecoilRecovery = 16,
		SpreadBase = 0.7,
		SpreadMoving = 1.8,
		SpreadPerShot = 0.4,
		SpreadMax = 3.5,
		SpreadRecovery = 9,
		AdsSpreadMultiplier = 0.3,
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
