// ignore_for_file: directives_ordering

/// Catch Clubs feature — public API barrel.
///
/// Re-exports the primary domain types, repositories, screens, and key
/// presentation artifacts consumers outside `lib/clubs/` rely on.
///
/// Prefer importing this barrel from outside the feature. Code within
/// `lib/clubs/` should import specific files to keep dependency edges
/// explicit.
library;

// ── Domain models ───────────────────────────────────────────────────────────
export 'domain/club.dart';
export 'domain/club_draft.dart';
export 'domain/club_host_defaults.dart';
export 'domain/club_membership.dart';
export 'domain/club_membership_extensions.dart';
export 'domain/update_club_patch.dart';

// ── Data ────────────────────────────────────────────────────────────────────
export 'data/club_callable_responses.dart';
export 'data/club_draft_repository.dart';
export 'data/club_membership_repository.dart';
export 'data/clubs_repository.dart';

// ── Presentation — screens ──────────────────────────────────────────────────
export 'presentation/detail/club_detail_screen.dart';

// ── Presentation — view models & controllers ────────────────────────────────
export 'presentation/detail/club_detail_view_model.dart';
export 'presentation/detail/club_host_contact_controller.dart';
export 'presentation/detail/club_membership_controller.dart';

// ── Presentation — widgets commonly reused outside the feature ──────────────
export 'presentation/detail/widgets/catch_club_dock.dart';
export 'presentation/detail/widgets/club_detail_body.dart';
export 'presentation/detail/widgets/club_detail_skeleton.dart';
export 'presentation/detail/widgets/club_hero_app_bar.dart';
export 'presentation/detail/widgets/club_schedule_section.dart';
export 'presentation/detail/widgets/club_share_card.dart';
export 'presentation/discovery/widgets/club_avatar_rail.dart';
export 'presentation/discovery/widgets/club_discover_list.dart';
export 'presentation/discovery/widgets/club_list_tile.dart';
export 'shared/catch_polaroid.dart';
export 'shared/club_identity_atoms.dart';
export 'shared/club_transition_tags.dart';

// ── Presentation — value types & formatters ─────────────────────────────────
export 'shared/club_action_keys.dart';
export 'data/club_name_lookup.dart';
