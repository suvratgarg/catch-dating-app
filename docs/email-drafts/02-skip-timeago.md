# Email Draft: Why we're NOT using timeago for relative time formatting

## What we found

The initial audit found 5 places doing manual relative-time formatting, and
suggested consolidating them with the `timeago` package. On closer inspection,
none of these are a good fit for `timeago`.

## The three formatting patterns (and why each is different)

### 1. Context-sensitive date formats (`chat_list_tile.dart`)

```dart
String _formatTime(DateTime? dt) {
  if (dt == null) return '';
  final now = DateTime.now();
  if (now.difference(dt).inDays == 0) return DateFormat.jm().format(dt);  // "2:30 PM"
  if (now.difference(dt).inDays < 7) return DateFormat.E().format(dt);    // "Mon"
  return DateFormat.MMMd().format(dt);                                      // "Jan 15"
}
```

This is the standard chat-app pattern (same day = time, this week = day name,
older = date). `timeago` replaces this with "2 hours ago" / "yesterday" /
"3 days ago" which is a fundamentally different UX. Most chat apps use this
exact DateFormat-switching pattern — it's industry standard, not reinvention.

### 2. Abbreviated relative time (`activity_section.dart`)

```dart
static String _relativeTime(DateTime time, DateTime now) {
  final difference = now.difference(time);
  if (difference.inMinutes < 1) return 'Now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m';
  if (difference.inHours < 24) return '${difference.inHours}h';
  return '${difference.inDays}d';
}
```

`timeago` would produce verbose strings like "about a minute ago", "about an
hour ago". The abbreviated format ("2m", "3h") is a deliberate design choice
for a dense activity feed — the same reason Twitter/X uses "2m" not "2 minutes
ago". The conversion is 5 lines of Dart — `timeago` adds a dependency for no
meaningful reduction in code or maintenance burden.

### 3. Future-event countdown (`next_run_hero.dart`, `swipe_hub_screen.dart`)

```dart
static String _countdown(DateTime startTime) {
  final diff = startTime.difference(DateTime.now());
  if (diff.inDays >= 1) return 'IN ${diff.inDays}D';
  if (diff.inHours >= 1) return 'IN ${diff.inHours}H';
  return 'STARTING SOON';
}
```

`timeago` is designed for PAST events ("2 hours ago"). It doesn't handle
future countdowns at all.

## Decision

Keep the existing implementations. Each serves a distinct UX purpose that
`timeago` doesn't replicate well. The 3-5 line helpers are not maintenance
burden — they're thin wrappers around `DateTime.difference()`, which is the
actual "library" doing the work.
