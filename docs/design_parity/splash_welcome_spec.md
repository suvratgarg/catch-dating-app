---
doc_id: splash_welcome_spec
version: 1.0.0
updated: 2026-07-06
owner: design_parity_review
status: ready-for-implementation
---

# Splash + Welcome — Boot Chrome Fix & Reel Parity Spec

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`
Design SoT: `~/Downloads/Catch Design System (2)/splash-welcome-handoff/`
(`SPEC.md` = geometry/motion contract; `reference/Splash-prototype.html` =
source of truth when in doubt; `strings.json` = phrase bank;
`assets/fonts` = the type cuts the reel needs).

## The three-layer model (why the current behavior happens)

1. **OS launch screen** (iOS storyboard / Android drawable): STATIC by
   platform design — no arbitrary animation is possible here, ever.
   Currently broken: `ios/Runner/Base.lproj/LaunchScreen.storyboard`
   backgroundColor is pure white (`1,1,1`) — the flutter_native_splash
   pubspec config (`#F4F4F1` light / `#0F0E10` dark — which ARE the exact
   `lightBg`/`darkBg` token values) was never (re)generated into the
   platform files.
2. **Boot gap**: `runCatchApp` awaits orientation lock + full Firebase
   init + error logger + analytics BEFORE `runApp`. The native splash
   covers all of it — but nothing calls
   `FlutterNativeSplash.preserve()/remove()`, so the handoff to Flutter is
   uncontrolled.
3. **First Flutter frames**: the force-update gate (`app.dart`) mounts
   `CatchStartupLoadingScreen` — a `t.primary`-colored scaffold — until
   remote config resolves, which is near-instant from cache. Result: white
   native splash → ~1 frame of brand-color flash → home. That flash is the
   "sometimes see a frame of it."

The reel animation was never a boot asset: the handoff is **Splash →
Welcome** — the signed-out landing sequence (its layout ends in the
"Continue with phone" / "See what's on" CTA block). Its Dart transcription
already exists at `lib/onboarding/presentation/pages/welcome_page.dart`
(router `:308` + onboarding welcome step) and has unlimited play time
there. Boot never gets a reel; the Welcome screen gets the pixel-accurate
one.

Workflow: standard (AGENTS.md; verify with `rg`; per-part commits with
pathspecs; focused tests + analyzer; sequential Flutter runs; catalog/
doc_versions/passes stamps; readiness gate).

---

## Part 1 — Regenerate the native splash correctly `[codex]`

1. Verify `assets/branding/catch_icon.png` composites correctly on BOTH
   `#F4F4F1` and `#0F0E10` (transparent background, no baked tile). If it
   has a baked background, escalate with an appshot — do not ship a tile
   on a tile.
2. Run `dart run flutter_native_splash:create` and commit the regenerated
   platform files. Confirm afterwards: the iOS storyboard backgroundColor
   is `0.956862745 0.956862745 0.945098039` (= #F4F4F1), the dark
   variants exist, and Android 12 sections generated
   (`android12splash.png` refreshed; night variants present).
3. Record before/after cold-launch appshots (light + dark) in the receipt.
4. Add a one-line note to `docs/release_operations.md` (or the platform
   runbook section that owns launch assets): "native splash is GENERATED —
   edit pubspec `flutter_native_splash:` then re-run create; never
   hand-edit the storyboard/drawables."

## Part 2 — Controlled boot handoff `[codex]`

In `lib/app_bootstrap.dart` (`runCatchApp`):

1. `final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();`
   then `FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);`
   BEFORE the awaits (package already in pubspec).
2. Call `FlutterNativeSplash.remove()` at the first stable frame: in the
   force-update gate widget, when the gate resolves to a non-loading
   branch (allowed / update-required / error), via a post-frame callback
   that fires exactly once. While the gate is still loading, the native
   splash simply stays up — no Flutter loading chrome flashes at all for
   fast boots.
3. Web is out of scope (native splash preserve is mobile; leave web
   behavior unchanged).

## Part 3 — Re-tone the startup screen (and stop reusing it) `[codex]`

1. `CatchStartupLoadingScreen` becomes the seamless continuation of the
   native splash instead of a brand-color flash: `backgroundColor: t.bg`
   (dark: `t.ink`-register via the standard token resolution — match the
   native dark hex), the mark centered at the same visual size/position
   as the native splash image, and the `CatchLoadingIndicator` appears
   only after a 600ms delay (fast boots must never show a spinner). With
   Part 2, this screen is visible only on slow boots — and when it is, it
   is indistinguishable from the native splash except the spinner.
2. `host_edit_club_route_screen.dart` reuses `CatchStartupLoadingScreen`
   as a ROUTE loading state (two sites) — wrong altitude. Replace with the
   feature's skeleton loading per the G2 doctrine (match whatever the host
   club editor's loaded composition mimics; a `CatchSkeletonList`-based
   body is acceptable if no mimic exists). After this,
   `CatchStartupLoadingScreen`'s only consumer is the boot gate — record
   that in the widget catalog entry.

