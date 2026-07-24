import { LinearGradient } from 'expo-linear-gradient';
import { useEffect, useState } from 'react';
import { View, type LayoutChangeEvent } from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';

import { Colors } from '@/constants/colors';

interface ProgressBarProps {
  /** Progression entre 0 et 1. */
  value: number;
  color: string;
}

export function ProgressBar({ value, color }: ProgressBarProps) {
  // La largeur est mesurée puis animée en pixels : plus fiable qu'un pourcentage.
  const [trackWidth, setTrackWidth] = useState(0);
  const width = useSharedValue(0);

  useEffect(() => {
    const ratio = Math.min(Math.max(value, 0), 1);
    width.value = withTiming(trackWidth * ratio, { duration: 900 });
  }, [value, trackWidth, width]);

  const animatedStyle = useAnimatedStyle(() => ({ width: width.value }));

  function handleLayout(event: LayoutChangeEvent): void {
    setTrackWidth(event.nativeEvent.layout.width);
  }

  return (
    <View
      onLayout={handleLayout}
      className="h-3 w-full overflow-hidden rounded-full bg-pacte-dark/10"
    >
      {/* Pas de `className` ici : NativeWind écraserait le style animé. */}
      <Animated.View
        style={[animatedStyle, { height: '100%', borderRadius: 999, overflow: 'hidden' }]}
      >
        {/* Dégradé orange → couleur du palier : lisible quel que soit le palier. */}
        <LinearGradient
          colors={[Colors.orange, color]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
          style={{ flex: 1 }}
        />
      </Animated.View>
    </View>
  );
}
