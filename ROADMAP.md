# Blanks / More Blanks — Improvement Roadmap

*Planning document, 2026-07-04. Legacy ObjC app v4.3 is live on the App Store; this SwiftUI rewrite is at v1.0.*

> **Bundle-id correction (2026-08-14):** the live App Store records are `com.yourcompany.Blanks` (app 286883373) and `com.yourcompany.MoreBlanks` (app 288808376) — NOT `de.kaikunze.*`, which was never registered. The v5.0 targets now point at the live ids.

> **Status 2026-08-14 (later): direction changed — the rewrite is now a faithful replica of the shipped ObjC 4.3.** Kai rejected the modernized look/behavior; both SwiftUI apps now render the legacy 320×568 canvas scaled between black bands (verified pixel-identical against the 4.3 binary running in the simulator), with the 4.3 text info bar, upper-right tick/cross feedback, retry-on-wrong (no advance/reveal), the TappingUI drag/tap toggle (default drag in both SKUs), and per-SKU About screens (tip jar only in Blanks). Invisible fixes kept: verified StoreKit, cached plist + error state, 12 unit tests, haptics. Legacy source preserved: `Blanks-old/Blanks` tagged **v4.3**, `Blanks-old/More Blanks` tagged **v4.4** (shipped state was the uncommitted working tree; HEAD was 2014-era). 4.3's telemetry was deliberately not ported.
>
> Earlier same-day status (superseded on look/behavior, still true for internals): **Phase 1 was implemented** in `blanks/` (tagged `pre-v5.0-stabilization` before the work). Decision: `blanks/` with both live SKUs is the canonical codebase; `__blanks/`/`--blanks/` (Blanks Pro redesign, dropped MoreBlanks) are parked. Done: honest scoring (wrong answers count once, reveal, advance), safe option shuffling, cached + fail-loud plist loading, cancellable feedback timer, observable high score, verified/finished StoreKit tip jar with Transaction.updates in both SKUs, drop-zone drag highlight, first-run drag hint, VoiceOver + Dynamic Type support, a layout fix (scaledToFill background widened the ZStack ~26pt off-center and clipped definitions), 11 unit tests (BlanksTests), deployment target 18.0, MARKETING_VERSION 5.0. Remaining before submission: device/sandbox tip-jar check, App Store Connect upload. Phases 2–3 below are still open.

## Current state

- **One project, two targets** (`blanks/blanks.xcodeproj`): Blanks (`de.kaikunze.blanks`, drag-and-drop answers) and MoreBlanks (`de.kaikunze.moreblanks`, button answers), sharing `Shared/Model/GameState.swift`, `WordModel.swift`, and common views.
- **Content:** single static `Shared/Resources/average.plist` with 8,109 word entries (definition + 4 authored choices), identical for both targets.
- **Scoring:** streak, total answered, accuracy; high score in UserDefaults. Haptics on answer.
- **Monetization:** StoreKit 2 tip jar (`TipJarView`, `BlanksStore.storekit` — $1.99/$5.99/$9.99).
- **Gaps:** no tests; no accessibility (VoiceOver/Dynamic Type); no per-word progress or spaced repetition; words drawn uniformly at random; plist reloaded per `WordModel` instance; silent failure to an empty word list if the plist is missing.

## Phase 1 — Ship the rewrite safely (v5.0, replacing the legacy binaries)

- **Unit tests** for `GameState` (scoring, streak reset, high-score persistence) and `WordModel` — including the edge case where an entry has fewer than 3 false options and `shuffledOptions()` could present fewer than 4 choices.
- **Robust content loading:** cache the plist parse (load once, share), and fail loudly (user-visible error state) instead of silently continuing with `words = []`.
- **Accessibility:** VoiceOver labels on cards, drop zones, and answer buttons; Dynamic Type support. A text-based learning app without this excludes exactly the users who benefit most, and it's an App Review risk on a fresh submission.
- **First-run hint** for the drag-and-drop gesture in Blanks (one-time overlay; the interaction is not discoverable).
- **Submit as v5.0** for both SKUs so the modern codebase replaces the 13-year-old Objective-C binaries before any new features are built on it.

## Phase 2 — Learning science (the biggest product lever)

Random uniform word selection is the core pedagogical weakness — users mostly re-see words they already know.

- **Per-word progress tracking** (SwiftData: word id, times seen, times correct, last seen, box number).
- **Leitner-box spaced repetition:** 4–5 boxes; correct → promote, wrong → back to box 1; selection favors low boxes and words due for review. Deliberately simpler than SM-2 — solo-dev-sized, no tunable parameters, easy to explain in the UI.
- **"Review mistakes" mode** — a session drawing only from box 1 / recently-missed words.
- **Learn from wrong answers:** on a miss, show a compact word detail (correct word, definition recap, the distractor chosen) before the next card, instead of instantly advancing.
- **SKU differentiation:** More Blanks gets the stats dashboard (per-box counts, accuracy trends) and word packs/levels from Phase 3, keeping the two-app split meaningful rather than cosmetic.

## Phase 3 — Content & engagement

- **Word packs:** split `average.plist` into themed/difficulty packs (common, academic, GRE-style, idioms). Structure only — content curation can trail the code.
- **Daily goal + streak notifications:** local notifications only (no server); daily word goal with a gentle evening reminder tied to the Phase 2 streak data.
- **Pronunciation** via `AVSpeechSynthesizer` — free, on-device audio for every word; a tap-to-hear button on the word card. Vocabulary retention measurably improves with audio.

## Sequencing rationale

Phase 1 exists to get the rewrite live without regressions — everything in it de-risks the v5.0 submission. Phase 2 is where the app stops being a quiz toy and becomes a learning tool; it also creates the data (per-word stats) that Phase 3's goals/streaks and More Blanks' dashboard consume. The tip jar stays as-is per the keep-current-SKUs decision; if Phase 2 lands well, revisit whether word packs justify paid IAP later.
