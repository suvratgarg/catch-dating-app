import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/domain/event_success_conversation_cue.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_structure_config_editor.dart';
import 'package:flutter/material.dart';

class EventSuccessHostSetupFlow extends StatefulWidget {
  const EventSuccessHostSetupFlow({
    super.key,
    this.initialDraft,
    this.playbooks = EventSuccessPlaybookLibrary.all,
  });

  final EventSuccessHostDraft? initialDraft;
  final List<EventSuccessPlaybook> playbooks;

  @override
  State<EventSuccessHostSetupFlow> createState() =>
      _EventSuccessHostSetupFlowState();
}

class _EventSuccessHostSetupFlowState extends State<EventSuccessHostSetupFlow> {
  late EventSuccessHostDraft _draft =
      widget.initialDraft ??
      EventSuccessHostDraft.fromPlaybook(
        widget.playbooks.isEmpty
            ? EventSuccessPlaybookLibrary.socialRun
            : widget.playbooks.first,
      );

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final readinessTone =
        _draft.status == EventSuccessSetupStatus.readyForLaunch
        ? CatchBadgeTone.success
        : CatchBadgeTone.warning;

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BlockHeader(
            icon: Icons.tune_rounded,
            title: 'Host setup flow',
            subtitle:
                'Choose the format, event structure, assignment tools, and safety gates before an event goes live.',
            badge: CatchBadge(label: _draft.status.label, tone: readinessTone),
          ),
          const SizedBox(height: CatchSpacing.s4),
          Text('Format', style: CatchTextStyles.titleS(context)),
          const SizedBox(height: CatchSpacing.s2),
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final playbook in widget.playbooks)
                CatchChip(
                  label: playbook.activityType.label,
                  active: playbook.id == _draft.playbook.id,
                  onTap: () {
                    setState(() {
                      _draft = EventSuccessHostDraft.fromPlaybook(playbook);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s4),
          _PlaybookSummaryCard(draft: _draft),
          const SizedBox(height: CatchSpacing.s4),
          Text('Event structure', style: CatchTextStyles.titleS(context)),
          const SizedBox(height: CatchSpacing.s2),
          EventSuccessStructureConfigEditor(
            value: _draft.structureConfig,
            targetAttendeeCount: _draft.targetAttendeeCount,
            enabled: true,
            onChanged: (value) {
              setState(() => _draft = _draft.copyWith(structureConfig: value));
            },
          ),
          const SizedBox(height: CatchSpacing.s4),
          Text(
            'Experience architecture',
            style: CatchTextStyles.titleS(context),
          ),
          const SizedBox(height: CatchSpacing.s2),
          for (final module in _draft.playbook.modules)
            _ModuleToggleRow(
              module: module,
              selected: _draft.isModuleSelected(module.id),
              onChanged: (_) {
                setState(() => _draft = _draft.toggleModule(module.id));
              },
            ),
          if (_draft.readinessIssues.isNotEmpty) ...[
            const SizedBox(height: CatchSpacing.s4),
            _IssueList(issues: _draft.readinessIssues),
          ],
        ],
      ),
    );
  }
}

class EventSuccessLiveHostMode extends StatelessWidget {
  const EventSuccessLiveHostMode({
    super.key,
    this.plan,
    this.showStepList = true,
  });

  final EventSuccessLivePlan? plan;
  final bool showStepList;

