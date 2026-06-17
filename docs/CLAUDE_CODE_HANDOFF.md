# CLAUDE CODE HANDOFF - NANYEN

Last updated: 2026-06-17

## 1. Project Summary

NANYEN is a rough household-money tracking and share-card app.
The product is not a strict ledger. It is a lightweight "how much did I spend?" app that turns daily or weekly money pace into a humorous visual card for SNS.

Core principle:

> Rough records that continue and get shared are better than precise records that users abandon.

Current active implementation:

- Expo / React Native / TypeScript
- Active app path: `expo-app/`
- Main screen: `expo-app/App.tsx`
- iPhone testing currently works through Expo Go
- Expo SDK is pinned to SDK 54 because the user's iPhone has Expo Go 54.0.6

Historical prototypes:

- `Sources/`
- `Package.swift`
- `NANYEN.xcodeproj/`
- These Swift/SwiftUI files are historical prototypes unless the user explicitly switches back.

## 2. Current Product Behavior

Implemented in `expo-app/App.tsx`:

- User sets rough monthly income and fixed costs.
- App calculates:
  - monthly free money
  - daily spending pace
  - weekly spending pace
- User records daily money entries.
- Genres:
  - `日用品`
  - `食事`
  - `娯楽`
  - `仕事`
  - `収入`
- Expense genres are recorded as negative amounts.
- `収入` is recorded as a positive amount.
- User can select dates from a calendar.
- Past dates can be selected and recorded.
- Existing entries can be cancelled/deleted.
- Settings screen is hidden by default and opened from the gear button.
- Share-card screen is hidden by default and opened from `結果をシェア！`.
- Settings and share-card screens have an `×` close button and replace the main entry screen while open.

## 3. Visual Direction

Current UI direction:

- Bright 80s-inspired color atmosphere.
- Metallic-ish NANYEN logo.
- Soft playful controls, not rigid finance-app styling.
- Mascot selection concept was removed.
- User's hand-drawn characters are not currently used in the active Expo MVP.
- Share cards use large humorous copy and small comic-like symbols.
- Tone should be funny, friendly, and non-judgmental.

Do not add blaming or shaming copy.
Do not use language like "使いすぎ", "サボった", "ダメ", "すべき".

## 4. Share Card Behavior

The share card can be generated for:

- 1 day
- 1 week

The card is rendered as a square visual card.

Current share flow:

- `react-native-view-shot` captures the visual card as PNG.
- On iOS, React Native `Share.share()` receives:
  - `url`: captured PNG file URI
  - `message`: text template with hashtags
  - `title`: `NANYEN`
- `expo-clipboard` also copies the share text automatically as a fallback.
- This is necessary because some SNS apps ignore shared text when receiving an image.

Required hashtags:

```text
#NANYEN #今日の何円 #今週の何円
```

Current share text format:

```text
NANYEN {period}
{sticker}
{quote}
{number}
{copy}
#NANYEN #今日の何円 #今週の何円
```

Important iOS limitation:

- iOS does not allow this app to force-paste text into another app's post composer.
- Some SNS apps accept the message automatically.
- Some SNS apps, especially Instagram-like flows, may ignore the message.
- The fallback is automatic clipboard copy.

Important Expo Go limitation:

- Specific SNS buttons cannot reliably open a specific SNS image composer directly in Expo Go.
- Image sharing through the iOS share sheet is the most stable path.
- Direct app-specific deep links may be possible later in a native dev build, but image attachment support differs by SNS.

## 5. Copy System

Copy lives directly in `expo-app/App.tsx` for the current MVP:

- `underPaceLines`
- `overPaceLines`

There are 10 under-pace and 10 over-pace variants.
Rare "てへ/てへぺろ" language is intentionally limited to about 1 in 10 variants per state.

Future refactor:

- Move copy arrays into `expo-app/src/copy/` or similar.
- Keep copy template-based, not AI-generated.

## 6. Guardrails

Keep these constraints:

- Do not implement bank, card, e-money, brokerage, or account aggregation.
- Do not handle or store financial-service credentials.
- Do not send financial data to external services without an explicit product decision.
- Do not use ML/LLM for forecasts, framing, or copy in v1.
- Do not expose income or savings absolute amounts in share-card output.
- Do not let users configure arbitrary shared card data fields.
- Do not add many settings/toggles.
- Do not punish absence or missed days.
- Keep card format unified for shareability.

## 7. Current Expo Setup

Path:

```bash
/Users/yutanakano/Documents/Codex/2026-06-11/claude-codex-codex-agents-md-codex/expo-app
```

Important package versions:

```json
{
  "expo": "~54.0.0",
  "react": "19.1.0",
  "react-native": "0.81.5",
  "expo-clipboard": "~8.0.8",
  "expo-linear-gradient": "~15.0.8",
  "expo-sharing": "~14.0.8",
  "react-native-view-shot": "4.0.3",
  "@expo/ngrok": "^4.1.3"
}
```

