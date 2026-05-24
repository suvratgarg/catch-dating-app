import 'dart:convert';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_draft.freezed.dart';
part 'event_draft.g.dart';

@freezed
abstract class EventDraft with _$EventDraft {
  const factory EventDraft({
    required String id,
    required String clubId,
    required DateTime savedAt,
    // Event Details step
    String? distance,
    String? capacity,
    String? price,
    String? description,
    String? activityKind,
    String? customActivityLabel,
    String? interactionModel,
    String? paceName,
    // Where step
    String? meetingPoint,
    String? locationDetails,
    String? meetingLocationAddress,
    String? meetingLocationPlaceId,
    double? startingPointLat,
    double? startingPointLng,
    // When step
    int? selectedDateMillis,
    int? selectedStartHour,
    int? selectedStartMinute,
    @Default(CatchBusinessRules.eventDefaultDurationMinutes)
    int durationMinutes,
    // Rules step
    String? minAge,
    String? maxAge,
    String? maxMen,
    String? maxWomen,
    String? admissionPreset,
    String? inviteCode,
    @Default(false) bool dynamicPricingEnabled,
    String? dynamicPricingStep,
    String? dynamicPricingMax,
    String? cancellationPolicy,
    @Default(EventSuccessDefaults()) EventSuccessDefaults eventSuccessDefaults,
  }) = _EventDraft;

  factory EventDraft.fromJson(Map<String, dynamic> json) =>
      _$EventDraftFromJson(json);

  static List<EventDraft> listFromJson(String jsonString) =>
      (jsonDecode(jsonString) as List<dynamic>)
          .map((e) => EventDraft.fromJson(e as Map<String, dynamic>))
          .toList();

  static String listToJson(List<EventDraft> drafts) =>
      jsonEncode(drafts.map((d) => d.toJson()).toList());
}

extension EventDraftX on EventDraft {
  bool get isEmpty =>
      distance == null &&
      capacity == null &&
      price == null &&
      description == null &&
      (activityKind == null || activityKind == 'socialRun') &&
      customActivityLabel == null &&
      interactionModel == null &&
      paceName == null &&
      meetingPoint == null &&
      locationDetails == null &&
      meetingLocationAddress == null &&
      meetingLocationPlaceId == null &&
      startingPointLat == null &&
      startingPointLng == null &&
      selectedDateMillis == null &&
      selectedStartHour == null &&
      selectedStartMinute == null &&
      durationMinutes == CatchBusinessRules.eventDefaultDurationMinutes &&
      minAge == null &&
      maxAge == null &&
      maxMen == null &&
      maxWomen == null &&
      admissionPreset == null &&
      inviteCode == null &&
      dynamicPricingEnabled == false &&
      dynamicPricingStep == null &&
      dynamicPricingMax == null &&
      cancellationPolicy == null &&
      eventSuccessDefaults == const EventSuccessDefaults();

  String get summary {
    final parts = <String>[];
    if (distance != null) {
      var distPart = '${distance!}km';
      if (paceName != null) distPart += ' $paceName';
      parts.add(distPart);
    } else if (customActivityLabel != null) {
      parts.add(customActivityLabel!);
    } else if (activityKind != null && activityKind != 'socialRun') {
      parts.add(_activityLabel(activityKind!));
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

String _activityLabel(String name) {
  return ActivityKind.values
      .firstWhere(
        (activityKind) => activityKind.name == name,
        orElse: () => ActivityKind.openActivity,
      )
      .label;
}
