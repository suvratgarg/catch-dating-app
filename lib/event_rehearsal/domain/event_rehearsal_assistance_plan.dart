import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_destination.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_rules.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_observation.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_parsing.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_configuration.dart';

/// Explicit synthetic execution. Shared rules confer no live sender authority.
final class RehearsalAssistancePlan {
  RehearsalAssistancePlan({
    required this.rules,
    required AssistanceJoiningGuidance guidance,
    required this.departureConfirmed,
    required this.responseDeadline,
    required List<AssistanceMessageRoute> routes,
    required this.deliveryPolicy,
    List<AssistanceLaterJoiningChoice>? laterChoices,
  }) : guidance = AssistanceJoiningGuidance.fromJson(_guidanceJson(guidance)),
       routes = List.unmodifiable(routes),
       laterChoices = laterChoices == null
           ? null
           : List.unmodifiable(laterChoices) {
    if (rules.destination is LateJoinConfirmedProgress) {
      throw const FormatException(
        'Choose a concrete practice joining destination.',
      );
    }
    if (routes.isEmpty ||
        routes.length > 3 ||
        routes.toSet().length != routes.length) {
      throw const FormatException('Choose distinct practice message routes.');
    }
    if (responseDeadline != null) assistanceInteger(responseDeadline);
    if (rules.unanswered == LateJoinUnansweredRule.hostReviewAtDeadline &&
        responseDeadline == null) {
      throw const FormatException('Choose a practice response deadline.');
    }
    if (laterChoices != null &&
        (laterChoices.length > 17 ||
            laterChoices.map((choice) => choice.target).toSet().length !=
                laterChoices.length)) {
      throw const FormatException(
        'Practice joining choices must have unique destinations.',
      );
    }
  }
  final AssistanceLateJoinRules rules;
  final AssistanceJoiningGuidance guidance;
  final bool departureConfirmed;
  final int? responseDeadline;
  final List<AssistanceMessageRoute> routes;
  final AssistanceDeliveryPolicy deliveryPolicy;
  final List<AssistanceLaterJoiningChoice>? laterChoices;

  Map<String, Object?> toJson() => {
    'policy': rules.toJson(),
    'guidance': _guidanceJson(guidance),
    'departureConfirmed': departureConfirmed,
    'responseDeadline': responseDeadline,
    'routes': routes.map((route) => route.name).toList(growable: false),
    'deliveryPolicy': deliveryPolicy.toJson(),
    if (laterChoices != null)
      'laterChoices': laterChoices!
          .map((choice) => choice.toJson())
          .toList(growable: false),
  };
}

Map<String, Object?> _guidanceJson(AssistanceJoiningGuidance guidance) => {
  'revision': guidance.revision,
  'destination': guidance.destination.toJson(),
  'materialKey': guidance.materialKey,
  'text': guidance.text,
  'validUntil': guidance.validUntil,
};
