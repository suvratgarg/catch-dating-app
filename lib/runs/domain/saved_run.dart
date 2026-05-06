import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_run.freezed.dart';
part 'saved_run.g.dart';

@freezed
abstract class SavedRun with _$SavedRun {
  const factory SavedRun({
    @JsonKey(includeToJson: false) required String id,
    required String uid,
    required String runId,
    @TimestampConverter() required DateTime savedAt,
    @NullableTimestampConverter() DateTime? removedAt,
  }) = _SavedRun;

  factory SavedRun.fromJson(Map<String, dynamic> json) =>
      _$SavedRunFromJson(json);
}

String savedRunId({required String uid, required String runId}) =>
    '${uid}_$runId';
