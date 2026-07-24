import { useEffect, useState } from 'react';
import { Image, ScrollView, Text, View } from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withDelay,
  withSequence,
  withSpring,
} from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';

import { Button } from '@/components/Button';
import { Card } from '@/components/Card';
import { InviteModal } from '@/components/InviteModal';
import { ProgressBar } from '@/components/ProgressBar';
import { TrustBadge } from '@/components/TrustBadge';
import { getTierProgress } from '@/constants/karma';
import { useAuth } from '@/lib/auth';
import { MOCK_CURRENT_USER } from '@/lib/mock';

export default function ProfileScreen() {
  const { user, isDemo, signOut } = useAuth();
  const [inviteVisible, setInviteVisible] = useState(false);

  const profile = user ?? MOCK_CURRENT_USER;
  const progress = getTierProgress(profile.pactesCompleted);

  // Petite bascule du badge à l'ouverture de l'écran.
  const badgeScale = useSharedValue(0.8);
  const badgeRotate = useSharedValue(-8);

  useEffect(() => {
    badgeScale.value = withDelay(150, withSpring(1, { damping: 6, stiffness: 140 }));
    badgeRotate.value = withDelay(
      150,
      withSequence(withSpring(6), withSpring(-3), withSpring(0)),
    );
  }, [badgeScale, badgeRotate]);

  const badgeStyle = useAnimatedStyle(() => ({
    transform: [{ scale: badgeScale.value }, { rotate: `${badgeRotate.value}deg` }],
  }));

  return (
    <SafeAreaView className="flex-1 bg-pacte-cream" edges={['top', 'left', 'right']}>
      <ScrollView
        contentContainerClassName="px-5 pb-10 pt-2"
        showsVerticalScrollIndicator={false}
      >
        <View className="items-center py-4">
          <Image
            source={{ uri: profile.avatarUrl ?? MOCK_CURRENT_USER.avatarUrl ?? undefined }}
            className="h-24 w-24 rounded-full border-4 border-white"
          />
          <Text className="mt-3 text-2xl font-extrabold text-pacte-dark">
            {profile.displayName}
          </Text>
          <Text className="text-sm text-pacte-dark/40">{profile.email}</Text>

          {/* Le wrapper porte la classe, l'Animated.View porte le style animé. */}
          <View className="mt-4">
            <Animated.View style={badgeStyle}>
              <TrustBadge tier={progress.definition.tier} size="lg" />
            </Animated.View>
          </View>
        </View>

        <Card className="mt-2 items-center p-6">
          <Text className="text-sm font-semibold text-pacte-dark/40">Karma</Text>
          <Text className="text-6xl font-extrabold text-pacte-orange">
            {profile.karma.toLocaleString('fr-FR')}
          </Text>
          <Text className="mt-1 text-sm text-pacte-dark/50">
            {profile.pactesCompleted} pactes conclus
          </Text>
        </Card>

        <Card className="mt-4 p-6">
          <View className="mb-3 flex-row items-center justify-between">
            <Text className="text-sm font-bold text-pacte-dark">
              Palier {progress.definition.label}
            </Text>
            <Text className="text-xs font-semibold text-pacte-dark/40">
              {progress.nextLabel === null
                ? 'Palier maximum atteint 🏆'
                : `${progress.remaining} pacte${progress.remaining > 1 ? 's' : ''} avant ${progress.nextLabel}`}
            </Text>
          </View>
          <ProgressBar value={progress.ratio} color={progress.definition.color} />
          <Text className="mt-3 text-[11px] leading-4 text-pacte-dark/35">
            Bronze 0–5 · Argent 5–20 · Or 20+. Chaque pacte validé par les deux parties
            fait monter ton score.
          </Text>
        </Card>

        <Card className="mt-4 p-6">
          <Text className="text-base font-bold text-pacte-dark">Inviter un voisin</Text>
          <Text className="mt-1 text-sm text-pacte-dark/50">
            Ton voisin n’a pas l’appli ? Envoie-lui un lien : il pourra valider le pacte
            sans créer de compte.
          </Text>
          <Button
            label="Générer un lien de confiance"
            icon="🔗"
            onPress={() => setInviteVisible(true)}
            className="mt-5"
          />
        </Card>

        {isDemo && (
          <View className="mt-4 rounded-3xl border border-amber-300 bg-amber-100/70 p-4">
            <Text className="text-xs leading-5 text-amber-900/80">
              ⚙️ Session de démonstration : les données affichées sont mockées tant que
              les clés Supabase ne sont pas renseignées.
            </Text>
          </View>
        )}

        <Button
          label="Se déconnecter"
          variant="ghost"
          onPress={() => {
            void signOut();
          }}
          className="mt-6"
        />
      </ScrollView>

      <InviteModal
        visible={inviteVisible}
        onClose={() => setInviteVisible(false)}
        inviteCode={profile.inviteCode}
        displayName={profile.displayName}
      />
    </SafeAreaView>
  );
}
