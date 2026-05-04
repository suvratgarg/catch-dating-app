import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_draft.freezed.dart';
part 'run_draft.g.dart';

@freezed
abstract class RunDraft with _$RunDraft {
  const factory RunDraft({
    required String id,
    required String runClubId,
    required DateTime savedAt,
    // Run Details step
    String? distance,
    String? capacity,
    String? price,
    String? description,
    String? paceName,
    // Where step
    String? meetingPoint,
    String? locationDetails,
    double? startingPointLat,
    double? startingPointLng,
    // When step
    int? selectedDateMillis,
    int? selectedStartHour,
    int? selectedStartMinute,
    @Default(60) int durationMinutes,
    // Rules step
    String? minAge,
    String? maxAge,
    String? maxMen,
    String? maxWomen,
  }) = _RunDraft;

  factory RunDraft.fromJson(Map<String, dynamic> json) =>
      _$RunDraftFromJson(json);

  static List<RunDraft> listFromJson(String jsonString) =>
      (jsonDecode(jsonString) as List<dynamic>)
          .map((e) => RunDraft.fromJson(e as Map<String, dynamic>))
          .toList();

  static String listToJson(List<RunDraft> drafts) =>
      jsonEncode(drafts.map((d) => d.toJson()).toList());
}

extension RunDraftX on RunDraft {
  bool get isEmpty =>
      distance == null &&
      capacity == null &&
      price == null &&
      description == null &&
      paceName == null &&
      meetingPoint == null &&
      locationDetails == null &&
      startingPointLat == null &&
      selectedDateMillis == null &&
      minAge == null &&
      maxAge == null &&
      maxMen == null &&
      maxWomen == null;

  String get summary {
    final parts = <String>[];
    if (distance != null) {
      var distPart = '${distance!}km';
      if (paceName != null) distPart += ' $paceName';
      parts.add(distPart);
    } else if (paceName != null) {
      parts.add(paceName!);
    }
    if (meetingPoint != null) parts.add(meetingPoint!);
    if (selectedDateMillis != null) {
      final d = DateTime.fromMillisecondsSinceEpoch(selectedDateMillis!);
      parts.add('${d.day}/${d.month}');
    }
    if (parts.isEmpty) return 'Empty draft';
    return parts.join(' · ');
  }
}
