// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_club_membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunClubMembership _$RunClubMembershipFromJson(Map<String, dynamic> json) =>
    _RunClubMembership(
      id: json['id'] as String,
      clubId: json['clubId'] as String,
      uid: json['uid'] as String,
      role: $enumDecode(_$RunClubMembershipRoleEnumMap, json['role']),
      status: $enumDecode(_$RunClubMembershipStatusEnumMap, json['status']),
      joinedAt: const TimestampConverter().fromJson(
        json['joinedAt'] as Timestamp,
      ),
      leftAt: const NullableTimestampConverter().fromJson(
        json['leftAt'] as Timestamp?,
      ),
      deletedAt: const NullableTimestampConverter().fromJson(
        json['deletedAt'] as Timestamp?,
      ),
    );

Map<String, dynamic> _$RunClubMembershipToJson(
  _RunClubMembership instance,
) => <String, dynamic>{
  'clubId': instance.clubId,
  'uid': instance.uid,
  'role': _$RunClubMembershipRoleEnumMap[instance.role]!,
  'status': _$RunClubMembershipStatusEnumMap[instance.status]!,
  'joinedAt': const TimestampConverter().toJson(instance.joinedAt),
  'leftAt': const NullableTimestampConverter().toJson(instance.leftAt),
  'deletedAt': const NullableTimestampConverter().toJson(instance.deletedAt),
};

const _$RunClubMembershipRoleEnumMap = {
  RunClubMembershipRole.host: 'host',
  RunClubMembershipRole.member: 'member',
};

const _$RunClubMembershipStatusEnumMap = {
  RunClubMembershipStatus.active: 'active',
  RunClubMembershipStatus.left: 'left',
  RunClubMembershipStatus.deleted: 'deleted',
};
