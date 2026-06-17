import React from 'react';
import { Pressable, Text, TextInput, View } from 'react-native';
import { genres } from '../constants';
import type { Genre } from '../types';
import { styles } from '../theme/styles';
import { ChoiceButton, Panel } from './ui';

export function EntryPanel({
  amountText,
  genre,
  onAmountChange,
  onGenreChange,
  onRecord,
}: {
  amountText: string;
  genre: Genre;
  onAmountChange: (text: string) => void;
  onGenreChange: (genre: Genre) => void;
  onRecord: () => void;
}) {
  return (
    <Panel>
      <View style={styles.panelTitle}>
        <Text style={styles.panelTitleText}>今日の入力</Text>
      </View>
      <Text style={styles.inputLabel}>金額</Text>
      <View style={styles.amountBox}>
        <Text style={styles.yenMark}>¥</Text>
        <TextInput
          keyboardType="number-pad"
          onChangeText={onAmountChange}
          placeholder="0"
          style={styles.amountInput}
          value={amountText}
        />
      </View>
      <View style={styles.genreGrid}>
        {genres.map((item) => (
          <ChoiceButton key={item} active={genre === item} income={item === '収入'} label={item} onPress={() => onGenreChange(item)} />
        ))}
      </View>
      <Pressable style={styles.primaryButton} onPress={onRecord}>
        <Text style={styles.primaryButtonText}>記録する</Text>
      </Pressable>
    </Panel>
  );
}
