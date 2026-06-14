# 🔫 FPS Game — Framework Roblox

Un framework FPS complet et modulaire pour Roblox, conçu pour être synchronisé
dans Roblox Studio via **Rojo**. Tu apportes la map, ce projet apporte tout le code :
armes hitscan, recul, visée, dégâts validés serveur (anti-triche), modes de jeu
(Team Deathmatch / Free-For-All), HUD complet et killfeed.

---

## ✨ Fonctionnalités

- **Armes hitscan** entièrement configurables (5 fournies : fusil d'assaut, SMG, sniper, fusil à pompe, pistolet)
- **Cadence, recul, dispersion, dégâts avec chute selon la distance, headshots**
- **Visée (ADS)** avec zoom de FOV et dispersion réduite
- **Validation serveur** des tirs : cadence, munitions, portée, ligne de vue (anti-wallbang), anti-aimbot basique
- **Modes de jeu modulaires** : `TDM` (équipes) ou `FFA`, score, timer, condition de victoire
- **HUD par code** : viseur dynamique, munitions, barre de vie, hitmarker, killfeed, tableau des scores (Tab)
- **Spawns** basés sur des points tagués + respawn automatique

---

## 📦 Installation

### 1. Installer les outils

Le plus simple est d'utiliser [Rokit](https://github.com/rojo-rbx/rokit) :

```bash
# Après avoir installé Rokit :
rokit install
```

> Alternative : installe Rojo via l'extension **Rojo** sur le VS Code Marketplace,
> ou télécharge-le sur https://rojo.space.

### 2. Installer le plugin Studio

Dans un terminal à la racine du projet :

```bash
rojo plugin install
```

(ou installe le plugin « Rojo » depuis la barre des plugins de Studio).

### 3. Synchroniser avec ta map

1. Ouvre **ta place** (celle avec ta map) dans Roblox Studio.
2. Lance le serveur Rojo à la racine du projet :
   ```bash
   rojo serve
   ```
3. Dans Studio, ouvre le plugin **Rojo** → **Connect**.

Le code se place automatiquement dans :

| Dossier du repo | Emplacement dans Studio                          |
| --------------- | ------------------------------------------------ |
| `src/shared`    | `ReplicatedStorage/Shared`                       |
| `src/server`    | `ServerScriptService/FPSServer` (Script)         |
| `src/client`    | `StarterPlayer/StarterPlayerScripts/FPSClient`   |

---

## 🗺️ Configurer ta map

### Points de spawn

Place des parts (invisibles, `CanCollide` off) là où les joueurs doivent
apparaître, puis **tague-les** avec le tag CollectionService **`FPSSpawn`** :

> Studio → onglet **View** → **Tag Editor** → crée le tag `FPSSpawn` → sélectionne
> tes parts → applique le tag.

S'il n'y a aucun point tagué, le framework utilise tes `SpawnLocation`
existants, sinon `(0, 50, 0)` par défaut.

### Équipes (mode TDM)

Les équipes sont créées automatiquement à partir de `GameConfig.Teams`.
Tu peux laisser tes spawns communs : l'équilibrage des joueurs est géré par code.

---

## ⚙️ Personnalisation

Tout se règle dans `src/shared/` :

### `GameConfig.luau`

```lua
GameConfig.Mode = "TDM"      -- ou "FFA"
GameConfig.MaxHealth = 100
GameConfig.RespawnTime = 4
GameConfig.ScoreToWin = 40
GameConfig.FriendlyFire = false
```

### `WeaponConfig.luau`

Ajoute une arme en copiant un bloc existant :

```lua
WeaponConfig.Weapons.MonFusil = {
    DisplayName = "Mon Fusil",
    Slot = "Primary",
    FireMode = "Auto",          -- "Auto" / "Semi"
    Damage = 28,
    HeadshotMultiplier = 2.0,
    Falloff = { {60, 1.0}, {140, 0.65} },
    RPM = 600,
    MagSize = 30,
    ReserveAmmo = 120,
    ReloadTime = 2.4,
    Range = 1200,
    BulletsPerShot = 1,
    -- recul / dispersion / visée ...
}
```

Change le loadout de départ :

```lua
WeaponConfig.DefaultLoadout = { Primary = "MonFusil", Secondary = "Pistol" }
```

---

## 🎮 Commandes par défaut

| Touche / souris  | Action               |
| ---------------- | -------------------- |
| Clic gauche      | Tirer                |
| Clic droit       | Viser (ADS)          |
| R                | Recharger            |
| 1 / 2            | Arme principale / secondaire |
| Tab              | Tableau des scores   |

---

## 🏗️ Architecture

```
src/
├── shared/                    → ReplicatedStorage.Shared (partagé client+serveur)
│   ├── GameConfig.luau        · réglages globaux du jeu
│   ├── WeaponConfig.luau      · stats des armes + calcul de la chute de dégâts
│   ├── Net.luau               · création / accès aux RemoteEvents
│   ├── Spring.luau            · ressort amorti (recul, sway)
│   └── RaycastUtil.luau       · dispersion, params de raycast, détection humanoid/tête
│
├── server/                    → ServerScriptService.FPSServer
│   ├── init.server.luau       · bootstrap : crée les remotes + lance les services
│   ├── GameModeService.luau   · équipes, scores, manche, victoire, killfeed
│   ├── SpawnService.luau      · points de spawn, respawn, loadout
│   └── CombatService.luau     · VALIDATION des tirs, dégâts, munitions, kills
│
└── client/                    → StarterPlayerScripts.FPSClient
    ├── init.client.luau       · bootstrap : démarre caméra/HUD/armes + vie/scores
    ├── CameraController.luau   · recul caméra + FOV (visée)
    ├── WeaponController.luau   · input, tir, dispersion, rechargement, effets
    └── Hud.luau               · viseur, munitions, vie, hitmarker, killfeed, scores
```

### Comment marche un tir (sécurité)

1. **Client** : raycast depuis la caméra (réactif), affiche tracer/impact/hitmarker.
2. Le client envoie au serveur uniquement les impacts touchant un personnage.
3. **Serveur** (`CombatService`) revérifie : arme équipée, cadence, munitions,
   portée, écart position annoncée vs réelle, et **ligne de vue** (re-raycast pour
   bloquer les tirs à travers les murs). Seulement ensuite il applique les dégâts.

Ce modèle « client-raycast + validation serveur » donne une bonne réactivité tout
en empêchant les tricheurs d'infliger des dégâts impossibles.

---

## 🚀 Pistes d'amélioration

- Viewmodel (bras + arme en vue) — brancher des modèles dans `ReplicatedStorage`
- Sons de tir/rechargement (ajoute des `SoundId` dans `WeaponController`)
- Système d'achat / loadout par joueur (déjà câblé via `PlayerLoadout`)
- Grenades, classes, killstreaks
- Lag compensation côté serveur (rewind des hitbox) pour le compétitif

Amuse-toi bien — et bon dev ! 🎯
