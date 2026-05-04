# Email Draft: Adding .select() to reduce widget rebuilds

## Why

Two screens watched the entire `uidProvider` (an `AsyncValue<String?>`):

```dart
// chat_screen.dart
final uid = ref.watch(uidProvider).value;

// matches_list_screen.dart
final uidAsync = ref.watch(uidProvider);
final uid = uidAsync.asData?.value;
```

`uidProvider` is a `StreamProvider` whose `AsyncValue` wrapper can change for:
- Loading → Data transitions
- Re-authentication (the stream emits a new value)
- Any internal provider refresh

Watching the full `AsyncValue` means the widget rebuilds on ALL of these
state transitions, even though it only uses the `.value` (the actual uid
string) or `.asData?.value`.

## What changed

`.select()` narrows the watch to a specific sub-field. The widget only
rebuilds when that sub-field changes:

```dart
// chat_screen.dart — only rebuilds when .value changes
final uid = ref.watch(uidProvider.select((v) => v.value));

// matches_list_screen.dart — only rebuilds when .asData?.value changes
final uid = ref.watch(uidProvider.select((v) => v.asData?.value));
```

## When this matters

The chat screen is the most rebuild-sensitive screen in the app — it rebuilds
on every new message, every input keystroke, and every provider change.
Eliminating unnecessary rebuilds from `uidProvider` state transitions means
less layout work per message and smoother scrolling.

## How to verify

Open the chat screen and verify it still shows the correct UI. The `.select()`
is a pure optimization — behavior should be identical, just fewer rebuilds.
