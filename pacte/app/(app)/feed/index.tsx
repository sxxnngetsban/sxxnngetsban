import { FlatList, Text, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { ProductCard } from '@/components/ProductCard';
import { useAuth } from '@/lib/auth';
import { MOCK_PRODUCTS } from '@/lib/mock';
import type { Product } from '@/types';

export default function FeedScreen() {
  const { user } = useAuth();

  return (
    <SafeAreaView className="flex-1 bg-pacte-cream" edges={['top', 'left', 'right']}>
      <FlatList<Product>
        data={[...MOCK_PRODUCTS]}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => <ProductCard product={item} />}
        contentContainerClassName="px-5 pb-8"
        showsVerticalScrollIndicator={false}
        ListHeaderComponent={
          <View className="pb-5 pt-2">
            <Text className="text-sm font-semibold text-pacte-dark/40">
              Salut {user?.displayName ?? 'voisin'} 👋
            </Text>
            <Text className="text-3xl font-extrabold text-pacte-dark">La Vitrine</Text>
            <Text className="mt-1 text-sm text-pacte-dark/50">
              {MOCK_PRODUCTS.length} objets à saisir dans ton quartier.
            </Text>
          </View>
        }
      />
    </SafeAreaView>
  );
}
