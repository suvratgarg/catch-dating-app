import 'package:catch_dating_app/event_policies/domain/event_policy.dart';

class EventPolicyPreviewResult {
  const EventPolicyPreviewResult({
    required this.scenarioId,
    required this.scenarioTitle,
    required this.rows,
    required this.cancellationRows,
  });

  final String scenarioId;
  final String scenarioTitle;
  final List<EventPolicyPreviewRow> rows;
  final List<EventPolicyCancellationPreviewRow> cancellationRows;

  Map<String, Object?> toDebugMap() {
    return {
      'scenarioId': scenarioId,
      'scenarioTitle': scenarioTitle,
      'rows': rows.map((row) => row.toDebugMap()).toList(),
      'cancellationRows': cancellationRows
          .map((row) => row.toDebugMap())
          .toList(),
    };
  }
}

class EventPolicyPreviewRow {
  const EventPolicyPreviewRow({
    required this.probeId,
    required this.probeLabel,
    required this.cohortId,
    required this.cohortLabel,
    required this.decisionType,
    required this.decisionReason,
    required this.waitlistMode,
    required this.basePriceInPaise,
    required this.cohortAdjustmentInPaise,
    required this.demandAdjustmentInPaise,
    required this.finalPriceInPaise,
  });

  final String probeId;
  final String probeLabel;
  final String cohortId;
  final String cohortLabel;
  final EventAdmissionDecisionType decisionType;
  final EventAdmissionDecisionReason decisionReason;
  final EventWaitlistMode waitlistMode;
  final int basePriceInPaise;
  final int cohortAdjustmentInPaise;
  final int demandAdjustmentInPaise;
  final int finalPriceInPaise;

  bool get isBookable => decisionType == EventAdmissionDecisionType.admitted;

  bool get requiresManualAction =>
      decisionType == EventAdmissionDecisionType.manualReviewRequired ||
      decisionType == EventAdmissionDecisionType.inviteRequired ||
      decisionType == EventAdmissionDecisionType.membershipRequired;

  bool get isWaitlisted =>
      decisionType == EventAdmissionDecisionType.waitlisted;

  Map<String, Object?> toDebugMap() {
    return {
      'probeId': probeId,
      'probeLabel': probeLabel,
      'cohortId': cohortId,
      'cohortLabel': cohortLabel,
      'decisionType': decisionType.name,
      'decisionReason': decisionReason.name,
      'waitlistMode': waitlistMode.name,
      'basePriceInPaise': basePriceInPaise,
      'cohortAdjustmentInPaise': cohortAdjustmentInPaise,
      'demandAdjustmentInPaise': demandAdjustmentInPaise,
      'finalPriceInPaise': finalPriceInPaise,
      'isBookable': isBookable,
      'isWaitlisted': isWaitlisted,
      'requiresManualAction': requiresManualAction,
    };
  }
}

class EventPolicyCancellationPreviewRow {
  const EventPolicyCancellationPreviewRow({
    required this.probeId,
    required this.probeLabel,
    required this.policyId,
    required this.policyTitle,
    required this.actor,
    required this.beforeStartHours,
    required this.isWaitlisted,
    required this.remedy,
    required this.refundAmountInPaise,
    required this.creditAmountInPaise,
    required this.userLabel,
    required this.explanation,
  });

  final String probeId;
  final String probeLabel;
  final EventCancellationPolicyId policyId;
  final String policyTitle;
  final EventCancellationActor actor;
  final int beforeStartHours;
  final bool isWaitlisted;
  final EventCancellationRemedy remedy;
  final int refundAmountInPaise;
  final int creditAmountInPaise;
  final String userLabel;
  final String explanation;

  Map<String, Object?> toDebugMap() {
    return {
      'probeId': probeId,
      'probeLabel': probeLabel,
      'policyId': policyId.name,
      'policyTitle': policyTitle,
      'actor': actor.name,
      'beforeStartHours': beforeStartHours,
      'isWaitlisted': isWaitlisted,
      'remedy': remedy.name,
      'refundAmountInPaise': refundAmountInPaise,
      'creditAmountInPaise': creditAmountInPaise,
      'userLabel': userLabel,
      'explanation': explanation,
    };
  }
}
