import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club.freezed.dart';
part 'club.g.dart';

enum ClubLifecycleStatus { active, archived }

enum ClubAppVisibility { discoverable, hidden }

/// Canonical organizer classification shared by clubs, communities,
/// individuals, event producers, venues, and brands.
enum OrganizerType { club, community, individual, eventProducer, venue, brand }

Object? _readOrganizerType(Map<dynamic, dynamic> json, String key) {
  final organizerType = json[key];
  if (organizerType is String &&
      OrganizerType.values.any((value) => value.name == organizerType)) {
    return organizerType;
  }
  return switch (json['entityKind']) {
    'creatorCommunity' => OrganizerType.community.name,
    'eventOrganizer' => OrganizerType.eventProducer.name,
    'venue' => OrganizerType.venue.name,
    'brand' => OrganizerType.brand.name,
    _ => OrganizerType.club.name,
  };
}

Object? _readOrganizerPhotos(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['clubPhotos'];

Object? _readFollowerCount(Map<dynamic, dynamic> json, String key) =>
    json[key] ?? json['memberCount'];

@freezed
abstract class Club with _$Club {
  const Club._();

  const factory Club({
    @JsonKey(includeToJson: false) required String id,
    required String name,
    required String description,
    required String location,
    @Default('') String locationCityId,
    @Default('') String locationMarketId,
    required String area,
    String? hostUserId,
    String? hostName,
    String? hostAvatarUrl,
    String? ownerUserId,
    @Default([]) List<String> hostUserIds,
    @Default([]) List<ClubHostProfile> hostProfiles,
    @TimestampConverter() required DateTime createdAt,
    String? imageUrl,
    String? profileImageUrl,
    @JsonKey(name: 'organizerPhotos', readValue: _readOrganizerPhotos)
    @Default([])
    List<UploadedPhoto> clubPhotos,
    UploadedPhoto? logoPhoto,
    @Default([]) List<String> tags,
    @JsonKey(name: 'followerCount', readValue: _readFollowerCount)
    @Default(0)
    int memberCount,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @NullableTimestampConverter() DateTime? nextEventAt,
    String? nextEventLabel,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
    @Default(ClubLifecycleStatus.active) ClubLifecycleStatus status,
    @Default(false) bool archived,
    @NullableTimestampConverter() DateTime? archivedAt,
    String? archiveReason,
    @Default(ClubAppVisibility.discoverable) ClubAppVisibility appVisibility,
    @JsonKey(readValue: _readOrganizerType)
    @Default(OrganizerType.club)
    OrganizerType organizerType,
    String? publicCategoryLabel,
    @Default(ClubHostDefaults()) ClubHostDefaults hostDefaults,
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);

  String? get ownerOrPrimaryHostUserId => ownerUserId ?? hostUserId;

  String get displayHostName {
    final trimmedHostName = hostName?.trim();
    if (trimmedHostName != null && trimmedHostName.isNotEmpty) {
      return trimmedHostName;
    }
    return name;
  }

  bool isOwnedBy(String? uid) => uid != null && uid == ownerOrPrimaryHostUserId;

  bool isHostedBy(String? uid) {
    if (uid == null) return false;
    return uid == hostUserId ||
        uid == ownerUserId ||
        hostUserIds.contains(uid) ||
        hostProfiles.any((host) => host.uid == uid);
  }

  List<ClubHostProfile> get displayHostProfiles {
    if (hostProfiles.isNotEmpty) return hostProfiles;
    final primaryHostUserId = hostUserId;
    if (primaryHostUserId == null) return const [];
    return [
      ClubHostProfile(
        uid: primaryHostUserId,
        displayName: displayHostName,
        avatarUrl: hostAvatarUrl,
        role: ClubHostRole.owner,
      ),
    ];
  }

  String? get primaryClubPhotoUrl {
    if (clubPhotos.isNotEmpty) return clubPhotos.first.url;
    return imageUrl;
  }

  List<UploadedPhoto> get organizerPhotos => clubPhotos;

  int get followerCount => memberCount;

  String? get logoPhotoUrl => logoPhoto?.thumbnailOrUrl ?? profileImageUrl;

  bool get isAppDiscoverable =>
      appVisibility == ClubAppVisibility.discoverable &&
      status == ClubLifecycleStatus.active &&
      !archived;
}

enum ClubHostRole { owner, host }

@freezed
abstract class ClubHostProfile with _$ClubHostProfile {
  const factory ClubHostProfile({
    required String uid,
    required String displayName,
    String? avatarUrl,
    @Default(ClubHostRole.host) ClubHostRole role,
  }) = _ClubHostProfile;

  factory ClubHostProfile.fromJson(Map<String, dynamic> json) =>
      _$ClubHostProfileFromJson(json);
}
