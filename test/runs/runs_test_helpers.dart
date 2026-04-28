import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Run buildRun({
  String id = 'run-1',
  String runClubId = 'club-1',
  DateTime? startTime,
  DateTime? endTime,
  String meetingPoint = 'Carter Road',
  double? startingPointLat,
  double? startingPointLng,
  String? locationDetails,
  double distanceKm = 5,
  PaceLevel pace = PaceLevel.easy,
  int capacityLimit = 20,
  String description = 'Easy paced seaside run.',
  int priceInPaise = 0,
  List<String> signedUpUserIds = const [],
  List<String> attendedUserIds = const [],
  List<String> waitlistUserIds = const [],
  RunConstraints constraints = const RunConstraints(),
  Map<String, int> genderCounts = const {},
}) {
  final start = startTime ?? DateTime.now().add(const Duration(hours: 2));
  return Run(
    id: id,
    runClubId: runClubId,
    startTime: start,
    endTime: endTime ?? start.add(const Duration(hours: 1)),
    meetingPoint: meetingPoint,
    startingPointLat: startingPointLat,
    startingPointLng: startingPointLng,
    locationDetails: locationDetails,
    distanceKm: distanceKm,
    pace: pace,
    capacityLimit: capacityLimit,
    description: description,
    priceInPaise: priceInPaise,
    signedUpUserIds: signedUpUserIds,
    attendedUserIds: attendedUserIds,
    waitlistUserIds: waitlistUserIds,
    constraints: constraints,
    genderCounts: genderCounts,
  );
}

UserProfile buildUser({
  String uid = 'runner-1',
  String name = 'Runner',
  String email = 'runner@example.com',
  Gender gender = Gender.man,
  DateTime? dateOfBirth,
  String phoneNumber = '+910000000000',
  List<String> joinedRunClubIds = const [],
  List<String> savedRunIds = const [],
  List<String> photoUrls = const [],
}) {
  return UserProfile(
    uid: uid,
    email: email,
    name: name,
    dateOfBirth: dateOfBirth ?? DateTime(1995, 6, 15),
    bio: 'Here for the run.',
    gender: gender,
    sexualOrientation: SexualOrientation.straight,
    phoneNumber: phoneNumber,
    profileComplete: true,
    joinedRunClubIds: joinedRunClubIds,
    savedRunIds: savedRunIds,
    interestedInGenders: const [Gender.woman],
    photoUrls: photoUrls,
  );
}

Review buildReview({
  String id = 'review-1',
  String runClubId = 'club-1',
  String? runId = 'run-1',
  String reviewerUserId = 'runner-1',
  String reviewerName = 'Runner 1',
  int rating = 5,
  String comment = 'Loved it.',
  DateTime? createdAt,
}) {
  return Review(
    id: id,
    runClubId: runClubId,
    runId: runId,
    reviewerUserId: reviewerUserId,
    reviewerName: reviewerName,
    rating: rating,
    comment: comment,
    createdAt: createdAt ?? DateTime(2025, 1, 2),
  );
}

RunClub buildRunClub({
  String id = 'club-1',
  String name = 'Stride Social',
  String description = 'Morning runners who like easy city loops.',
  IndianCity location = IndianCity.mumbai,
  String area = 'Bandra',
  String hostUserId = 'host-1',
  String hostName = 'Host',
  DateTime? createdAt,
}) {
  return RunClub(
    id: id,
    name: name,
    description: description,
    location: location,
    area: area,
    hostUserId: hostUserId,
    hostName: hostName,
    createdAt: createdAt ?? DateTime(2025, 1, 1),
    memberUserIds: const ['host-1'],
    memberCount: 1,
  );
}

PublicProfile buildPublicProfile({
  String uid = 'runner-1',
  String name = 'Runner',
  int age = 30,
  String bio = 'Always up for a sunrise run.',
  Gender gender = Gender.man,
  List<String> photoUrls = const [],
}) {
  return PublicProfile(
    uid: uid,
    name: name,
    age: age,
    bio: bio,
    gender: gender,
    photoUrls: photoUrls,
  );
}

Future<void> pumpRunsTestApp(
  WidgetTester tester,
  Widget child, {
  Iterable overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(theme: AppTheme.light, home: child),
    ),
  );
  await tester.pump();
}

