import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_preview/probes.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_preview/results.dart';

class EventPolicyPreviewHarness {
  const EventPolicyPreviewHarness({this.engine = const EventPolicyEngine()});

  final EventPolicyEngine engine;

  EventPolicyPreviewResult preview(EventPolicyPreviewScenario scenario) {
    final rows = scenario.probes
        .map((probe) {
          final decision = engine.decideAdmission(
            policy: scenario.policy,
            request: probe.toAdmissionRequest(),
            roster: scenario.roster,
          );
          final price = decision.priceQuote;

          return EventPolicyPreviewRow(
            probeId: probe.id,
            probeLabel: probe.label,
            cohortId: decision.cohort.id,
            cohortLabel: decision.cohort.label,
            decisionType: decision.type,
            decisionReason: decision.reason,
            waitlistMode: decision.waitlistMode,
            basePriceInPaise: price.basePrice.inPaise,
            cohortAdjustmentInPaise: price.cohortAdjustment.inPaise,
            demandAdjustmentInPaise: price.demandAdjustment.inPaise,
            finalPriceInPaise: price.finalAmount.inPaise,
          );
        })
        .toList(growable: false);
    final cancellationRows = scenario.cancellationProbes
        .map((probe) {
          final quote = scenario.policy.cancellationPolicy.quoteFor(
            probe.toCancellationRequest(),
          );

          return EventPolicyCancellationPreviewRow(
            probeId: probe.id,
            probeLabel: probe.label,
            policyId: quote.policyId,
            policyTitle: scenario.policy.cancellationPolicy.title,
            actor: quote.actor,
            beforeStartHours: probe.beforeStart.inHours,
            isWaitlisted: probe.isWaitlisted,
            remedy: quote.remedy,
            refundAmountInPaise: quote.refundAmount.inPaise,
            creditAmountInPaise: quote.creditAmount.inPaise,
            userLabel: quote.userLabel,
            explanation: quote.explanation,
          );
        })
        .toList(growable: false);

    return EventPolicyPreviewResult(
      scenarioId: scenario.id,
      scenarioTitle: scenario.title,
      rows: rows,
      cancellationRows: cancellationRows,
    );
  }

  List<EventPolicyPreviewResult> previewAll(
    List<EventPolicyPreviewScenario> scenarios,
  ) {
    return scenarios.map(preview).toList(growable: false);
  }
}
