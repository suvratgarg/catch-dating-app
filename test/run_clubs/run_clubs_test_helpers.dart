import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

RunClub buildRunClub({
  String id = 'club-1',
  String name = 'Stride Social',
  String description = 'Morning runners who like easy city loops.',
  IndianCity location = IndianCity.mumbai,
  String area = 'Bandra',
  String hostUserId = 'host-1',
  String hostName = 'Host',
  String? hostAvatarUrl,
  DateTime? createdAt,
  String? imageUrl,
  List<String> tags = const ['social'],
  List<String> memberUserIds = const ['host-1'],
  int? memberCount,
  double rating = 0,
  int reviewCount = 0,
  DateTime? nextRunAt,
  String? nextRunLabel,
  String? instagramHandle,
  String? phoneNumber,
  String? email,
}) {
  return RunClub(
    id: id,
    name: name,
    description: description,
    location: location,
    area: area,
    hostUserId: hostUserId,
    hostName: hostName,
    hostAvatarUrl: hostAvatarUrl,
    createdAt: createdAt ?? DateTime(2025, 1, 1),
    imageUrl: imageUrl,
    tags: tags,
    memberUserIds: memberUserIds,
    memberCount: memberCount ?? memberUserIds.length,
    rating: rating,
    reviewCount: reviewCount,
    nextRunAt: nextRunAt,
    nextRunLabel: nextRunLabel,
    instagramHandle: instagramHandle,
    phoneNumber: phoneNumber,
    email: email,
  );
}

UserProfile buildUser({
  required String uid,
  String name = 'Runner',
  String email = 'runner@example.com',
  List<String> joinedRunClubIds = const [],
  List<String> photoUrls = const [],
}) {
  return UserProfile(
    uid: uid,
    email: email,
    name: name,
    dateOfBirth: DateTime(1995, 6, 15),
    bio: 'Here for the runs.',
    gender: Gender.man,
    sexualOrientation: SexualOrientation.straight,
    phoneNumber: '+10000000000',
    profileComplete: true,
    joinedRunClubIds: joinedRunClubIds,
    interestedInGenders: const [Gender.woman],
    photoUrls: photoUrls,
  );
}

Run buildRun({
  String id = 'run-1',
  String runClubId = 'club-1',
  DateTime? startTime,
  DateTime? endTime,
  int priceInPaise = 0,
  List<String> signedUpUserIds = const [],
  List<String> waitlistUserIds = const [],
}) {
  final start = startTime ?? DateTime.now().add(const Duration(hours: 2));
  return Run(
    id: id,
    runClubId: runClubId,
    startTime: start,
    endTime: endTime ?? start.add(const Duration(hours: 1)),
    meetingPoint: 'Start',
    distanceKm: 5,
    pace: PaceLevel.easy,
    capacityLimit: 20,
    description: 'Easy paced run.',
    priceInPaise: priceInPaise,
    signedUpUserIds: signedUpUserIds,
    waitlistUserIds: waitlistUserIds,
    constraints: const RunConstraints(),
  );
}

Review buildReview({
  String id = 'review-1',
  String runClubId = 'club-1',
  String reviewerUserId = 'runner-1',
  String reviewerName = 'Runner 1',
  int rating = 5,
  String comment = 'Loved it.',
  DateTime? createdAt,
}) {
  return Review(
    id: id,
    runClubId: runClubId,
    reviewerUserId: reviewerUserId,
    reviewerName: reviewerName,
    rating: rating,
    comment: comment,
    createdAt: createdAt ?? DateTime(2025, 1, 2),
  );
}

