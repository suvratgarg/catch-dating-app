# Catch widget catalog

Screens are **composed from this catalog**, not hand-rolled. Before writing a
new private widget (`class _Foo extends StatelessWidget`), check whether one of
these already covers the pattern. Raw Material equivalents are blocked by the
`packages/catch_ui_lints` analyzer rules (`catch_no_raw_material_control`,
`catch_no_raw_button_control`, …); reach for the Catch widget instead.

## Decision tree

| You need… | Use | Don't use |
|---|---|---|
| A primary/secondary/ghost/danger action | `CatchButton` | `ElevatedButton`, `FilledButton`, `OutlinedButton` |
| A low-emphasis text action | `CatchTextButton` | `TextButton` |
| A text input | `CatchTextField` | `TextField`, `TextFormField` |
| A dropdown / picker / stepper / slider | `CatchDropdownField`, `CatchAdaptivePicker`, `CatchNumberStepper`, `CatchRangeSlider` | raw Material equivalents |
| A filter / choice / tag / removable chip | `CatchChip` (`active` + `onTap` = filter/choice, `onRemove` = input) | `Chip`, `FilterChip`, `ChoiceChip`, `ActionChip`, `InputChip` |
| A card / panel / tappable tile | `CatchSurface` (primitive) or `CatchSectionCard` (titled) | `Card`, raw `Container` shells |
| A leading-icon + title + message (+ CTA) callout card | `CatchInfoCard` | hand-rolled `CatchSurface(Row(Icon, Column(...)))` |
| A small status/count pill or label | `CatchBadge`, `CatchStatusDot` | raw decorated `Container` |
| An empty state (icon + title + message + optional CTA) | `CatchEmptyState` (`stacked` or `inline`) | a private `_EmptyState` |
| An error / retry view | `CatchErrorState` (`fullscreen` / `inline` / `compact`) | a private `_ErrorView` |
| A loading state | `CatchLoadingIndicator` (spinner) or `CatchSkeleton` (placeholder) | `CircularProgressIndicator`, custom shimmer |
| The loading/error/data shell over a Riverpod `AsyncValue` | `AsyncValueWidget` / `AsyncValueSliverWidget` | a bare `value.when(...)` with custom spinners |
| A confirmation / info / warning toast | `showCatchSuccessSnackBar`, `showCatchInfoSnackBar`, `showCatchWarningSnackBar` | raw `ScaffoldMessenger…showSnackBar(SnackBar(…))` |
| An error toast (mapped to a user message) | `showCatchErrorSnackBar(context, error)` | `SnackBar(content: Text(error.toString()))` |
| A mutation error surface | `ErrorBanner` + `listenForMutationErrorSnackbar` / `mutationErrorMessage()` | raw `error.toString()` |
| An app bar | `CatchTopBar` | `AppBar` |
| A bottom sheet | `CatchBottomSheet` helpers / `CatchBottomSheetScaffold` | raw `showModalBottomSheet` |
| A confirm / destructive dialog | `CatchAdaptiveDialog` / `ConfirmDangerDialog` | `AlertDialog`, `showDialog` |
| An avatar | `PersonAvatar` | raw `CircleAvatar` / `ClipOval` |

## Snackbars

`catch_error_snackbar.dart` is the single entry point:

- `showCatchErrorSnackBar(context, error)` — maps any error to a user message.
- `showCatchSuccessSnackBar(context, 'Saved.')` — green-iconed confirmation.
- `showCatchInfoSnackBar(context, '…')` — neutral info.
- `showCatchWarningSnackBar(context, '…')` — soft-failure notice.

When the snackbar fires inside an `async` callback after an `await`, capture
the messenger first (`final messenger = ScaffoldMessenger.of(context);`) **and
guard `context.mounted`** before showing, or pass a still-mounted context.

## Tokens, not magic numbers

Color, spacing, radius, typography, icon size, motion, and opacity all come
from tokens — `CatchTokens`, `CatchSpacing`/`CatchInsets`, `CatchRadius`,
`CatchTextStyles`, `CatchIcons`/`CatchIcon`, `CatchMotion`, `CatchOpacity`.
Inline `Colors.*`, `Color(0x…)`, `fontSize:`, and `BorderRadius.circular(12)`
are flagged by the analyzer; use the token instead.

## Enforcement

The catalog is guarded by analyzer rules in `packages/catch_ui_lints` and the
`tool/check_catch_ui_lints.sh` / `tool/check_ui_*` scripts (run in CI). New raw
Material usage in `lib/**/presentation/**` fails the lint; a genuinely
unavoidable case can be annotated with a scoped `// <area>:allow:` comment,
which the allow-debt budget (`tool/check_ui_allow_debt.sh`) tracks down to zero.
