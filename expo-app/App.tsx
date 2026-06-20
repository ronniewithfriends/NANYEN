import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Clipboard from 'expo-clipboard';
import { LinearGradient } from 'expo-linear-gradient';
import * as Sharing from 'expo-sharing';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  Alert,
  Platform,
  Pressable,
  SafeAreaView,
  ScrollView,
  Share,
  Text,
  View,
} from 'react-native';
import { captureRef } from 'react-native-view-shot';

import { CalendarPanel } from './src/components/CalendarPanel';
import { EntryPanel } from './src/components/EntryPanel';
import { MonthlyPlanPanel } from './src/components/MonthlyPlanPanel';
import { ScreenShell } from './src/components/ScreenShell';
import { ShareCard } from './src/components/ShareCard';
import { ChoiceButton, IconButton, MetalLogo, Panel } from './src/components/ui';
import { shareHashtags } from './src/constants';
import { styles } from './src/theme/styles';
import type { Genre, MonthlyPlan, MoneyEntry, ShareRange } from './src/types';
import {
  addMonths,
  dateKey,
  daysInMonth,
  longDate,
  monthKey,
  shortDate,
  weekDateKeys,
  weekLabel,
} from './src/utils/date';
import { paceResult, spendForEntries, yen, yenValue } from './src/utils/money';

const today = new Date();

