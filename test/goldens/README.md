# Golden visual-regression harness

Deterministic golden tests are Catch's automated substitute for the light/dark +
Dynamic-Type visual QA that can't be eyeballed in CI. They guard the UI-elevation
migration (token re-skin, the 186-site sizing pass, the activity re-grade) from
**silent** visual breakage.

## Run

```bash
flutter test test/goldens                    # verify against committed baselines
flutter test --update-goldens test/goldens   # regenerate baselines (review the diff!)
```

Baselines live in `test/goldens/baseline/<name>.<light|dark>.png`.

These tests are tagged `golden`. The Ubuntu Flutter CI unit/widget step runs
with `--exclude-tags=golden` because the committed baselines are macOS-rendered.
The dedicated macOS lane uses `CatchGoldenFileComparator` with a 0.30% pixel
tolerance: the reviewed hosted-runner variance is at most 0.29% and concentrated
on anti-aliased text/icon edges, while larger visual drift still fails and emits
Flutter's normal master, test, isolated-diff, and masked-diff artifacts.

## What's covered

| Golden | What it locks |
|---|---|
| `design_system_sheet` | All `CatchTokens` color roles + activity pigments, the full `CatchTextStyles` ramp (serif/sans/mono, weights, italic), and the activity-art duotone + pattern + glyph — light **and** dark. |
| `adaptive_tab_bar_ios_chrome` | Floating/glass `CatchTabBar` chrome, active-label pill, badge placement, safe-area offset, and light/dark token mapping on iOS. |
| `adaptive_tab_bar_android_chrome` | Anchored/material `CatchTabBar` chrome, active-label pill, badge placement, safe-area behavior, and light/dark token mapping on Android. |

Add coverage as components stabilize (ticket card, polaroid, profile sections, …).

## Adding a golden

```dart
// test/goldens/my_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'support/golden_pump.dart';

void main() {
  testWidgets('my widget', (tester) async {
    await matchCatchGolden(tester, 'my_widget', builder: (context) => const MyWidget());
    // Optional Dynamic-Type variant:
    // await matchCatchGolden(tester, 'my_widget@1.5', textScale: 1.5, builder: ...);
  });
}
```

`matchCatchGolden` pumps inside the real `AppTheme`, renders **light + dark**, pins
devicePixelRatio to 1.0 on a fixed surface, and leaves font/layout failures
visible. Avoid `Image.network` in goldens (it loads nothing in tests) — use
activity art or inject a fake image.

## How fonts work (the tricky part)

Goldens load the same bundled font assets the app ships:

1. `flutter_test_config.dart` registers Archivo and IBM Plex Mono via
   `FontLoader`; deterministic Roboto files stand in for the concrete platform
   function-family aliases.
2. Archivo weights/widths are driven through `FontVariation` in `CatchFonts`.
3. Mono uses the bundled per-weight statics.

This is **test-only** — no fonts are added to the app bundle. If `CatchFonts`
changes the display face, re-probe the emitted family names and update the loader.

## ⚠️ Platform determinism

Golden PNGs are **platform-specific** (font rasterization differs across macOS /
Linux). The committed baselines were generated on **macOS**. Run golden tests on
the pinned macOS CI platform; the narrow comparator tolerance handles rasterizer
noise between developer and hosted macOS machines. Do not widen it to make a
visual change pass. Treat a golden diff as "review the change," not "auto-fail"
— regenerate only when the change is intended.

## CI

Do not run these PNG goldens in the default Ubuntu Flutter CI job. Run
`flutter test test/goldens` on the pinned platform alongside visual-review gates
(see `docs/release_operations.md`). A diff above the checked 0.30% tolerance
means a reviewer must confirm the visual change and regenerate baselines.
