# NANYEN アプリ化・ログイン・広告収益化 作業計画

このドキュメントは、現在のMVPを「配信できるアプリ」に育てるための実行順です。

## 方針

- 最短ルートは **iOS優先**。
- PCブラウザ版はデザイン確認とPNG生成確認用。
- iPhoneアプリ版を本番の画像共有・広告・ログインの中心にする。
- Apple Watchは記録と確認用。SNS共有や広告表示の主役にしない。
- Android / Wear OS は iOS版の体験が固まってから判断する。

## 重要な設計変更

現状の `AGENTS.md` / 仕様では、金融データを外部送信しない方針です。
アカウント機能と複数端末同期を入れる場合、記録データをクラウドに保存する必要があります。

そのため、同期を実装する前に以下を決める必要があります。

- クラウド同期を v2 スコープとして許可するか。
- 同期するデータを最小限にするか。
- 端末内のみで使うモードを残すか。
- プライバシーポリシーに、保存するデータ、利用目的、削除方法を書く。
- 銀行/カード/電子マネー連携は引き続き実装しない。

## 収益化

スマホアプリの広告は、Google AdSenseではなく **Google AdMob** を使う。
AdMobはアプリ内広告向けで、バナー、ネイティブ、リワード、インタースティシャルなどを扱える。

NANYENで最初に入れるなら、体験を壊しにくい順にする。

1. 月次/週次レポート下部の小さなバナー広告。
2. 設定画面下部のバナー広告。
3. 将来、無料版ではカード保存後に控えめな広告。

避けるもの:

- 金額入力直後の全画面広告。
- シェア直前に邪魔する広告。
- 記録を続ける気持ちを折る広告。

公式入口:
- Google AdMob: https://admob.google.com/home/

## フェーズ

### Phase 1: iOSアプリとして成立させる

目的: App Store / TestFlightへ出せる形にする。

- Xcodeの正式iOS Appプロジェクトを作る。
- 既存のSwiftUI MVP画面をアプリターゲットへ組み込む。
- `NANYENCore` を共有ロジックとして使う。
- App Icon / Launch Screen / Bundle ID を設定する。
- SwiftDataで月設定・記録・カード履歴を保存する。
- iOS実機でPNG画像共有シートを確認する。

### Phase 2: TestFlight配信

目的: 身内テストできる状態にする。

- Apple Developer Program登録を前提にする。
- App Store Connectにアプリを作成。
- Archiveしてビルドをアップロード。
- TestFlightで実機配布。
- スクリーンショット、説明文、プライバシー情報を準備する。

公式入口:
- App Store Connect ビルドアップロード: https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/

### Phase 3: ログインと同期

目的: PC、スマホ、スマートウォッチで同じユーザーとして使えるようにする。

候補:

- Firebase Authentication + Firestore
- Supabase Auth + Postgres

推奨初期案:

- iOS優先なら Firebase が楽。
- AdMobやAnalyticsとの連携も取りやすい。
- ただし金融データなので、同期する項目は最小限にする。

最初の同期対象:

- ユーザーID
- 月ごとの収入概算
- 月ごとの固定費概算
- 日別の入力記録
- カード生成履歴

同期しないもの:

- 銀行口座情報
- カード情報
- 金融機関ログイン情報
- 収入や貯蓄の絶対額を含む共有データ

### Phase 4: AdMob広告

目的: 収益化の最小実装。

- AdMobアカウントを作る。
- iOSアプリをAdMobに登録。
- テスト広告IDで実装。
- 本番広告IDへ切り替える。
- App Storeのプライバシー申告を更新する。

最初の広告位置:

- レポート画面下
- 設定画面下

### Phase 5: iOSウィジェット

目的: ホーム画面で確認・簡単記録できるようにする。

- WidgetKit extensionを追加。
- 表示内容:
  - 今日のペース
  - 今週のペース
  - 今日の一言
- App Groupで本体アプリとデータ共有。
- App Intentsでワンタップ記録。

### Phase 6: 音声入力

目的: 「コンビニ500円」などを声で記録する。

- App Intentsでショートカットを作る。
- Siriから金額とジャンルを受け取る。
- 自然文はルールベースで解析する。
- 例:
  - `コンビニ500円`
  - `食事1200円`
  - `収入3万円`

### Phase 7: Apple Watch

目的: 記録と確認に特化する。

- watchOS Appを追加。
- 今日のペースを表示。
- 音声または定番ボタンで記録。
- SNS共有はiPhone側へ誘導する。

### Phase 8: Android / Google Play

目的: Androidにも展開する。

選択肢:

- iOS版完成後にAndroidネイティブで作る。
- Flutter / React Nativeへ移植して両対応にする。

Google PlayではAndroid App Bundle（`.aab`）で提出する。

公式入口:
- Android App Bundle: https://developer.android.com/guide/app-bundle

## 直近の作業順

1. 現在のMVPを正式なiOSアプリプロジェクトへ移す。
2. SwiftData保存を入れる。
3. 実機で画像共有を確認する。
4. TestFlight配信準備。
5. ログイン/同期を入れるか最終決定する。
6. AdMobをテスト広告で入れる。
7. WidgetKit / App Intents / Apple Watchへ広げる。
