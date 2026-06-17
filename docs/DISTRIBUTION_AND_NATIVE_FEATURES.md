# NANYEN 配信・ウィジェット・音声入力ロードマップ

このリポジトリは現在、`expo-app/` の Expo / React Native MVP を中心にした構成です。
ブラウザ確認はデザイン確認用で、App Store / Google Play 配信は EAS Build でネイティブアプリ化して進めます。

アカウント機能、広告収益化、スマートウォッチ対応まで含む長期計画は `docs/APP_GROWTH_PLAN.md` を参照してください。

## いま対応済み

- ブラウザプレビューのSNS共有ボタンを改善。
  - 画像共有APIが使える端末では、PNG画像付きの共有シートを開く。
  - 使えない端末では、PNG画像を保存してからSNS投稿ページを開く。
  - InstagramはWebから画像付き投稿を直接プリセットできないため、PNG保存後にInstagramを開く。
- Expoアプリ側は `react-native-view-shot` と `expo-sharing` でPNG共有する構成。

## iOS / App Store 配信に必要な作業

公式入口:
- App Store Connect のビルドアップロード: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/

1. Expo GoでMVPを実機確認する。
2. AsyncStorage / SQLiteなどで、記録がアプリ再起動後も残るようにする。
3. App Icon、Splash Screen、Bundle ID、権限文言を設定する。
4. EAS BuildでiOSビルドを作る。
5. App Store Connect / TestFlightへアップロードする。
6. スクリーンショット、説明文、プライバシー情報、年齢レーティングを登録する。
7. App Reviewへ提出する。

## Android / Google Play 配信に必要な作業

Androidは同じExpoアプリから `.aab` を作って提出します。

公式入口:
- Android App Bundle: https://developer.android.com/guide/app-bundle

1. Expo GoでAndroid実機確認する。
2. Android package、App Icon、Adaptive Icon、権限文言を設定する。
3. EAS BuildでAndroid App Bundle（`.aab`）を作る。
4. Google Play Consoleへアップロードする。
5. データセーフティ、年齢レーティング、スクリーンショットを登録する。

## スマホウィジェット

### iOS

- WidgetKit extension を追加する。
- 表示内容は「今日の残りペース」「今週のペース」「今日の一言」程度に絞る。
- App Group でアプリ本体とウィジェットが同じデータを読む。
- iOS 17+ の App Intents で、ウィジェットから定番金額をワンタップ記録できるようにする。

### Android

- Glance App Widget でホーム画面ウィジェットを作る。
- DataStore / Room などに保存したデータをウィジェットが読む。
- ワンタップ記録は PendingIntent 経由で実装する。

## スマートウォッチ

### Apple Watch

- watchOS app / WidgetKit complication を追加する。
- 表示は「今日のペース」「残り自由額」「記録ボタン」の最小構成。
- 音声入力は iPhone側の App Intent / Siri Shortcut と連携するのが現実的。

### Wear OS

- Wear OS Tile または Complication を追加する。
- Android本体アプリ側のデータと同期する。

## 音声入力

### iOS

- App Intents で「NANYENに500円を食事で記録」のようなショートカットを作る。
- Siriから呼び出して、金額・ジャンル・日付をパースする。
- 自然文パースはルールベースに限定する。
  - 例: `コンビニで500円くらい` → 金額 `500`、ジャンル `食事` または `日用品`

### Android

- Android SpeechRecognizer または Assistant連携を使う。
- ルールベースで金額・ジャンルを抽出する。

## 推奨順序

1. Expo Goでスマホ実機確認。
2. 記録の永続化を入れる。
3. PNG画像共有をiOS/Android実機で確認。
4. EAS Buildの開発ビルドを作る。
5. TestFlight / Google Play内部テストへ配信。
6. アカウント同期を設計する。
7. 広告はAdMobで導入する。
8. iOS/Androidウィジェット、音声入力、スマートウォッチ対応へ進む。

## 注意

- 銀行・カード・電子マネー連携は入れない。
- 金融データを外部送信しない。
- シェアカードには収入・貯蓄の絶対額を出さない。
- 共有ボタンはブラウザでは制限がある。ネイティブアプリではOS標準共有シートを使うのが最も確実。
