// ignore_for_file: directives_ordering

/// Swipes (Catches) feature — public API barrel.
///
/// Re-exports the primary domain types, repositories, screens, and key
/// presentation artifacts consumers outside `lib/swipes/` rely on.
///
/// Prefer importing this barrel from outside the feature. Code within
/// `lib/swipes/` should import specific files to keep dependency edges
/// explicit.
library;

// ── Domain models ───────────────────────────────────────────────────────────
export 'domain/swipe.dart';
export 'domain/swipe_extensions.dart';
export 'domain/swipe_window.dart';

// ── Data ────────────────────────────────────────────────────────────────────
export 'data/swipe_candidate_repository.dart';
export 'data/swipe_repository.dart';

// ── Presentation — screens ──────────────────────────────────────────────────
export 'presentation/event_recap_screen.dart';
export 'presentation/filters_screen.dart';
export 'presentation/swipe_hub_screen.dart';
export 'presentation/swipe_screen.dart';

// ── Presentation — view models & controllers ────────────────────────────────
export 'presentation/catches_hub_screen_state.dart';
export 'presentation/event_recap_view_model.dart';
export 'presentation/filters_controller.dart';
export 'presentation/filters_screen_state.dart';
export 'presentation/swipe_queue_notifier.dart';

// ── Presentation — widgets commonly reused outside the feature ──────────────
export 'presentation/profile_card_content.dart';
export 'presentation/profile_surface.dart';
export 'presentation/swipe_empty_content.dart';
export 'presentation/widgets/attended_event_tile.dart';
export 'presentation/widgets/catches_pass_button.dart';
export 'presentation/widgets/profile_card_style.dart';
export 'presentation/widgets/profile_info_chip.dart';
export 'presentation/widgets/profile_reaction_controls.dart';
export 'presentation/widgets/swipe_empty_state.dart';

// ── Presentation — value types & formatters ─────────────────────────────────
export 'presentation/swipe_keys.dart';
