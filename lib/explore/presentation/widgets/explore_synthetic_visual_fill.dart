import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const int _syntheticExploreTargetEventCount = 10;
const int _syntheticExploreTargetClubCount = 2;
const String _syntheticExploreIdPrefix = 'synthetic-explore-';

bool get shouldUseExploreSyntheticVisualFill =>
    kDebugMode && AppConfig.enableExploreSyntheticVisualFill;

List<Club> withDebugSyntheticExploreClubs(
  List<Club> clubs, {
  required Set<String> joinedClubIds,
}) {
  if (!shouldUseExploreSyntheticVisualFill) return clubs;

  final result = clubs.toList(growable: true);
  var syntheticIndex = 0;
  while (rankExploreClubIntermixCandidates(
        result,
        joinedClubIds: joinedClubIds,
      ).length <
      _syntheticExploreTargetClubCount) {
    result.add(_syntheticExploreClub(syntheticIndex));
    syntheticIndex += 1;
  }
  return result;
}

List<ExploreEventItem> withDebugSyntheticExploreItems(
  List<ExploreEventItem> items, {
  required List<Club> seedClubs,
}) {
  if (!shouldUseExploreSyntheticVisualFill) return items;

  final result = items.toList(growable: true);
  final clubs = seedClubs
      .where((club) => club.status == ClubLifecycleStatus.active)
      .where((club) => !club.archived)
      .toList(growable: true);
  if (clubs.isEmpty) clubs.add(_syntheticExploreClub(0));

  final reference = DateTime.now();
  final today = DateUtils.dateOnly(reference);
  final existingDays = {
    for (final item in result) DateUtils.dateOnly(item.event.startTime),
  };

  for (var dayOffset = 0; dayOffset < DateTime.daysPerWeek; dayOffset += 1) {
    if (topExploreThisWeekRecommendations(result, now: reference).length >=
        DateTime.daysPerWeek) {
      break;
    }
    final day = today.add(Duration(days: dayOffset));
    if (existingDays.contains(day)) continue;
    final spec =
        _syntheticExploreEventSpecs[dayOffset %
            _syntheticExploreEventSpecs.length];
    result.add(
      _syntheticExploreItem(
        club: clubs[dayOffset % clubs.length],
        spec: spec,
        day: day,
        dayOffset: dayOffset,
        variant: 0,
        reference: reference,
      ),
    );
    existingDays.add(day);
  }

  var overflowIndex = 0;
  while (result.length < _syntheticExploreTargetEventCount) {
    final dayOffset = 1 + (overflowIndex % (DateTime.daysPerWeek - 1));
    final spec =
        _syntheticExploreEventSpecs[(overflowIndex + DateTime.daysPerWeek) %
            _syntheticExploreEventSpecs.length];
    result.add(
      _syntheticExploreItem(
        club: clubs[overflowIndex % clubs.length],
        spec: spec,
        day: today.add(Duration(days: dayOffset)),
        dayOffset: dayOffset,
        variant: overflowIndex + 1,
        reference: reference,
      ),
    );
    overflowIndex += 1;
  }

  return result;
}

Club _syntheticExploreClub(int index) {
  final spec =
      _syntheticExploreClubSpecs[index % _syntheticExploreClubSpecs.length];
  return Club(
    id: '${_syntheticExploreIdPrefix}club-$index',
    name: spec.name,
    description: 'Synthetic Explore visual-fill club.',
    location: spec.location,
    area: spec.area,
    hostUserId: '${_syntheticExploreIdPrefix}host-$index',
    hostName: spec.hostName,
    createdAt: DateTime(2026, 5),
    tags: spec.tags,
    memberCount: spec.memberCount,
    rating: spec.rating,
    reviewCount: spec.reviewCount,
    nextEventAt: DateTime.now().add(Duration(days: index + 1, hours: 7)),
    nextEventLabel: spec.nextEventLabel,
  );
}

ExploreEventItem _syntheticExploreItem({
  required Club club,
  required _SyntheticExploreEventSpec spec,
  required DateTime day,
  required int dayOffset,
  required int variant,
  required DateTime reference,
}) {
  var start = DateTime(day.year, day.month, day.day, spec.hour, spec.minute);
  if (!start.isAfter(reference)) {
    start = reference.add(const Duration(hours: 2));
  }
  final event = Event(
    id: '${_syntheticExploreIdPrefix}event-$dayOffset-$variant',
    clubId: club.id,
    startTime: start,
    endTime: start.add(Duration(minutes: spec.durationMinutes)),
    meetingPoint: spec.meetingPoint,
    eventFormat: spec.eventFormat,
    distanceKm: spec.distanceKm,
    pace: spec.pace,
    capacityLimit: spec.capacityLimit,
    description: 'Synthetic Explore visual-fill event.',
    priceInPaise: spec.priceInPaise,
    bookedCount: spec.bookedCount,
  );
  return ExploreEventItem(
    event: event,
    club: club,
    status: EventTileStatus.open,
    distanceFromUserKm: spec.distanceFromUserKm,
  );
}

bool isSyntheticExploreItem(ExploreEventItem item) {
  return item.event.id.startsWith(_syntheticExploreIdPrefix);
}

