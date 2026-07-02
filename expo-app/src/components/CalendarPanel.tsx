import React from 'react';
import { Pressable, Text, View } from 'react-native';
import type { MoneyEntry } from '../types';
import { dateKey, firstWeekdayOffset, monthDates, monthLabel } from '../utils/date';
import { styles } from '../theme/styles';
import { IconButton, Panel } from './ui';

export function CalendarPanel({
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
        {blanks.map((_, index) => <View key={`blank-${index}`} style={styles.dayCell} />)}
        {days.map((date) => {
          const selected = dateKey(date) === dateKey(selectedDate);
          const hasEntry = entryDates.has(dateKey(date));
          return (
            <View key={dateKey(date)} style={styles.dayCell}>
              <Pressable style={[styles.dayButton, selected && styles.daySelected]} onPress={() => onSelectDate(date)}>
                <Text style={styles.dayText}>{date.getDate()}</Text>
                {hasEntry && !selected ? <View style={styles.dayDot} /> : null}
              </Pressable>
            </View>
          );
        })}
      </View>
    </Panel>
  );
}
