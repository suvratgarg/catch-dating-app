import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_club_membership.freezed.dart';
part 'run_club_membership.g.dart';

enum RunClubMembershipRole { host, member }

enum RunClubMembershipStatus { active, left, deleted }

@freezed
abstract class RunClubMembership with _$RunClubMembership {
  const factory RunClubMembership({
    @JsonKey(includeToJson: false) required String id,
    required String clubId,
    required String uid,
    required RunClubMembershipRole role,
    required RunClubMembershipStatus status,
    @Default(false) bool pushNotificationsEnabled,
    @TimestampConverter() required DateTime joinedAt,
    @NullableTimestampConverter() DateTime? leftAt,
    @NullableTimestampConverter() DateTime? deletedAt,
  }) = _RunClubMembership;

  factory RunClubMembership.fromJson(Map<String, dynamic> json) =>
      _$RunClubMembershipFromJson(json);
}

String runClubMembershipId({required String clubId, required String uid}) =>
    '${clubId}_$uid';
