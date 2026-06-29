# 🪙 Collecteur de pièces — projet d'entraînement Roblox/Luau

Petit projet **débutant et jetable** pour apprendre les bases du dev Roblox :
des pièces dorées apparaissent sur la map, le joueur les ramasse, un compteur
s'affiche à l'écran et le total est sauvegardé entre les sessions.

> Ce n'est pas un vrai jeu — c'est un terrain d'entraînement. On vise la
> simplicité et la compréhension étape par étape.

## Pile technique

- **Roblox / Luau** (pas Lua 5.1, pas JS).
- **Rojo** pour synchroniser le code de ce dépôt vers Roblox Studio.
- **Rokit** pour installer les outils (`rojo`, `stylua`).

## Structure

```
src/
├── server/   → ServerScriptService/Server   (code serveur)
├── client/   → StarterPlayer/.../Client      (UI, input joueur)
└── shared/   → ReplicatedStorage/Shared      (modules partagés)
```

La correspondance exacte est définie dans `default.project.json`.

## Démarrage rapide

```bash
rokit install        # installe rojo + stylua (versions épinglées dans rokit.toml)
rojo plugin install  # installe le plugin Rojo dans Studio (version assortie)
rojo serve           # démarre le serveur de synchro
```

Puis dans Studio : plugin **Rojo → Connect**.

Voir `CLAUDE.md` pour les conventions du projet.
