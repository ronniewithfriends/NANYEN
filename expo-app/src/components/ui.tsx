import React from 'react';
import { Pressable, Text, TextInput, View } from 'react-native';
import { styles } from '../theme/styles';

export function Panel({ children }: { children: React.ReactNode }) {
  return <View style={styles.panel}>{children}</View>;
}

export function MoneyField({ label, onChangeText, value }: { label: string; onChangeText: (text: string) => void; value: string }) {
  return (
    <View style={styles.moneyField}>
      <Text style={styles.inputLabel}>{label}</Text>
      <View style={styles.moneyInputWrap}>
        <Text style={styles.moneyYen}>¥</Text>
        <TextInput keyboardType="number-pad" onChangeText={onChangeText} style={styles.moneyInput} value={value} />
      </View>
    </View>
  );
}

export function Metric({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.metric}>
      <Text style={styles.metricLabel}>{label}</Text>
      <Text style={styles.metricValue}>{value}</Text>
    </View>
  );
}

export function ChoiceButton({
  active,
  income = false,
  label,
  onPress,
}: {
  active: boolean;
  income?: boolean;
  label: string;
  onPress: () => void;
}) {
  return (
    <Pressable style={[styles.choiceButton, active && (income ? styles.choiceIncome : styles.choiceActive)]} onPress={onPress}>
      <Text style={styles.choiceText}>{label}</Text>
    </Pressable>
  );
}

export function IconButton({ label, onPress }: { label: string; onPress: () => void }) {
  return (
    <Pressable style={styles.iconButton} onPress={onPress}>
      <Text style={styles.iconButtonText}>{label}</Text>
    </Pressable>
  );
}

export function MetalLogo({ size }: { size: number }) {
  return (
    <Text
      style={[
        styles.logo,
        {
          fontSize: size,
          lineHeight: size * 1.03,
          textShadowOffset: { width: 2, height: 2 },
        },
      ]}
    >
      NANYEN
    </Text>
  );
}
