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
export 'shared/event_check_in_celebration_screen.dart';
export 'presentation/event_detail_screen.dart'; // public-api: route entry point exposed to app routing
export 'shared/event_joined_celebration_screen.dart';
export 'presentation/event_location_map_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/event_map_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/location_picker_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/saved_events_screen.dart'; // public-api: route entry point exposed to app routing

// ── Presentation — view models & controllers ────────────────────────────────
export 'shared/attendance_sheet_view_model.dart';
export 'presentation/event_booking_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/event_detail_controller.dart'; // public-api: command seam for route-owned actions
export 'presentation/event_detail_view_model.dart'; // public-api: read-model seam for route composition
export 'shared/event_invite_share_copy.dart';
export 'presentation/event_map_view_model.dart'; // public-api: read-model seam for route composition

// ── Presentation — widgets commonly reused outside the feature ──────────────
export 'presentation/widgets/event_detail_body.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/event_detail_cta.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/event_detail_hero_app_bar.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/event_detail_overview_section.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/event_detail_social_section.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/event_hype_avatar_stack.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/event_photo_header.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/event_pins_map.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/who_is_going.dart'; // public-api: shared presentation component used outside this feature
export 'shared/event_share_card.dart';
export 'presentation/widgets/event_stats_grid.dart'; // public-api: shared presentation component used outside this feature
export 'package:catch_dating_app/core/widgets/event_ticket_surface.dart';
export 'package:catch_dating_app/core/widgets/event_visual_atoms.dart';
export 'shared/event_tiles/event_tile_data.dart';
export 'shared/event_tiles/event_tiles.dart';

// ── Presentation — value types & formatters ─────────────────────────────────
export 'presentation/event_action_keys.dart'; // public-api: presentation value/helper API used across feature boundaries
export 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
export 'domain/event_arrival_action.dart';
export 'domain/event_check_in_qr_payload.dart';
export 'domain/event_formatters.dart';
export 'domain/event_location_links.dart';
export 'data/event_calendar_links.dart';
export 'shared/event_detail_route_transition.dart';
export 'presentation/event_map_center.dart'; // public-api: presentation value/helper API used across feature boundaries
