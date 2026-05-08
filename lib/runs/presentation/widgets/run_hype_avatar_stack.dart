import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_hype_avatar_stack.g.dart';

class RunHypeAvatarQuery {
  const RunHypeAvatarQuery({
    required this.runId,
    required this.viewerInterestedInGenders,
    this.limit = 4,
  });

  final String runId;
  final List<Gender> viewerInterestedInGenders;
  final int limit;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunHypeAvatarQuery &&
          runtimeType == other.runtimeType &&
          runId == other.runId &&
          limit == other.limit &&
          _sameGenders(
            viewerInterestedInGenders,
            other.viewerInterestedInGenders,
          );

  @override
  int get hashCode => Object.hash(
    runId,
    limit,
    Object.hashAll(viewerInterestedInGenders.map((gender) => gender.name)),
  );
}

@riverpod
Future<List<PersonAvatarItem>> runHypeAvatars(
  Ref ref,
  RunHypeAvatarQuery query,
) async {
  final participations = await ref
      .watch(runParticipationRepositoryProvider)
      .fetchParticipationsForRun(runId: query.runId);
  final eligibleParticipations = _eligibleParticipations(
    participations,
    query.viewerInterestedInGenders.toSet(),
  );
  if (eligibleParticipations.isEmpty) return const [];

  final profiles = await ref
      .watch(publicProfileRepositoryProvider)
      .fetchPublicProfiles(
        eligibleParticipations
            .map((participation) => participation.uid)
            .toList(),
      );
  final profilesByUid = {for (final profile in profiles) profile.uid: profile};

  final items = <PersonAvatarItem>[];
  final interestedIn = query.viewerInterestedInGenders.toSet();
  for (final participation in eligibleParticipations) {
    final profile = profilesByUid[participation.uid];
    if (profile == null) {
      items.add(PersonAvatarItem(name: participation.uid));
    } else if (interestedIn.isEmpty || interestedIn.contains(profile.gender)) {
      items.add(
        PersonAvatarItem(
          name: profile.name,
          imageUrl: profile.photoThumbnailUrls.firstOrNull,
        ),
      );
    }
    if (items.length >= query.limit) break;
  }

  return items;
}

class RunHypeAvatarStack extends ConsumerWidget {
  const RunHypeAvatarStack({
    super.key,
    required this.runId,
    required this.totalCount,
    required this.viewerInterestedInGenders,
    this.size = 32,
    this.limit = 4,
    this.obscured = true,
    this.showOverflowCount = false,
  });

  final String runId;
  final int totalCount;
  final List<Gender> viewerInterestedInGenders;
  final double size;
  final int limit;
  final bool obscured;
  final bool showOverflowCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (totalCount <= 0) return const SizedBox.shrink();
    final avatarsAsync = ref.watch(
      runHypeAvatarsProvider(
        RunHypeAvatarQuery(
          runId: runId,
          viewerInterestedInGenders: viewerInterestedInGenders,
          limit: limit,
        ),
      ),
    );
    final items = avatarsAsync.asData?.value;
    final avatarItems = items == null || items.isEmpty
        ? _fallbackItems(runId, totalCount, limit)
        : items;

    return PersonAvatarStack(
      items: avatarItems,
      totalCount: totalCount,
      size: size,
      limit: limit,
      obscured: obscured,
      showOverflowCount: showOverflowCount,
    );
  }
}

List<RunParticipation> _eligibleParticipations(
  List<RunParticipation> participations,
  Set<Gender> viewerInterestedInGenders,
) {
  final eligible = participations.where((participation) {
    final isBooked =
        participation.status == RunParticipationStatus.signedUp ||
        participation.status == RunParticipationStatus.attended;
    if (!isBooked) return false;
    final gender = participation.genderAtSignup;
    return viewerInterestedInGenders.isEmpty ||
        gender == null ||
        viewerInterestedInGenders.contains(gender);
  }).toList()..sort(_compareRecentSignupFirst);
  return eligible;
}

int _compareRecentSignupFirst(RunParticipation a, RunParticipation b) {
  final aTime = a.signedUpAt ?? a.attendedAt ?? a.createdAt;
  final bTime = b.signedUpAt ?? b.attendedAt ?? b.createdAt;
  final byTime = bTime.compareTo(aTime);
  if (byTime != 0) return byTime;
  return a.uid.compareTo(b.uid);
}

List<PersonAvatarItem> _fallbackItems(String runId, int totalCount, int limit) {
  final count = totalCount.clamp(0, limit);
  return [
    for (var i = 0; i < count; i++)
      PersonAvatarItem(name: '$runId-hype-avatar-$i'),
  ];
}

bool _sameGenders(List<Gender> a, List<Gender> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