  @override
  Widget build(BuildContext context) {
    final resolvedPlan = plan ?? EventSuccessFeatureSamples.livePlan;
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BlockHeader(
            icon: Icons.play_circle_outline_rounded,
            title: 'Live host mode',
            subtitle:
                'A phone-friendly guide for check-in, welcome, the current instruction, and the next social cue.',
            badge: CatchBadge(label: 'Host only', tone: CatchBadgeTone.brand),
          ),
          const SizedBox(height: CatchSpacing.s4),
          _ProgressRow(
            label: 'Checked in',
            value: resolvedPlan.checkInProgress,
            detail:
                '${resolvedPlan.checkedInCount}/${resolvedPlan.bookedCount}',
          ),
          const SizedBox(height: CatchSpacing.s3),
          _ProgressRow(
            label: 'Run of show',
            value: resolvedPlan.runOfShowProgress,
            detail:
                '${resolvedPlan.activeStepIndex + 1}/${resolvedPlan.steps.length}',
          ),
          const SizedBox(height: CatchSpacing.s4),
          CatchSurface(
            tone: CatchSurfaceTone.raised,
            radius: CatchRadius.sm,
            borderColor: t.line,
            padding: const EdgeInsets.all(CatchSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchBadge(
                  label: resolvedPlan.activeStep.stage.label,
                  tone: CatchBadgeTone.live,
                ),
                const SizedBox(height: CatchSpacing.s3),
                Text(
                  resolvedPlan.activeStep.title,
                  style: CatchTextStyles.displayS(context),
                ),
                const SizedBox(height: CatchSpacing.s2),
                Text(
                  resolvedPlan.activeStep.hostInstruction,
                  style: CatchTextStyles.bodyM(context),
                ),
                const SizedBox(height: CatchSpacing.s3),
                Text(
                  'Attendee experience: ${resolvedPlan.activeStep.attendeeExperience}',
                  style: CatchTextStyles.bodyS(context),
                ),
              ],
            ),
          ),
          if (showStepList) ...[
            const SizedBox(height: CatchSpacing.s4),
            for (var i = 0; i < resolvedPlan.steps.length; i++)
              _LiveStepRow(
                step: resolvedPlan.steps[i],
                index: i,
                activeIndex: resolvedPlan.activeStepIndex,
              ),
          ],
        ],
      ),
    );
  }
}

class EventSuccessAttendeeCompanionPreview extends StatelessWidget {
  const EventSuccessAttendeeCompanionPreview({super.key, this.state});

  final EventSuccessAttendeeState? state;

  @override
  Widget build(BuildContext context) {
    final resolvedState = state ?? EventSuccessFeatureSamples.attendeeState;
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BlockHeader(
            icon: Icons.phone_iphone_rounded,
            title: 'Attendee companion',
            subtitle:
                'The attendee sees only what helps them participate: check-in, assignment, prompt, and host help.',
            badge: CatchBadge(label: 'Attendee', tone: CatchBadgeTone.success),
          ),
          const SizedBox(height: CatchSpacing.s4),
          CatchSurface(
            tone: CatchSurfaceTone.primarySoft,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.all(CatchSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchBadge(
                  label: resolvedState.checkedIn ? 'Checked in' : 'Check in',
                  tone: resolvedState.checkedIn
                      ? CatchBadgeTone.success
                      : CatchBadgeTone.warning,
                  icon: Icons.qr_code_2_rounded,
                ),
                const SizedBox(height: CatchSpacing.s3),
                Text(
                  resolvedState.eventTitle,
                  style: CatchTextStyles.displayS(context),
                ),
                const SizedBox(height: CatchSpacing.s2),
                Text(
                  resolvedState.podLabel,
                  style: CatchTextStyles.bodyM(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: CatchSpacing.s4),
          EventSuccessPromptCard(prompt: resolvedState.prompt),
          const SizedBox(height: CatchSpacing.s4),
          Text('Ask host for help', style: CatchTextStyles.titleS(context)),
          const SizedBox(height: CatchSpacing.s2),
          for (final candidate in resolvedState.wingmanRequestCandidates)
            _WingmanCandidateRow(candidate: candidate),
        ],
      ),
    );
  }
}

class EventSuccessPostEventReport extends StatelessWidget {
  const EventSuccessPostEventReport({super.key, this.brief});

  final EventSuccessBrief? brief;

  @override
  Widget build(BuildContext context) {
    final resolvedBrief = brief ?? EventSuccessFeatureSamples.postEventBrief;
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BlockHeader(
            icon: Icons.insights_outlined,
            title: 'Post-event host report',
            subtitle:
                'A concrete report surface that turns event outcomes into the next change the host should make.',
            badge: CatchBadge(
              label:
                  '${(resolvedBrief.scorecard.experienceScore * 100).round()}%',
              tone: CatchBadgeTone.brand,
            ),
          ),
          const SizedBox(height: CatchSpacing.s4),
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              EventSuccessMetricPill(
                label: 'Check-in',
                value: resolvedBrief.scorecard.checkInRate,
              ),
              EventSuccessMetricPill(
                label: 'Intro coverage',
                value: resolvedBrief.scorecard.introCoverageRate,
              ),
              EventSuccessMetricPill(
                label: 'Host help',
                value: resolvedBrief.scorecard.wingmanRequestRate,
              ),
              EventSuccessMetricPill(
                label: 'Chat start',
                value: resolvedBrief.scorecard.chatStartRate,
              ),
            ],
          ),
          if (resolvedBrief.strengths.isNotEmpty) ...[
            const SizedBox(height: CatchSpacing.s4),
            Text('Working well', style: CatchTextStyles.titleS(context)),
            const SizedBox(height: CatchSpacing.s2),
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (final strength in resolvedBrief.strengths.take(4))
                  CatchBadge(
                    label: strength,
                    tone: CatchBadgeTone.success,
                    icon: Icons.check_rounded,
                  ),
              ],
            ),
          ],
          const SizedBox(height: CatchSpacing.s4),
          for (final recommendation in resolvedBrief.recommendations.take(4))
            EventSuccessRecommendationTile(recommendation: recommendation),
        ],
      ),
    );
  }
}

