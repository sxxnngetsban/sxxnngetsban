import { Redirect } from 'expo-router';

import { useAuth } from '@/lib/auth';

/** Point d'entrée : oriente vers la connexion ou la vitrine. */
export default function Index() {
  const { user } = useAuth();
  return <Redirect href={user === null ? '/(auth)/login' : '/(app)/feed'} />;
}
