import { overPaceLines, underPaceLines } from '../copy/paceLines';
import type { MoneyEntry, PaceResult } from '../types';

export function paceResult(spend: number, pace: number, seed: string): PaceResult {
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

export function spendForEntries(items: MoneyEntry[]) {
  return Math.max(0, -items.reduce((sum, item) => sum + item.amountYen, 0));
}

export function yenValue(text: string) {
  return Number(text.replace(/[^\d]/g, '')) || 0;
}

export function yen(value: number) {
  const sign = value > 0 ? '+' : value < 0 ? '-' : '';
  return `${sign}¥${Math.abs(Math.round(value)).toLocaleString('ja-JP')}`;
}
