import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_club.freezed.dart';
part 'run_club.g.dart';

@freezed
abstract class RunClub with _$RunClub {
  const factory RunClub({
    @JsonKey(includeToJson: false) required String id,
    required String name,
    required String description,
    required IndianCity location,
    required String area,
    required String hostUserId,
    required String hostName,
    String? hostAvatarUrl,
    @TimestampConverter() required DateTime createdAt,
    String? imageUrl,
    @Default([]) List<String> tags,
    @Default([]) List<String> memberUserIds,
    @Default(0) int memberCount,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @TimestampConverter() DateTime? nextRunAt,
    String? nextRunLabel,
  }) = _RunClub;

  factory RunClub.fromJson(Map<String, dynamic> json) =>
      _$RunClubFromJson(json);
}

extension RunClubX on RunClub {
  bool hasMember(String userId) => memberUserIds.contains(userId);

  RunClub addMember(String userId) {
    if (hasMember(userId)) {
      return this;
    }

    final updatedMemberUserIds = [...memberUserIds, userId];
    return copyWith(
      memberUserIds: updatedMemberUserIds,
      memberCount: updatedMemberUserIds.length,
    );
  }

  RunClub removeMember(String userId) {
    if (!hasMember(userId)) {
      return this;
    }

    final updatedMemberUserIds = memberUserIds
        .where((memberUserId) => memberUserId != userId)
        .toList(growable: false);
    return copyWith(
      memberUserIds: updatedMemberUserIds,
      memberCount: updatedMemberUserIds.length,
    );
  }
}
