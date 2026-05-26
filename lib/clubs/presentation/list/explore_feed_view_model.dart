import 'package:catch_dating_app/clubs/presentation/list/event_discovery_view_model.dart';

export 'package:catch_dating_app/clubs/presentation/list/event_discovery_view_model.dart'
    show EventDiscoveryDayGroup, EventDiscoveryItem, EventDiscoveryViewModel;

typedef ExploreFeedViewModel = EventDiscoveryViewModel;
typedef ExploreEventItem = EventDiscoveryItem;
typedef ExploreEventDayGroup = EventDiscoveryDayGroup;

final exploreFeedViewModelProvider = eventDiscoveryViewModelProvider;
