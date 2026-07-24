import { View, type ViewProps } from 'react-native';

interface CardProps extends ViewProps {
  className?: string;
}

/** Conteneur blanc, angles très arrondis et ombre légère. */
export function Card({ className = '', style, children, ...rest }: CardProps) {
  return (
    <View
      {...rest}
      style={[
        {
          shadowColor: '#1E293B',
          shadowOpacity: 0.08,
          shadowRadius: 16,
          shadowOffset: { width: 0, height: 6 },
          elevation: 3,
        },
        style,
      ]}
      className={`rounded-3xl bg-white ${className}`}
    >
      {children}
    </View>
  );
}
