import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club.freezed.dart';
part 'club.g.dart';

enum ClubLifecycleStatus { active, archived }

@freezed
abstract class Club with _$Club {
  const factory Club({
    @JsonKey(includeToJson: false) required String id,
    required String name,
    required String description,
    required String location,
    required String area,
    required String hostUserId,
    required String hostName,
    String? hostAvatarUrl,
    @TimestampConverter() required DateTime createdAt,
    String? imageUrl,
    @Default([]) List<String> tags,
    @Default(0) int memberCount,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @TimestampConverter() DateTime? nextEventAt,
    String? nextEventLabel,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
    @Default(ClubLifecycleStatus.active) ClubLifecycleStatus status,
    @Default(false) bool archived,
    @TimestampConverter() DateTime? archivedAt,
    String? archiveReason,
    @Default(ClubHostDefaults()) ClubHostDefaults hostDefaults,
  }) = _Club;

  factory Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);
}