export default function App() {
  const [selectedDate, setSelectedDate] = useState(today);
  const [monthCursor, setMonthCursor] = useState(today);
  const [activeScreen, setActiveScreen] = useState<'main' | 'settings' | 'share'>('main');
  const [selectedGenre, setSelectedGenre] = useState<Genre>('日用品');
  const [amountText, setAmountText] = useState('');
  const [shareRange, setShareRange] = useState<ShareRange>('day');
  const [nextEntryId, setNextEntryId] = useState(1);
  const [plans, setPlans] = useState<Record<string, MonthlyPlan>>({});
  const [entries, setEntries] = useState<MoneyEntry[]>([]);
  const [loaded, setLoaded] = useState(false);
  const cardRef = useRef<View>(null);

  useEffect(() => {
    async function load() {
      try {
        const [entriesJson, plansJson, nextIdStr] = await Promise.all([
          AsyncStorage.getItem('nanyen_entries'),
          AsyncStorage.getItem('nanyen_plans'),
          AsyncStorage.getItem('nanyen_next_id'),
        ]);
        if (entriesJson) setEntries(JSON.parse(entriesJson));
        if (plansJson) setPlans(JSON.parse(plansJson));
        if (nextIdStr) setNextEntryId(Number(nextIdStr));
      } catch {
        // proceed without stored data if storage is unavailable
      }
      setLoaded(true);
    }
    load();
  }, []);

  useEffect(() => {
    if (!loaded) return;
    AsyncStorage.setItem('nanyen_entries', JSON.stringify(entries)).catch(() => {});
  }, [entries, loaded]);

  useEffect(() => {
    if (!loaded) return;
    AsyncStorage.setItem('nanyen_plans', JSON.stringify(plans)).catch(() => {});
  }, [plans, loaded]);

  useEffect(() => {
    if (!loaded) return;
    AsyncStorage.setItem('nanyen_next_id', String(nextEntryId)).catch(() => {});
  }, [nextEntryId, loaded]);

  const plan = plans[monthKey(selectedDate)] ?? { incomeYen: 260000, fixedCostYen: 150000 };
  const freeMonthly = plan.incomeYen - plan.fixedCostYen;
  const dailyPace = Math.max(0, freeMonthly) / daysInMonth(selectedDate);
  const weeklyPace = dailyPace * 7;

  const dayEntries = entries.filter((entry) => entry.dateKey === dateKey(selectedDate));
  const weekEntries = entries.filter((entry) => weekDateKeys(selectedDate).includes(entry.dateKey));
  const selectedDaySpend = spendForEntries(dayEntries);
  const selectedWeekSpend = spendForEntries(weekEntries);
  const selectedShareSpend = shareRange === 'day' ? selectedDaySpend : selectedWeekSpend;
  const selectedSharePace = shareRange === 'day' ? dailyPace : weeklyPace;
  const periodLabel = shareRange === 'day' ? shortDate(selectedDate) : weekLabel(selectedDate);
  const result = useMemo(
    () => paceResult(selectedShareSpend, selectedSharePace, `${periodLabel}-${shareRange}`),
    [periodLabel, selectedSharePace, selectedShareSpend, shareRange],
  );
  const shareText = `NANYEN ${periodLabel}\n${result.sticker}\n${result.quote}\n${result.number}\n${result.copy}\n${shareHashtags}`;

  function updatePlan(field: keyof MonthlyPlan, text: string) {
    const value = yenValue(text);
    setPlans((current) => ({
      ...current,
      [monthKey(selectedDate)]: {
        ...plan,
        [field]: value,
      },
    }));
  }

  function recordEntry() {
    const raw = yenValue(amountText);
    if (raw <= 0) return;
    const signed = selectedGenre === '収入' ? raw : -raw;
    setEntries((current) => [
      ...current,
      { id: nextEntryId, dateKey: dateKey(selectedDate), genre: selectedGenre, amountYen: signed },
    ]);
    setNextEntryId((value) => value + 1);
    setAmountText('');
  }

  async function shareImage(targetName: string) {
    try {
      if (!cardRef.current) return;
      await Clipboard.setStringAsync(shareText);
      if (Platform.OS === 'web') {
        await Share.share({ message: shareText });
        return;
      }
      const uri = await captureRef(cardRef, {
        format: 'png',
        quality: 1,
        result: 'tmpfile',
      });
      if (Platform.OS === 'ios') {
        await Share.share({
          title: 'NANYEN',
          message: shareText,
          url: uri,
        });
        return;
      }
      const available = await Sharing.isAvailableAsync();
      if (available) {
        await Sharing.shareAsync(uri, {
          dialogTitle: `${targetName}へNANYENカードを共有（本文コピー済み）`,
          mimeType: 'image/png',
          UTI: 'public.png',
        });
        return;
      }
      await Share.share({ message: shareText, url: uri });
    } catch {
      Alert.alert('共有できませんでした', 'もう一度試すか、スクリーンショットで保存してください。');
    }
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <LinearGradient colors={['#fff0fb', '#c7f8ff', '#ff9bd4']} style={styles.background}>
        <ScrollView contentContainerStyle={styles.page}>
          {activeScreen === 'settings' && (
            <ScreenShell title="設定" onClose={() => setActiveScreen('main')}>
              <MonthlyPlanPanel
                fixedCost={plan.fixedCostYen}
                freeMonthly={freeMonthly}
                income={plan.incomeYen}
                dailyPace={dailyPace}
                weeklyPace={weeklyPace}
                onChange={updatePlan}
              />
            </ScreenShell>
          )}

          {activeScreen === 'share' && (
            <ScreenShell title="結果をシェア" onClose={() => setActiveScreen('main')}>
              <Panel>
                <View style={styles.panelTitle}>
                  <Text style={styles.panelTitleText}>ビジュアルカード作成</Text>
                  <Text style={styles.smallNote}>{periodLabel}</Text>
                </View>
                <View style={styles.segmented}>
                  <ChoiceButton active={shareRange === 'day'} label="1日" onPress={() => setShareRange('day')} />
                  <ChoiceButton active={shareRange === 'week'} label="1週間" onPress={() => setShareRange('week')} />
                </View>
                <View ref={cardRef} collapsable={false}>
                  <ShareCard period={periodLabel} result={result} />
                </View>
                <View style={styles.shareGrid}>
                  {['X', 'Instagram', 'Threads', 'LINE'].map((name) => (
                    <Pressable key={name} style={styles.shareButton} onPress={() => shareImage(name)}>
                      <Text style={styles.shareButtonText}>{name}</Text>
                    </Pressable>
                  ))}
                </View>
                <Text style={styles.helperText}>画像と投稿本文を一緒に渡します。本文非対応のSNSでも、本文はコピー済みです。</Text>
              </Panel>
            </ScreenShell>
          )}

          {activeScreen === 'main' && (
            <View style={styles.mainStack}>
              <View style={styles.topBar}>
                <IconButton label="⚙" onPress={() => setActiveScreen('settings')} />
                <View style={styles.titleBox}>
                  <MetalLogo size={43} />
                  <Text style={styles.dateText}>{longDate(selectedDate)}</Text>
                </View>
              </View>

              <CalendarPanel
                cursor={monthCursor}
                entries={entries}
                selectedDate={selectedDate}
                onMoveMonth={(value) => setMonthCursor(addMonths(monthCursor, value))}
                onSelectDate={(date) => {
                  setSelectedDate(date);
                  setMonthCursor(date);
                }}
              />

              <EntryPanel
                amountText={amountText}
                genre={selectedGenre}
                onAmountChange={setAmountText}
                onGenreChange={setSelectedGenre}
                onRecord={recordEntry}
              />

              <Pressable style={styles.primaryButton} onPress={() => setActiveScreen('share')}>
                <Text style={styles.primaryButtonText}>結果をシェア！</Text>
              </Pressable>

              <Panel>
                <View style={styles.panelTitle}>
                  <Text style={styles.panelTitleText}>選んだ日の記録</Text>
                  <Text style={styles.smallNote}>{dayEntries.length}件</Text>
                </View>
                {dayEntries.length === 0 ? (
                  <View style={styles.entryRow}>
                    <Text style={styles.entryText}>まだ記録なし</Text>
                    <Text style={styles.entrySub}>ぼちぼちでOK</Text>
                  </View>
                ) : (
                  dayEntries.map((entry) => (
                    <View key={entry.id} style={styles.entryRow}>
                      <Text style={styles.entryText}>{entry.genre}</Text>
                      <Text style={[styles.entryAmount, entry.amountYen >= 0 ? styles.positive : styles.negative]}>
                        {yen(entry.amountYen)}
                      </Text>
                      <Pressable onPress={() => setEntries((current) => current.filter((item) => item.id !== entry.id))}>
                        <Text style={styles.deleteText}>取消</Text>
                      </Pressable>
                    </View>
                  ))
                )}
              </Panel>
            </View>
          )}
        </ScrollView>
      </LinearGradient>
    </SafeAreaView>
  );
}
