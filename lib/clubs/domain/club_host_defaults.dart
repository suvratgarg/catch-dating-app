import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_host_defaults.freezed.dart';
part 'club_host_defaults.g.dart';

@freezed
abstract class ClubHostDefaults with _$ClubHostDefaults {
  const factory ClubHostDefaults({
    @Default(EventPolicyDefaults()) EventPolicyDefaults eventPolicy,
    @Default(EventSuccessDefaults()) EventSuccessDefaults eventSuccess,
  }) = _ClubHostDefaults;

  factory ClubHostDefaults.fromJson(Map<String, dynamic> json) =>
      _$ClubHostDefaultsFromJson(json);
}
