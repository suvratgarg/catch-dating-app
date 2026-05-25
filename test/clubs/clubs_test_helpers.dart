import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

Club buildClub({
  String id = 'club-1',
  String name = 'Stride Social',
  String description = 'Morning runners who like easy city loops.',
  String location = 'mumbai',
  String area = 'Bandra',
  String hostUserId = 'host-1',
  String hostName = 'Host',
  String? hostAvatarUrl,
  String? ownerUserId,
  List<String>? hostUserIds,
  List<ClubHostProfile>? hostProfiles,
  DateTime? createdAt,
  String? imageUrl,
  String? profileImageUrl,
  List<String> tags = const ['social'],
  int memberCount = 1,
  double rating = 0,
  int reviewCount = 0,
  DateTime? nextEventAt,
  String? nextEventLabel,
  String? instagramHandle,
  String? phoneNumber,
  String? email,
}) {
  return Club(
    id: id,
    name: name,
    description: description,
    location: location,
    area: area,
    hostUserId: hostUserId,
    hostName: hostName,
    hostAvatarUrl: hostAvatarUrl,
    ownerUserId: ownerUserId,
    hostUserIds: hostUserIds ?? const [],
    hostProfiles: hostProfiles ?? const [],
    createdAt: createdAt ?? DateTime(2025, 1, 1),
    imageUrl: imageUrl,
    profileImageUrl: profileImageUrl,
    tags: tags,
    memberCount: memberCount,
    rating: rating,
    reviewCount: reviewCount,
    nextEventAt: nextEventAt,
    nextEventLabel: nextEventLabel,
    instagramHandle: instagramHandle,
    phoneNumber: phoneNumber,
    email: email,
  );
}

UserProfile buildUser({
  required String uid,
  String name = 'Runner',
  String email = 'runner@example.com',
  List<String> photoUrls = const [],
}) {
  return UserProfile(
    uid: uid,
    email: email,
    name: name,
    dateOfBirth: DateTime(1995, 6, 15),
    gender: Gender.man,
    phoneNumber: '+10000000000',
    profileComplete: true,
    interestedInGenders: const [Gender.woman],
    photoUrls: photoUrls,
    runPreferencesVersion: currentRunPreferencesVersion,
  );
}

Event buildEvent({
  String id = 'event-1',
  String clubId = 'club-1',
  DateTime? startTime,
  DateTime? endTime,
  int priceInPaise = 0,
  int? bookedCount,
  int? checkedInCount,
  int? waitlistedCount,
}) {
  final start = startTime ?? DateTime.now().add(const Duration(hours: 2));
  return Event(
    id: id,
    clubId: clubId,
    startTime: start,
    endTime: endTime ?? start.add(const Duration(hours: 1)),
    meetingPoint: 'Start',
    distanceKm: 5,
    pace: PaceLevel.easy,
    capacityLimit: 20,
    description: 'Easy paced event.',
    priceInPaise: priceInPaise,
    bookedCount: bookedCount,
    checkedInCount: checkedInCount,
    waitlistedCount: waitlistedCount,
    constraints: const EventConstraints(),
  );
}