class FakeRunRepository extends Fake implements RunRepository {
  String generatedId = 'generated-run-id';
  Run? createdRun;
  Object? createError;
  Object? cancelError;
  Object? joinWaitlistError;
  Object? leaveWaitlistError;
  Object? markAttendanceError;
  String? cancelledRunId;
  String? joinedWaitlistRunId;
  String? leftWaitlistRunId;
  String? leftWaitlistUserId;
  String? markedAttendanceRunId;
  Run? fetchedRun;
  final Map<String, Run?> watchedRuns = {};
  final Map<String, List<Run>> clubRuns = {};
  final Map<String, List<Run>> attendedRuns = {};
  final Map<String, List<Run>> signedUpRuns = {};
  List<String>? recommendedClubIds;
  List<Run> recommendedRuns = const [];

  @override
  String generateId() => generatedId;

  @override
  Future<void> createRun({required Run run}) async {
    if (createError != null) {
      throw createError!;
    }
    createdRun = run;
  }

  @override
  Future<Run?> fetchRun(String id) async => fetchedRun;

  @override
  Stream<Run?> watchRun(String id) => Stream.value(watchedRuns[id]);

  @override
  Stream<List<Run>> watchRunsForClub({required String runClubId}) =>
      Stream.value(clubRuns[runClubId] ?? const []);

  @override
  Stream<List<Run>> watchAttendedRuns({required String uid}) =>
      Stream.value(attendedRuns[uid] ?? const []);

  @override
  Stream<List<Run>> watchSignedUpRuns({required String uid}) =>
      Stream.value(signedUpRuns[uid] ?? const []);

  @override
  Future<List<Run>> fetchUpcomingRunsForClubs(List<String> runClubIds) async {
    recommendedClubIds = runClubIds;
    return recommendedRuns;
  }

  @override
  Future<void> cancelSignUpViaFunction({required String runId}) async {
    if (cancelError != null) {
      throw cancelError!;
    }
    cancelledRunId = runId;
  }

  @override
  Future<void> joinWaitlistViaFunction({required String runId}) async {
    if (joinWaitlistError != null) {
      throw joinWaitlistError!;
    }
    joinedWaitlistRunId = runId;
  }

  @override
  Future<void> leaveWaitlist({
    required String runId,
    required String userId,
  }) async {
    if (leaveWaitlistError != null) {
      throw leaveWaitlistError!;
    }
    leftWaitlistRunId = runId;
    leftWaitlistUserId = userId;
  }

  @override
  Future<void> markAttendance({required String runId}) async {
    if (markAttendanceError != null) {
      throw markAttendanceError!;
    }
    markedAttendanceRunId = runId;
  }
}

class FakePaymentRepository extends Fake implements PaymentRepository {
  FakePaymentRepository({this.supportsPaid = true});

  final bool supportsPaid;
  Object? bookFreeRunError;
  Object? processPaymentError;
  bool bookFreeRunCalled = false;
  String? bookedFreeRunId;
  bool processPaymentCalled = false;
  ProcessPaymentCall? lastProcessPaymentCall;

  @override
  bool get supportsPaidBookings => supportsPaid;

  @override
  Future<void> bookFreeRun({required String runId}) async {
    if (bookFreeRunError != null) {
      throw bookFreeRunError!;
    }
    bookFreeRunCalled = true;
    bookedFreeRunId = runId;
  }

  @override
  Future<void> processPayment({
    required String runId,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
  }) async {
    if (!supportsPaid) {
      throw const PaidBookingUnsupportedException();
    }
    if (processPaymentError != null) {
      throw processPaymentError!;
    }
    processPaymentCalled = true;
    lastProcessPaymentCall = ProcessPaymentCall(
      runId: runId,
      description: description,
      userName: userName,
      userEmail: userEmail,
      userContact: userContact,
    );
  }

  @override
  void dispose() {}
}

class ProcessPaymentCall {
  const ProcessPaymentCall({
    required this.runId,
    required this.description,
    required this.userName,
    required this.userEmail,
    required this.userContact,
  });

  final String runId;
  final String description;
  final String userName;
  final String userEmail;
  final String userContact;
}

class FakePublicProfileRepository extends Fake
    implements PublicProfileRepository {
  List<String>? lastRequestedUids;
  List<PublicProfile> profiles = const [];

  @override
  Future<List<PublicProfile>> fetchPublicProfiles(List<String> uids) async {
    lastRequestedUids = uids;
    return profiles;
  }
}

class FakeUserProfileRepository extends Fake implements UserProfileRepository {
  String? savedUid;
  String? savedRunId;
  String? unsavedUid;
  String? unsavedRunId;

  @override
  Future<void> saveRun({required String uid, required String runId}) async {
    savedUid = uid;
    savedRunId = runId;
  }

  @override
  Future<void> unsaveRun({required String uid, required String runId}) async {
    unsavedUid = uid;
    unsavedRunId = runId;
  }
}
