import React from 'react';
import { Text, View } from 'react-native';
import type { MonthlyPlan } from '../types';
import { yen } from '../utils/money';
import { styles } from '../theme/styles';
import { Metric, MoneyField, Panel } from './ui';

export function MonthlyPlanPanel({
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
