--!nonstrict
-- WeaponConfig
-- Données de TOUTES les armes (data-driven). Ajoute/édite une arme = ajoute/édite une entrée.
--
-- Champs :
--   Category            : "AR" / "SMG" / "Sniper" / "Shotgun" / "LMG" / "Pistol"
--   UnlockLevel         : niveau requis pour débloquer (0 = dispo dès le départ)
--   Price               : coût en monnaie in-game (0 = gratuit / débloqué par niveau)
--   FireMode            : "Auto" (maintenu) / "Semi" (clic par clic)
--   Damage / HeadshotMultiplier / Falloff (chute de dégâts par distance)
--   RPM / MagSize / ReserveAmmo / ReloadTime / Range / BulletsPerShot
--   Recoil* / Spread*   : recul et dispersion (degrés)
--   AdsFov / HipFov / AdsSpeed / AdsSpreadMultiplier
--   FireSoundId         : "rbxassetid://..." (vide = pas de son) — ⚠️ ASSET À AJOUTER
--   ModelName           : nom du modèle d'arme dans ReplicatedStorage.Assets.ViewModels
--                         — ⚠️ ASSET À AJOUTER (laisse vide tant que tu n'as pas de modèle)

local WeaponConfig = {}

WeaponConfig.DefaultLoadout = {
	Primary = "AK77",
	Secondary = "G18",
}

-- Catégories (pour l'UI / le filtrage)
WeaponConfig.Categories = { "AR", "SMG", "Sniper", "Shotgun", "LMG", "Pistol" }

WeaponConfig.Weapons = {
	-- ───────────── FUSILS D'ASSAUT (AR) ─────────────
	AK77 = {
		DisplayName = "AK-77", Category = "AR", Slot = "Primary",
		UnlockLevel = 0, Price = 0, FireMode = "Auto",
		Damage = 26, HeadshotMultiplier = 2.0,
		Falloff = { { 70, 1.0 }, { 150, 0.7 }, { 280, 0.5 } },
		RPM = 600, MagSize = 30, ReserveAmmo = 120, ReloadTime = 2.2, Range = 1200, BulletsPerShot = 1,
		RecoilVertical = 0.22, RecoilHorizontal = 0.07, RecoilRecovery = 22,
		SpreadBase = 0.25, SpreadMoving = 1.4, SpreadPerShot = 0.16, SpreadMax = 2.4, SpreadRecovery = 9,
		AdsSpreadMultiplier = 0.1, AdsFov = 55, HipFov = 70, AdsSpeed = 12, EquipTime = 0.4,
		FireSoundId = "", ModelName = "",
	},
	M4X = {
		DisplayName = "M4-X", Category = "AR", Slot = "Primary",
		UnlockLevel = 3, Price = 1500, FireMode = "Auto",
		Damage = 24, HeadshotMultiplier = 2.0,
		Falloff = { { 80, 1.0 }, { 170, 0.72 }, { 300, 0.5 } },
		RPM = 700, MagSize = 30, ReserveAmmo = 120, ReloadTime = 2.1, Range = 1200, BulletsPerShot = 1,
		RecoilVertical = 0.18, RecoilHorizontal = 0.06, RecoilRecovery = 24,
		SpreadBase = 0.22, SpreadMoving = 1.3, SpreadPerShot = 0.14, SpreadMax = 2.2, SpreadRecovery = 10,
		AdsSpreadMultiplier = 0.1, AdsFov = 55, HipFov = 70, AdsSpeed = 13, EquipTime = 0.4,
		FireSoundId = "", ModelName = "",
	},
	FAMASG = {
		DisplayName = "FAMAS-G", Category = "AR", Slot = "Primary",
		UnlockLevel = 8, Price = 4000, FireMode = "Semi", -- ⚠️ burst non implémenté : Semi pour l'instant
		Damage = 30, HeadshotMultiplier = 2.0,
		Falloff = { { 90, 1.0 }, { 180, 0.7 }, { 300, 0.5 } },
		RPM = 900, MagSize = 25, ReserveAmmo = 100, ReloadTime = 2.3, Range = 1200, BulletsPerShot = 1,
		RecoilVertical = 0.3, RecoilHorizontal = 0.08, RecoilRecovery = 20,
		SpreadBase = 0.2, SpreadMoving = 1.4, SpreadPerShot = 0.12, SpreadMax = 2.0, SpreadRecovery = 11,
		AdsSpreadMultiplier = 0.08, AdsFov = 55, HipFov = 70, AdsSpeed = 13, EquipTime = 0.4,
		FireSoundId = "", ModelName = "",
	},

	-- ───────────── MITRAILLETTES (SMG) ─────────────
	MP9 = {
		DisplayName = "MP-9", Category = "SMG", Slot = "Primary",
		UnlockLevel = 0, Price = 0, FireMode = "Auto",
		Damage = 18, HeadshotMultiplier = 1.7,
		Falloff = { { 40, 1.0 }, { 95, 0.65 }, { 160, 0.45 } },
		RPM = 850, MagSize = 25, ReserveAmmo = 150, ReloadTime = 1.9, Range = 600, BulletsPerShot = 1,
		RecoilVertical = 0.16, RecoilHorizontal = 0.09, RecoilRecovery = 25,
		SpreadBase = 0.5, SpreadMoving = 1.5, SpreadPerShot = 0.15, SpreadMax = 2.8, SpreadRecovery = 12,
		AdsSpreadMultiplier = 0.2, AdsFov = 60, HipFov = 72, AdsSpeed = 16, EquipTime = 0.3,
		FireSoundId = "", ModelName = "",
	},
	VectorK = {
		DisplayName = "Vector-K", Category = "SMG", Slot = "Primary",
		UnlockLevel = 5, Price = 2500, FireMode = "Auto",
		Damage = 15, HeadshotMultiplier = 1.6,
		Falloff = { { 35, 1.0 }, { 85, 0.6 }, { 150, 0.4 } },
		RPM = 1100, MagSize = 25, ReserveAmmo = 175, ReloadTime = 1.8, Range = 550, BulletsPerShot = 1,
		RecoilVertical = 0.13, RecoilHorizontal = 0.08, RecoilRecovery = 27,
		SpreadBase = 0.55, SpreadMoving = 1.5, SpreadPerShot = 0.13, SpreadMax = 3.0, SpreadRecovery = 13,
		AdsSpreadMultiplier = 0.22, AdsFov = 62, HipFov = 72, AdsSpeed = 17, EquipTime = 0.28,
		FireSoundId = "", ModelName = "",
	},
	P90 = {
		DisplayName = "P-90", Category = "SMG", Slot = "Primary",
		UnlockLevel = 11, Price = 5500, FireMode = "Auto",
		Damage = 17, HeadshotMultiplier = 1.6,
		Falloff = { { 45, 1.0 }, { 100, 0.6 }, { 160, 0.42 } },
		RPM = 900, MagSize = 50, ReserveAmmo = 200, ReloadTime = 2.6, Range = 600, BulletsPerShot = 1,
		RecoilVertical = 0.15, RecoilHorizontal = 0.07, RecoilRecovery = 24,
		SpreadBase = 0.5, SpreadMoving = 1.4, SpreadPerShot = 0.12, SpreadMax = 2.8, SpreadRecovery = 12,
		AdsSpreadMultiplier = 0.2, AdsFov = 60, HipFov = 72, AdsSpeed = 16, EquipTime = 0.32,
		FireSoundId = "", ModelName = "",
	},

	-- ───────────── SNIPERS ─────────────
	Intervention = {
		DisplayName = "Intervention", Category = "Sniper", Slot = "Primary",
		UnlockLevel = 6, Price = 3000, FireMode = "Semi",
		Damage = 95, HeadshotMultiplier = 2.2, Falloff = { { 1000, 1.0 } },
		RPM = 50, MagSize = 5, ReserveAmmo = 25, ReloadTime = 3.0, Range = 3000, BulletsPerShot = 1,
		RecoilVertical = 1.8, RecoilHorizontal = 0.28, RecoilRecovery = 8,
		SpreadBase = 0.0, SpreadMoving = 4.5, SpreadPerShot = 0.0, SpreadMax = 5.0, SpreadRecovery = 5,
		AdsSpreadMultiplier = 0.02, AdsFov = 25, HipFov = 70, AdsSpeed = 9, EquipTime = 0.55,
		FireSoundId = "", ModelName = "",
	},
	Barrett50 = {
		DisplayName = "Barrett-50", Category = "Sniper", Slot = "Primary",
		UnlockLevel = 14, Price = 7000, FireMode = "Semi",
		Damage = 110, HeadshotMultiplier = 2.0, Falloff = { { 1000, 1.0 } },
		RPM = 40, MagSize = 7, ReserveAmmo = 28, ReloadTime = 3.4, Range = 3000, BulletsPerShot = 1,
		RecoilVertical = 2.4, RecoilHorizontal = 0.35, RecoilRecovery = 6,
		SpreadBase = 0.0, SpreadMoving = 5.5, SpreadPerShot = 0.0, SpreadMax = 6.0, SpreadRecovery = 4,
		AdsSpreadMultiplier = 0.02, AdsFov = 28, HipFov = 70, AdsSpeed = 8, EquipTime = 0.6,
		FireSoundId = "", ModelName = "",
	},

	-- ───────────── FUSILS À POMPE (Shotgun) ─────────────
	Breche12 = {
		DisplayName = "Brèche-12", Category = "Shotgun", Slot = "Primary",
		UnlockLevel = 4, Price = 2000, FireMode = "Semi",
		Damage = 11, HeadshotMultiplier = 1.5,
		Falloff = { { 22, 1.0 }, { 45, 0.55 }, { 70, 0.2 } },
		RPM = 95, MagSize = 6, ReserveAmmo = 36, ReloadTime = 2.8, Range = 120, BulletsPerShot = 9,
		RecoilVertical = 1.5, RecoilHorizontal = 0.4, RecoilRecovery = 9,
		SpreadBase = 2.8, SpreadMoving = 4.0, SpreadPerShot = 0.0, SpreadMax = 5.0, SpreadRecovery = 6,
		AdsSpreadMultiplier = 0.6, AdsFov = 62, HipFov = 72, AdsSpeed = 12, EquipTime = 0.4,
		FireSoundId = "", ModelName = "",
	},

	-- ───────────── MITRAILLEUSE LOURDE (LMG) ─────────────
	M249S = {
		DisplayName = "M249-S", Category = "LMG", Slot = "Primary",
		UnlockLevel = 12, Price = 6000, FireMode = "Auto",
		Damage = 28, HeadshotMultiplier = 1.8,
		Falloff = { { 90, 1.0 }, { 200, 0.7 }, { 320, 0.5 } },
		RPM = 700, MagSize = 100, ReserveAmmo = 200, ReloadTime = 5.0, Range = 1400, BulletsPerShot = 1,
		RecoilVertical = 0.28, RecoilHorizontal = 0.12, RecoilRecovery = 18,
		SpreadBase = 0.6, SpreadMoving = 2.4, SpreadPerShot = 0.18, SpreadMax = 3.2, SpreadRecovery = 7,
		AdsSpreadMultiplier = 0.18, AdsFov = 58, HipFov = 70, AdsSpeed = 9, EquipTime = 0.6,
		FireSoundId = "", ModelName = "",
	},

	-- ───────────── PISTOLETS (secondaires) ─────────────
	G18 = {
		DisplayName = "G-18", Category = "Pistol", Slot = "Secondary",
		UnlockLevel = 0, Price = 0, FireMode = "Semi",
		Damage = 22, HeadshotMultiplier = 1.9,
		Falloff = { { 45, 1.0 }, { 95, 0.65 }, { 160, 0.5 } },
		RPM = 400, MagSize = 17, ReserveAmmo = 68, ReloadTime = 1.5, Range = 500, BulletsPerShot = 1,
		RecoilVertical = 0.45, RecoilHorizontal = 0.14, RecoilRecovery = 19,
		SpreadBase = 0.35, SpreadMoving = 1.4, SpreadPerShot = 0.22, SpreadMax = 2.2, SpreadRecovery = 11,
		AdsSpreadMultiplier = 0.25, AdsFov = 62, HipFov = 72, AdsSpeed = 18, EquipTime = 0.25,
		FireSoundId = "", ModelName = "",
	},
	Deagle50 = {
		DisplayName = "Deagle-50", Category = "Pistol", Slot = "Secondary",
		UnlockLevel = 9, Price = 4500, FireMode = "Semi",
		Damage = 48, HeadshotMultiplier = 2.0,
		Falloff = { { 50, 1.0 }, { 110, 0.7 }, { 180, 0.5 } },
		RPM = 250, MagSize = 7, ReserveAmmo = 35, ReloadTime = 1.9, Range = 600, BulletsPerShot = 1,
		RecoilVertical = 1.1, RecoilHorizontal = 0.2, RecoilRecovery = 14,
		SpreadBase = 0.5, SpreadMoving = 1.8, SpreadPerShot = 0.4, SpreadMax = 3.0, SpreadRecovery = 9,
		AdsSpreadMultiplier = 0.25, AdsFov = 60, HipFov = 72, AdsSpeed = 16, EquipTime = 0.3,
		FireSoundId = "", ModelName = "",
	},
}

-- ⚠️ SYSTÈME D'ATTACHEMENTS (scaffold de base — branché mais à enrichir).
-- Chaque attachement modifie des stats par multiplication/addition.
WeaponConfig.Attachments = {
	-- Optiques (modifient surtout la visée)
	RedDot = { DisplayName = "Point rouge", Slot = "Optic", Mods = { AdsSpeed = 1.1 } },
	Holo = { DisplayName = "Holographique", Slot = "Optic", Mods = { AdsSpeed = 1.05, SpreadBase = 0.9 } },
	Scope4x = { DisplayName = "Lunette x4", Slot = "Optic", Mods = { AdsFov = 0.6, AdsSpeed = 0.85 } },
	-- Canons (dégâts / portée / recul)
	LongBarrel = { DisplayName = "Canon long", Slot = "Barrel", Mods = { Range = 1.2, RecoilVertical = 1.1 } },
	Compensator = { DisplayName = "Compensateur", Slot = "Barrel", Mods = { RecoilVertical = 0.85, RecoilHorizontal = 0.8 } },
	-- Poignées (recul / dispersion)
	Grip = { DisplayName = "Poignée", Slot = "Grip", Mods = { RecoilHorizontal = 0.8, SpreadMoving = 0.9 } },
	-- Chargeurs (capacité / rechargement)
	ExtMag = { DisplayName = "Chargeur étendu", Slot = "Mag", Mods = { MagSize = 1.4, ReloadTime = 1.1 } },
}

-- Renvoie la config d'une arme ou nil
function WeaponConfig.get(weaponId: string)
	return WeaponConfig.Weapons[weaponId]
end

-- Renvoie une COPIE de l'arme avec les attachements appliqués (sans modifier l'original).
-- attachmentIds : liste d'IDs d'attachements à appliquer.
function WeaponConfig.getWithAttachments(weaponId: string, attachmentIds: { string }?)
	local base = WeaponConfig.Weapons[weaponId]
	if not base then
		return nil
	end
	-- Copie superficielle
	local result = table.clone(base)
	if attachmentIds then
		for _, attId in ipairs(attachmentIds) do
			local att = WeaponConfig.Attachments[attId]
			if att and att.Mods then
				for stat, factor in att.Mods do
					if typeof(result[stat]) == "number" then
						-- Convention : facteur < 5 = multiplicateur, sinon valeur absolue
						result[stat] = result[stat] * factor
					end
				end
			end
		end
		-- MagSize doit rester entier
		if result.MagSize then
			result.MagSize = math.floor(result.MagSize + 0.5)
		end
	end
	return result
end

-- Multiplicateur de dégâts selon la distance (interpolation linéaire)
function WeaponConfig.getFalloffMultiplier(weapon, distance: number): number
	local falloff = weapon.Falloff
	if not falloff or #falloff == 0 then
		return 1.0
	end
	if distance <= falloff[1][1] then
		return falloff[1][2]
	end
	local last = falloff[#falloff]
	if distance >= last[1] then
		return last[2]
	end
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
