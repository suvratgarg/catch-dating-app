# UI Audit Patterns

Running log of patterns, anti-patterns, and conventions discovered during UI audits. Use these as a checklist when reviewing any screen.

## Screen responsibilities (the "thin screen" rule)

A screen should be a plain `StatelessWidget` that handles **only**:

- `CatchTokens.of(context)` for theming
- `Scaffold` with `backgroundColor` and `body`
- Composing feature widgets (header, content)

A screen should **never**:

- Watch providers (`ref.watch`) — that belongs in feature content widgets
- Hold `TextEditingController` or any `State` — that belongs in the relevant widget
- Wire mutation callbacks — mutations are owned by the widget that triggers them
- Know about mutation error feedback — wrap the triggering widget instead

**Canonical example** (24 lines):
```dart
class RunClubsListScreen extends StatelessWidget {
  const RunClubsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: CustomScrollView(
        slivers: [
          RunClubsSliverHeader(),
          const RunClubsList(),
        ],
      ),
    );
  }
}
```

`RunClubsList` (ConsumerWidget) handles async state dispatch:
- loading → `SliverFillRemaining(CatchSkeletonList)`
- error → `SliverFillRemaining(CatchErrorText)`
- empty → `SliverFillRemaining(RunClubsEmptyState)`
- data → `SliverToBoxAdapter(MutationErrorSnackbarListener(RunClubsListBody))`

`RunClubsListBody` (StatelessWidget) composes the two section widgets:
- `RunClubAvatarRail` (CatchHorizontalRail instantiation)
- `RunClubDiscoverList` (CatchVerticalSection instantiation, owns join mutation)

## Feature-specific sliver headers

Create a feature-specific sliver header widget that wraps the generic primitive (`CatchSliverTopBar`) with all feature config baked in:

- `titleWidget`: use a private `StatelessWidget` subclass — it gets its own `BuildContext` at build time, so `CatchTextStyles`, `CatchTokens` work without leaking into the parent
- `actions`: same pattern — private `StatelessWidget` per action
- `bottom`: layout row with feature widgets. If the layout contains multiple widgets (e.g. `CityPicker` + `RunClubsSearchField` in a `Row`), own that layout in a private `PreferredSizeWidget` rather than nesting widgets inside each other
- `expandedHeight`: compute based on title content height + toolbar height + padding

Private helper widgets inside the header file are fine — they're implementation details of that header.

**File**: `<feature>/presentation/list/widgets/<feature>_sliver_header.dart`

## Widget composition: don't nest unrelated widgets

A `RunClubsSearchField` should be just a search text field. It should NOT contain a `CityPicker` just because they happen to share a `Row`. Layout is the parent's job.

**Bad**: `RunClubsSearchField` returns a `Row` containing `CityPicker` + `CatchTextField`
**Good**: `_SearchRow` (parent) lays out `CityPicker` + `RunClubsSearchField` in a `Row`

## State dispatch should live in a feature content widget

Extract `viewModelAsync.when()` into a dedicated `ConsumerWidget` (e.g. `RunClubsList`) that handles:
- loading → skeleton
- error → error text
- empty → empty state
- data → content widget

This widget also owns mutation error feedback (`MutationErrorSnackbarListener`) for mutations triggered by its content children.

## Move location/GPS logic into the widget that needs it

If a `CityPicker` needs GPS auto-detect, make it self-contained. The screen shouldn't know about `deviceLocationProvider`, `CityRepository.nearestCity()`, or GPS lifecycle. `CityPicker` becomes a `ConsumerStatefulWidget` with `initState` (post-frame callback) and `ref.listen(deviceLocationProvider)`.

## Use design-system primitives

Before writing a private helper widget, check if a core primitive already does the job:

- `CatchTextField` with `showClearButton: true` replaces any custom search field wrapper
- `CatchSliverTopBar` for collapsible sliver headers
- `CatchTopBar` for non-scrolling top bars
- `CatchTokens.of(context)` for all colors — never hardcode

If a primitive is *almost* right but missing a capability (e.g. `CatchTextField` didn't have `showClearButton`), add it to the primitive rather than wrapping it.

## Mutation error feedback placement

`MutationErrorSnackbarListener` should wrap the widget that **triggers** the mutation, not the whole screen. The screen shouldn't import mutation controllers.

## Riverpod patterns

- Data flows **down** via constructor props (`viewModel: value`)
- Mutations stay **internal** to the widget that triggers them (use `ConsumerWidget` for `ref` access)
- Don't pass `WidgetRef` through helper method parameters — if a method needs `ref`, it should be a `ConsumerWidget`

## File structure for a list screen

```
<feature>/presentation/list/
  <feature>_list_screen.dart         # StatelessWidget, layout only
  <feature>_list_view_model.dart     # providers, partitioning
  <feature>_list_controller.dart     # mutations
  widgets/
    <feature>_list.dart              # ConsumerWidget, state dispatch (loading/error/empty)
    <feature>_list_body.dart         # StatelessWidget, composes section widgets
    <feature>_sliver_header.dart     # extends CatchSliverTopBar, all header config
    <feature>_avatar_rail.dart       # CatchHorizontalRail instantiation
    <feature>_discover_list.dart     # CatchVerticalSection instantiation, owns mutations
    <feature>_search_field.dart      # single-purpose input widget
    <feature>_empty_state.dart       # empty state widget
    city_picker.dart                 # self-contained, includes GPS logic
    run_club_list_tile.dart          # tile variants (directory, avatarChip)
```
