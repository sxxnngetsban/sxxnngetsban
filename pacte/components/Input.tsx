import { useState } from 'react';
import { Text, TextInput, View, type TextInputProps } from 'react-native';

import { Colors } from '@/constants/colors';

interface InputProps extends Omit<TextInputProps, 'className'> {
  label: string;
  /** Message d'erreur affiché sous le champ. */
  error?: string | null;
  hint?: string;
}

export function Input({ label, error = null, hint, ...rest }: InputProps) {
  const [focused, setFocused] = useState(false);

  const borderClass = error
    ? 'border-red-400'
    : focused
      ? 'border-pacte-orange'
      : 'border-black/5';

  return (
    <View className="w-full">
      <Text className="mb-2 ml-1 text-sm font-semibold text-pacte-dark/70">{label}</Text>
      <TextInput
        {...rest}
        onFocus={(event) => {
          setFocused(true);
          rest.onFocus?.(event);
        }}
        onBlur={(event) => {
          setFocused(false);
          rest.onBlur?.(event);
        }}
        placeholderTextColor={Colors.muted}
        className={`h-14 rounded-3xl border-2 bg-white px-5 text-base text-pacte-dark ${borderClass}`}
      />
      {error !== null && error.length > 0 ? (
        <Text className="ml-1 mt-1.5 text-xs font-medium text-red-500">{error}</Text>
      ) : hint !== undefined ? (
        <Text className="ml-1 mt-1.5 text-xs text-pacte-dark/40">{hint}</Text>
      ) : null}
    </View>
  );
}
