import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_host_defaults.freezed.dart';
part 'club_host_defaults.g.dart';

@freezed
abstract class ClubHostDefaults with _$ClubHostDefaults {
  const ClubHostDefaults._();

  const factory ClubHostDefaults({
    @Default(ActivityKind.socialRun) ActivityKind primaryActivityKind,
    @Default(<ActivityKind>[]) List<ActivityKind> supportedActivityKinds,
    @Default(EventPolicyDefaults()) EventPolicyDefaults eventPolicy,
    @Default(EventSuccessDefaults()) EventSuccessDefaults eventSuccess,
    @Default(<String, EventSuccessDefaults>{})
    Map<String, EventSuccessDefaults> eventSuccessByActivityKind,
  }) = _ClubHostDefaults;

  factory ClubHostDefaults.fromJson(Map<String, dynamic> json) =>
      _$ClubHostDefaultsFromJson(json);

  List<ActivityKind> get effectiveSupportedActivityKinds {
    final values = <ActivityKind>{
      primaryActivityKind,
      ...supportedActivityKinds,
    };
    return values.toList(growable: false);
  }

  EventSuccessDefaults eventSuccessForActivity(
    ActivityKind activityKind, {
    int? targetAttendeeCount,
  }) => eventSuccessForFormat(
    EventFormatSnapshot.fromActivityKind(activityKind),
    targetAttendeeCount: targetAttendeeCount,
  );

  EventSuccessDefaults eventSuccessForFormat(
    EventFormatSnapshot format, {
    int? targetAttendeeCount,
  }) {
    final configured =
        eventSuccessByActivityKind[format.activityKind.name] ?? eventSuccess;
    return configured.normalizedForFormat(
      format,
      targetAttendeeCount: targetAttendeeCount,
    );
  }

  ClubHostDefaults copyWithEventSuccessForActivity({
    required ActivityKind activityKind,
    required EventSuccessDefaults defaults,
  }) {
    final normalized = defaults.normalizedForActivity(activityKind);
    final nextByActivity = {
      ...eventSuccessByActivityKind,
      activityKind.name: normalized,
    };
    return copyWith(
      primaryActivityKind: activityKind,
      supportedActivityKinds:
          effectiveSupportedActivityKinds.contains(activityKind)
          ? supportedActivityKinds
          : [...supportedActivityKinds, activityKind],
      eventSuccess:
          activityKind == primaryActivityKind ||
              eventSuccess == const EventSuccessDefaults()
          ? normalized
          : eventSuccess,
      eventSuccessByActivityKind: nextByActivity,
    );
  }
}
