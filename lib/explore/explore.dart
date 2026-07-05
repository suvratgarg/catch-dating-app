/// Explore feature — public API barrel.
///
/// Prefer importing this barrel over individual files so internal reorg stays
/// invisible to external consumers.
///
library;

export 'presentation/explore_feed_view_model.dart'; // public-api: read-model seam for route composition
export 'presentation/explore_filter_logic.dart'; // public-api: presentation value/helper API used across feature boundaries
export 'presentation/explore_map_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/explore_screen.dart'; // public-api: route entry point exposed to app routing
export 'presentation/explore_view_model.dart'; // public-api: read-model seam for route composition
export 'presentation/widgets/catch_cover_story.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/catch_cross_paths_card.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/explore_body.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/explore_city_picker.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/explore_event_type_browse_grid.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/explore_events_section.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/explore_filter_rail.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/explore_header.dart'; // public-api: shared presentation component used outside this feature
export 'presentation/widgets/explore_list.dart'; // public-api: shared presentation component used outside this feature
