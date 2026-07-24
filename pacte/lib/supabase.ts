import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import 'react-native-url-polyfill/auto';

/**
 * Les clés sont lues depuis un fichier `.env.local` à la racine du projet.
 * Expo n'expose au bundle que les variables préfixées par `EXPO_PUBLIC_`.
 *
 *   EXPO_PUBLIC_SUPABASE_URL=https://xxxxxxxx.supabase.co
 *   EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOi...
 */
const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL ?? '';
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '';

/** `true` seulement si les deux variables d'environnement sont renseignées. */
export const isSupabaseConfigured =
  supabaseUrl.length > 0 && supabaseAnonKey.length > 0;

export const SUPABASE_SETUP_MESSAGE =
  "Supabase n'est pas encore branché. Crée un fichier .env.local avec " +
  'EXPO_PUBLIC_SUPABASE_URL et EXPO_PUBLIC_SUPABASE_ANON_KEY, ' +
  'puis relance `npx expo start --clear`.';

/**
 * `null` tant que les clés ne sont pas fournies : l'UI reste utilisable,
 * seules les actions réseau sont désactivées (voir `signIn` / `signUp`).
 */
export const supabase: SupabaseClient | null = isSupabaseConfigured
  ? createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        storage: AsyncStorage,
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: false,
      },
    })
  : null;
