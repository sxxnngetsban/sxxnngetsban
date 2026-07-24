import { LinearGradient } from 'expo-linear-gradient';
import { ActivityIndicator, Pressable, Text, View, type ViewStyle } from 'react-native';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
} from 'react-native-reanimated';

import { Colors, PRIMARY_GRADIENT } from '@/constants/colors';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost';

interface ButtonProps {
  label: string;
  onPress: () => void;
  variant?: ButtonVariant;
  disabled?: boolean;
  loading?: boolean;
  /** Emoji ou pictogramme affiché avant le libellé. */
  icon?: string;
  className?: string;
  style?: ViewStyle;
}

export function Button({
  label,
  onPress,
  variant = 'primary',
  disabled = false,
  loading = false,
  icon,
  className = '',
  style,
}: ButtonProps) {
  const scale = useSharedValue(1);
  const isDisabled = disabled || loading;

  // Le style animé vit sur un Animated.View sans `className` :
  // NativeWind reprend la main sur `style` dès qu'une classe est présente.
  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: isDisabled ? 0.45 : 1,
  }));

  const content = (
    <View className="h-14 flex-row items-center justify-center gap-2 px-6">
      {loading ? (
        <ActivityIndicator color={variant === 'primary' ? Colors.white : Colors.dark} />
      ) : (
        <>
          {icon !== undefined && <Text className="text-lg">{icon}</Text>}
          <Text
            className={
              variant === 'primary'
                ? 'text-base font-bold text-white'
                : variant === 'secondary'
                  ? 'text-base font-bold text-pacte-dark'
                  : 'text-base font-semibold text-pacte-dark/70'
            }
          >
            {label}
          </Text>
        </>
      )}
    </View>
  );

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ disabled: isDisabled, busy: loading }}
      disabled={isDisabled}
      onPress={onPress}
      onPressIn={() => {
        scale.value = withSpring(0.96, { damping: 14, stiffness: 260 });
      }}
      onPressOut={() => {
        scale.value = withSpring(1, { damping: 14, stiffness: 260 });
      }}
      style={style}
      className={className}
    >
      <Animated.View style={[animatedStyle, { borderRadius: 24, overflow: 'hidden' }]}>
        {variant === 'primary' ? (
          <LinearGradient
            colors={PRIMARY_GRADIENT}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
          >
            {content}
          </LinearGradient>
        ) : (
          <View
            className={
              variant === 'secondary'
                ? 'border-2 border-pacte-dark/10 bg-white'
                : 'bg-transparent'
            }
          >
            {content}
          </View>
        )}
      </Animated.View>
    </Pressable>
  );
}