## Part 4 — Welcome reel pixel parity `[codex]`

Audit `welcome_page.dart` against `splash-welcome-handoff/SPEC.md` line by
line; fix concrete deltas; receipt each row (aligned/fixed). The contract
(authored at 320pt reference width — keep PROPORTIONS AND ANCHORS, refit
to device; when in doubt match `reference/Splash-prototype.html`):

- **Type**: reel/headline = Archivo 36 / weight 600 / **font-stretch 78%**
  / line-height 1.02 / tracking −0.5. Flutter has no font-stretch: this
  REQUIRES the condensed Archivo cut. Check `splash-welcome-handoff/
  assets/fonts` for the exact cut the prototype uses; bundle it under
  `assets/fonts/` + pubspec (bundled-fonts doctrine — no google_fonts),
  register a `_WelcomeType`/CatchFonts entry for it. If the app currently
  renders the reel in regular-width Archivo, this is the single biggest
  visible parity break — fix first.
- **Geometry** (scaled): ROW 90; WHEEL_TOP 50; WHEEL_H 540; FOCUS 230
  (focus-row centre y≈280); CATCH_TOP 249; object left inset 116
  (double) / 108 (single) with the "Catch gap" as the tweakable; object
  right inset 18 (so "someone real" wraps to two lines); body top 340;
  CTA block pinned bottom 30 above safe area.
- **Reel mechanics**: 12 phrase rows from `strings.json` (sync the Dart
  phrase bank to it — the JSON is the source), looped ×2 (24) for
  seamless wrap; "Catch" is FIXED (does not scroll); the period renders
  only on the focused row (opacity 1 focused / 0 otherwise); rows wrap to
  ≤2 lines.
- **Focus + color math**: focused when `|distanceFromFocusCentre| <
  ROW/2`; non-focus dim `opacity = max(0.12, 1 − dist/(ROW·3.2))`; focus
  color = the phrase's activity pigment; non-focus color = mix(pigment
  26%, ink3). Band mask: fade 0→14%, solid 14→88%, fade 88→100%.
- **Landing**: body/buttons hidden during the spin; land per
  `ReelToWelcome.source.html` (spin settles on the landing phrase, body +
  CTA block enter). Verify the two-controller structure
  (`_spinController`/`_landingController`) matches the reference timing —
  extract durations/curves from the prototype and token-ize them through
  `CatchMotion` (named additions allowed here; this is a new motion
  primitive per the design-language motion rule).
- **Reduced motion**: `MediaQuery.disableAnimations` → skip the spin,
  render landed state immediately (`playIntro: false` path must equal the
  landed end-state pixel-for-pixel).
- Tests: widget tests for landed geometry anchors (Catch fixed position,
  CTA pinned, focus row phrase + period), reduced-motion path, phrase
  bank = strings.json. Appshots (light) for the receipt; widgetbook
  states: spinning (static mid-frame acceptable), landed.

## Part 5 — OPTIONAL cold-boot brand beat (deferred, owner call)

If a boot brand moment is still wanted after Parts 1–3: cap it at a
≤400ms fade-in of the mark on the bg frame (post-`remove()`), cold start
only, never on resume, never a reel. NOT part of this spec's checklist —
record as a backlog note only.

## Acceptance

- Cold launch: OS splash in correct brand colors (both registers) → app
  content, with zero color flashes between; no spinner unless boot
  exceeds 600ms.
- Force-update gate keeps working (update-required and error branches
  still render after `remove()`).
- Welcome reel matches the prototype: condensed cut, geometry anchors,
  focus/dim/period math, band mask, strings.json bank, reduced-motion
  landing.
- Route-level loading no longer uses the startup screen.
- Receipts: appshots (before/after native, welcome landed), parity
  checklist rows, catalog/doc_versions/passes stamps, readiness 100/100.
