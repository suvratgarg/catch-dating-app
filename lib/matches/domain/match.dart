import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'match.freezed.dart';
part 'match.g.dart';

@freezed
abstract class Match with _$Match {
  const Match._();

  const factory Match({
    @JsonKey(includeToJson: false) required String id,
    required String user1Id,
    required String user2Id,
    required String runId,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? lastMessageAt,
    String? lastMessagePreview,
    String? lastMessageSenderId,
    @Default({}) Map<String, int> unreadCounts,
    @Default('active') String status,
    String? blockedBy,
    @NullableTimestampConverter() DateTime? blockedAt,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  /// Returns the UID of the other participant in this match.
  String otherId(String myUid) => user1Id == myUid ? user2Id : user1Id;

  bool get isBlocked => status == 'blocked';
}
