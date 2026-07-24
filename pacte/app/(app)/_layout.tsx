import { Redirect, Tabs } from 'expo-router';
import { Camera, Store, UserRound } from 'lucide-react-native';

import { Colors } from '@/constants/colors';
import { useAuth } from '@/lib/auth';

export default function AppLayout() {
  const { loading, user } = useAuth();

  if (loading) return null;
  if (user === null) return <Redirect href="/(auth)/login" />;

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: Colors.orange,
        tabBarInactiveTintColor: Colors.muted,
        sceneStyle: { backgroundColor: Colors.cream },
        tabBarStyle: {
          backgroundColor: Colors.white,
          borderTopWidth: 0,
          elevation: 12,
          shadowColor: Colors.dark,
          shadowOpacity: 0.08,
          shadowRadius: 12,
          shadowOffset: { width: 0, height: -4 },
          height: 88,
          paddingTop: 8,
        },
        tabBarLabelStyle: { fontSize: 11, fontWeight: '700' },
      }}
    >
      <Tabs.Screen
        name="feed/index"
        options={{
          title: 'Vitrine',
          tabBarIcon: ({ color, size }) => <Store color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="create/index"
        options={{
          title: 'Vendre',
          tabBarIcon: ({ color, size }) => <Camera color={color} size={size} />,
        }}
      />
      <Tabs.Screen
        name="profile/index"
        options={{
          title: 'Profil',
          tabBarIcon: ({ color, size }) => <UserRound color={color} size={size} />,
        }}
      />
    </Tabs>
  );
}
