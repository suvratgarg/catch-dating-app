import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'match.freezed.dart';
part 'match.g.dart';

enum MatchStatus { active, blocked }

@freezed
abstract class Match with _$Match {
  const Match._();

  const factory Match({
    @JsonKey(includeToJson: false) required String id,
    required String user1Id,
    required String user2Id,
    @JsonKey(readValue: _readRunIds) @Default(<String>[]) List<String> runIds,
    @TimestampConverter() required DateTime createdAt,
    @NullableTimestampConverter() DateTime? lastMessageAt,
    String? lastMessagePreview,
    String? lastMessageSenderId,
    @Default({}) Map<String, int> unreadCounts,
    @Default(MatchStatus.active) MatchStatus status,
    String? blockedBy,
    @NullableTimestampConverter() DateTime? blockedAt,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  /// Returns the UID of the other participant in this match.
  String otherId(String myUid) => user1Id == myUid ? user2Id : user1Id;

  /// Latest shared run context for legacy call sites and notification copy.
  String? get latestRunId => runIds.isEmpty ? null : runIds.last;

  bool get isBlocked => status == MatchStatus.blocked;
}

Object? _readRunIds(Map json, String key) {
  final runIds = json[key];
  if (runIds is List) return runIds;

  final legacyRunId = json['runId'];
  if (legacyRunId is String && legacyRunId.isNotEmpty) {
    return [legacyRunId];
  }

  return null;
}
