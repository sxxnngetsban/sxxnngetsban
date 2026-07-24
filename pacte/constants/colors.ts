/**
 * Palette officielle Pacte.
 * Ces valeurs sont dupliquées dans `tailwind.config.js` (clé `pacte`)
 * pour pouvoir écrire `bg-pacte-orange`, `text-pacte-dark`, etc.
 */
export const Colors = {
  orange: '#FF8A00',
  orangeLight: '#FFB800',
  cream: '#FDF6E3',
  mint: '#4ADE80',
  dark: '#1E293B',
  muted: '#64748B',
  border: '#E7DFC9',
  white: '#FFFFFF',
  danger: '#EF4444',
} as const;

/** Dégradé signature des boutons primaires (orange → jaune). */
export const PRIMARY_GRADIENT: readonly [string, string] = [
  Colors.orange,
  Colors.orangeLight,
];

/** Couleurs des paliers de confiance. */
export const TrustColors = {
  bronze: '#B87333',
  argent: '#9CA3AF',
  or: '#F5B301',
} as const;

export type ColorName = keyof typeof Colors;
