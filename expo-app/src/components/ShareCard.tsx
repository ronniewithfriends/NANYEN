import { LinearGradient } from 'expo-linear-gradient';
import React from 'react';
import { Text, View } from 'react-native';
import { shareHashtags } from '../constants';
import type { PaceResult } from '../types';
import { withAlpha } from '../utils/color';
import { styles } from '../theme/styles';
import { MetalLogo } from './ui';

export function ShareCard({ period, result }: { period: string; result: PaceResult }) {
  return (
    <LinearGradient colors={['#fff8dd', '#dcf8ff', '#ffc2e7']} style={styles.shareCard}>
      <View style={[styles.cardStripe, { backgroundColor: result.accent }]} />
      <Text style={[styles.comicMark, { color: withAlpha(result.accent, 0.28) }]}>{result.comicMark}</Text>
      <Text style={styles.sparkLeft}>✧</Text>
      <Text style={styles.sparkRight}>{result.spark}</Text>
      <View style={styles.reportTop}>
        <MetalLogo size={18} />
        <Text style={styles.periodText}>{period}</Text>
      </View>
      <View style={styles.reportMain}>
        <Text style={[styles.sticker, { color: result.accent }]}>{result.sticker}</Text>
        <Text style={styles.quote}>{result.quote}</Text>
        <Text style={styles.reportTitle}>{result.title}</Text>
        <Text style={[styles.reportNumber, { color: result.accent }]}>{result.number}</Text>
        <Text style={styles.reportCopy}>{result.copy}</Text>
      </View>
      <Text style={styles.hashText}>{shareHashtags}</Text>
    </LinearGradient>
  );
}
