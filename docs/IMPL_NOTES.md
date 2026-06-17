# IMPL_NOTES.md - Technical Notes

## 1. Current Implementation Strategy

The active MVP implementation is now the Expo / React Native app in `expo-app/`.
The previous Swift package and Xcode project remain as historical prototypes.

The Expo MVP covers:

- calculate rough monthly free money from income and fixed costs
- calculate daily and weekly spending pace
- record rough daily expenses or income
- record against past dates through a calendar view
- classify the selected day/week as under or over pace
- render a square visual share card with fixed hashtags
- share the visual card as a PNG image on native devices

The web build is for browser design checks. Final sharing behavior must be confirmed on a phone.

## 2. Stack

- Expo / React Native / TypeScript for the active app.
- Expo Go is the fastest device preview path.
- EAS Build will be used later for TestFlight, App Store, and Google Play packages.
- No networking for financial data.
- No ML/LLM generation in v1.

## 3. Money Rules

- Store yen as `Int`.
- No floating-point money calculations.
- Share-card deltas are budget-vs-actual differences, not income or savings balances.
- Negative/invalid inputs should be rejected by core types.

## 4. App Responsibilities

Primary app path: `expo-app/App.tsx`

Responsibilities:

- rough monthly plan state
- calendar date selection
- rough entry creation and cancellation
- day/week pace evaluation
- safe template copy selection
- visual card rendering and native image sharing

Non-responsibilities:

- account linking
- network sync
- bank/card/e-money aggregation
- external financial-data transmission

## 5. Visual Card Direction

The current MVP removed user-selectable mascot characters from the main experience.
The visual card is now led by large humorous copy, metallic lettering, and small comic-like marks.

The old mascot resources may remain in the repository as unused historical assets, but new implementation
should not reintroduce mascot selection unless the product direction changes explicitly.

## 6. Verification

Run:

```bash
cd expo-app
npm run typecheck
npx expo export --platform web
```

Run the app locally with:

```bash
cd expo-app
npm start
```

Then scan the QR code with Expo Go on a phone.
