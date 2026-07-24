import { Text, View } from 'react-native';

import { TIERS } from '@/constants/karma';
import type { TrustTier } from '@/types';

interface TrustBadgeProps {
  tier: TrustTier;
  size?: 'sm' | 'lg';
}

/** Pastille « Confiance Bronze / Argent / Or » affichée sur les cartes et le profil. */
export function TrustBadge({ tier, size = 'sm' }: TrustBadgeProps) {
  const definition = TIERS.find((item) => item.tier === tier) ?? TIERS[0]!;
  const isLarge = size === 'lg';

  return (
    <View
      style={{ backgroundColor: `${definition.color}22`, borderColor: definition.color }}
      className={`flex-row items-center gap-1 rounded-full border ${
        isLarge ? 'px-4 py-2' : 'px-2.5 py-1'
      }`}
    >
      <Text className={isLarge ? 'text-base' : 'text-xs'}>{definition.emoji}</Text>
      <Text
        style={{ color: definition.color }}
        className={`font-bold ${isLarge ? 'text-sm' : 'text-[11px]'}`}
      >
        Confiance {definition.label}
      </Text>
    </View>
  );
}
