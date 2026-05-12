import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_club.freezed.dart';
part 'run_club.g.dart';

enum RunClubLifecycleStatus { active, archived }

@freezed
abstract class RunClub with _$RunClub {
  const factory RunClub({
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
    @TimestampConverter() DateTime? nextRunAt,
    String? nextRunLabel,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
    @Default(RunClubLifecycleStatus.active) RunClubLifecycleStatus status,
    @Default(false) bool archived,
    @TimestampConverter() DateTime? archivedAt,
    String? archiveReason,
  }) = _RunClub;

  factory RunClub.fromJson(Map<String, dynamic> json) =>
      _$RunClubFromJson(json);
}
