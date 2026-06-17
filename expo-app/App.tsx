import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { useEffect, useMemo, useRef, useState } from 'react';
import {
  Alert,
  Modal,
  Platform,
  Pressable,
  SafeAreaView,
  ScrollView,
  Share,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import * as Clipboard from 'expo-clipboard';
import { LinearGradient } from 'expo-linear-gradient';
import * as Sharing from 'expo-sharing';
import { captureRef } from 'react-native-view-shot';

type Genre = '日用品' | '食事' | '娯楽' | '仕事' | '収入';
type ShareRange = 'day' | 'week';

type MoneyEntry = {
  id: number;
  dateKey: string;
  genre: Genre;
  amountYen: number;
};

type MonthlyPlan = {
  incomeYen: number;
  fixedCostYen: number;
};

type PaceLine = {
  title: string;
  quote: string;
  copy: string;
  sticker: string;
  comicMark: string;
  spark: string;
};

type PaceResult = PaceLine & {
  accent: string;
  number: string;
};

const genres: Genre[] = ['日用品', '食事', '娯楽', '仕事', '収入'];
const shareHashtags = '#NANYEN #今日の何円 #今週の何円';

const underPaceLines: PaceLine[] = [
  { title: 'ペースより軽め', quote: '財布、今日だけ羽生えてる', copy: 'この余裕、ちょっと映画の主人公っぽい。', sticker: '軽やか判定', comicMark: '♡', spark: 'キラ' },
  { title: 'いい感じに低空飛行', quote: 'お金の減り方、上品', copy: '派手じゃないけど強い。こういう日があとで効く。', sticker: '余裕あり', comicMark: '♪', spark: 'nice' },
  { title: '予算と仲良し', quote: '今日は財布と握手できる', copy: 'ちゃんと残ってる。財布もたぶん拍手してる。', sticker: '平和', comicMark: '◎', spark: 'ぱち' },
  { title: 'だいたい勝ち', quote: '出費、ちゃんと小走り', copy: '暴走してない。えらいというより、地味に強い。', sticker: '小走り支出', comicMark: '☆', spark: 'ok' },
  { title: 'かなり穏やか', quote: '財布が深呼吸してる', copy: '今日の支出、温度でいうとぬるめ。かなり助かる。', sticker: 'すやすや財布', comicMark: '〜', spark: 'ほっ' },
  { title: 'ペース守れてる', quote: '未来の自分が少し笑った', copy: 'あとで効くやつ。地味だけど、こういうの好き。', sticker: '未来加点', comicMark: '＋', spark: 'ふふ' },
  { title: '余白あり', quote: '財布にまだ余白がある', copy: '余白って大事。予定外のアイスも理論上いける。', sticker: '余白発見', comicMark: '□', spark: '余' },
  { title: '今日は堅実', quote: '支出がちゃんと整列してる', copy: '並び方がきれい。家計の体育委員みたいな日。', sticker: '整列中', comicMark: '!!', spark: 'ピシ' },
  { title: 'いい守備', quote: '財布の守備範囲、広め', copy: '攻めすぎず守れてる。今日は守備職人。', sticker: '守備成功', comicMark: '◇', spark: '守' },
  { title: 'レア勝ち', quote: '財布、今日だけドヤ顔', copy: 'これは10回に1回のてへぺろ勝ち。調子のってOK。', sticker: 'てへぺろ勝ち', comicMark: '♡', spark: 'てへ' },
];

const overPaceLines: PaceLine[] = [
  { title: 'ペースより多め', quote: '財布、ちょっと叫んでた', copy: 'でも記録した。そこが今日のちゃんとした部分。', sticker: 'まあヨシ案件', comicMark: '?!', spark: 'わっ' },
  { title: '勢いあり', quote: '支出、今日は前のめり', copy: '前のめりな日もある。問題は気づけたこと。', sticker: '前のめり', comicMark: '!!', spark: 'どん' },
  { title: 'ちょい派手', quote: '財布にスポットライト当たった', copy: '目立つ日だった。次の一手でちゃんと戻せる。', sticker: '派手め', comicMark: '★', spark: 'ギラ' },
  { title: '予算より元気', quote: '支出のテンション高め', copy: '今日はお金がライブ会場にいた。記録はできた。', sticker: 'テンション高', comicMark: '♪', spark: 'wow' },
  { title: 'すこし暴れた', quote: '財布が一瞬だけ遠い目', copy: '遠い目の日もある。見なかったことにはしてない。', sticker: '遠い目', comicMark: '...', spark: 'しー' },
  { title: '多めの日', quote: 'レシートが急に主張してきた', copy: '主張強め。でも記録したから、ちゃんと回収済み。', sticker: '回収済み', comicMark: '↗', spark: '回収' },
  { title: '今日は攻めた', quote: '財布、攻めの姿勢', copy: '攻めた日は守りに戻れる。まずは現状把握。', sticker: '攻めの日', comicMark: '▲', spark: '攻' },
  { title: 'ちょいオーバー', quote: 'お金、少し早歩き', copy: '走ってはいない。早歩き。まだ会話できる。', sticker: '早歩き支出', comicMark: '≡', spark: '速' },
  { title: 'にぎやか会計', quote: '財布の中で祭り開催', copy: '祭りの後に記録できる人、だいぶ強い。', sticker: '祭り後', comicMark: '＊', spark: '祭' },
  { title: 'レア自虐', quote: '財布、今日は照れてる', copy: '10回に1回のてへぺろ回。笑って次いこ。', sticker: 'てへぺろ回', comicMark: '?!', spark: 'てへ' },
];

const today = new Date();

export default function App() {
  const [selectedDate, setSelectedDate] = useState(today);
  const [monthCursor, setMonthCursor] = useState(today);
  const [activeScreen, setActiveScreen] = useState<'main' | 'settings' | 'share'>('main');
  const [selectedGenre, setSelectedGenre] = useState<Genre>('日用品');
  const [amountText, setAmountText] = useState('1200');
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

function ScreenShell({ children, onClose, title }: { children: React.ReactNode; onClose: () => void; title: string }) {
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

function MonthlyPlanPanel({
  dailyPace,
  fixedCost,
  freeMonthly,
  income,
  onChange,
  weeklyPace,
}: {
  dailyPace: number;
  fixedCost: number;
  freeMonthly: number;
  income: number;
  onChange: (field: keyof MonthlyPlan, text: string) => void;
  weeklyPace: number;
}) {
  return (
    <Panel>
      <View style={styles.panelTitle}>
        <Text style={styles.panelTitleText}>月のだいたい設定</Text>
        <Text style={styles.smallNote}>この月の設定</Text>
      </View>
      <View style={styles.moneyFields}>
        <MoneyField label="月の収入" value={String(income)} onChangeText={(text) => onChange('incomeYen', text)} />
        <MoneyField label="月の固定費" value={String(fixedCost)} onChangeText={(text) => onChange('fixedCostYen', text)} />
      </View>
      <View style={styles.metrics}>
        <Metric label="自由に使える" value={yen(freeMonthly)} />
        <Metric label="1日ペース" value={yen(Math.round(dailyPace))} />
        <Metric label="1週間ペース" value={yen(Math.round(weeklyPace))} />
      </View>
    </Panel>
  );
}

function EntryPanel({
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

function CalendarPanel({
  cursor,
  entries,
  onMoveMonth,
  onSelectDate,
  selectedDate,
}: {
  cursor: Date;
  entries: MoneyEntry[];
  onMoveMonth: (value: number) => void;
  onSelectDate: (date: Date) => void;
  selectedDate: Date;
}) {
  const entryDates = new Set(entries.map((entry) => entry.dateKey));
  const days = monthDates(cursor);
  const blanks = Array.from({ length: firstWeekdayOffset(cursor) });

  return (
    <Panel>
      <View style={styles.panelTitle}>
        <Text style={styles.panelTitleText}>日付を選ぶ</Text>
        <Text style={styles.smallNote}>過去の日付にも記録できます</Text>
      </View>
      <View style={styles.monthNav}>
        <IconButton label="‹" onPress={() => onMoveMonth(-1)} />
        <Text style={styles.monthLabel}>{monthLabel(cursor)}</Text>
        <IconButton label="›" onPress={() => onMoveMonth(1)} />
      </View>
      <View style={styles.calendarGrid}>
        {['日', '月', '火', '水', '木', '金', '土'].map((day) => (
          <Text key={day} style={styles.dow}>{day}</Text>
        ))}
        {blanks.map((_, index) => <View key={`blank-${index}`} style={styles.dayBlank} />)}
        {days.map((date) => {
          const selected = dateKey(date) === dateKey(selectedDate);
          const hasEntry = entryDates.has(dateKey(date));
          return (
            <Pressable key={dateKey(date)} style={[styles.dayButton, selected && styles.daySelected]} onPress={() => onSelectDate(date)}>
              <Text style={styles.dayText}>{date.getDate()}</Text>
              {hasEntry && !selected ? <View style={styles.dayDot} /> : null}
            </Pressable>
          );
        })}
      </View>
    </Panel>
  );
}

function ShareCard({ period, result }: { period: string; result: PaceResult }) {
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

function Panel({ children }: { children: React.ReactNode }) {
  return <View style={styles.panel}>{children}</View>;
}

function MoneyField({ label, onChangeText, value }: { label: string; onChangeText: (text: string) => void; value: string }) {
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

function Metric({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.metric}>
      <Text style={styles.metricLabel}>{label}</Text>
      <Text style={styles.metricValue}>{value}</Text>
    </View>
  );
}

function ChoiceButton({
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

function IconButton({ label, onPress }: { label: string; onPress: () => void }) {
  return (
    <Pressable style={styles.iconButton} onPress={onPress}>
      <Text style={styles.iconButtonText}>{label}</Text>
    </Pressable>
  );
}

function MetalLogo({ size }: { size: number }) {
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

function paceResult(spend: number, pace: number, seed: string): PaceResult {
  const diff = Math.round(pace) - spend;
  if (diff >= 0) {
    const line = underPaceLines[variantIndex(spend, pace, seed, underPaceLines.length)];
    return { ...line, accent: '#129455', number: `${yen(diff)} 余裕` };
  }
  const line = overPaceLines[variantIndex(spend, pace, seed, overPaceLines.length)];
  return { ...line, accent: '#ea5048', number: `${yen(Math.abs(diff))} 多め` };
}

function variantIndex(spend: number, pace: number, seed: string, count: number) {
  const seedValue = Array.from(seed).reduce((sum, char) => sum + (char.codePointAt(0) ?? 0), 0);
  return Math.abs(spend * 31 + Math.round(pace) * 17 + seedValue) % count;
}

function spendForEntries(items: MoneyEntry[]) {
  return Math.max(0, -items.reduce((sum, item) => sum + item.amountYen, 0));
}

function yenValue(text: string) {
  return Number(text.replace(/[^\d]/g, '')) || 0;
}

function yen(value: number) {
  const sign = value > 0 ? '+' : value < 0 ? '-' : '';
  return `${sign}¥${Math.abs(Math.round(value)).toLocaleString('ja-JP')}`;
}

function dateKey(date: Date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function monthKey(date: Date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  return `${year}-${month}`;
}

function longDate(date: Date) {
  return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
}

function shortDate(date: Date) {
  return `${date.getMonth() + 1}/${date.getDate()}`;
}

function monthLabel(date: Date) {
  return `${date.getFullYear()}年${date.getMonth() + 1}月`;
}

function daysInMonth(date: Date) {
  return new Date(date.getFullYear(), date.getMonth() + 1, 0).getDate();
}

function monthDates(date: Date) {
  return Array.from({ length: daysInMonth(date) }, (_, index) => new Date(date.getFullYear(), date.getMonth(), index + 1));
}

function firstWeekdayOffset(date: Date) {
  return new Date(date.getFullYear(), date.getMonth(), 1).getDay();
}

function addMonths(date: Date, value: number) {
  return new Date(date.getFullYear(), date.getMonth() + value, 1);
}

function startOfWeek(date: Date) {
  const start = new Date(date);
  start.setDate(date.getDate() - date.getDay());
  start.setHours(0, 0, 0, 0);
  return start;
}

function weekDateKeys(date: Date) {
  const start = startOfWeek(date);
  return Array.from({ length: 7 }, (_, index) => {
    const item = new Date(start);
    item.setDate(start.getDate() + index);
    return dateKey(item);
  });
}

function weekLabel(date: Date) {
  const start = startOfWeek(date);
  const end = new Date(start);
  end.setDate(start.getDate() + 6);
  return `${shortDate(start)}-${shortDate(end)}`;
}

function withAlpha(hex: string, alpha: number) {
  const value = hex.replace('#', '');
  const r = parseInt(value.slice(0, 2), 16);
  const g = parseInt(value.slice(2, 4), 16);
  const b = parseInt(value.slice(4, 6), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: '#fff0fb',
  },
  background: {
    flex: 1,
  },
  page: {
    width: '100%',
    maxWidth: 620,
    alignSelf: 'center',
    padding: 20,
    paddingBottom: 48,
    gap: 14,
  },
  mainStack: {
    gap: 14,
  },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  fullHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 12,
  },
  titleBox: {
    flex: 1,
  },
  logo: {
    color: '#dfe8f4',
    fontWeight: '900',
    letterSpacing: 2,
    textShadowColor: '#35124d',
    textShadowRadius: 0,
  },
  dateText: {
    color: '#6e7887',
    fontSize: 15,
    fontWeight: '900',
    textShadowColor: '#ffffff',
    textShadowOffset: { width: 0, height: -1 },
    textShadowRadius: 1,
  },
  iconButton: {
    width: 48,
    height: 48,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.9)',
    borderWidth: 1,
    borderColor: 'rgba(0,0,0,0.08)',
  },
  iconButtonText: {
    color: '#657180',
    fontSize: 24,
    fontWeight: '900',
  },
  panel: {
    padding: 14,
    gap: 12,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.88)',
    borderWidth: 1,
    borderColor: 'rgba(36,242,255,0.28)',
  },
  panelTitle: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    gap: 10,
  },
  panelTitleText: {
    color: '#25232a',
    fontSize: 15,
    fontWeight: '900',
  },
  smallNote: {
    color: '#6e7887',
    fontSize: 12,
    fontWeight: '900',
  },
  moneyFields: {
    flexDirection: 'row',
    gap: 10,
  },
  moneyField: {
    flex: 1,
    gap: 8,
  },
  inputLabel: {
    color: '#6e7887',
    fontSize: 13,
    fontWeight: '900',
  },
  moneyInputWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    height: 50,
    paddingHorizontal: 12,
    borderRadius: 10,
    backgroundColor: '#fff8e6',
  },
  moneyYen: {
    fontSize: 18,
    fontWeight: '900',
  },
  moneyInput: {
    flex: 1,
    color: '#25232a',
    fontSize: 20,
    fontWeight: '900',
  },
  metrics: {
    flexDirection: 'row',
    gap: 8,
  },
  metric: {
    flex: 1,
    padding: 10,
    gap: 4,
    borderRadius: 10,
    backgroundColor: '#ffffff',
  },
  metricLabel: {
    color: '#6e7887',
    fontSize: 11,
    fontWeight: '900',
  },
  metricValue: {
    color: '#25232a',
    fontSize: 14,
    fontWeight: '900',
  },
  amountBox: {
    height: 78,
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 14,
    borderRadius: 12,
    backgroundColor: '#fff8e6',
  },
  yenMark: {
    fontSize: 26,
    fontWeight: '900',
  },
  amountInput: {
    flex: 1,
    color: '#25232a',
    textAlign: 'center',
    fontSize: 46,
    fontWeight: '900',
  },
  genreGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  choiceButton: {
    flexGrow: 1,
    minWidth: 78,
    height: 44,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(36,242,255,0.22)',
    backgroundColor: 'rgba(255,255,255,0.94)',
  },
  choiceActive: {
    borderColor: 'rgba(255,41,148,0.58)',
    backgroundColor: 'rgba(255,41,148,0.13)',
  },
  choiceIncome: {
    borderColor: 'rgba(18,148,85,0.72)',
    backgroundColor: 'rgba(18,148,85,0.16)',
  },
  choiceText: {
    color: '#657180',
    fontSize: 13,
    fontWeight: '900',
  },
  primaryButton: {
    minHeight: 48,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderColor: 'rgba(255,255,255,0.86)',
  },
  primaryButtonText: {
    color: '#657180',
    fontSize: 16,
    fontWeight: '900',
  },
  monthNav: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  monthLabel: {
    flex: 1,
    color: '#25232a',
    textAlign: 'center',
    fontSize: 15,
    fontWeight: '900',
  },
  calendarGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 5,
  },
  dow: {
    width: '13.4%',
    color: '#6e7887',
    textAlign: 'center',
    fontSize: 11,
    fontWeight: '900',
  },
  dayBlank: {
    width: '13.4%',
    height: 38,
  },
  dayButton: {
    width: '13.4%',
    height: 38,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 10,
    backgroundColor: 'rgba(255,255,255,0.92)',
  },
  daySelected: {
    backgroundColor: 'rgba(36,242,255,0.34)',
  },
  dayText: {
    color: '#657180',
    fontSize: 13,
    fontWeight: '900',
  },
  dayDot: {
    position: 'absolute',
    bottom: 0,
    width: '100%',
    height: 4,
    borderBottomLeftRadius: 10,
    borderBottomRightRadius: 10,
    backgroundColor: '#efb33d',
  },
  entryRow: {
    minHeight: 40,
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    paddingHorizontal: 10,
    borderRadius: 10,
    backgroundColor: '#ffffff',
  },
  entryText: {
    flex: 1,
    color: '#25232a',
    fontSize: 13,
    fontWeight: '900',
  },
  entrySub: {
    color: '#6e7887',
    fontSize: 11,
    fontWeight: '900',
  },
  entryAmount: {
    fontSize: 13,
    fontWeight: '900',
  },
  positive: {
    color: '#129455',
  },
  negative: {
    color: '#ea5048',
  },
  deleteText: {
    color: '#ea5048',
    fontSize: 12,
    fontWeight: '900',
  },
  segmented: {
    flexDirection: 'row',
    gap: 8,
  },
  shareCard: {
    aspectRatio: 1,
    overflow: 'hidden',
    position: 'relative',
    justifyContent: 'space-between',
    padding: 18,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: 'rgba(0,0,0,0.1)',
  },
  cardStripe: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 9,
  },
  comicMark: {
    position: 'absolute',
    top: 42,
    right: 22,
    fontSize: 64,
    fontWeight: '900',
    transform: [{ rotate: '-12deg' }],
  },
  sparkLeft: {
    position: 'absolute',
    bottom: 48,
    left: 24,
    color: 'rgba(255,41,148,0.28)',
    fontSize: 42,
    fontWeight: '900',
    transform: [{ rotate: '14deg' }],
  },
  sparkRight: {
    position: 'absolute',
    right: 28,
    bottom: 92,
    color: 'rgba(36,242,255,0.48)',
    fontSize: 22,
    fontWeight: '900',
    transform: [{ rotate: '8deg' }],
  },
  reportTop: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  periodText: {
    color: '#6e7887',
    fontSize: 12,
    fontWeight: '900',
  },
  reportMain: {
    gap: 9,
  },
  sticker: {
    alignSelf: 'flex-start',
    overflow: 'hidden',
    paddingHorizontal: 10,
    paddingVertical: 6,
    borderRadius: 999,
    backgroundColor: 'rgba(255,255,255,0.72)',
    fontSize: 13,
    fontWeight: '900',
  },
  quote: {
    color: '#6f7a89',
    fontSize: 36,
    fontWeight: '900',
    lineHeight: 38,
    textShadowColor: '#ffffff',
    textShadowOffset: { width: 0, height: -1 },
    textShadowRadius: 1,
  },
  reportTitle: {
    color: '#657180',
    fontSize: 19,
    fontWeight: '900',
  },
  reportNumber: {
    fontSize: 30,
    fontWeight: '900',
  },
  reportCopy: {
    color: 'rgba(31,31,29,0.72)',
    fontSize: 13,
    fontWeight: '900',
    lineHeight: 18,
  },
  hashText: {
    color: 'rgba(31,31,29,0.66)',
    fontSize: 12,
    fontWeight: '900',
  },
  shareGrid: {
    flexDirection: 'row',
    gap: 8,
  },
  shareButton: {
    flex: 1,
    minHeight: 42,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 12,
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderColor: 'rgba(0,0,0,0.08)',
  },
  shareButtonText: {
    color: '#657180',
    fontSize: 12,
    fontWeight: '900',
  },
  helperText: {
    color: '#6e7887',
    textAlign: 'center',
    fontSize: 12,
    fontWeight: '800',
  },
});