class _BlockHeader extends StatelessWidget {
  const _BlockHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget badge;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: t.primary),
            const SizedBox(width: CatchSpacing.s2),
            Expanded(
              child: Text(title, style: CatchTextStyles.titleL(context)),
            ),
            const SizedBox(width: CatchSpacing.s2),
            badge,
          ],
        ),
        const SizedBox(height: CatchSpacing.s2),
        Text(subtitle, style: CatchTextStyles.bodyS(context)),
      ],
    );
  }
}

class _PlaybookSummaryCard extends StatelessWidget {
  const _PlaybookSummaryCard({required this.draft});

  final EventSuccessHostDraft draft;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.sm,
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(draft.playbook.title, style: CatchTextStyles.titleM(context)),
          const SizedBox(height: CatchSpacing.s2),
          Text(draft.playbook.summary, style: CatchTextStyles.bodyS(context)),
          const SizedBox(height: CatchSpacing.s3),
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: '${draft.targetAttendeeCount} target attendees',
                tone: CatchBadgeTone.neutral,
                icon: Icons.confirmation_number_outlined,
              ),
              CatchBadge(
                label: draft.playbook.socialIntensity.label,
                tone: CatchBadgeTone.brand,
              ),
              CatchBadge(
                label: '${draft.livePhoneModules.length} live phone tools',
                tone: draft.livePhoneModules.length > 2
                    ? CatchBadgeTone.warning
                    : CatchBadgeTone.neutral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleToggleRow extends StatelessWidget {
  const _ModuleToggleRow({
    required this.module,
    required this.selected,
    required this.onChanged,
  });

  final EventSuccessModule module;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: CatchSurface(
        tone: selected ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
        radius: CatchRadius.sm,
        borderColor: selected ? Colors.transparent : t.line,
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s3,
          CatchSpacing.s2,
          CatchSpacing.s2,
          CatchSpacing.s2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module.title, style: CatchTextStyles.titleS(context)),
                  const SizedBox(height: CatchSpacing.s1),
                  Text(
                    module.hostPromise,
                    style: CatchTextStyles.bodyS(context),
                  ),
                ],
              ),
            ),
            Semantics(
              label: '${module.title} tool',
              toggled: selected,
              child: Material(
                type: MaterialType.transparency,
                child: Switch.adaptive(value: selected, onChanged: onChanged),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueList extends StatelessWidget {
  const _IssueList({required this.issues});

  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.sm,
      borderColor: t.warning.withValues(alpha: 0.28),
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchBadge(
            label: 'Before launch',
            tone: CatchBadgeTone.warning,
            icon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: CatchSpacing.s2),
          for (final issue in issues)
            Padding(
              padding: const EdgeInsets.only(bottom: CatchSpacing.s1),
              child: Text(issue, style: CatchTextStyles.bodyS(context)),
            ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final double value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: CatchTextStyles.titleS(context)),
            ),
            Text(detail, style: CatchTextStyles.labelL(context)),
          ],
        ),
        const SizedBox(height: CatchSpacing.s2),
        ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: t.raised,
            valueColor: AlwaysStoppedAnimation<Color>(t.primary),
          ),
        ),
      ],
    );
  }
}

class _LiveStepRow extends StatelessWidget {
  const _LiveStepRow({
    required this.step,
    required this.index,
    required this.activeIndex,
  });

