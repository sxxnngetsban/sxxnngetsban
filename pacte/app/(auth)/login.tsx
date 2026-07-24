import { useRouter } from 'expo-router';
import { useState } from 'react';
import {
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  Text,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { Button } from '@/components/Button';
import { Input } from '@/components/Input';
import { useAuth } from '@/lib/auth';
import { isSupabaseConfigured, SUPABASE_SETUP_MESSAGE } from '@/lib/supabase';

type Mode = 'signin' | 'signup';

export default function LoginScreen() {
  const router = useRouter();
  const { signIn, signUp } = useAuth();

  const [mode, setMode] = useState<Mode>('signin');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function handleSubmit(): Promise<void> {
    setError(null);

    if (isSupabaseConfigured) {
      if (!email.includes('@')) {
        setError('Il manque une adresse email valide.');
        return;
      }
      if (password.length < 6) {
        setError('Le mot de passe fait au moins 6 caractères.');
        return;
      }
    }

    setSubmitting(true);
    const result = mode === 'signin' ? await signIn(email, password) : await signUp(email, password);
    setSubmitting(false);

    if (!result.ok) {
      setError(result.error);
      return;
    }

    router.replace('/(app)/feed');
  }

  return (
    <SafeAreaView className="flex-1 bg-pacte-cream">
      <KeyboardAvoidingView
        className="flex-1"
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerClassName="flex-grow justify-center px-6 py-10"
          keyboardShouldPersistTaps="handled"
        >
          <View className="mb-10 items-center">
            <View className="mb-4 h-24 w-24 items-center justify-center rounded-[32px] bg-pacte-orange">
              <Text className="text-5xl">🤝</Text>
            </View>
            <Text className="text-4xl font-extrabold text-pacte-dark">Pacte</Text>
            <Text className="mt-2 text-center text-base text-pacte-dark/50">
              Vendre, troquer, se faire confiance.{'\n'}Entre voisins, sans prise de tête.
            </Text>
          </View>

          {!isSupabaseConfigured && (
            <View className="mb-6 rounded-3xl border border-amber-300 bg-amber-100/70 p-4">
              <Text className="mb-1 text-sm font-bold text-amber-900">
                ⚙️ Mode démo activé
              </Text>
              <Text className="text-xs leading-5 text-amber-900/80">
                {SUPABASE_SETUP_MESSAGE} En attendant, tu peux entrer : l’app tourne avec
                des données de démonstration.
              </Text>
            </View>
          )}

          <View className="gap-4">
            <Input
              label="Email"
              value={email}
              onChangeText={setEmail}
              placeholder="voisin@quartier.fr"
              autoCapitalize="none"
              autoComplete="email"
              keyboardType="email-address"
              inputMode="email"
            />
            <Input
              label="Mot de passe"
              value={password}
              onChangeText={setPassword}
              placeholder="••••••••"
              secureTextEntry
              autoCapitalize="none"
              hint={mode === 'signup' ? '6 caractères minimum.' : undefined}
            />
          </View>

          {error !== null && (
            <View className="mt-4 rounded-2xl border border-red-200 bg-red-50 p-3">
              <Text className="text-sm font-medium text-red-600">😕 {error}</Text>
            </View>
          )}

          <Button
            label={mode === 'signin' ? "Démarrer l'aventure" : 'Créer mon compte'}
            icon="🚀"
            onPress={() => {
              void handleSubmit();
            }}
            loading={submitting}
            className="mt-8"
          />

          <Pressable
            className="mt-6 items-center"
            onPress={() => {
              setError(null);
              setMode((current) => (current === 'signin' ? 'signup' : 'signin'));
            }}
          >
            <Text className="text-sm font-semibold text-pacte-dark/60">
              {mode === 'signin'
                ? "Pas encore de compte ? S'inscrire"
                : 'Déjà un compte ? Se connecter'}
            </Text>
          </Pressable>

          <Text className="mt-10 text-center text-[11px] leading-4 text-pacte-dark/35">
            En continuant, tu acceptes que chaque pacte engage les deux parties.
            Validation en deux étapes, comme une vraie poignée de main.
          </Text>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
