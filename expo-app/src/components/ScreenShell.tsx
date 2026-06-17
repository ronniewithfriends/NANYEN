import React from 'react';
import { Text, View } from 'react-native';
import { styles } from '../theme/styles';
import { IconButton, MetalLogo } from './ui';

export function ScreenShell({ children, onClose, title }: { children: React.ReactNode; onClose: () => void; title: string }) {
  return (
    <View style={styles.mainStack}>
      <View style={styles.fullHeader}>
        <View>
          <MetalLogo size={30} />
          <Text style={styles.dateText}>{title}</Text>
        </View>
        <IconButton label="×" onPress={onClose} />
      </View>
      {children}
    </View>
  );
}
