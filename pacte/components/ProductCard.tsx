import { Image, Text, View } from 'react-native';

import { Card } from '@/components/Card';
import { TrustBadge } from '@/components/TrustBadge';
import type { Product } from '@/types';

const CONDITION_LABEL: Record<Product['condition'], string> = {
  neuf: 'Neuf',
  excellent: 'Très bon état',
  bon: 'Bon état',
  usé: 'Usé mais fonctionnel',
};

export function ProductCard({ product }: { product: Product }) {
  return (
    <Card className="mb-4 overflow-hidden">
      <Image
        source={{ uri: product.imageUrl }}
        className="h-48 w-full"
        resizeMode="cover"
      />

      <View className="gap-3 p-4">
        <View className="flex-row items-start justify-between gap-3">
          <Text className="flex-1 text-lg font-bold text-pacte-dark" numberOfLines={1}>
            {product.title}
          </Text>
          <Text className="text-lg font-extrabold text-pacte-orange">
            {product.price === 0 ? 'Troc' : `${product.price} €`}
          </Text>
        </View>

        <Text className="text-sm leading-5 text-pacte-dark/60" numberOfLines={2}>
          {product.description}
        </Text>

        <View className="flex-row items-center gap-2">
          <View className="rounded-full bg-pacte-mint/20 px-2.5 py-1">
            <Text className="text-[11px] font-bold text-emerald-700">
              🔍 {CONDITION_LABEL[product.condition]}
            </Text>
          </View>
          <Text className="text-[11px] text-pacte-dark/40">
            à {product.distanceKm.toFixed(1)} km
          </Text>
        </View>

        <View className="mt-1 flex-row items-center justify-between border-t border-black/5 pt-3">
          <View className="flex-row items-center gap-2">
            <Image
              source={{ uri: product.seller.avatarUrl }}
              className="h-8 w-8 rounded-full"
            />
            <Text className="text-sm font-semibold text-pacte-dark">
              {product.seller.displayName}
            </Text>
          </View>
          <TrustBadge tier={product.seller.tier} />
        </View>
      </View>
    </Card>
  );
}
