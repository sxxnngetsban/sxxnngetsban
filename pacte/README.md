# Pacte 🤝

Appli de supervision de ventes et de troc entre particuliers. Ton détendu, cadre
juridique clair : chaque échange se valide en deux étapes, comme une poignée de main.

## Démarrer

```bash
cd pacte
npx expo start --clear
```

Puis scanne le QR Code affiché dans le terminal avec **Expo Go** sur ton iPhone
(même réseau Wi-Fi que la machine qui lance la commande).

## Supabase

Sans clés, l'app démarre en **mode démo** : l'UI est complète, les données sont
mockées et un bandeau l'indique sur l'écran de connexion. Pour brancher le vrai
backend, crée un fichier `.env.local` à la racine de `pacte/` :

```
EXPO_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9....
```

Les deux valeurs se trouvent dans Supabase → *Project Settings* → *API*.
Relance ensuite `npx expo start --clear` (Expo ne relit les variables qu'au démarrage).

L'auth utilisée est email + mot de passe. Table `profiles` attendue côté Supabase :
`id`, `display_name`, `avatar_url`, `karma`, `pactes_completed`, `invite_code`,
`created_at` (voir `types/index.ts`, interface `ProfileRow`).

## Stack

- **Expo SDK 57** + TypeScript strict
- **Expo Router** (`app/`, layout racine + groupes `(auth)` / `(app)`)
- **NativeWind 4** / Tailwind CSS 3 — palette dans `constants/colors.ts` et `tailwind.config.js`
- **Supabase JS** pour l'auth et les profils
- **Reanimated 4** pour les confettis, la jauge de karma et les boutons

## Arborescence

```
app/
  _layout.tsx            Stack racine + splash + redirection selon la session
  (auth)/login.tsx       Connexion / inscription
  (app)/_layout.tsx      Tabs protégés : Vitrine · Vendre · Profil
  (app)/feed/index.tsx   Vitrine (5 annonces mockées)
  (app)/create/index.tsx Création d'annonce + scan caméra
  (app)/profile/index.tsx Karma, badge, jauge, lien de confiance
components/              Button, Card, Input, ProductCard, TrustBadge, ProgressBar,
                         Confetti, InviteModal
constants/               colors.ts (palette), karma.ts (paliers Bronze/Argent/Or)
lib/                     supabase.ts, auth.tsx (contexte de session), mock.ts
types/                   User, Product, Transaction, ProfileRow
```

## Paliers de confiance

Bronze `0–5` · Argent `5–20` · Or `20+` pactes conclus. La jauge du profil montre
la progression vers le palier suivant.

## Notes

- Les annonces sont **mockées** (`lib/mock.ts`) : rien ne transite par Supabase.
- Le scan IA de l'usure ouvre un aperçu caméra et renvoie un résultat simulé.
- Le lien d'invitation (`pacte.app/invite/XXXXX`) est fictif : copie et partage
  natif fonctionnent, la route d'atterrissage reste à créer.

## Scripts

```bash
npm run start      # serveur de dev Expo
npm run typecheck  # tsc --noEmit
```
