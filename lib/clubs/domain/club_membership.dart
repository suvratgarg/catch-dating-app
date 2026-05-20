import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_membership.freezed.dart';
part 'club_membership.g.dart';

enum ClubMembershipRole { owner, host, member }

enum ClubMembershipStatus { active, left, deleted }

@freezed
abstract class ClubMembership with _$ClubMembership {
  const factory ClubMembership({
    @JsonKey(includeToJson: false) required String id,
    required String clubId,
    required String uid,
    required ClubMembershipRole role,
    required ClubMembershipStatus status,
    @Default(false) bool pushNotificationsEnabled,
    @TimestampConverter() required DateTime joinedAt,
    @NullableTimestampConverter() DateTime? leftAt,
    @NullableTimestampConverter() DateTime? deletedAt,
  }) = _ClubMembership;

  factory ClubMembership.fromJson(Map<String, dynamic> json) =>
      _$ClubMembershipFromJson(json);
}

String clubMembershipId({required String clubId, required String uid}) =>
    '${clubId}_$uid';
