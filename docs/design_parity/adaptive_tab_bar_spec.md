---
doc_id: adaptive_tab_bar_spec
version: 1.0.3
updated: 2026-07-12
owner: design_parity_review
status: implemented
depends_on: home_catches_unification_spec
---

# Adaptive Tab Bar — Redesign Spec

Repo: `/Users/suvratgarg/Development/catch-dating-app/catch_dating_app`
Touches: `lib/core/presentation/app_shell.dart`,
`lib/core/presentation/host_app_shell.dart`,
`lib/core/presentation/catch_adaptive_tab_scaffold.dart`,
`lib/core/presentation/app_shell_active_tab.dart`,
`lib/core/widgets/catch_tab_dock.dart` (retired), a new
`lib/core/widgets/catch_tab_bar.dart`, terminal scroll primitives, tokens,
Widgetbook, tests, and the tab-root scroll manifest.

## Why

The consumer bar is being consolidated 5 → 4 tabs (Home · Explore · Chats ·
You, after `home_catches_unification_spec` removes Catches). Today's bar is
wrong in three ways:

1. **Two divergent implementations.** `AppShellNavigationBar` renders a
   native `CupertinoTabBar` on iOS but a custom `CatchTabDock` on Android —
   different behavior, different metrics, one brand voice split in half.
2. **Always-labels, stacked.** `CatchTabDock` stacks an icon over an
   uppercase mono label for *every* tab. At 4 sparse tabs this reads heavy
   and evenly-spread; the vertical stack forces a tall bar and the padding
   (`tabDockTopPadding`/`BottomPadding` + per-item `s1` + `tabDockItemGap`)
   compounds into the "padding is all wrong" feel.
3. **No selection rhythm.** Every tab has equal visual weight, so nothing
   anchors the eye.

## The resolved design (one bar, adaptive chrome)

**The behavior is the Catch constant; the chrome goes native.** These two
cannot both be "native widgets" — no platform's native tab bar
(Material 3 `NavigationBar`, iOS `UITabBar`, the iOS 26 floating glass bar)
does "icon-only unselected, animated icon+label pill on selected." That
selected-label-reveal is a *custom* pattern by nature. So:

- **Behavior (constant, both platforms):** unselected tabs are icon-only;
  the selected tab is an icon + label **pill** that animates its width open
  with the label cross-fading in to the right of the icon. This is the
  distinctive Catch bar, and it reads plausibly-native on *both* modern
  platforms — it echoes iOS 26's expand-on-select minimized tab bar and
  Material 3's pill selection indicator, a convergent pattern.
- **Chrome (adapts per platform):** materials, motion curve, haptics,
  typography, and float-vs-anchored go native.

Retire BOTH the `CupertinoTabBar` branch and `CatchTabDock`; replace with one
`CatchTabBar` widget carrying the adaptive chrome behind the shared behavior.

### Behavior spec (both platforms)

- Unselected item: centered icon (`item.icon`), `t.ink3`, no label, fixed
  compact hit target (≥48dp).
- Selected item: a pill (rounded, subtle fill `t.ink` @ low alpha or
  `primarySoft`) containing `activeIcon` (`t.ink`) + label to its right.
- Animate on selection change with `CatchMotion.standard` (add a named
  token if none fits): the pill width opens via `AnimatedSize`/an
  animated flex, the label cross-fades + slides ~4px in. Deselecting
  reverses. Respect `MediaQuery.disableAnimations` (snap, no tween).
- Label typography: the platform function font (NOT uppercase mono — that
  was the old dock's brand-heavy tell; the selected label should read as a
  quiet native tab label). Sentence-case ("Explore", not "EXPLORE").
- Unread badge stays on the icon (reuse `CatchCountBadge`); it shows whether
  or not the tab is selected.
- Haptic on select: `catchSelectionHaptic()` (already the app's discrete-
  choice haptic).

### iOS chrome

- **Floating, inset** from the bottom safe area and side margins (detached
  bar), rounded to a pill/`CatchRadius.lg`-class corner.
- **Translucent** background: `BackdropFilter` blur (the dock already uses
  `tabDockBlurSigma`) + a low-alpha surface fill — a restrained glass, NOT a
  heavy refraction. Catch's identity is B&W editorial restraint; the bar
  should read as quiet frosted glass, not a decorative lens (see the package
  note for a true-liquid-glass upgrade path if wanted later).
