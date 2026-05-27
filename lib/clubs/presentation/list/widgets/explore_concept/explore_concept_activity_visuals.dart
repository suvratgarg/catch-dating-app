import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';

typedef ExploreConceptActivityPattern = EventActivityPattern;
typedef ExploreConceptActivityVisualTheme = EventActivityVisualSpec;
typedef ExploreConceptActivityBackdrop = EventActivityBackdrop;

const exploreConceptPrimaryBrowseKinds = primaryBrowseActivityKinds;
const exploreConceptAllActivityKinds = allActivityKindsForVisuals;

EventActivityVisualSpec exploreConceptActivityVisual(ActivityKind kind) =>
    eventActivityVisual(kind);
