import 'package:catch_dating_app/app_user/domain/app_user.dart';
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

  bool get hasRequirements =>
      minAge > 0 || maxAge < 99 || maxMen != null || maxWomen != null;

  List<String> get requirementLabels {
    final labels = <String>[];

    if (minAge > 0 && maxAge < 99) {
      labels.add('Age $minAge–$maxAge');
    } else if (minAge > 0) {
      labels.add('$minAge+ years');
    } else if (maxAge < 99) {
      labels.add('Up to $maxAge years');
    }

    if (maxMen != null) labels.add('Max $maxMen men');
    if (maxWomen != null) labels.add('Max $maxWomen women');

    return labels;
  }

  /// Returns the gender-specific cap for [gender], or null if uncapped.
  int? maxForGender(Gender gender) => switch (gender) {
    Gender.man => maxMen,
    Gender.woman => maxWomen,
    _ => null,
  };
}
