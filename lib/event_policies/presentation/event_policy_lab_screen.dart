import 'dart:convert';

import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/stat_column.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_preview.dart';
import 'package:flutter/material.dart';

abstract final class EventPolicyLabKeys {
  static const scenarioList = ValueKey('event-policy-lab.scenario-list');
  static const resultList = ValueKey('event-policy-lab.result-list');
  static const debugOutput = ValueKey('event-policy-lab.debug-output');

  static Key scenarioCard(String scenarioId) =>
      ValueKey('event-policy-lab.scenario.$scenarioId');

  static Key resultRow(String probeId) =>
      ValueKey('event-policy-lab.result.$probeId');
}

class EventPolicyLabScreen extends StatefulWidget {
  const EventPolicyLabScreen({super.key});

  @override
  State<EventPolicyLabScreen> createState() => _EventPolicyLabScreenState();
}

class _EventPolicyLabScreenState extends State<EventPolicyLabScreen> {
  static const _harness = EventPolicyPreviewHarness();
  EventPolicyPreviewScenario _scenario =
      EventPolicyPreviewCatalog.defaultScenarios.first;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final result = _harness.preview(_scenario);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Event policy lab', border: true),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            CatchSpacing.s8,
          ),
          children: [
            _LabHeader(scenario: _scenario),
            gapH16,
            _ScenarioPicker(
              selectedScenario: _scenario,
              onSelected: (scenario) => setState(() => _scenario = scenario),
            ),
            gapH20,
            _PolicySummary(scenario: _scenario),
            gapH20,
            _ResultRows(result: result),
            gapH20,
            _CancellationRows(result: result),
            gapH20,
            _DebugOutput(result: result),
          ],
        ),
      ),
    );
  }
}

class _LabHeader extends StatelessWidget {
  const _LabHeader({required this.scenario});

  final EventPolicyPreviewScenario scenario;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final policy = scenario.policy.admissionPolicy;
    final pricing = scenario.policy.pricingPolicy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s1,
          children: [
            CatchBadge(
              label: 'In development',
              tone: CatchBadgeTone.warning,
              icon: CatchIcons.scienceOutlined,
            ),
            CatchBadge(
              label: 'No live writes',
              tone: CatchBadgeTone.success,
              icon: CatchIcons.lockOutlineRounded,
            ),
          ],
        ),
        gapH12,
        Text(
          scenario.title,
          style: CatchTextStyles.titleL(context, color: t.ink),
        ),
        gapH6,
        Text(
          scenario.description,
          style: CatchTextStyles.bodyLead(context, color: t.ink2),
        ),
        gapH16,
        LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth <
                ComponentBreakpoints.eventPolicyLabMetricsBreakpoint;
            final children = [
              _MetricTile(
                icon: CatchIcons.groupOutlined,
                label: 'Capacity',
                value: '${policy.capacityLimit}',
              ),
              _MetricTile(
                icon: CatchIcons.confirmationNumberOutlined,
                label: 'Base',
                value: _formatPaise(pricing.basePrice.inPaise),
              ),
              _MetricTile(
                icon: CatchIcons.eventSeatOutlined,
                label: 'Booked',
                value: '${scenario.roster.totalBooked}',
              ),
              _MetricTile(
                icon: CatchIcons.scheduleOutlined,
                label: 'Waitlist',
                value: '${scenario.roster.totalWaitlisted}',
              ),
            ];

            if (compact) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: children[0]),
                      gapW8,
                      Expanded(child: children[1]),
                    ],
                  ),
                  gapH8,
                  Row(
                    children: [
                      Expanded(child: children[2]),
                      gapW8,
                      Expanded(child: children[3]),
                    ],
                  ),
                ],
              );
            }

            return Row(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  Expanded(child: children[i]),
                  if (i != children.length - 1) gapW8,
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s3),
      borderColor: t.line,
      child: StatColumn(
        icon: icon,
        value: value,
        label: label,
        center: true,
        monoValue: label == 'Base',
      ),
    );
  }
}

class _ScenarioPicker extends StatelessWidget {
  const _ScenarioPicker({
    required this.selectedScenario,
    required this.onSelected,
  });

