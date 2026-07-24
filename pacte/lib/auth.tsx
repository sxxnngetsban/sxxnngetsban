import AsyncStorage from '@react-native-async-storage/async-storage';
import type { Session } from '@supabase/supabase-js';
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react';

import { MOCK_CURRENT_USER } from '@/lib/mock';
import { isSupabaseConfigured, supabase } from '@/lib/supabase';
import type { User } from '@/types';

const DEMO_SESSION_KEY = 'pacte.demo-session';

export interface AuthResult {
  ok: boolean;
  /** Message prêt à afficher, `null` si tout s'est bien passé. */
  error: string | null;
  /** `true` quand la session a été ouverte en mode démo (Supabase absent). */
  demo: boolean;
}

interface AuthContextValue {
  /** `true` tant que la session persistée n'a pas été restaurée. */
  loading: boolean;
  user: User | null;
  isDemo: boolean;
  signIn: (email: string, password: string) => Promise<AuthResult>;
  signUp: (email: string, password: string) => Promise<AuthResult>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

function userFromSession(session: Session): User {
  const email = session.user.email ?? 'inconnu@pacte.app';
  const metadata = session.user.user_metadata as Record<string, unknown>;
  const displayName =
    typeof metadata.display_name === 'string' && metadata.display_name.length > 0
      ? metadata.display_name
      : (email.split('@')[0] ?? 'Voisin');

  return {
    id: session.user.id,
    email,
    displayName,
    avatarUrl: typeof metadata.avatar_url === 'string' ? metadata.avatar_url : null,
    karma: MOCK_CURRENT_USER.karma,
    pactesCompleted: MOCK_CURRENT_USER.pactesCompleted,
    inviteCode: MOCK_CURRENT_USER.inviteCode,
    createdAt: session.user.created_at,
  };
}

/** Traduit les erreurs Supabase les plus fréquentes en français. */
function humanizeError(message: string): string {
  if (/invalid login credentials/i.test(message)) {
    return 'Email ou mot de passe incorrect.';
  }
  if (/email not confirmed/i.test(message)) {
    return 'Confirme ton email avant de te connecter.';
  }
  if (/network|fetch/i.test(message)) {
    return 'Connexion impossible. Vérifie ton réseau (ou tes clés Supabase).';
  }
  if (/already registered/i.test(message)) {
    return 'Ce compte existe déjà — connecte-toi plutôt.';
  }
  return message;
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [loading, setLoading] = useState(true);
  const [user, setUser] = useState<User | null>(null);
  const [isDemo, setIsDemo] = useState(false);

  useEffect(() => {
    let active = true;

    async function restore(): Promise<void> {
      if (!supabase) {
        const stored = await AsyncStorage.getItem(DEMO_SESSION_KEY);
        if (!active) return;
        if (stored !== null) {
          setUser({ ...MOCK_CURRENT_USER, email: stored });
          setIsDemo(true);
        }
        setLoading(false);
        return;
      }

      const { data } = await supabase.auth.getSession();
      if (!active) return;
      setUser(data.session ? userFromSession(data.session) : null);
      setLoading(false);
    }

    void restore();

    const subscription = supabase?.auth.onAuthStateChange((_event, session) => {
      setUser(session ? userFromSession(session) : null);
    });

    return () => {
      active = false;
      subscription?.data.subscription.unsubscribe();
    };
  }, []);

  /** Ouvre une session locale quand Supabase n'est pas configuré. */
  const startDemoSession = useCallback(async (email: string): Promise<AuthResult> => {
    const identity = email.trim().length > 0 ? email.trim() : MOCK_CURRENT_USER.email;
    await AsyncStorage.setItem(DEMO_SESSION_KEY, identity);
    setUser({ ...MOCK_CURRENT_USER, email: identity });
    setIsDemo(true);
    return { ok: true, error: null, demo: true };
  }, []);

  const signIn = useCallback(
    async (email: string, password: string): Promise<AuthResult> => {
      if (!supabase) return startDemoSession(email);

      const { error } = await supabase.auth.signInWithPassword({
        email: email.trim(),
        password,
      });

      return error
        ? { ok: false, error: humanizeError(error.message), demo: false }
        : { ok: true, error: null, demo: false };
    },
    [startDemoSession],
  );

  const signUp = useCallback(
    async (email: string, password: string): Promise<AuthResult> => {
      if (!supabase) return startDemoSession(email);

      const { error } = await supabase.auth.signUp({
        email: email.trim(),
        password,
      });

      return error
        ? { ok: false, error: humanizeError(error.message), demo: false }
        : { ok: true, error: null, demo: false };
    },
    [startDemoSession],
  );

  const signOut = useCallback(async (): Promise<void> => {
    if (supabase) {
      await supabase.auth.signOut();
    }
    await AsyncStorage.removeItem(DEMO_SESSION_KEY);
    setUser(null);
    setIsDemo(false);
  }, []);

  const value = useMemo<AuthContextValue>(
    () => ({ loading, user, isDemo, signIn, signUp, signOut }),
    [loading, user, isDemo, signIn, signUp, signOut],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);
  if (context === null) {
    throw new Error('useAuth doit être utilisé dans un <AuthProvider>.');
  }
  return context;
}

export { isSupabaseConfigured };