  final EventRunOfShowStep step;
  final int index;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final active = index == activeIndex;
    final complete = index < activeIndex;
    final color = active
        ? t.primary
        : complete
        ? t.success
        : t.ink3;

    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            complete
                ? Icons.check_circle_rounded
                : active
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: color,
            size: CatchIcon.md,
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: CatchTextStyles.titleS(context)),
                const SizedBox(height: CatchSpacing.s1),
                Text(
                  '${step.durationMinutes} min · ${step.stage.label}',
                  style: CatchTextStyles.bodyS(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventSuccessPromptCard extends StatelessWidget {
  const EventSuccessPromptCard({
    super.key,
    required this.prompt,
    this.title = 'Social mission',
  });

  final String prompt;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.sm,
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, color: t.primary),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CatchTextStyles.titleS(context)),
                const SizedBox(height: CatchSpacing.s1),
                Text(prompt, style: CatchTextStyles.bodyS(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventSuccessConversationCueCard extends StatelessWidget {
  const EventSuccessConversationCueCard({
    super.key,
    required this.title,
    required this.cues,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final List<EventSuccessConversationCue> cues;

  @override
  Widget build(BuildContext context) {
    if (cues.isEmpty) return const SizedBox.shrink();

    final t = CatchTokens.of(context);
    final moment = cues.first.moment;
    final icon = switch (moment) {
      EventSuccessConversationCueMoment.live => Icons.forum_outlined,
      EventSuccessConversationCueMoment.postEvent => Icons.chat_outlined,
    };

    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.sm,
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: t.primary),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: CatchSpacing.s2,
                      runSpacing: CatchSpacing.s2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(title, style: CatchTextStyles.titleS(context)),
                        CatchBadge(
                          label: moment.label,
                          tone: moment == EventSuccessConversationCueMoment.live
                              ? CatchBadgeTone.live
                              : CatchBadgeTone.brand,
                        ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: CatchSpacing.s1),
                      Text(
                        subtitle!,
                        style: CatchTextStyles.bodyS(context, color: t.ink2),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s3),
          for (final cue in cues.take(3)) _ConversationCueRow(cue: cue),
        ],
      ),
    );
  }
}

class _ConversationCueRow extends StatelessWidget {
  const _ConversationCueRow({required this.cue});

  final EventSuccessConversationCue cue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(Icons.arrow_forward_rounded, size: 16, color: t.ink3),
          ),
          const SizedBox(width: CatchSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(cue.title, style: CatchTextStyles.titleS(context)),
                    CatchBadge(
                      label: cue.contextLabel,
                      tone: CatchBadgeTone.neutral,
                    ),
                  ],
                ),
                const SizedBox(height: CatchSpacing.s1),
                Text(cue.body, style: CatchTextStyles.bodyS(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WingmanCandidateRow extends StatelessWidget {
  const _WingmanCandidateRow({required this.candidate});

  final WingmanRequestCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: Row(
        children: [
          Icon(
            candidate.marked
                ? Icons.volunteer_activism_rounded
                : Icons.volunteer_activism_outlined,
            color: candidate.marked ? t.primary : t.ink3,
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.displayName,
                  style: CatchTextStyles.titleS(context),
                ),
                Text(candidate.context, style: CatchTextStyles.bodyS(context)),
              ],
            ),
          ),
          CatchBadge(
            label: candidate.marked ? 'Requested' : 'Host visible',
            tone: candidate.marked
                ? CatchBadgeTone.brand
                : CatchBadgeTone.neutral,
          ),
        ],
      ),
    );
  }
}

class EventSuccessRecommendationTile extends StatelessWidget {
  const EventSuccessRecommendationTile({
    super.key,
    required this.recommendation,
    this.icon = Icons.tips_and_updates_outlined,
  });

  final EventSuccessRecommendation recommendation;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
      child: CatchSurface(
        tone: CatchSurfaceTone.raised,
        radius: CatchRadius.sm,
        borderColor: t.line,
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: t.primary),
            const SizedBox(width: CatchSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recommendation.title,
                    style: CatchTextStyles.titleS(context),
                  ),
                  const SizedBox(height: CatchSpacing.s1),
                  Text(
                    recommendation.rationale,
                    style: CatchTextStyles.bodyS(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventSuccessMetricPill extends StatelessWidget {
  const EventSuccessMetricPill({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.pill,
      borderColor: t.line,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s2,
      ),
      child: Text(
        '$label ${(value * 100).round()}%',
        style: CatchTextStyles.labelL(context),
      ),
    );
  }
}

class EventSuccessDarkPill extends StatelessWidget {
  const EventSuccessDarkPill({
    super.key,
    required this.label,
    this.foregroundColor,
  });

  final String label;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final color = foregroundColor ?? Colors.white;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s2,
        ),
        child: Text(
          label,
          style: CatchTextStyles.labelL(context, color: color),
        ),
      ),
    );
  }
}
