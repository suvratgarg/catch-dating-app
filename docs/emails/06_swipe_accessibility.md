# Email 6: Swipe Accessibility

**To:** Suvrat
**Subject:** [Catch Audit #12] Swipe flow accessibility — Semantics for screen readers

---

## What changed

Added `Semantics` wrappers to the core swipe flow so screen reader users can navigate, understand swipe actions, and access profile information.

### Files modified (2)

| File | Change |
|------|--------|
| `lib/swipes/presentation/profile_card.dart` | `Semantics` wrapper with profile name/age + swipe hint |
| `lib/swipes/presentation/widgets/swipe_action_buttons.dart` | `Semantics` labels on pass/like buttons |

---

## Why this was made

The audit found zero accessibility support in the swipe flow — the app's primary feature. Screen reader users could not navigate between profiles, understand swipe direction, or know when they've liked/passed. This is both an ethical issue and an increasing legal requirement globally.

---

## How it was made

### ProfileCard: Semantics with dynamic label

```dart
return Semantics(
  label: 'Profile of ${profile.name}, ${profile.age}',
  hint: 'Swipe left to pass, right to like. Tap to view full profile.',
  child: ClipRRect(/* ... */),
);
```

The `label` property tells the screen reader what this element IS ("Profile of Riya, 28"). The `hint` property tells the screen reader what the user can DO with it ("Swipe left to pass, right to like. Tap to view full profile."). The label is dynamic — it changes per profile card — while the hint is static.

**Design decision — Semantics on the card, not the swipe gesture:**
The `Semantics` is on the `ClipRRect` (the visual card), not on the `GestureDetector` (which captures taps) or the `CardSwiper` (which captures swipes). Screen readers don't need to know about the gesture mechanics — they need to know what profile they're looking at and what actions are available.

### SwipeCircleButton: configurable semantic label

The `SwipeCircleButton` widget is used for both pass and like. Previously it had no accessibility label. Now it accepts a `semanticLabel` parameter:

```dart
class SwipeCircleButton extends StatelessWidget {
  const SwipeCircleButton({
    // ...
    this.semanticLabel,
  });

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? '',
      button: true,
      child: Material(/* ... */),
    );
  }
}
```

The parent `SwipeActionButtons` passes distinct labels:

```dart
SwipeCircleButton(
  icon: Icons.close_rounded,
  semanticLabel: 'Pass — swipe left',
  // ...
),
SwipeCircleButton(
  icon: Icons.favorite_rounded,
  semanticLabel: 'Like — swipe right',
  // ...
),
```

**Design decision — action-oriented labels:**
"Pass — swipe left" and "Like — swipe right" rather than just "Close button" and "Heart button." The labels describe the action AND the gesture, giving screen reader users the same mental model as sighted users (who see the card move left on pass, right on like).

**Design decision — empty string fallback, not null:**
`semanticLabel ?? ''` — when no label is provided, the `Semantics` widget still wraps the button (with `button: true`) but with an empty label. This means the screen reader announces "button" (useful for tap-target discovery) without incorrect text. If `Semantics` were omitted entirely when the label is null, the button would be invisible to screen readers.

### What was NOT changed

- **OTP fields** — already have `Semantics(label: 'One-time code', textField: true)` at `otp_page.dart:227`. The six individual digit boxes don't need separate labels — the transparent `TextField` overlay handles text input with autofill support.
- **ScrollableProfile sections** — the profile detail sections (Bio, Lifestyle, Running) are inside a `CustomScrollView` which is inherently navigable by screen readers. Adding section-level `Semantics` headers would be nice-to-have post-launch.
- **Match celebration dialog** — a 2-second auto-dismiss dialog; screen reader announcements for transient dialogs require a different pattern (live regions / announcements). Deferred.

---

## Verification

```
$ flutter analyze lib/swipes/presentation/widgets/swipe_action_buttons.dart \
                 lib/swipes/presentation/profile_card.dart
No issues found!
```

---

## Files changed

```
 lib/swipes/presentation/profile_card.dart                 | +2 lines
 lib/swipes/presentation/widgets/swipe_action_buttons.dart  | +9 lines
```

**11 lines total. The swipe flow is now navigable by screen readers.**