  final EventPolicyPreviewScenario selectedScenario;
  final ValueChanged<EventPolicyPreviewScenario> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: CatchIcons.tuneRounded,
          title: 'Host configuration',
          trailing: Text(
            '${EventPolicyPreviewCatalog.defaultScenarios.length} fixtures',
            style: CatchTextStyles.labelS(
              context,
              color: CatchTokens.of(context).ink3,
            ),
          ),
        ),
        gapH10,
        SingleChildScrollView(
          key: EventPolicyLabKeys.scenarioList,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final scenario
                  in EventPolicyPreviewCatalog.defaultScenarios) ...[
                _ScenarioCard(
                  scenario: scenario,
                  selected: scenario.id == selectedScenario.id,
                  onTap: () => onSelected(scenario),
                ),
                gapW10,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ScenarioCard extends StatelessWidget {
  const _ScenarioCard({
    required this.scenario,
    required this.selected,
    required this.onTap,
  });

  final EventPolicyPreviewScenario scenario;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = selected ? t.primary : t.ink;

    return SizedBox(
      width: CatchLayout.eventPolicyLabScenarioCardWidth,
      child: CatchSurface(
        key: EventPolicyLabKeys.scenarioCard(scenario.id),
        onTap: onTap,
        padding: const EdgeInsets.all(CatchSpacing.s4),
        backgroundColor: selected ? t.primarySoft : t.surface,
        borderColor: selected ? t.primary : t.line,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _formatIcon(scenario.policy.admissionPolicy.format),
              color: color,
            ),
            gapH10,
            Text(
              scenario.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.sectionTitle(context, color: color),
            ),
            gapH6,
            Text(
              _formatAdmissionFormat(scenario.policy.admissionPolicy.format),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySummary extends StatelessWidget {
  const _PolicySummary({required this.scenario});

  final EventPolicyPreviewScenario scenario;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final admission = scenario.policy.admissionPolicy;
    final pricing = scenario.policy.pricingPolicy;
    final cancellation = scenario.policy.cancellationPolicy;
    final settlement = scenario.policy.settlementPolicy;
    final ratio = admission.balancedRatioPolicy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: CatchIcons.ruleRounded, title: 'Policy shape'),
        gapH10,
        CatchSurface(
          padding: const EdgeInsets.all(CatchSpacing.s4),
          borderColor: t.line,
          child: Column(
            children: [
              _PolicyLine(
                icon: CatchIcons.eventAvailableOutlined,
                label: 'Admission',
                value: _formatAdmissionFormat(admission.format),
              ),
              _DividerLine(color: t.line),
              _PolicyLine(
                icon: CatchIcons.queueOutlined,
                label: 'Waitlist',
                value: _formatWaitlist(admission.waitlistPolicy.mode),
              ),
              if (admission.inviteRequired) ...[
                _DividerLine(color: t.line),
                _PolicyLine(
                  icon: CatchIcons.keyOutlined,
                  label: 'Invite',
                  value: 'Required',
                ),
              ],
              if (admission.membershipRequired) ...[
                _DividerLine(color: t.line),
                _PolicyLine(
                  icon: CatchIcons.cardMembershipOutlined,
                  label: 'Membership',
                  value: 'Required',
                ),
              ],
              if (admission.manualApprovalRequired) ...[
                _DividerLine(color: t.line),
                _PolicyLine(
                  icon: CatchIcons.factCheckOutlined,
                  label: 'Host review',
                  value: 'Required',
                ),
              ],
              if (admission.cohortCapacityLimits.isNotEmpty) ...[
                _DividerLine(color: t.line),
                _PolicyLine(
                  icon: CatchIcons.groups2Outlined,
                  label: 'Cohort caps',
                  value: _formatCohortCaps(admission.cohortCapacityLimits),
                ),
              ],
              if (ratio != null) ...[
                _DividerLine(color: t.line),
                _PolicyLine(
                  icon: CatchIcons.balanceOutlined,
                  label: 'Ratio',
                  value:
                      '${_formatCohortId(ratio.leftCohortId)} / ${_formatCohortId(ratio.rightCohortId)} · ±${ratio.maxSkew}',
                ),
                _DividerLine(color: t.line),
                _PolicyLine(
                  icon: CatchIcons.diversity3Outlined,
                  label: 'Out-of-ratio',
                  value: _formatOutOfRatio(ratio.outOfRatioCohortPolicy),
                ),
              ],
              if (pricing.cohortAdjustments.isNotEmpty) ...[
                _DividerLine(color: t.line),
                _PolicyLine(
                  icon: CatchIcons.discountOutlined,
                  label: 'Cohort pricing',
                  value: pricing.cohortAdjustments.entries
                      .map(
                        (entry) =>
                            '${_formatCohortId(entry.key)} ${_formatSignedPaise(entry.value.inPaise)}',
                      )
                      .join(' · '),
                ),
              ],
              if (pricing.demandPricingRules.isNotEmpty) ...[
                _DividerLine(color: t.line),
                _PolicyLine(
                  icon: CatchIcons.trendingUpRounded,
                  label: 'Demand pricing',
                  value: pricing.demandPricingRules
                      .map(
                        (rule) =>
                            '${_formatCohortId(rule.pricedCohortId)} ${_formatSignedPaise(rule.stepAdjustment.inPaise)} / ${rule.demandStep}',
                      )
                      .join(' · '),
                ),
              ],
              _DividerLine(color: t.line),
              _PolicyLine(
                icon: CatchIcons.eventBusyOutlined,
                label: 'Cancellation',
                value: cancellation.title,
              ),
              _DividerLine(color: t.line),
              _PolicyLine(
                icon: CatchIcons.assignmentReturnOutlined,
                label: 'Attendee terms',
                value: cancellation.attendeeSummary,
              ),
              _DividerLine(color: t.line),
              _PolicyLine(
                icon: CatchIcons.paymentsOutlined,
                label: 'Host payout',
                value: settlement.title,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultRows extends StatelessWidget {
  const _ResultRows({required this.result});

  final EventPolicyPreviewResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: EventPolicyLabKeys.resultList,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: CatchIcons.tableRowsOutlined,
          title: 'Preview outcomes',
          trailing: Text(
            '${result.rows.length} probes',
            style: CatchTextStyles.labelS(
              context,
              color: CatchTokens.of(context).ink3,
            ),
          ),
        ),
        gapH10,
        for (var index = 0; index < result.rows.length; index++) ...[
          _ResultRow(row: result.rows[index]),
          if (index != result.rows.length - 1) gapH10,
        ],
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.row});

  final EventPolicyPreviewRow row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final tone = _decisionTone(row.decisionType);

    return CatchSurface(
      key: EventPolicyLabKeys.resultRow(row.probeId),
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.probeLabel,
                      style: CatchTextStyles.sectionTitle(
                        context,
                        color: t.ink,
                      ),
                    ),
                    gapH4,
                    Text(
                      row.cohortLabel,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              gapW8,
              CatchBadge(label: _formatDecision(row.decisionType), tone: tone),
            ],
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: _formatReason(row.decisionReason),
                tone: CatchBadgeTone.neutral,
                icon: CatchIcons.infoOutline,
              ),
              CatchBadge(
                label: _formatWaitlist(row.waitlistMode),
                tone: CatchBadgeTone.neutral,
                icon: CatchIcons.queueOutlined,
              ),
              CatchBadge(
                label: _formatPaise(row.finalPriceInPaise),
                tone: CatchBadgeTone.neutral,
                icon: CatchIcons.paymentsOutlined,
              ),
            ],
          ),
          if (row.cohortAdjustmentInPaise != 0 ||
              row.demandAdjustmentInPaise != 0) ...[
            gapH10,
            Text(
              'Base ${_formatPaise(row.basePriceInPaise)} · cohort ${_formatSignedPaise(row.cohortAdjustmentInPaise)} · demand ${_formatSignedPaise(row.demandAdjustmentInPaise)}',
              style: CatchTextStyles.supporting(context, color: t.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

class _CancellationRows extends StatelessWidget {
  const _CancellationRows({required this.result});

  final EventPolicyPreviewResult result;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          icon: CatchIcons.assignmentReturnOutlined,
          title: 'Cancellation outcomes',
          trailing: Text(
            '${result.cancellationRows.length} probes',
            style: CatchTextStyles.labelS(context, color: t.ink3),
          ),
        ),
        gapH10,
        for (
          var index = 0;
          index < result.cancellationRows.length;
          index++
        ) ...[
          _CancellationRow(row: result.cancellationRows[index]),
          if (index != result.cancellationRows.length - 1) gapH10,
        ],
      ],
    );
  }
}

class _CancellationRow extends StatelessWidget {
  const _CancellationRow({required this.row});

  final EventPolicyCancellationPreviewRow row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.probeLabel,
                      style: CatchTextStyles.sectionTitle(
                        context,
                        color: t.ink,
                      ),
                    ),
                    gapH4,
                    Text(
                      '${_formatCancellationActor(row.actor)} · ${row.beforeStartHours}h before start',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              gapW8,
              CatchBadge(
                label: row.userLabel,
                tone: _cancellationTone(row.remedy),
              ),
            ],
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: _formatCancellationRemedy(row.remedy),
                tone: CatchBadgeTone.neutral,
                icon: CatchIcons.ruleOutlined,
              ),
              CatchBadge(
                label: 'Refund ${_formatPaise(row.refundAmountInPaise)}',
                tone: CatchBadgeTone.neutral,
                icon: CatchIcons.paymentsOutlined,
              ),
              CatchBadge(
                label: 'Credit ${_formatPaise(row.creditAmountInPaise)}',
                tone: CatchBadgeTone.neutral,
                icon: CatchIcons.accountBalanceWalletOutlined,
              ),
              if (row.isWaitlisted)
                CatchBadge(
                  label: 'Waitlist',
                  tone: CatchBadgeTone.brand,
                  icon: CatchIcons.queueOutlined,
                ),
            ],
          ),
          gapH10,
          Text(
            row.explanation,
            style: CatchTextStyles.supporting(context, color: t.ink3),
          ),
        ],
      ),
    );
  }
}

