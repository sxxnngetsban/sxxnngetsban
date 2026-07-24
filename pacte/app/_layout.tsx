import { Stack, useRouter, useSegments } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { useEffect } from 'react';
import { ActivityIndicator, Text, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SafeAreaProvider } from 'react-native-safe-area-context';

import { Colors } from '@/constants/colors';
import { AuthProvider, useAuth } from '@/lib/auth';

import '../global.css';

function SplashScreen() {
  return (
    <View className="flex-1 items-center justify-center bg-pacte-cream">
      <Text className="mb-3 text-6xl">🤝</Text>
      <Text className="text-3xl font-extrabold text-pacte-dark">Pacte</Text>
      <Text className="mb-8 text-sm text-pacte-dark/50">On se met d’accord ?</Text>
      <ActivityIndicator color={Colors.orange} />
    </View>
  );
}

/** Redirige entre le groupe `(auth)` et le groupe `(app)` selon la session. */
function RootNavigator() {
  const { loading, user } = useAuth();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (loading) return;

    const inAuthGroup = segments[0] === '(auth)';

    if (user === null && !inAuthGroup) {
      router.replace('/(auth)/login');
    } else if (user !== null && inAuthGroup) {
      router.replace('/(app)/feed');
    }
  }, [loading, user, segments, router]);

  if (loading) return <SplashScreen />;

  return (
    <Stack screenOptions={{ headerShown: false, contentStyle: { backgroundColor: Colors.cream } }}>
      <Stack.Screen name="(auth)" />
      <Stack.Screen name="(app)" />
    </Stack>
  );
}

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <AuthProvider>
          <StatusBar style="dark" />
          <RootNavigator />
        </AuthProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}
