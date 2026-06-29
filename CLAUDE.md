# CLAUDE.md — Contexte du projet

Projet **d'entraînement jetable** pour apprendre les bases du dev Roblox.
Objectif pédagogique : un petit « collecteur de pièces ». Ce n'est PAS un vrai jeu
de production — on privilégie la **simplicité** et les explications pas à pas pour
un débutant complet.

## Plateforme & langage — À NE JAMAIS OUBLIER

- Cible : **Roblox**. Le code tourne dans le moteur Roblox (Roblox Studio).
- Langage : **Luau** (le dialecte de Roblox), **PAS** Lua 5.1, **PAS** JavaScript/TypeScript.
- API : on utilise les services Roblox (`game:GetService(...)`), les `Instance`,
  les `RemoteEvent`, `DataStoreService`, etc. Pas de bibliothèques Node/npm.

## Structure Rojo

Le code vit dans `src/` et est synchronisé dans Studio par **Rojo** (voir
`default.project.json`). Correspondance dossier → emplacement Studio :

| Dossier du repo | Emplacement dans Studio                         | Rôle                          |
| --------------- | ----------------------------------------------- | ----------------------------- |
| `src/server`    | `ServerScriptService/Server`                    | Code serveur (autorité, data) |
| `src/client`    | `StarterPlayer/StarterPlayerScripts/Client`     | Code joueur (UI, input)       |
| `src/shared`    | `ReplicatedStorage/Shared`                      | Modules partagés client+serveur |

## Conventions de nommage des fichiers (IMPORTANT)

Rojo déduit le **type d'Instance** à partir du suffixe du nom de fichier :

- `*.server.luau` → un **Script** (s'exécute sur le **serveur**).
- `*.client.luau` → un **LocalScript** (s'exécute sur le **client/joueur**).
- `*.luau` (sans suffixe) → un **ModuleScript** (du code réutilisable, qu'on
  `require()` ; ne s'exécute pas tout seul).
- `init.server.luau` / `init.client.luau` / `init.luau` → le script du dossier
  parent lui-même (transforme le dossier en Script/LocalScript/ModuleScript).

## Style

- Indentation : **tabulations** (voir `stylua.toml`). Largeur de colonne 120.
- Guillemets : doubles par défaut.
- Formatage via **StyLua** (`stylua src/`).

## Outils

- `rojo` (CLI) + plugin Rojo dans Studio — synchronisation du code.
- `rokit` — gestionnaire d'outils, installe `rojo` et `stylua` (voir `rokit.toml`).
