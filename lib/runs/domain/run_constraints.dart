import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_constraints.freezed.dart';
part 'run_constraints.g.dart';

@freezed
abstract class RunConstraints with _$RunConstraints {
  const RunConstraints._();

  const factory RunConstraints({
    @Default(0) int minAge,
    @Default(99) int maxAge,
    int? maxMen,
    int? maxWomen,
  }) = _RunConstraints;

  factory RunConstraints.fromJson(Map<String, dynamic> json) =>
      _$RunConstraintsFromJson(json);

  /// Returns the gender-specific cap for [gender], or null if uncapped.
  int? maxForGender(Gender gender) => switch (gender) {
        Gender.man => maxMen,
        Gender.woman => maxWomen,
        _ => null,
      };
}