Review buildReview({
  String id = 'review-1',
  String clubId = 'club-1',
  String reviewerUserId = 'runner-1',
  String reviewerName = 'Runner 1',
  int rating = 5,
  String comment = 'Loved it.',
  DateTime? createdAt,
}) {
  return Review(
    id: id,
    clubId: clubId,
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

class FakeClubsRepository implements ClubsRepository {
  String generatedId = 'generated-club-id';
  String? joinedClubId;
  String? leftClubId;
  String? notificationsClubId;
  String? addedHostClubId;
  String? addedHostUid;
  String? addedHostPhoneNumber;
  String? removedHostClubId;
  String? removedHostUid;
  String? transferredOwnershipClubId;
  String? transferredOwnershipUid;
  String? startedConversationClubId;
  String? startedConversationHostUid;
  String nextHostConversationMatchId = 'host-inquiry-match-id';
  bool? notificationsEnabled;
  Object? createError;
  Object? joinError;
  Object? leaveError;
  CreateClubCall? lastCreateCall;
  String? lastUpdatedClubId;
  Map<String, dynamic>? lastUpdatedFields;

  final Map<String, Club> clubsById = {};
  final Map<String, List<Club>> clubsByLocation = {};

  @override
  String generateId() => generatedId;

  @override
  Future<String> createClub({
    String? clubId,
    required String name,
    required String description,
    required String location,
    required String area,
    String? imageUrl,
    String? profileImageUrl,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
    ClubHostDefaults? hostDefaults,
  }) async {
    if (createError != null) {
      throw createError!;
    }
    final resolvedClubId = clubId ?? generatedId;
    lastCreateCall = CreateClubCall(
      clubId: resolvedClubId,
      name: name,
      description: description,
      location: location,
      area: area,
      imageUrl: imageUrl,
      profileImageUrl: profileImageUrl,
      instagramHandle: instagramHandle,
      phoneNumber: phoneNumber,
      email: email,
      hostDefaults: hostDefaults ?? const ClubHostDefaults(),
    );
    return resolvedClubId;
  }

  @override
  Future<Club?> fetchClub(String id) async => clubsById[id];

  @override
  Future<void> joinClub(String clubId) async {
    if (joinError != null) {
      throw joinError!;
    }
    joinedClubId = clubId;
  }

  @override
  Future<void> leaveClub(String clubId) async {
    if (leaveError != null) {
      throw leaveError!;
    }
    leftClubId = clubId;
  }

  @override
  Future<void> setClubPushNotifications({
    required String clubId,
    required bool enabled,
  }) async {
    notificationsClubId = clubId;
    notificationsEnabled = enabled;
  }

  @override
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {
    lastUpdatedClubId = clubId;
    lastUpdatedFields = Map<String, dynamic>.from(patch.toFieldsJson());
  }

  @override
  Stream<Club?> watchClub(String id) => Stream.value(clubsById[id]);

  @override
  Stream<List<Club>> watchClubsByLocation(String location) =>
      Stream.value(clubsByLocation[location] ?? const []);

  @override
  Stream<List<Club>> watchClubsByLocationSortedByRating(String location) {
    final clubs = <Club>[...(clubsByLocation[location] ?? const <Club>[])]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return Stream.value(clubs);
  }

  @override
  Stream<List<Club>> watchClubsHostedBy(String uid) => Stream.value(
    clubsById.values.where((club) => club.isHostedBy(uid)).toList(),
  );

  @override
  Stream<List<Club>> watchClubsOwnedBy(String uid) => Stream.value(
    clubsById.values.where((club) => club.isOwnedBy(uid)).toList(),
  );

  @override
  Future<void> addClubHost({
    required String clubId,
    String? uid,
    String? phoneNumber,
  }) async {
    addedHostClubId = clubId;
    addedHostUid = uid;
    addedHostPhoneNumber = phoneNumber;
  }

  @override
  Future<void> removeClubHost({
    required String clubId,
    required String uid,
  }) async {
    removedHostClubId = clubId;
    removedHostUid = uid;
  }

  @override
  Future<void> transferClubOwnership({
    required String clubId,
    required String uid,
  }) async {
    transferredOwnershipClubId = clubId;
    transferredOwnershipUid = uid;
  }

  @override
  Future<String> startClubHostConversation({
    required String clubId,
    required String hostUid,
  }) async {
    startedConversationClubId = clubId;
    startedConversationHostUid = hostUid;
    return nextHostConversationMatchId;
  }
}

class CreateClubCall {
  const CreateClubCall({
    required this.clubId,
    required this.name,
    required this.description,
    required this.location,
    required this.area,
    this.imageUrl,
    this.profileImageUrl,
    this.instagramHandle,
    this.phoneNumber,
    this.email,
    this.hostDefaults = const ClubHostDefaults(),
  });

  final String clubId;
  final String name;
  final String description;
  final String location;
  final String area;
  final String? imageUrl;
  final String? profileImageUrl;
  final String? instagramHandle;
  final String? phoneNumber;
  final String? email;
  final ClubHostDefaults hostDefaults;
}

class FakeImageUploadRepository implements ImageUploadRepository {
  FakeImageUploadRepository({
    this.pickedImage,
    this.uploadResult = 'https://example.com/club-cover.jpg',
  });

  XFile? pickedImage;
  Object? pickError;
  Object? uploadError;
  String uploadResult;
  String? lastUploadClubId;
  String? lastUploadEventId;
  XFile? lastUploadedImage;

  @override
  Future<XFile?> pickImage({
    ImageUploadPurpose purpose = ImageUploadPurpose.profilePhoto,
    int? imageQuality,
  }) async {
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
  Future<UploadedImage> uploadWithMetadata({
    required String storagePath,
    required XFile image,
  }) async {
    if (uploadError != null) {
      throw uploadError!;
    }
    lastUploadedImage = image;
    return UploadedImage(url: uploadResult, storagePath: '$storagePath.jpg');
  }

  @override
  Future<String> uploadClubCover({
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
  Future<String> uploadClubProfileImage({
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
  Future<String> uploadEventPhoto({
    required String clubId,
    required String eventId,
    required XFile image,
  }) async {
    if (uploadError != null) {
      throw uploadError!;
    }
    lastUploadClubId = clubId;
    lastUploadEventId = eventId;
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

  @override
  Future<UploadedImage> uploadUserProfilePhoto({
    required String uid,
    required int index,
    required XFile image,
  }) async {
    if (uploadError != null) {
      throw uploadError!;
    }
    lastUploadedImage = image;
    return UploadedImage(
      url: uploadResult,
      storagePath: 'users/$uid/photos/${index}_test.jpg',
    );
  }

  @override
  Future<String> uploadChatImage({
    required String matchId,
    required String messageId,
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
