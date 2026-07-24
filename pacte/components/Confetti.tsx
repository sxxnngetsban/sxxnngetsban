import { useEffect } from 'react';
import { Dimensions, StyleSheet, Text, View } from 'react-native';
import Animated, {
  Easing,
  useAnimatedStyle,
  useSharedValue,
  withDelay,
  withTiming,
} from 'react-native-reanimated';

const SCREEN = Dimensions.get('window');
const PIECES = ['🎉', '🎊', '🤝', '✨', '🧡', '🎁'];
const COUNT = 18;

interface ConfettiPieceProps {
  index: number;
  /** Incrémenté à chaque déclenchement pour relancer l'animation. */
  trigger: number;
}

function ConfettiPiece({ index, trigger }: ConfettiPieceProps) {
  const translateY = useSharedValue(-60);
  const rotate = useSharedValue(0);
  const opacity = useSharedValue(0);

  // Positions pseudo-aléatoires mais stables pour un index donné.
  const left = ((index * 37) % 100) / 100;
  const delay = (index % 6) * 90;
  const duration = 1400 + ((index * 53) % 700);

  useEffect(() => {
    if (trigger === 0) return;

    translateY.value = -60;
    rotate.value = 0;
    opacity.value = 1;

    translateY.value = withDelay(
      delay,
      withTiming(SCREEN.height * 0.9, { duration, easing: Easing.out(Easing.quad) }),
    );
    rotate.value = withDelay(delay, withTiming(index % 2 === 0 ? 540 : -540, { duration }));
    opacity.value = withDelay(delay + duration - 300, withTiming(0, { duration: 300 }));
  }, [trigger, delay, duration, index, translateY, rotate, opacity]);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }, { rotate: `${rotate.value}deg` }],
  }));

  return (
    <Animated.View
      pointerEvents="none"
      style={[{ position: 'absolute', left: left * (SCREEN.width - 32), top: 0 }, animatedStyle]}
    >
      <Text style={{ fontSize: 22 }}>{PIECES[index % PIECES.length]}</Text>
    </Animated.View>
  );
}

/** Pluie de confettis déclenchée en incrémentant `trigger`. */
export function Confetti({ trigger }: { trigger: number }) {
  if (trigger === 0) return null;

  return (
    <View pointerEvents="none" style={StyleSheet.absoluteFill}>
      {Array.from({ length: COUNT }, (_, index) => (
        <ConfettiPiece key={`${trigger}-${index}`} index={index} trigger={trigger} />
      ))}
    </View>
  );
}
