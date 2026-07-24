import * as Clipboard from 'expo-clipboard';
import { useState } from 'react';
import { Modal, Pressable, Share, Text, View } from 'react-native';

import { Button } from '@/components/Button';
import { Card } from '@/components/Card';

interface InviteModalProps {
  visible: boolean;
  onClose: () => void;
  /** Code court du profil, ex. `K7X2M`. */
  inviteCode: string;
  displayName: string;
}

/** Lien partageable permettant à un non-inscrit de rejoindre un pacte. */
export function InviteModal({
  visible,
  onClose,
  inviteCode,
  displayName,
}: InviteModalProps) {
  const [copied, setCopied] = useState(false);
  const link = `pacte.app/invite/${inviteCode}`;

  async function handleCopy(): Promise<void> {
    await Clipboard.setStringAsync(`https://${link}`);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  }

  async function handleShare(): Promise<void> {
    await Share.share({
      message: `${displayName} t'invite à conclure un pacte en toute confiance : https://${link}`,
    });
  }

  return (
    <Modal visible={visible} transparent animationType="fade" onRequestClose={onClose}>
      <Pressable className="flex-1 justify-end bg-black/40" onPress={onClose}>
        <Pressable onPress={(event) => event.stopPropagation()}>
          <Card className="rounded-b-none p-6 pb-10">
            <View className="mb-5 items-center">
              <View className="mb-4 h-1.5 w-12 rounded-full bg-black/10" />
              <Text className="text-3xl">🔗</Text>
              <Text className="mt-2 text-xl font-extrabold text-pacte-dark">
                Ton lien de confiance
              </Text>
              <Text className="mt-1 text-center text-sm text-pacte-dark/50">
                Même sans compte, ton voisin peut valider le pacte avec toi.
              </Text>
            </View>

            <View className="items-center rounded-3xl border-2 border-dashed border-pacte-orange/40 bg-pacte-cream p-5">
              <Text className="text-base font-bold tracking-wide text-pacte-dark">
                {link}
              </Text>
              <Text className="mt-1 text-[11px] text-pacte-dark/40">
                Valable 7 jours · usage unique
              </Text>
            </View>

            <View className="mt-6 gap-3">
              <Button
                label={copied ? 'Lien copié !' : 'Copier le lien'}
                icon={copied ? '✅' : '📋'}
                variant="secondary"
                onPress={() => {
                  void handleCopy();
                }}
              />
              <Button
                label="Partager"
                icon="📤"
                onPress={() => {
                  void handleShare();
                }}
              />
              <Button label="Fermer" variant="ghost" onPress={onClose} />
            </View>
          </Card>
        </Pressable>
      </Pressable>
    </Modal>
  );
}