bool isSyntheticExploreClub(Club club) {
  return club.id.startsWith(_syntheticExploreIdPrefix);
}

class _SyntheticExploreClubSpec {
  const _SyntheticExploreClubSpec({
    required this.name,
    required this.location,
    required this.area,
    required this.hostName,
    required this.tags,
    required this.memberCount,
    required this.rating,
    required this.reviewCount,
    required this.nextEventLabel,
  });

  final String name;
  final String location;
  final String area;
  final String hostName;
  final List<String> tags;
  final int memberCount;
  final double rating;
  final int reviewCount;
  final String nextEventLabel;
}

class _SyntheticExploreEventSpec {
  const _SyntheticExploreEventSpec({
    required this.meetingPoint,
    required this.activityKind,
    this.customActivityLabel,
    this.customInteractionModel,
    required this.distanceKm,
    required this.pace,
    required this.capacityLimit,
    required this.bookedCount,
    required this.priceInPaise,
    required this.hour,
    required this.minute,
    required this.durationMinutes,
    required this.distanceFromUserKm,
  });

  final String meetingPoint;
  final ActivityKind activityKind;
  final String? customActivityLabel;
  final EventInteractionModel? customInteractionModel;
  final double distanceKm;
  final PaceLevel pace;
  final int capacityLimit;
  final int bookedCount;
  final int priceInPaise;
  final int hour;
  final int minute;
  final int durationMinutes;
  final double distanceFromUserKm;

  EventFormatSnapshot get eventFormat {
    final label = customActivityLabel;
    if (label != null) {
      return EventFormatSnapshot.custom(
        label: label,
        interactionModel:
            customInteractionModel ?? EventInteractionModel.openFormat,
      );
    }
    return EventFormatSnapshot.fromActivityKind(activityKind);
  }
}

const _syntheticExploreClubSpecs = [
  _SyntheticExploreClubSpec(
    name: 'Lodhi Garden Event Collective',
    location: 'Delhi',
    area: 'Lodhi Garden',
    hostName: 'Aarav',
    tags: ['Social runs', 'Outdoors'],
    memberCount: 128,
    rating: 4.8,
    reviewCount: 36,
    nextEventLabel: 'Wed 7:30 PM',
  ),
  _SyntheticExploreClubSpec(
    name: 'Sundowner Run Club',
    location: 'Bengaluru',
    area: 'Indiranagar',
    hostName: 'Mira',
    tags: ['Evening runs', 'Cafe stops'],
    memberCount: 94,
    rating: 4.7,
    reviewCount: 21,
    nextEventLabel: 'Thu 6:30 PM',
  ),
];

const _syntheticExploreEventSpecs = [
  _SyntheticExploreEventSpec(
    meetingPoint: 'Lodhi Garden gate 1',
    activityKind: ActivityKind.socialRun,
    distanceKm: 10,
    pace: PaceLevel.competitive,
    capacityLimit: 8,
    bookedCount: 5,
    priceInPaise: 0,
    hour: 19,
    minute: 30,
    durationMinutes: 75,
    distanceFromUserKm: 1.2,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Long table room',
    activityKind: ActivityKind.openActivity,
    customActivityLabel: 'long table',
    customInteractionModel: EventInteractionModel.seatedTable,
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 8,
    bookedCount: 6,
    priceInPaise: 140000,
    hour: 19,
    minute: 30,
    durationMinutes: 120,
    distanceFromUserKm: 3.6,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Cubbon Park bandstand',
    activityKind: ActivityKind.socialRun,
    distanceKm: 5,
    pace: PaceLevel.easy,
    capacityLimit: 12,
    bookedCount: 9,
    priceInPaise: 0,
    hour: 6,
    minute: 30,
    durationMinutes: 60,
    distanceFromUserKm: 2.1,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'NGMA courtyard',
    activityKind: ActivityKind.openActivity,
    customActivityLabel: 'sketching strangers',
    customInteractionModel: EventInteractionModel.openFormat,
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 6,
    bookedCount: 4,
    priceInPaise: 60000,
    hour: 16,
    minute: 30,
    durationMinutes: 90,
    distanceFromUserKm: 4.8,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Corner sourdough bar',
    activityKind: ActivityKind.dinner,
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 6,
    bookedCount: 5,
    priceInPaise: 95000,
    hour: 11,
    minute: 30,
    durationMinutes: 120,
    distanceFromUserKm: 5.4,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Neighborhood court 2',
    activityKind: ActivityKind.pickleball,
    distanceKm: 0,
    pace: PaceLevel.moderate,
    capacityLimit: 10,
    bookedCount: 7,
    priceInPaise: 75000,
    hour: 18,
    minute: 0,
    durationMinutes: 75,
    distanceFromUserKm: 2.9,
  ),
  _SyntheticExploreEventSpec(
    meetingPoint: 'Museum cafe steps',
    activityKind: ActivityKind.singlesMixer,
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: 14,
    bookedCount: 8,
    priceInPaise: 50000,
    hour: 17,
    minute: 0,
    durationMinutes: 90,
    distanceFromUserKm: 6.1,
  ),
];
