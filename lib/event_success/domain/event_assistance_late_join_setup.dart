import 'package:catch_dating_app/event_success/domain/event_assistance_joining_option.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_parsing.dart';

/// The current, bounded joining choices bound to a settings review source.
final class LateJoinSettingSetup {
  const LateJoinSettingSetup._(this.eventEnd, this.destinations);
  final int eventEnd;
  final List<AssistanceJoiningOption> destinations;

  factory LateJoinSettingSetup.fromJson(
    Object? value, {
    required String groupId,
  }) {
    final map = assistanceObject(value, {'eventEnd', 'destinations'});
    final raw = map['destinations'];
    if (raw is! List || raw.length > 41) {
      throw const FormatException('Invalid joining options.');
    }
    final options = raw
        .map(
          (item) =>
              parseAssistanceJoiningOption(item, expectedGroupId: groupId),
        )
        .toList(growable: false);
    if (options.map((item) => item.target).toSet().length != options.length) {
      throw const FormatException('Duplicate joining option.');
    }
    return LateJoinSettingSetup._(
      assistanceInteger(map['eventEnd']),
      List.unmodifiable(options),
    );
  }
}