Future<void> pumpTestApp(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

class FakeRunClubsRepository implements RunClubsRepository {
  String generatedId = 'generated-club-id';
  String? joinedClubId;
  String? joinedUserId;
  String? leftClubId;
  String? leftUserId;
  Object? createError;
  Object? joinError;
  Object? leaveError;
  CreateRunClubCall? lastCreateCall;
  String? lastUpdatedClubId;
  Map<String, dynamic>? lastUpdatedFields;

  final Map<String, RunClub> clubsById = {};
  final Map<IndianCity, List<RunClub>> clubsByLocation = {};

  @override
  String generateId() => generatedId;

  @override
  Future<String> createRunClub({
    String? clubId,
    required String name,
    required String description,
    required IndianCity location,
    required String area,
    required String hostUserId,
    required String hostName,
    String? hostAvatarUrl,
    String? imageUrl,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
  }) async {
    if (createError != null) {
      throw createError!;
    }
    final resolvedClubId = clubId ?? generatedId;
    lastCreateCall = CreateRunClubCall(
      clubId: resolvedClubId,
      name: name,
      description: description,
      location: location,
      area: area,
      hostUserId: hostUserId,
      hostName: hostName,
      hostAvatarUrl: hostAvatarUrl,
      imageUrl: imageUrl,
      instagramHandle: instagramHandle,
      phoneNumber: phoneNumber,
      email: email,
    );
    return resolvedClubId;
  }

  @override
  Future<void> deleteRunClub(String id) async {
    clubsById.remove(id);
  }

  @override
  Future<RunClub?> fetchRunClub(String id) async => clubsById[id];

  @override
  Future<void> joinClub(String clubId, String userId) async {
    if (joinError != null) {
      throw joinError!;
    }
    joinedClubId = clubId;
    joinedUserId = userId;
  }

  @override
  Future<void> leaveClub(String clubId, String userId) async {
    if (leaveError != null) {
      throw leaveError!;
    }
    leftClubId = clubId;
    leftUserId = userId;
  }


  @override
  Future<void> updateRunClub({
    required String clubId,
    required Map<String, dynamic> fields,
  }) async {
    lastUpdatedClubId = clubId;
    lastUpdatedFields = fields;
  }

  @override
  Stream<RunClub?> watchRunClub(String id) => Stream.value(clubsById[id]);

  @override
  Stream<List<RunClub>> watchRunClubsByLocation(IndianCity location) =>
      Stream.value(clubsByLocation[location] ?? const []);

  @override
  Stream<List<RunClub>> watchRunClubsByLocationSortedByRating(
    IndianCity location,
  ) {
    final clubs = <RunClub>[...(clubsByLocation[location] ?? const <RunClub>[])]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return Stream.value(clubs);
  }
}

class CreateRunClubCall {
  const CreateRunClubCall({
    required this.clubId,
    required this.name,
    required this.description,
    required this.location,
    required this.area,
    required this.hostUserId,
    required this.hostName,
    this.hostAvatarUrl,
    this.imageUrl,
    this.instagramHandle,
    this.phoneNumber,
    this.email,
  });

  final String clubId;
  final String name;
  final String description;
  final IndianCity location;
  final String area;
  final String hostUserId;
  final String hostName;
  final String? hostAvatarUrl;
  final String? imageUrl;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? email;
}

class FakeImageUploadRepository implements ImageUploadRepository {
  FakeImageUploadRepository({
    this.pickedImage,
    this.uploadResult = 'https://example.com/run-club-cover.jpg',
  });

  XFile? pickedImage;
  Object? pickError;
  Object? uploadError;
  String uploadResult;
  String? lastUploadClubId;
  XFile? lastUploadedImage;

  @override
  Future<XFile?> pickImage({int imageQuality = 85}) async {
    if (pickError != null) {
      throw pickError!;
    }
    return pickedImage;
  }

  @override
  Future<String> upload({
    required String storagePath,
    required XFile image,
  }) async {
    if (uploadError != null) {
      throw uploadError!;
    }
    lastUploadedImage = image;
    return uploadResult;
  }

  @override
  Future<String> uploadRunClubCover({
    required String clubId,
    required XFile image,
  }) async {
    if (uploadError != null) {
      throw uploadError!;
    }
    lastUploadClubId = clubId;
    lastUploadedImage = image;
    return uploadResult;
  }

  @override
  Future<String> uploadUserPhoto({
    required String uid,
    required int index,
    required XFile image,
  }) async {
    if (uploadError != null) {
      throw uploadError!;
    }
    lastUploadedImage = image;
    return uploadResult;
  }
}

class TestNavigatorObserver extends NavigatorObserver {
  final poppedRoutes = <Route<dynamic>>[];

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }
}
