# PRODUCT_SPEC.md - NANYEN MVP

## 1. One-Line Product

**A loose money-review share-card generator.**

The visible shape is a household-budget app, but the core product is a generator that turns rough
money reflection into something users want to post on X/SNS.

## 2. Audience

- People who have quit strict household-budget apps.
- People who can enter "about this much" but will not record every yen.
- People who may share a funny monthly result if the card does not feel too private or judgmental.

## 3. Core Mechanic

The MVP has two core data units:

```text
monthly rough income and fixed costs
daily rough money entries
```

- At first setup, the user enters rough monthly income and rough monthly fixed costs.
- The app calculates monthly free money: income minus fixed costs.
- The app calculates daily and weekly spending pace from monthly free money.
- The user records daily entries by date, amount, and genre.
- Spending genres subtract money. The income genre adds money.
- The app evaluates whether the selected day/week is under or over pace and creates visual cards.

The app automatically frames the result. The user does not pick the emotional category.

| Type | Trigger | Feeling | Accent | Visual voice |
| --- | --- | --- | --- | --- |
| Savings brag | Actual is below budget | Proud / playful | green | playful positive one-liner |
| Overspend self-joke | Actual is above budget | Self-joking | coral | gentle self-joke one-liner |
| Empathy | Close to budget, or trend-first framing | "Same here" | purple | relatable one-liner |

## 4. Share Card Requirements

- All card types use exactly the same layout.
- Only accent color, comic marks, sticker copy, and the main one-liner vary.
- Main number is always approximate: "だいたい" / "くらい".
- Share output must not reveal absolute income or savings.
- Daily and weekly report cards compare actual pace against the calculated allowance pace.
- The card should be image-first and shareable as a PNG.
- The card automatically includes `#NANYEN #今日の何円 #今週の何円`.
- The only user choice at share time is privacy density:
  - amount
  - rounded
  - vibe only

Recommended dimensions are still undecided. Default implementation should keep the card model
dimension-agnostic, with a likely future target of either `1200x675` or `1080x1080`.

## 5. Visual Personality

The current product direction removes user-selectable companion characters from the main experience.
The share card is led by typography, 80s-inspired color, comic-like marks, and humorous one-liners.

Rules:

- Do not show mascot selection in the main flow.
- Do not put character artwork on the default share card.
- Use large, bold, readable one-liners.
- Keep the joke gentle, never shaming.
- Keep `てへ` / `てへぺろ` rare, around one out of ten copy variants.
- Maintain at least 20 card-copy variants across good/bad pace states so repeat sharing does not feel stale.

## 6. Copy Voice

The voice is a loose companion-like narrator, not a coach, parent, teacher, or judge.

Allowed:

- playful praise for recording or reflecting
- "まあヨシ" acceptance
- laughing with the user
- light self-joke that does not shame the user

Forbidden:

- blame
- commands
- shame
- "should have"
- "bad"
- "you failed"
- absence warnings such as "you have not recorded for X days"

## 7. MVP Anti-Requirements

- Do not build bank/card/e-money integration.
- Do not build arbitrary share-field settings.
- Do not expose income or savings amounts in card output.
- Do not add many settings.
- Do not use LLM-generated copy in v1. Use fixed templates with variables.

## 8. Open Decisions

- Final app name.
- Final share-card aspect ratio.
- Monetization.
- Final rough-input UI.
