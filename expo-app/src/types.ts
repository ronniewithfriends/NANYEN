export type Genre = '日用品' | '食事' | '娯楽' | '仕事' | '収入';
export type ShareRange = 'day' | 'week';

export type MoneyEntry = {
  id: number;
  dateKey: string;
  genre: Genre;
  amountYen: number;
};

export type MonthlyPlan = {
  incomeYen: number;
  fixedCostYen: number;
};

export type PaceLine = {
  title: string;
  quote: string;
  copy: string;
  sticker: string;
  comicMark: string;
  spark: string;
};

export type PaceResult = PaceLine & {
  accent: string;
  number: string;
};
