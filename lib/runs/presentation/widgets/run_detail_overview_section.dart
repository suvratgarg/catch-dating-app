import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/widgets/requirements_row.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_stats_grid.dart';
import 'package:catch_dating_app/runs/presentation/widgets/when_where_card.dart';
import 'package:flutter/material.dart';

class RunDetailOverviewSection extends StatelessWidget {
  const RunDetailOverviewSection({
    super.key,
    required this.run,
    this.onLocationTap,
  });

  final Run run;
  final VoidCallback? onLocationTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final description = run.description.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(run.title, style: CatchTextStyles.displayL(context)),
        gapH6,
        Row(
          children: [
            VibeTag(label: run.pace.label, active: true),
            gapW6,
            Text(
              run.shortDateLabel,
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ],
        ),
        gapH20,
        RunStatsGrid(run: run),
        gapH20,
        WhenWhereCard(run: run, onLocationTap: onLocationTap),
        if (description.isNotEmpty) ...[
          gapH20,
          _RunDescription(description: description),
        ],
        if (run.hasRequirements) ...[gapH20, RequirementsRow(run: run)],
        gapH20,
        _RunPolicySummary(run: run),
      ],
    );
  }
}

class _RunDescription extends StatelessWidget {
  const _RunDescription({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About this run', style: CatchTextStyles.titleM(context)),
        gapH8,
        Text(description, style: CatchTextStyles.bodyM(context, color: t.ink2)),
      ],
    );
  }
}

class _RunPolicySummary extends StatelessWidget {
  const _RunPolicySummary({required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final policy = run.effectiveEventPolicy;
    final cancellation = policy.cancellationPolicy;

    return CatchSurface(
      padding: const EdgeInsets.all(14),
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.md,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Booking policy', style: CatchTextStyles.titleM(context)),
          gapH10,
          _PolicyLine(
            icon: Icons.group_outlined,
            title: _admissionTitle(policy.admissionPolicy),
            body: _admissionSummary(policy.admissionPolicy),
          ),
          gapH10,
          _PolicyLine(
            icon: Icons.receipt_long_outlined,
            title: '${cancellation.title} cancellation',
            body: cancellation.attendeeSummary,
          ),
          gapH10,
          _PolicyLine(
            icon: Icons.verified_user_outlined,
            title: policy.settlementPolicy.title,
            body: policy.settlementPolicy.summary,
          ),
        ],
      ),
    );
  }
}

class _PolicyLine extends StatelessWidget {
  const _PolicyLine({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: t.primary, size: 18),
        gapW8,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CatchTextStyles.labelL(context)),
              gapH2,
              Text(body, style: CatchTextStyles.bodyS(context, color: t.ink2)),
            ],
          ),
        ),
      ],
    );
  }
}

String _admissionTitle(EventAdmissionPolicy policy) {
  return switch (policy.format) {
    EventAdmissionFormat.open => 'Open capacity',
    EventAdmissionFormat.inviteOnly => 'Invite only',
    EventAdmissionFormat.manualApproval => 'Manual approval',
    EventAdmissionFormat.fixedCohortCaps => 'Fixed cohort caps',
    EventAdmissionFormat.balancedRatio => 'Balanced singles',
    EventAdmissionFormat.membersOnly => 'Members only',
  };
}

String _admissionSummary(EventAdmissionPolicy policy) {
  return switch (policy.format) {
    EventAdmissionFormat.open =>
      'Attendees book until ${policy.capacityLimit} spots are filled.',
    EventAdmissionFormat.fixedCohortCaps =>
      'Straight men and women use explicit cohort caps; other cohorts book within total capacity.',
    EventAdmissionFormat.balancedRatio =>
      'Straight men and women are balanced within a small tolerance; other cohorts book within total capacity.',
    EventAdmissionFormat.inviteOnly =>
      'Only attendees with the host invite can book.',
    EventAdmissionFormat.manualApproval =>
      'The host reviews requests before confirming spots.',
    EventAdmissionFormat.membersOnly =>
      'Only active club members can book this event.',
  };
}
