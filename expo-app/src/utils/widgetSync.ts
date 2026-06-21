import { clearPendingEntries, getPendingEntries } from '../../modules/widget-bridge';
import { genres } from '../constants';
import type { Genre, MoneyEntry } from '../types';

// Pulls entries recorded by the home-screen widget out of the shared App Group
// inbox, assigns app-side incremental ids starting at `startId`, and clears the
// inbox. Returns the new entries plus the next free id.
export async function pullWidgetEntries(
  startId: number,
): Promise<{ newEntries: MoneyEntry[]; nextId: number }> {
  const pending = await getPendingEntries();
  if (pending.length === 0) return { newEntries: [], nextId: startId };

  let id = startId;
  const newEntries: MoneyEntry[] = [];
  for (const item of pending) {
    const amountYen = typeof item.amountYen === 'number' ? item.amountYen : 0;
    if (amountYen === 0 || !item.dateKey) continue;
    const genre = (genres as string[]).includes(item.genre) ? (item.genre as Genre) : '食事';
    newEntries.push({ id, dateKey: item.dateKey, genre, amountYen });
    id += 1;
  }

  await clearPendingEntries();
  return { newEntries, nextId: id };
}
