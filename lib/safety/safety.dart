// ignore_for_file: directives_ordering

/// Catch Safety feature — public API barrel.
///
/// Re-exports the primary domain types, repositories, screens, and key
/// presentation artifacts consumers outside `lib/safety/` rely on.
///
/// Prefer importing this barrel from outside the feature. Code within
/// `lib/safety/` should import specific files to keep dependency edges
/// explicit.
library;

// ── Domain models ───────────────────────────────────────────────────────────
export 'domain/blocked_user.dart';

// ── Data ────────────────────────────────────────────────────────────────────
export 'data/safety_repository.dart';

// ── Presentation — screens ──────────────────────────────────────────────────
export 'presentation/settings_screen.dart';

// ── Presentation — controllers & state ──────────────────────────────────────
export 'presentation/settings_controller.dart';
export 'presentation/settings_account_state.dart';
export 'presentation/settings_keys.dart';