Why SDK 54:

- User's iPhone Expo Go version is `54.0.6`.
- The project was initially on Expo SDK 56 and Expo Go showed:

```text
Project is incompatible with this version of Expo Go
```

- Project was downgraded to Expo SDK 54 to match the phone.

## 8. Commands

Install dependencies:

```bash
cd /Users/yutanakano/Documents/Codex/2026-06-11/claude-codex-codex-agents-md-codex/expo-app
npm install
```

Run type check:

```bash
npm run typecheck
```

Run normal LAN Expo server:

```bash
npm start
```

Run tunnel mode when iPhone cannot connect to the local server:

```bash
npm run tunnel
```

Open web preview:

```bash
npm run web
```

Export web build:

```bash
npx expo export --platform web
```

## 9. Known Issues and Fix History

### Missing assets directory

Earlier error:

```text
ENOENT: no such file or directory, scandir .../expo-app/assets/images
```

Fix:

- Added `expo-app/assets/images/.gitkeep`

### Expo Go incompatibility

Earlier phone error:

```text
Project is incompatible with this version of Expo Go
```

Fix:

- Downgraded project from Expo SDK 56 to SDK 54.

### Could not connect to server

Earlier phone error:

```text
Could not connect to the server
```

Cause:

- iPhone could not reach Mac's LAN Expo server.

Fix:

- Added `npm run tunnel`.
- Added project-local `@expo/ngrok`.

### Repeating ngrok install request

Earlier loop:

```text
The package @expo/ngrok@^4.1.0 is required...
CommandError: Install @expo/ngrok@^4.1.0 and try again
```

Fix:

- Installed `@expo/ngrok` in the project devDependencies.
- Removed fixed port from the `tunnel` script.

Current script:

```json
"tunnel": "expo start --tunnel"
```

### iOS share text

User requested no manual paste.

Current best effort:

- iOS `Share.share()` now passes image URL and message together.
- `expo-clipboard` copies the message as fallback.

Remaining limitation:

- iOS/SNS apps may ignore shared text when an image is attached.
- The app cannot force-paste into another app.

## 10. Current Verification

Last successful verification:

```bash
cd expo-app
npm run typecheck
```

Result:

```text
tsc --noEmit
```

completed successfully.

Web export was also successfully run after the SDK 54 migration:

```bash
npx expo export --platform web
```

## 11. GitHub Backup Instructions

Current folder is not yet a Git repository.

From repo root:

```bash
cd /Users/yutanakano/Documents/Codex/2026-06-11/claude-codex-codex-agents-md-codex
git init
git add .
git commit -m "feat: create NANYEN Expo MVP"
```

Then create an empty GitHub repository, for example `nanyen`, and connect it:

```bash
git branch -M main
git remote add origin https://github.com/YOUR_USER_NAME/nanyen.git
git push -u origin main
```

Important:

- `.gitignore` excludes `expo-app/node_modules/`, `expo-app/dist/`, and `expo-app/.expo/`.
- Do not commit `node_modules`.

If GitHub authentication fails, use GitHub Desktop or GitHub CLI.

## 12. Recommended Next Tasks

Do these in order:

1. Add persistence.
   - Current entries/settings are in React state and reset when the app restarts.
   - Suggested Expo MVP option: `AsyncStorage`.
2. Split `App.tsx`.
   - Move copy, date utilities, card view, settings screen, and entry screen into separate files.
3. Improve real-device share UX.
   - Keep iOS share sheet as default.
   - Add clearer text explaining that the caption is copied if the SNS does not receive it.
4. Add app icon and splash screen.
5. Add EAS setup for TestFlight/internal testing.
6. Later:
   - account login
   - cloud sync
   - AdMob
   - iOS/Android widgets
   - voice input
   - watch companion

## 13. What Not To Do Next

Avoid these until the MVP is stable:

- Do not add bank/card linking.
- Do not build a complex account system before local persistence.
- Do not add many customization settings for share cards.
- Do not reintroduce mascot selection unless the user explicitly asks.
- Do not replace the current Expo app with SwiftUI unless the user explicitly changes direction.

## 14. Quick Prompt For Claude Code

Use this when handing off:

```text
このリポジトリでNANYENのExpo/React Native MVPを引き継いでください。
最初に AGENTS.md, docs/PRODUCT_SPEC.md, docs/IMPL_NOTES.md, docs/CLAUDE_CODE_HANDOFF.md を読んでください。
現在の実装は expo-app/App.tsx です。Swift/SwiftUI側は過去プロトタイプ扱いです。

まず npm run typecheck を通し、Expo Go SDK 54 前提を崩さず、次の作業として
AsyncStorage等で収入・固定費・記録の永続化を実装してください。
銀行/カード連携、外部送信、責める文言、過度な設定追加は禁止です。
```
