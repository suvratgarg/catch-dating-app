import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_hype_avatar_stack.g.dart';

class EventHypeAvatarQuery {
  const EventHypeAvatarQuery({
    required this.eventId,
    required this.viewerInterestedInGenders,
    this.limit = 4,
  });

  final String eventId;
  final List<Gender> viewerInterestedInGenders;
  final int limit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventHypeAvatarQuery &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          limit == other.limit &&
          _sameGenders(
            viewerInterestedInGenders,
            other.viewerInterestedInGenders,
          );

  @override
  int get hashCode => Object.hash(
    eventId,
    limit,
    Object.hashAll(viewerInterestedInGenders.map((gender) => gender.name)),
  );
}

@riverpod
Future<List<CatchPersonAvatarItem>> eventHypeAvatars(
  Ref ref,
  EventHypeAvatarQuery query,
) async {
  final participations = await ref
      .watch(eventParticipationRepositoryProvider)
      .fetchParticipationsForEvent(eventId: query.eventId);
  final eligibleParticipations = _eligibleParticipations(
    participations,
    query.viewerInterestedInGenders.toSet(),
  );
  if (eligibleParticipations.isEmpty) return const [];
  final visibleParticipations = eligibleParticipations.take(query.limit);

  final profiles = await ref
      .watch(publicProfileRepositoryProvider)
      .fetchPublicProfiles(
        visibleParticipations
            .map((participation) => participation.uid)
            .toList(),
      );
  final profilesByUid = {for (final profile in profiles) profile.uid: profile};

  final items = <CatchPersonAvatarItem>[];
  for (final participation in visibleParticipations) {
    final profile = profilesByUid[participation.uid];
    if (profile == null) {
      items.add(CatchPersonAvatarItem(name: participation.uid));
    } else {
      items.add(
        CatchPersonAvatarItem(
          name: profile.name,
          imageUrl: profile.primaryPhotoThumbnailUrl,
        ),
      );
    }
    if (items.length >= query.limit) break;
  }

  return items;
}

class EventHypeAvatarStack extends StatelessWidget {
  const EventHypeAvatarStack({
    super.key,
    required this.eventId,
    required this.totalCount,
    required this.viewerInterestedInGenders,
    this.avatarItems,
    this.size = 32,
    this.limit = 4,
    this.obscured = true,
    this.showOverflowCount = false,
    this.activityKind = ActivityKind.openActivity,
  });

  final String eventId;
  final int totalCount;
  final List<Gender> viewerInterestedInGenders;
  final List<CatchPersonAvatarItem>? avatarItems;
  final double size;
  final int limit;
  final bool obscured;
  final bool showOverflowCount;
  final ActivityKind activityKind;

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 0) return const SizedBox.shrink();
    if (obscured) {
      return CatchPersonAvatarStack(
        items: const [],
        totalCount: totalCount,
        size: size,
        limit: limit,
        veiledCount: totalCount,
        activityKind: activityKind,
        showOverflowCount: showOverflowCount,
      );
    }

    final items = avatarItems;
    final visibleItems = items == null || items.isEmpty
        ? _fallbackItems(eventId, totalCount, limit)
        : items;

    return CatchPersonAvatarStack(
      items: visibleItems,
      totalCount: totalCount,
      size: size,
      limit: limit,
      showOverflowCount: showOverflowCount,
    );
  }
}

List<EventParticipation> _eligibleParticipations(
  List<EventParticipation> participations,
  Set<Gender> viewerInterestedInGenders,
) {
  final eligible = participations.where((participation) {
    final isBooked =
        participation.status == EventParticipationStatus.signedUp ||
        participation.status == EventParticipationStatus.attended;
    if (!isBooked) return false;
    final gender = participation.genderAtSignup;
    return viewerInterestedInGenders.isEmpty ||
        gender == null ||
        viewerInterestedInGenders.contains(gender);
  }).toList()..sort(_compareRecentSignupFirst);
  return eligible;
}

int _compareRecentSignupFirst(EventParticipation a, EventParticipation b) {
  final aTime = a.signedUpAt ?? a.attendedAt ?? a.createdAt;
  final bTime = b.signedUpAt ?? b.attendedAt ?? b.createdAt;
  final byTime = bTime.compareTo(aTime);
  if (byTime != 0) return byTime;
  return a.uid.compareTo(b.uid);
}

List<CatchPersonAvatarItem> _fallbackItems(
  String eventId,
  int totalCount,
  int limit,
) {
  final count = totalCount.clamp(0, limit);
  return [
    for (var i = 0; i < count; i++)
      CatchPersonAvatarItem(name: '$eventId-hype-avatar-$i'),
  ];
}

bool _sameGenders(List<Gender> a, List<Gender> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