class _DebugOutput extends StatelessWidget {
  const _DebugOutput({required this.result});

  final EventPolicyPreviewResult result;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    const encoder = JsonEncoder.withIndent('  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(icon: CatchIcons.dataObjectRounded, title: 'Debug map'),
        gapH10,
        CatchSurface(
          padding: const EdgeInsets.all(CatchSpacing.s4),
          backgroundColor: t.ink,
          borderColor: Colors.transparent,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText(
              key: EventPolicyLabKeys.debugOutput,
              encoder.convert(result.toDebugMap()),
              style: CatchTextStyles.debugDetails(context, color: t.surface),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, this.trailing});

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        Icon(icon, size: CatchIcon.md, color: t.primary),
        gapW8,
        Expanded(
          child: Text(
            title,
            style: CatchTextStyles.sectionTitle(context, color: t.ink),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _PolicyLine extends StatelessWidget {
  const _PolicyLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: CatchIcon.md, color: t.primary),
        gapW10,
        Expanded(
          child: Text(
            label,
            style: CatchTextStyles.bodyLead(context, color: t.ink2),
          ),
        ),
        gapW12,
        Flexible(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: CatchTextStyles.labelL(context, color: t.ink),
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s3),
      child: Divider(height: 1, color: color),
    );
  }
}

IconData _formatIcon(EventAdmissionFormat format) {
  return switch (format) {
    EventAdmissionFormat.open => CatchIcons.lockOpenOutlined,
    EventAdmissionFormat.inviteOnly => CatchIcons.keyOutlined,
    EventAdmissionFormat.manualApproval => CatchIcons.factCheckOutlined,
    EventAdmissionFormat.fixedCohortCaps => CatchIcons.groups2Outlined,
    EventAdmissionFormat.balancedRatio => CatchIcons.balanceOutlined,
    EventAdmissionFormat.membersOnly => CatchIcons.cardMembershipOutlined,
  };
}

CatchBadgeTone _decisionTone(EventAdmissionDecisionType type) {
  return switch (type) {
    EventAdmissionDecisionType.admitted => CatchBadgeTone.success,
    EventAdmissionDecisionType.waitlisted => CatchBadgeTone.warning,
    EventAdmissionDecisionType.manualReviewRequired => CatchBadgeTone.brand,
    EventAdmissionDecisionType.inviteRequired ||
    EventAdmissionDecisionType.membershipRequired => CatchBadgeTone.neutral,
    EventAdmissionDecisionType.soldOut ||
    EventAdmissionDecisionType.cohortUnavailable => CatchBadgeTone.danger,
  };
}

String _formatAdmissionFormat(EventAdmissionFormat format) {
  return switch (format) {
    EventAdmissionFormat.open => 'Open',
    EventAdmissionFormat.inviteOnly => 'Invite-only',
    EventAdmissionFormat.manualApproval => 'Manual approval',
    EventAdmissionFormat.fixedCohortCaps => 'Fixed cohort caps',
    EventAdmissionFormat.balancedRatio => 'Balanced ratio',
    EventAdmissionFormat.membersOnly => 'Members-only',
  };
}

String _formatWaitlist(EventWaitlistMode mode) {
  return switch (mode) {
    EventWaitlistMode.disabled => 'Disabled',
    EventWaitlistMode.rankedOffer => 'Ranked offers',
    EventWaitlistMode.broadcastFirstComeFirstServed => 'Broadcast',
    EventWaitlistMode.manualReview => 'Manual review',
  };
}

String _formatOutOfRatio(EventOutOfRatioCohortPolicy policy) {
  return switch (policy) {
    EventOutOfRatioCohortPolicy.admitWithinGeneralCapacity => 'Admit',
    EventOutOfRatioCohortPolicy.waitlist => 'Waitlist',
    EventOutOfRatioCohortPolicy.manualReview => 'Manual review',
    EventOutOfRatioCohortPolicy.reject => 'Reject',
  };
}

String _formatDecision(EventAdmissionDecisionType type) {
  return switch (type) {
    EventAdmissionDecisionType.admitted => 'Admitted',
    EventAdmissionDecisionType.waitlisted => 'Waitlisted',
    EventAdmissionDecisionType.manualReviewRequired => 'Review',
    EventAdmissionDecisionType.inviteRequired => 'Invite required',
    EventAdmissionDecisionType.membershipRequired => 'Members only',
    EventAdmissionDecisionType.soldOut => 'Sold out',
    EventAdmissionDecisionType.cohortUnavailable => 'Unavailable',
  };
}

String _formatReason(EventAdmissionDecisionReason reason) {
  return switch (reason) {
    EventAdmissionDecisionReason.capacityAvailable => 'Capacity available',
    EventAdmissionDecisionReason.capacityFull => 'Capacity full',
    EventAdmissionDecisionReason.inviteRequired => 'Invite required',
    EventAdmissionDecisionReason.membershipRequired => 'Membership required',
    EventAdmissionDecisionReason.manualApprovalRequired => 'Host review',
    EventAdmissionDecisionReason.cohortCapReached => 'Cohort cap reached',
    EventAdmissionDecisionReason.balancedRatioLimitReached =>
      'Ratio limit reached',
    EventAdmissionDecisionReason.outOfRatioCohortRequiresReview =>
      'Out-of-ratio review',
    EventAdmissionDecisionReason.outOfRatioCohortWaitlisted =>
      'Out-of-ratio waitlist',
    EventAdmissionDecisionReason.outOfRatioCohortRejected =>
      'Out-of-ratio rejected',
  };
}

String _formatCancellationActor(EventCancellationActor actor) {
  return switch (actor) {
    EventCancellationActor.attendee => 'Attendee',
    EventCancellationActor.host => 'Host',
    EventCancellationActor.platform => 'Platform',
  };
}

String _formatCancellationRemedy(EventCancellationRemedy remedy) {
  return switch (remedy) {
    EventCancellationRemedy.fullRefund => 'Full refund',
    EventCancellationRemedy.platformCredit => 'Platform credit',
    EventCancellationRemedy.noRefund => 'No refund',
    EventCancellationRemedy.waitlistRelease => 'Waitlist release',
    EventCancellationRemedy.platformMakesAttendeeComplete => 'Made complete',
  };
}

CatchBadgeTone _cancellationTone(EventCancellationRemedy remedy) {
  return switch (remedy) {
    EventCancellationRemedy.fullRefund ||
    EventCancellationRemedy.waitlistRelease ||
    EventCancellationRemedy.platformMakesAttendeeComplete =>
      CatchBadgeTone.success,
    EventCancellationRemedy.platformCredit => CatchBadgeTone.brand,
    EventCancellationRemedy.noRefund => CatchBadgeTone.warning,
  };
}

String _formatCohortCaps(Map<String, int> caps) {
  return caps.entries
      .map((entry) => '${_formatCohortId(entry.key)} ${entry.value}')
      .join(' · ');
}

String _formatCohortId(String cohortId) {
  return switch (cohortId) {
    EventCohortIds.menInterestedInWomen => 'Men seeking women',
    EventCohortIds.womenInterestedInMen => 'Women seeking men',
    EventCohortIds.queerOrOpen => 'Queer/open',
    EventCohortIds.nonBinaryOrOther => 'Non-binary/other',
    _ => cohortId,
  };
}

String _formatPaise(int paise) {
  return formatMinorCurrency(paise);
}

String _formatSignedPaise(int paise) {
  if (paise == 0) return _formatPaise(0);
  return paise > 0 ? '+${_formatPaise(paise)}' : _formatPaise(paise);
}
