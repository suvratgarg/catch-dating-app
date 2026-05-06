import 'package:catch_dating_app/runs/domain/run_participation.dart';

class RunParticipationRoster {
  const RunParticipationRoster({
    required this.bookedIds,
    required this.checkedInIds,
    required this.waitlistedIds,
  });

  factory RunParticipationRoster.fromParticipations(
    List<RunParticipation> participations,
  ) {
    final bookedParticipations =
        participations
            .where(
              (participation) => switch (participation.status) {
                RunParticipationStatus.signedUp ||
                RunParticipationStatus.attended => true,
                RunParticipationStatus.waitlisted ||
                RunParticipationStatus.cancelled ||
                RunParticipationStatus.deleted => false,
              },
            )
            .toList()
          ..sort(_compareBookedParticipations);
    final checkedInParticipations =
        participations
            .where(
              (participation) =>
                  participation.status == RunParticipationStatus.attended,
            )
            .toList()
          ..sort(_compareCheckedInParticipations);
    final waitlistedParticipations =
        participations
            .where(
              (participation) =>
                  participation.status == RunParticipationStatus.waitlisted,
            )
            .toList()
          ..sort(_compareWaitlistedParticipations);

    return RunParticipationRoster(
      bookedIds: List.unmodifiable(_uniqueUids(bookedParticipations)),
      checkedInIds: List.unmodifiable(_uniqueUids(checkedInParticipations)),
      waitlistedIds: List.unmodifiable(_uniqueUids(waitlistedParticipations)),
    );
  }

  factory RunParticipationRoster.empty() => const RunParticipationRoster(
    bookedIds: [],
    checkedInIds: [],
    waitlistedIds: [],
  );

  final List<String> bookedIds;
  final List<String> checkedInIds;
  final List<String> waitlistedIds;

  int get bookedCount => bookedIds.length;
  int get checkedInCount => checkedInIds.length;
  int get waitlistedCount => waitlistedIds.length;

  bool get isBookedEmpty => bookedIds.isEmpty;
  bool get isWaitlistEmpty => waitlistedIds.isEmpty;

  bool isCheckedIn(String uid) => checkedInIds.contains(uid);
}

List<String> _uniqueUids(List<RunParticipation> participations) {
  final ids = <String>[];
  final seen = <String>{};
  for (final participation in participations) {
    if (seen.add(participation.uid)) {
      ids.add(participation.uid);
    }
  }
  return ids;
}

int _compareBookedParticipations(RunParticipation a, RunParticipation b) {
  final aTime = a.signedUpAt ?? a.attendedAt ?? a.createdAt;
  final bTime = b.signedUpAt ?? b.attendedAt ?? b.createdAt;
  return _compareTimeThenUid(a, b, aTime, bTime);
}

int _compareCheckedInParticipations(RunParticipation a, RunParticipation b) {
  final aTime = a.attendedAt ?? a.signedUpAt ?? a.createdAt;
  final bTime = b.attendedAt ?? b.signedUpAt ?? b.createdAt;
  return _compareTimeThenUid(a, b, aTime, bTime);
}

int _compareWaitlistedParticipations(RunParticipation a, RunParticipation b) {
  final aTime = a.waitlistedAt ?? a.createdAt;
  final bTime = b.waitlistedAt ?? b.createdAt;
  return _compareTimeThenUid(a, b, aTime, bTime);
}

int _compareTimeThenUid(
  RunParticipation a,
  RunParticipation b,
  DateTime aTime,
  DateTime bTime,
) {
  final byTime = aTime.compareTo(bTime);
  if (byTime != 0) return byTime;
  return a.uid.compareTo(b.uid);
}
