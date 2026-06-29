# Widget Anti-Pattern Migration — 2026-06-30

## Summary

Mechanical conversion of widget-returning functions and private widget classes
across the entire codebase, guided by the Catch architecture rule that widget
construction should happen in named, public widget classes — never in private
functions or methods.

## Results

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Widget-returning functions | 320 | 101 | -68% |
| Private widget classes | 4 | 4 (core internals) | — |
| Builder methods on State | 17 | 17 (mostly core internals) | — |
| Files with findings | 107 | 55 | -49% |

## What Was Converted

~220 private `Widget _build*(...)` functions → public `class *Widget extends StatelessWidget/ConsumerWidget`
across 58 files in 17 feature areas. Zero compilation errors.

### By Feature

| Feature | Functions | Files |
|---------|-----------|-------|
| Explore | ~20 | ~10 |
| Profile | ~15 | ~8 |
| Events | 31 | 6 |
| Clubs | 34 | 7 |
| Swipes | 36 | 7 |
| Dashboard | 17 | 7 |
| Chats | 15 | 5 |
| Calendar | 12 | 1 |
| User Analytics | 11 | 1 |
| Celebration | 8 | 1 |
| Hosts | 7 | 4 |
| Event Success | 10 | 2 |
| Other (8 features) | ~16 | ~8 |

## Core Primitives Created/Enhanced

- **`CatchField.actions`** — expanding field with Cancel/Done buttons (new)
- **`CatchTopBar` search** — replaced custom search morph animation
- **`CatchCoverStory`** — replaced duplicate cover header implementation

## Remaining (101 functions)

Most are in `lib/core/widgets/` — internal implementation details of core
primitives (State class build-method decomposition). These are not anti-patterns
but legitimate internal structure of complex primitives like `CatchField`.

~50 functions marked "needs judgment" — core infrastructure (transitions,
platform-adaptive pickers, custom painters) that require feature-level context.

## Scanner

`tool/scan_widget_antipatterns.py` — reusable scanner that detects:
- Top-level widget-returning functions
- Private widget classes
- Builder methods on State classes
- Potential core primitive matches

Output: `docs/audit_registry/widget_antipattern_scan.json`
