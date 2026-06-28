import 'dart:convert';

import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
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
  const EventPolicyLabScreen({super.key, this.initialScenario});

  final EventPolicyPreviewScenario? initialScenario;

  @override
  State<EventPolicyLabScreen> createState() => _EventPolicyLabScreenState();
}

class _EventPolicyLabScreenState extends State<EventPolicyLabScreen> {
  static const _harness = EventPolicyPreviewHarness();
  late EventPolicyPreviewScenario _scenario;

  @override
  void initState() {
    super.initState();
    _scenario =
        widget.initialScenario ??
        EventPolicyPreviewCatalog.defaultScenarios.first;
  }

  @override
  void didUpdateWidget(covariant EventPolicyLabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialScenario?.id == widget.initialScenario?.id) return;
    _scenario =
        widget.initialScenario ??
        EventPolicyPreviewCatalog.defaultScenarios.first;
  }

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
          padding: CatchInsets.pageBodyRelaxed,
          children: [
            EventPolicyLabHeader(scenario: _scenario),
            gapH16,
            EventPolicyScenarioPicker(
              selectedScenario: _scenario,
              onSelected: (scenario) => setState(() => _scenario = scenario),
            ),
            gapH20,
            EventPolicySummary(scenario: _scenario),
            gapH20,
            EventPolicyResultRows(result: result),
            gapH20,
            EventPolicyCancellationRows(result: result),
            gapH20,
            EventPolicyDebugOutput(result: result),
          ],
        ),
      ),
    );
  }
}

