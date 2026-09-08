import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_destination.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_parsing.dart';

enum AssistanceTemplateAuthority { observe, prepare, executeWithinPolicy }

enum AssistanceTemplateDisabledReason { hostChoice, organizerDefault }

enum LateJoinUnansweredRule { keepUnknownUntilCutoff, hostReviewAtDeadline }

sealed class AssistanceTemplateSetting {
  const AssistanceTemplateSetting();
  Map<String, Object?> toJson();
  factory AssistanceTemplateSetting.fromJson(Object? value) {
    final map = assistanceObject(value);
    if (map['kind'] == 'enabled') {
      assistanceObject(map, {'kind', 'authority'});
      return AssistanceTemplateEnabled(
        assistanceEnum(AssistanceTemplateAuthority.values, map['authority']),
      );
    }
    if (map['kind'] == 'disabled') {
      assistanceObject(map, {'kind', 'reason'});
      return AssistanceTemplateDisabled(
        assistanceEnum(AssistanceTemplateDisabledReason.values, map['reason']),
      );
    }
    throw const FormatException('Unknown assistance authority.');
  }
}

final class AssistanceTemplateEnabled extends AssistanceTemplateSetting {
  const AssistanceTemplateEnabled(this.authority);
  final AssistanceTemplateAuthority authority;
  @override
  Map<String, Object?> toJson() => {
    'kind': 'enabled',
    'authority': authority.name,
  };
}

final class AssistanceTemplateDisabled extends AssistanceTemplateSetting {
  const AssistanceTemplateDisabled(this.reason);
  final AssistanceTemplateDisabledReason reason;
  @override
  Map<String, Object?> toJson() => {'kind': 'disabled', 'reason': reason.name};
}

sealed class LateJoinCutoff {
  const LateJoinCutoff();
  Map<String, Object?> toJson();
  factory LateJoinCutoff.fromJson(Object? value) {
    final map = assistanceObject(value);
    if (map['kind'] == 'eventEnd') {
      assistanceObject(map, {'kind'});
      return const LateJoinEventEnd();
    }
    if (map['kind'] == 'time') {
      assistanceObject(map, {'kind', 'at'});
      return LateJoinAtTime(assistanceInteger(map['at']));
    }
    throw const FormatException('Unknown late joining cutoff.');
  }
}

final class LateJoinEventEnd extends LateJoinCutoff {
  const LateJoinEventEnd();
  @override
  Map<String, Object?> toJson() => {'kind': 'eventEnd'};
}

final class LateJoinAtTime extends LateJoinCutoff {
  LateJoinAtTime(this.at) {
    assistanceInteger(at);
  }
  final int at;
  @override
  Map<String, Object?> toJson() => {'kind': 'time', 'at': at};
}

/// Reusable configuration, without a runtime subject or provider authority.
final class AssistanceLateJoinTemplate {
  AssistanceLateJoinTemplate({
    required this.setting,
    required this.destination,
    required this.cutoff,
    required this.maxMessagesPerEpisode,
    required this.minimumMinutesBetweenMessages,
    required this.unanswered,
  }) {
    _bounded(maxMessagesPerEpisode, 100);
    _bounded(minimumMinutesBetweenMessages, 1440);
  }
  final AssistanceTemplateSetting setting;
  final LateJoinDestination destination;
  final LateJoinCutoff cutoff;
  final int maxMessagesPerEpisode;
  final int minimumMinutesBetweenMessages;
  final LateJoinUnansweredRule unanswered;

  factory AssistanceLateJoinTemplate.fromJson(Object? value) {
    final map = assistanceObject(value, {
      'kind',
      'version',
      'setting',
      'config',
    });
    if (map['kind'] != 'lateJoin' || map['version'] != 1) {
      throw const FormatException('Unsupported late joining template.');
    }
    final config = assistanceObject(map['config'], {
      'destination',
      'cutoff',
      'maxMessagesPerEpisode',
      'minimumMinutesBetweenMessages',
      'updateOn',
      'unanswered',
    });
    if (config['updateOn'] != 'materialGuidanceChange') {
      throw const FormatException('Unsupported guidance update rule.');
    }
    return AssistanceLateJoinTemplate(
      setting: AssistanceTemplateSetting.fromJson(map['setting']),
      destination: LateJoinDestination.fromJson(config['destination']),
      cutoff: LateJoinCutoff.fromJson(config['cutoff']),
      maxMessagesPerEpisode: _bounded(config['maxMessagesPerEpisode'], 100),
      minimumMinutesBetweenMessages: _bounded(
        config['minimumMinutesBetweenMessages'],
        1440,
      ),
      unanswered: assistanceEnum(
        LateJoinUnansweredRule.values,
        config['unanswered'],
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'kind': 'lateJoin',
    'version': 1,
    'setting': setting.toJson(),
    'config': {
      'destination': destination.toJson(),
      'cutoff': cutoff.toJson(),
      'maxMessagesPerEpisode': maxMessagesPerEpisode,
      'minimumMinutesBetweenMessages': minimumMinutesBetweenMessages,
      'updateOn': 'materialGuidanceChange',
      'unanswered': unanswered.name,
    },
  };
}

int _bounded(Object? value, int maximum) {
  final number = assistanceInteger(value);
  if (number > maximum) {
    throw const FormatException('Assistance limit exceeded.');
  }
  return number;
}
