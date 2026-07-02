// ignore_for_file: directives_ordering

/// Catch Events feature — public API barrel.
///
/// Re-exports the primary domain types, repositories, screens, and key
/// presentation artifacts consumers outside `lib/events/` rely on.
///
/// Prefer importing this barrel from outside the feature. Code within
/// `lib/events/` should import specific files to keep dependency edges
/// explicit.
library;

// ── Domain models ───────────────────────────────────────────────────────────
export 'domain/event.dart';
export 'domain/event_constraints.dart';
export 'domain/event_domain_readiness.dart';
export 'domain/event_draft.dart';
export 'domain/event_eligibility.dart';
export 'domain/event_invite_link.dart';
export 'domain/event_meeting_location.dart';
export 'domain/event_participation.dart';
export 'domain/event_participation_roster.dart';
export 'domain/event_private_access.dart';
export 'domain/external_event.dart';
export 'domain/saved_event.dart';
export 'domain/viewer_event_availability.dart';

// ── Repositories ────────────────────────────────────────────────────────────
export 'data/event_callable_adapters.dart';
export 'data/event_callable_responses.dart';
export 'data/event_discovery_repository.dart';
export 'data/event_draft_repository.dart';
export 'data/event_participation_repository.dart';
export 'data/event_repository.dart';
export 'data/external_event_repository.dart';
export 'data/saved_event_repository.dart';

// ── Presentation — screens ──────────────────────────────────────────────────
export 'presentation/event_check_in_celebration_screen.dart';
export 'presentation/event_detail_screen.dart';
export 'presentation/event_joined_celebration_screen.dart';
export 'presentation/event_location_map_screen.dart';
export 'presentation/event_map_screen.dart';
export 'presentation/location_picker_screen.dart';
export 'presentation/saved_events_screen.dart';

// ── Presentation — view models & controllers ────────────────────────────────
export 'presentation/attendance_sheet_view_model.dart';
export 'presentation/event_booking_controller.dart';
export 'presentation/event_detail_controller.dart';
export 'presentation/event_detail_view_model.dart';
export 'data/event_invite_share_copy.dart';
export 'presentation/event_map_view_model.dart';

// ── Presentation — widgets commonly reused outside the feature ──────────────
export 'presentation/widgets/event_detail_body.dart';
export 'presentation/widgets/event_detail_cta.dart';
export 'presentation/widgets/event_detail_hero_app_bar.dart';
export 'presentation/widgets/event_detail_overview_section.dart';
export 'presentation/widgets/event_detail_social_section.dart';
export 'presentation/widgets/event_hype_avatar_stack.dart';
export 'presentation/widgets/event_photo_header.dart';
export 'presentation/widgets/event_pins_map.dart';
export 'presentation/widgets/event_share_card.dart';
export 'presentation/widgets/event_stats_grid.dart';
export 'package:catch_dating_app/core/widgets/event_ticket_surface.dart';
export 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
export 'shared/event_tiles/event_tile_data.dart';
export 'shared/event_tiles/event_tiles.dart';

// ── Presentation — value types & formatters ─────────────────────────────────
export 'presentation/event_action_keys.dart';
export 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
export 'domain/event_arrival_action.dart';
export 'domain/event_check_in_qr_payload.dart';
export 'domain/event_formatters.dart';
export 'domain/event_location_links.dart';
export 'data/event_calendar_links.dart';
export 'presentation/event_detail_route_transition.dart';
export 'presentation/event_map_center.dart';
