import { TrustColors } from '@/constants/colors';
import type { TrustTier } from '@/types';

export interface TierDefinition {
  tier: TrustTier;
  label: string;
  emoji: string;
  color: string;
  /** Nombre de pactes conclus requis pour entrer dans le palier. */
  min: number;
  /** Seuil d'entrée du palier suivant (`Infinity` pour le dernier). */
  next: number;
}

export const TIERS: readonly TierDefinition[] = [
  {
    tier: 'bronze',
    label: 'Bronze',
    emoji: '🥉',
    color: TrustColors.bronze,
    min: 0,
    next: 5,
  },
  {
    tier: 'argent',
    label: 'Argent',
    emoji: '🥈',
    color: TrustColors.argent,
    min: 5,
    next: 20,
  },
  {
    tier: 'or',
    label: 'Or',
    emoji: '🥇',
    color: TrustColors.or,
    min: 20,
    next: Infinity,
  },
];

export function getTierDefinition(pactesCompleted: number): TierDefinition {
  const found = [...TIERS]
    .reverse()
    .find((definition) => pactesCompleted >= definition.min);
  // TIERS commence à 0, donc `found` est toujours défini — fallback défensif.
  return found ?? TIERS[0]!;
}

export function getTier(pactesCompleted: number): TrustTier {
  return getTierDefinition(pactesCompleted).tier;
}

export interface TierProgress {
  definition: TierDefinition;
  /** Progression dans le palier courant, entre 0 et 1. */
  ratio: number;
  /** Pactes restants avant le palier suivant (`0` si palier max). */
  remaining: number;
  nextLabel: string | null;
}

export function getTierProgress(pactesCompleted: number): TierProgress {
  const definition = getTierDefinition(pactesCompleted);

  if (definition.next === Infinity) {
    return { definition, ratio: 1, remaining: 0, nextLabel: null };
  }

  const span = definition.next - definition.min;
  const done = pactesCompleted - definition.min;
  const nextIndex = TIERS.findIndex((t) => t.tier === definition.tier) + 1;

  return {
    definition,
    ratio: Math.min(Math.max(done / span, 0), 1),
    remaining: Math.max(definition.next - pactesCompleted, 0),
    nextLabel: TIERS[nextIndex]?.label ?? null,
  };
}