- Cupertino selection curve + `catchSelectionHaptic` (maps to iOS
  selection feedback).
- Hide the top hairline border (a floating bar doesn't need it); rely on the
  blur/elevation separation.

### Android chrome

- **Anchored, edge-to-edge** at the bottom (Material convention — not
  floating), Material 3 tonal surface (`t.surface`), a top hairline
  (`t.line`) OR M3 elevation, whichever reads cleaner against content.
- Material ripple on tap (`InkWell`, already present), Material emphasized
  motion for the pill.
- Same selected-label-reveal behavior; the pill indicator is very
  Material-You-native.

### Padding fix (falls out of the layout)

The stacked icon+label is gone, so the bar is a single horizontal row →
shorter. Define ONE height token (`CatchLayout.tabBarExtent`) for the row,
symmetric vertical centering, and derive the iOS float insets from existing
spacing tokens (no raw values — D1). Do not carry over
`tabDock*Padding`/`tabDockItemGap`/`tabDockLabelFontSize`; replace with the
new bar's tokens and delete the orphaned ones.

## The iOS 26 liquid-glass package question (answered)

A pub.dev scan (July 2026) surfaced several options; **vet quality,
maintenance, and performance before adopting any — this is a production
dating app and shader glass has real cost.** Two categories:

- **Native-control wrappers** (`cupertino_native`, `cupertino_native_better`,
  `native_glass_navbar`): these render the *real* UIKit tab bar, so on
  iOS 26 you get true Liquid Glass for free. **BUT they forbid the
  selected-label-reveal** — you cannot inject custom layout/animation into a
  native `UITabBar`. Incompatible with your primary ask. Do NOT use for this
  bar.
- **Glass *renderers*** (`liquid_glass_renderer`, `liquid_glass_widgets`,
  `adaptive_platform_ui`): these give a glass *material* you paint into your
  OWN widget. Compatible with the custom bar — swap the iOS background layer
  from `BackdropFilter` to the renderer for true refraction, keeping our
  layout/animation.

**Recommendation:** ship the custom `CatchTabBar` with the zero-dependency
`BackdropFilter` glass approximation FIRST (the current dock already proves
it works, no new dependency, no shader perf risk, and it suits the editorial
restraint). Treat true liquid glass as an *optional background-layer swap*
(`liquid_glass_renderer`) behind a flag if you later want the iOS 26 lens —
it is a material change, not an architecture change, precisely because the
bar is our custom widget. This keeps the door open without betting the
production bar on a young shader package.

## Architecture / scaffold

- `CatchTabBar` (core widget) owns the adaptive behavior + chrome; takes
  the same `AppShellNavigationItem` list + `currentIndex` +
  `onDestinationSelected` contract `AppShellNavigationBar` uses today.
- `AppShellNavigationBar` collapses to: build the 4-item consumer set, hand
  to `CatchTabBar`. Delete the `prefersCupertinoControls()` branch here (the
  adaptivity moves INSIDE `CatchTabBar`, keyed off `prefersCupertinoControls`
  for chrome only).
- iOS float means the bar no longer occupies layout space at the bottom the
  way an anchored bar does. The shell injects the reserved floating inset for
  tab-root overlays through `AppShellActiveTab`; tab-root affordances use
  `AppShellActiveTab.bottomOverlayClearanceOf(context, minimum: ...)` rather
  than recomputing tab-bar metrics in feature code. Branch child routes that
  own CTAs, composers, or route-level bottom docks are promoted to the root
  navigator with `parentNavigatorKey: _rootNavigatorKey`, so the floating tab
  bar is not present on those screens at all. Bottom sheets use
  `showCatchBottomSheet`, which presents on the root navigator by default and
  therefore sits above shell chrome. Android anchored bar keeps today's layout
  behavior (no body overlap).
- `CatchAdaptiveTabScaffold` is the shared placement owner for consumer and
  host shells. It publishes typed none/anchored/floating state through
  `AppShellActiveTab`, overlays on iOS, and installs the bar through
  `Scaffold.bottomNavigationBar` on Android.
- Root scroll owners terminate with `CatchSliverTerminalPadding` or
  `CatchScrollTerminalPadding`. These consume raw iOS obstruction, add no
  duplicate Android bar inset, preserve no-bar/non-shell safe areas, and never
  add keyboard `viewInsets`. `tool/design/tab_root_scroll_contracts.json`
  makes a new shell branch fail until its true scroll owner is registered.
- Verify every `StatefulShellBranch` index site after Catches is removed
  (this spec assumes `home_catches_unification_spec` U3 already dropped that
  branch — sequence after it).

## Accessibility

- Semantics: EVERY tab exposes its label + selected state even when the
  label is visually hidden (unselected). Keep the
  `Semantics(button, selected, label)` contract in `CatchTabBarButton`.
- Text scaling: the selected pill must grow with Dynamic Type without
  clipping the label or overflowing the row; validate at 1.0/1.5/2.0. If a
  long label at large scale would overflow with 4 pills' worth of room,
  cap the label to the selected pill only (which is the design) and let the
  pill flex; never truncate mid-word.
- Reduced motion: no width tween, no cross-fade — snap to the end state.

## Tests + widgetbook

- Widget tests: only the selected tab renders a visible label; selecting a
  new tab moves the label and fires `catchSelectionHaptic`; semantics expose
  all four labels + the selected index; reduced-motion renders the end state
  with no animation; iOS chrome floats (has bottom inset) vs Android anchored
  (verify via `prefersCupertinoControls` override in the pump).
- Widgetbook: `CatchTabBar` states — each of the 4 tabs selected, iOS chrome
  vs Android chrome, with-badge; delete the old `CatchTabDock` use-cases.
- Golden/appshot both chromes for the receipt.

## Sequencing

After `home_catches_unification_spec` U3 (the 4-tab set must exist first).
Independent of the parity handoff and splash work. This is the natural
finish to the tab consolidation.

## Non-goals

- No true liquid-glass shader dependency in v1 (optional later swap).
- No change to the tab destinations/routing (that's the unification spec).
- No host-specific placement fork. Host and consumer shells share the same
  adaptive scaffold while retaining separate destination sets.

## Completion checklist (goal mode)

### 2026-07-07 implementation status

Landed the shared `CatchTabBar` primitive, rewired `AppShellNavigationBar`,
retired `CatchTabDock` and the shell-level `CupertinoTabBar` branch, refreshed
component contracts, Widgetbook states, widget registries, and design context
pack outputs. The consumer shell still renders five destinations because
`docs/plans/home_catches_unification_spec.md` U3 has not landed; removing the
Catches item before that route/branch migration would shift StatefulShell
indices and make Profile unreachable. `CatchTabBar` supports the four-tab
shape and Widgetbook covers it. The live consumer set is now Home, Explore,
Chats, You: the Catches branch was removed from the shell, `/catches` redirects
home, and `/catches/:eventId` stays intact under the Home branch for deep
links. Chrome proof now lives in `test/goldens/tab_bar_test.dart`, with paired
light/dark baselines for the iOS floating glass bar and Android anchored bar.
The follow-up clearance pass moved consumer and host placement into
`CatchAdaptiveTabScaffold`, made both terminal-padding primitives shell-aware,
adopted them at all eight direct shell branches (including Profile Preview's
nested scroll), and added known-bad scanner fixtures for missing terminals and
new unregistered branches. Widgetbook now exposes explicit iOS floating,
Android anchored, and iOS keyboard-open states.
The standalone Catches hub widgets/captures remain as Home+Catches U1/U2/U4
absorption debt, not as a tab-bar blocker.

- [x] `CatchTabBar` built: selected-label-reveal behavior + adaptive chrome
- [x] iOS chrome (floating, restrained frosted glass, Cupertino motion/haptics)
- [x] Android chrome (anchored M3, ripple, hairline/elevation)
- [x] `AppShellNavigationBar` rewired; `CatchTabDock` + CupertinoTabBar branch retired; orphan tokens deleted
- [x] body bottom-inset seam so screens clear the floated iOS bar
- [x] route/sheet chrome policy so child screens and drawers render above the shell
- [x] a11y: semantics for all tabs, text-scale 1.0/1.5/2.0, reduced motion
- [x] live four-tab consumer set — U3 nav-shell mechanics landed; Catches hub absorption remains in `home_catches_unification_spec.md`
- [x] appshot/golden for both chromes — `test/goldens/tab_bar_test.dart`
- [x] tests + widgetbook states + catalog/doc_versions/passes stamps
- [x] full analyzer passes with `--no-fatal-infos`; readiness 100/100; scanners green
