import { requireOptionalNativeModule } from 'expo-modules-core';

export type WidgetPendingEntry = {
  uuid: string;
  dateKey: string;
  genre: string;
  amountYen: number;
  createdAt: number;
};

// Optional: returns null on platforms/builds without the native module
// (web, Expo Go, Android), so the rest of the app degrades gracefully.
const WidgetBridge = requireOptionalNativeModule('WidgetBridge');

export async function getPendingEntries(): Promise<WidgetPendingEntry[]> {
  if (!WidgetBridge) return [];
  try {
    const json: string = await WidgetBridge.getPendingEntries();
    const parsed = JSON.parse(json);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

export async function clearPendingEntries(): Promise<void> {
  if (!WidgetBridge) return;
  try {
    await WidgetBridge.clearPendingEntries();
  } catch {
    // ignore
  }
}