class EventPolicyLabHeader extends StatelessWidget {
  const EventPolicyLabHeader({super.key, required this.scenario});

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
              CatchStatColumn(
                icon: CatchIcons.groupOutlined,
                label: 'Capacity',
                value: '${policy.capacityLimit}',
                center: true,
                surface: true,
              ),
              CatchStatColumn(
                icon: CatchIcons.confirmationNumberOutlined,
                label: 'Base',
                value: _formatPaise(pricing.basePrice.inPaise),
                center: true,
                monoValue: true,
                surface: true,
              ),
              CatchStatColumn(
                icon: CatchIcons.eventSeatOutlined,
                label: 'Booked',
                value: '${scenario.roster.totalBooked}',
                center: true,
                surface: true,
              ),
              CatchStatColumn(
                icon: CatchIcons.scheduleOutlined,
                label: 'Waitlist',
                value: '${scenario.roster.totalWaitlisted}',
                center: true,
                surface: true,
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

class EventPolicyScenarioPicker extends StatelessWidget {
  const EventPolicyScenarioPicker({
    super.key,
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
        EventPolicyLabSectionTitle(
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
                EventPolicyScenarioCard(
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

class EventPolicyScenarioCard extends StatelessWidget {
  const EventPolicyScenarioCard({
    super.key,
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
        padding: CatchInsets.content,
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

class EventPolicySummary extends StatelessWidget {
  const EventPolicySummary({super.key, required this.scenario});

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
        EventPolicyLabSectionTitle(
          icon: CatchIcons.ruleRounded,
          title: 'Policy shape',
        ),
        gapH10,
        CatchSurface(
          padding: CatchInsets.content,
          borderColor: t.line,
          child: Column(
            children: [
              EventPolicySummaryLine(
                icon: CatchIcons.eventAvailableOutlined,
                label: 'Admission',
                value: _formatAdmissionFormat(admission.format),
              ),
              EventPolicyDividerLine(color: t.line),
              EventPolicySummaryLine(
                icon: CatchIcons.queueOutlined,
                label: 'Waitlist',
                value: _formatWaitlist(admission.waitlistPolicy.mode),
              ),
              if (admission.inviteRequired) ...[
                EventPolicyDividerLine(color: t.line),
                EventPolicySummaryLine(
                  icon: CatchIcons.keyOutlined,
                  label: 'Invite',
                  value: 'Required',
                ),
              ],
              if (admission.membershipRequired) ...[
                EventPolicyDividerLine(color: t.line),
                EventPolicySummaryLine(
                  icon: CatchIcons.cardMembershipOutlined,
                  label: 'Membership',
                  value: 'Required',
                ),
              ],
              if (admission.manualApprovalRequired) ...[
                EventPolicyDividerLine(color: t.line),
                EventPolicySummaryLine(
                  icon: CatchIcons.factCheckOutlined,
                  label: 'Host review',
                  value: 'Required',
                ),
              ],
              if (admission.cohortCapacityLimits.isNotEmpty) ...[
                EventPolicyDividerLine(color: t.line),
                EventPolicySummaryLine(
                  icon: CatchIcons.groups2Outlined,
                  label: 'Cohort caps',
                  value: _formatCohortCaps(admission.cohortCapacityLimits),
                ),
              ],
              if (ratio != null) ...[
                EventPolicyDividerLine(color: t.line),
                EventPolicySummaryLine(
                  icon: CatchIcons.balanceOutlined,
                  label: 'Ratio',
                  value:
                      '${_formatCohortId(ratio.leftCohortId)} / ${_formatCohortId(ratio.rightCohortId)} · ±${ratio.maxSkew}',
                ),
                EventPolicyDividerLine(color: t.line),
                EventPolicySummaryLine(
                  icon: CatchIcons.diversity3Outlined,
                  label: 'Out-of-ratio',
                  value: _formatOutOfRatio(ratio.outOfRatioCohortPolicy),
                ),
              ],
              if (pricing.cohortAdjustments.isNotEmpty) ...[
                EventPolicyDividerLine(color: t.line),
                EventPolicySummaryLine(
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
                EventPolicyDividerLine(color: t.line),
                EventPolicySummaryLine(
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
              EventPolicyDividerLine(color: t.line),
              EventPolicySummaryLine(
                icon: CatchIcons.eventBusyOutlined,
                label: 'Cancellation',
                value: cancellation.title,
              ),
              EventPolicyDividerLine(color: t.line),
              EventPolicySummaryLine(
                icon: CatchIcons.assignmentReturnOutlined,
                label: 'Attendee terms',
                value: cancellation.attendeeSummary,
              ),
              EventPolicyDividerLine(color: t.line),
              EventPolicySummaryLine(
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

class EventPolicyResultRows extends StatelessWidget {
  const EventPolicyResultRows({super.key, required this.result});

  final EventPolicyPreviewResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: EventPolicyLabKeys.resultList,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventPolicyLabSectionTitle(
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
          EventPolicyResultRow(row: result.rows[index]),
          if (index != result.rows.length - 1) gapH10,
        ],
      ],
    );
  }
}

class EventPolicyResultRow extends StatelessWidget {
  const EventPolicyResultRow({super.key, required this.row});

  final EventPolicyPreviewRow row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final tone = _decisionTone(row.decisionType);

    return CatchSurface(
      key: EventPolicyLabKeys.resultRow(row.probeId),
      padding: CatchInsets.content,
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
                icon: CatchIcons.infoOutline,
              ),
              CatchBadge(
                label: _formatWaitlist(row.waitlistMode),
                icon: CatchIcons.queueOutlined,
              ),
              CatchBadge(
                label: _formatPaise(row.finalPriceInPaise),
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

class EventPolicyCancellationRows extends StatelessWidget {
  const EventPolicyCancellationRows({super.key, required this.result});

  final EventPolicyPreviewResult result;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventPolicyLabSectionTitle(
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
          EventPolicyCancellationRow(row: result.cancellationRows[index]),
          if (index != result.cancellationRows.length - 1) gapH10,
        ],
      ],
    );
  }
}

class EventPolicyCancellationRow extends StatelessWidget {
  const EventPolicyCancellationRow({super.key, required this.row});

  final EventPolicyCancellationPreviewRow row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.content,
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
                icon: CatchIcons.ruleOutlined,
              ),
              CatchBadge(
                label: 'Refund ${_formatPaise(row.refundAmountInPaise)}',
                icon: CatchIcons.paymentsOutlined,
              ),
              CatchBadge(
                label: 'Credit ${_formatPaise(row.creditAmountInPaise)}',
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

class EventPolicyDebugOutput extends StatelessWidget {
  const EventPolicyDebugOutput({super.key, required this.result});

  final EventPolicyPreviewResult result;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    const encoder = JsonEncoder.withIndent('  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventPolicyLabSectionTitle(
          icon: CatchIcons.dataObjectRounded,
          title: 'Debug map',
        ),
        gapH10,
        CatchSurface(
          padding: CatchInsets.content,
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

class EventPolicyLabSectionTitle extends StatelessWidget {
  const EventPolicyLabSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

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

class EventPolicySummaryLine extends StatelessWidget {
  const EventPolicySummaryLine({
    super.key,
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

class EventPolicyDividerLine extends StatelessWidget {
  const EventPolicyDividerLine({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.contentVertical,
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
