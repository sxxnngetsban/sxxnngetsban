import { CameraView, useCameraPermissions } from 'expo-camera';
import { useEffect, useRef, useState } from 'react';
import {
  KeyboardAvoidingView,
  Modal,
  Platform,
  Pressable,
  ScrollView,
  Text,
  View,
} from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSequence,
  withSpring,
} from 'react-native-reanimated';
import { SafeAreaView } from 'react-native-safe-area-context';

import { Button } from '@/components/Button';
import { Card } from '@/components/Card';
import { Confetti } from '@/components/Confetti';
import { Input } from '@/components/Input';
import type { WearCondition } from '@/types';

/** Résultat simulé du scan IA tant que le modèle n'est pas branché. */
const FAKE_SCAN: { condition: WearCondition; score: number } = {
  condition: 'bon',
  score: 78,
};

export default function CreateScreen() {
  const [title, setTitle] = useState('');
  const [price, setPrice] = useState('');
  const [description, setDescription] = useState('');
  const [scanned, setScanned] = useState(false);
  const [cameraOpen, setCameraOpen] = useState(false);
  const [confettiTrigger, setConfettiTrigger] = useState(0);
  const [published, setPublished] = useState(false);
  const [permission, requestPermission] = useCameraPermissions();

  const confirmTimeout = useRef<ReturnType<typeof setTimeout> | null>(null);
  useEffect(
    () => () => {
      if (confirmTimeout.current !== null) clearTimeout(confirmTimeout.current);
    },
    [],
  );

  const scanScale = useSharedValue(1);
  const scanStyle = useAnimatedStyle(() => ({ transform: [{ scale: scanScale.value }] }));

  const canPublish = title.trim().length > 0 && description.trim().length > 0;

  async function openCamera(): Promise<void> {
    scanScale.value = withSequence(withSpring(0.92), withSpring(1));

    if (permission?.granted !== true) {
      const result = await requestPermission();
      if (!result.granted) return;
    }
    setCameraOpen(true);
  }

  function handlePublish(): void {
    if (!canPublish) return;
    setConfettiTrigger((value) => value + 1);
    // On laisse les confettis tomber avant d'ouvrir la confirmation.
    confirmTimeout.current = setTimeout(() => setPublished(true), 850);
  }

  function resetForm(): void {
    setTitle('');
    setPrice('');
    setDescription('');
    setScanned(false);
    setPublished(false);
  }

  return (
    <SafeAreaView className="flex-1 bg-pacte-cream" edges={['top', 'left', 'right']}>
      <KeyboardAvoidingView
        className="flex-1"
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          contentContainerClassName="px-5 pb-10 pt-2"
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          <Text className="text-3xl font-extrabold text-pacte-dark">Nouvelle vente</Text>
          <Text className="mb-6 mt-1 text-sm text-pacte-dark/50">
            Trois champs, un scan, et c’est parti.
          </Text>

          <View className="gap-4">
            <Input
              label="Nom du produit"
              value={title}
              onChangeText={setTitle}
              placeholder="Vélo de ville vintage"
            />
            <Input
              label="Prix (€)"
              value={price}
              onChangeText={setPrice}
              placeholder="0 pour un troc"
              keyboardType="numeric"
              inputMode="numeric"
            />
            <Input
              label="Description"
              value={description}
              onChangeText={setDescription}
              placeholder="État, historique, petits défauts…"
              multiline
              hint="Sois honnête : ça fait grimper ton Karma."
            />
          </View>

          <View className="my-8 items-center">
            <Animated.View style={scanStyle}>
              <Pressable
                accessibilityRole="button"
                onPress={() => {
                  void openCamera();
                }}
                className={`h-36 w-36 items-center justify-center rounded-full ${
                  scanned ? 'bg-pacte-mint' : 'bg-pacte-orange'
                }`}
                style={{
                  shadowColor: '#FF8A00',
                  shadowOpacity: 0.35,
                  shadowRadius: 20,
                  shadowOffset: { width: 0, height: 10 },
                  elevation: 8,
                }}
              >
                <Text className="text-4xl">{scanned ? '✅' : '📸'}</Text>
                <Text className="mt-1 px-4 text-center text-xs font-bold text-white">
                  {scanned ? 'État scanné' : "Scanner l'état"}
                </Text>
              </Pressable>
            </Animated.View>

            {scanned && (
              <Card className="mt-5 w-full p-4">
                <Text className="text-sm font-bold text-pacte-dark">
                  🤖 Analyse IA de l’usure
                </Text>
                <Text className="mt-1 text-sm text-pacte-dark/60">
                  État estimé : <Text className="font-bold">{FAKE_SCAN.condition}</Text> —
                  indice de fraîcheur {FAKE_SCAN.score}/100.
                </Text>
                <Text className="mt-2 text-[11px] text-pacte-dark/35">
                  Estimation indicative, non contractuelle.
                </Text>
              </Card>
            )}
          </View>

          <Button
            label="Lancer la vente"
            icon="🤝"
            onPress={handlePublish}
            disabled={!canPublish}
          />
          {!canPublish && (
            <Text className="mt-3 text-center text-xs text-pacte-dark/40">
              Ajoute au moins un nom et une description.
            </Text>
          )}
        </ScrollView>
      </KeyboardAvoidingView>

      <Confetti trigger={confettiTrigger} />

      {/* Aperçu caméra — la capture arrivera avec le vrai scan IA. */}
      <Modal visible={cameraOpen} animationType="slide" onRequestClose={() => setCameraOpen(false)}>
        <View className="flex-1 bg-black">
          {permission?.granted === true ? (
            <CameraView style={{ flex: 1 }} facing="back" />
          ) : (
            <View className="flex-1 items-center justify-center p-8">
              <Text className="text-center text-white">
                Pacte a besoin de la caméra pour analyser l’usure de ton objet.
              </Text>
            </View>
          )}

          <View className="absolute bottom-0 left-0 right-0 gap-3 p-6 pb-10">
            <Text className="text-center text-sm text-white/70">
              Cadre l’objet en entier, lumière du jour de préférence.
            </Text>
            <Button
              label="Valider le scan"
              icon="✨"
              onPress={() => {
                setScanned(true);
                setCameraOpen(false);
              }}
            />
            <Button
              label="Fermer"
              variant="secondary"
              onPress={() => setCameraOpen(false)}
            />
          </View>
        </View>
      </Modal>

      {/* Confirmation de publication */}
      <Modal visible={published} transparent animationType="fade" onRequestClose={resetForm}>
        <View className="flex-1 items-center justify-center bg-black/40 px-8">
          <Card className="w-full items-center p-6">
            <Text className="text-5xl">🎉</Text>
            <Text className="mt-3 text-center text-xl font-extrabold text-pacte-dark">
              Pacte lancé !
            </Text>
            <Text className="mt-2 text-center text-sm text-pacte-dark/60">
              « {title.trim()} » est en vitrine. On te prévient dès qu’un voisin mord.
            </Text>
            <Button label="Super" icon="👌" onPress={resetForm} className="mt-6 w-full" />
          </Card>
        </View>
      </Modal>
    </SafeAreaView>
  );
}
