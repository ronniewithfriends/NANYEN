# AGENTS.md

> Codex reads this file before working in this repository.
> Keep this file stable during a session; put detailed product notes in `docs/`.

## Project Definition

**NANYEN** is a loose household-money share-card app for people who do not keep strict budgets.
The product is less a ledger and more a small visual joke generator: users enter a rough budget and
rough actual spending, then the app turns the result into a shareable card for X/SNS.

When in doubt, optimize for this principle:

**Rough records that get shared beat precise records that get abandoned.**

## Required Reading

Read these before implementation work:

1. `docs/PRODUCT_SPEC.md` - product intent, mascot, copy, and anti-requirements.
2. `docs/IMPL_NOTES.md` - technical scope, data boundaries, and MVP implementation notes.

If documents conflict, prioritize the product intent in `docs/PRODUCT_SPEC.md`.

## Guardrails

- Do not implement bank, card, e-money, brokerage, or account aggregation.
- Do not handle or store financial-service credentials.
- Do not send financial data to external services.
- Do not use machine learning for forecasts, framing, or copy in v1.
- Do not expose income or savings absolute amounts in share-card output.
- Do not let users configure arbitrary shared data fields; the card format must stay unified.
- Do not add many settings or toggles. The app should decide for the user.
- Do not write blaming, shaming, commanding, or moralizing copy.
- Do not punish absence or missed days with streak loss or warning language.

## MVP Scope

Build only this loop first:

1. User sets rough monthly income and fixed costs.
2. The app calculates monthly free money plus daily and weekly spending pace.
3. User records rough daily expenses or income, including past dates.
4. The app evaluates whether the selected day/week is under or over pace.
5. The app generates a square, fixed-layout visual share card with humorous copy.
6. Native app sharing exports the visual card as a PNG image with the standard hashtags.

Everything else is post-MVP unless explicitly requested.

## Technical Direction

- Primary implementation: Expo / React Native in `expo-app/`.
- Targets: iOS and Android first, with web used for design and PNG-generation checks.
- Future native additions: mobile widgets, voice input, watch companion, account sync, and ads.
- Amounts are `Int` yen. Do not use floating-point for money.
- User-facing copy should be centralized in copy/framing types, not scattered through UI code.
- Initial automated verification is TypeScript checking and Expo web export.
- Full image sharing must be verified on a real phone via Expo Go or an EAS development build.

## Current Build/Test Commands

```bash
cd expo-app
npm run typecheck
npx expo export --platform web
npm start
```

Swift sources in `Sources/` and `NANYEN.xcodeproj` are historical prototypes unless the user explicitly
switches back to SwiftUI.
