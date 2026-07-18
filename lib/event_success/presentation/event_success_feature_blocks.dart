import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_analytics_kit.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_progress_cue.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/domain/event_success_conversation_cue.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_conversation_cue_copy.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_structure_config_editor.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

const EdgeInsets _moduleToggleRowGap = EdgeInsets.only(bottom: CatchSpacing.s2);
const EdgeInsets _moduleToggleContentPadding = EdgeInsets.fromLTRB(
  CatchSpacing.s3,
  CatchSpacing.s2,
  CatchSpacing.s2,
  CatchSpacing.s2,
);
const EdgeInsets _issueListItemGap = EdgeInsets.only(bottom: CatchSpacing.s1);
const EdgeInsets _liveStepRowGap = EdgeInsets.only(bottom: CatchSpacing.s3);
const EdgeInsets _conversationCueRowGap = EdgeInsets.only(
  bottom: CatchSpacing.s2,
);
const EdgeInsets _conversationCueIconInset = EdgeInsets.only(
  top: CatchSpacing.micro3,
);
const EdgeInsets _wingmanCandidateGap = EdgeInsets.only(
  bottom: CatchSpacing.s2,
);

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
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlockHeader(
            icon: CatchIcons.tuneRounded,
            title: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksTitleHostSetupFlow,
            subtitle: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksSubtitleChooseTheFormatEvent,
            badge: CatchBadge(label: _draft.status.label, tone: readinessTone),
          ),
          const SizedBox(height: CatchSpacing.s4),
          Text(
            context.l10n.eventSuccessEventSuccessFeatureBlocksTextFormat,
            style: CatchTextStyles.sectionTitle(context),
          ),
          const SizedBox(height: CatchSpacing.s2),
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final playbook in widget.playbooks)
                CatchChip.selectable(
                  label: playbook.activityType.label,
                  selected: playbook.id == _draft.playbook.id,
                  onChanged: (_) {
                    setState(() {
                      _draft = EventSuccessHostDraft.fromPlaybook(playbook);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s4),
          PlaybookSummaryCard(draft: _draft),
          const SizedBox(height: CatchSpacing.s4),
          Text(
            context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksTextEventStructure,
            style: CatchTextStyles.sectionTitle(context),
          ),
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
            context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksTextExperienceArchitecture,
            style: CatchTextStyles.sectionTitle(context),
          ),
          const SizedBox(height: CatchSpacing.s2),
          for (final module in _draft.playbook.modules)
            ModuleToggleRow(
              module: module,
              selected: _draft.isModuleSelected(module.id),
              onChanged: (_) {
                setState(() => _draft = _draft.toggleModule(module.id));
              },
            ),
          if (_draft.readinessIssues.isNotEmpty) ...[
            const SizedBox(height: CatchSpacing.s4),
            IssueList(issues: _draft.readinessIssues),
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
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlockHeader(
            icon: CatchIcons.playCircleOutlineRounded,
            title: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksTitleLiveHostMode,
            subtitle: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksSubtitleAPhoneFriendlyGuide,
            badge: CatchBadge(
              label: context
                  .l10n
                  .eventSuccessEventSuccessFeatureBlocksLabelHostOnly,
              tone: CatchBadgeTone.brand,
            ),
          ),
          const SizedBox(height: CatchSpacing.s4),
          ProgressRow(
            label: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksLabelCheckedIn,
            value: resolvedPlan.checkInProgress,
            detail: context.l10n
                .eventSuccessEventSuccessFeatureBlocksDetailCheckedincountBookedcount(
                  checkedInCount: resolvedPlan.checkedInCount,
                  bookedCount: resolvedPlan.bookedCount,
                ),
          ),
          const SizedBox(height: CatchSpacing.s3),
          ProgressRow(
            label: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksLabelRunOfShow,
            value: resolvedPlan.runOfShowProgress,
            detail: context.l10n
                .eventSuccessEventSuccessFeatureBlocksDetailValue1Length(
                  value1: resolvedPlan.activeStepIndex + 1,
                  length: resolvedPlan.steps.length,
                ),
          ),
          const SizedBox(height: CatchSpacing.s4),
          CatchSurface(
            tone: CatchSurfaceTone.raised,
            radius: CatchRadius.sm,
            borderColor: t.line,
            padding: CatchInsets.content,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchBadge.live(label: resolvedPlan.activeStep.stage.label),
                const SizedBox(height: CatchSpacing.s3),
                Text(
                  resolvedPlan.activeStep.title,
                  style: CatchTextStyles.titleL(context),
                ),
                const SizedBox(height: CatchSpacing.s2),
                Text(
                  resolvedPlan.activeStep.hostInstruction,
                  style: CatchTextStyles.proseM(context),
                ),
                const SizedBox(height: CatchSpacing.s3),
                Text(
                  context.l10n
                      .eventSuccessEventSuccessFeatureBlocksTextAttendeeExperienceAttendeeexperience(
                        attendeeExperience:
                            resolvedPlan.activeStep.attendeeExperience,
                      ),
                  style: CatchTextStyles.supporting(context),
                ),
              ],
            ),
          ),
          if (showStepList) ...[
            const SizedBox(height: CatchSpacing.s4),
            for (var i = 0; i < resolvedPlan.steps.length; i++)
              LiveStepRow(
                step: resolvedPlan.steps[i],
                state: CatchProgressCueState.fromPosition(
                  index: i,
                  currentIndex: resolvedPlan.activeStepIndex,
                ),
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
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlockHeader(
            icon: CatchIcons.phoneIphoneRounded,
            title: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksTitleAttendeeCompanion,
            subtitle: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksSubtitleTheAttendeeSeesOnly,
            badge: CatchBadge(
              label: context
                  .l10n
                  .eventSuccessEventSuccessFeatureBlocksLabelAttendee,
              tone: CatchBadgeTone.success,
            ),
          ),
          const SizedBox(height: CatchSpacing.s4),
          CatchSurface(
            tone: CatchSurfaceTone.primarySoft,
            borderColor: t.surface.withValues(alpha: CatchOpacity.none),
            padding: CatchInsets.content,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatchBadge(
                  label: resolvedState.checkedIn
                      ? context
                            .l10n
                            .eventSuccessEventSuccessFeatureBlocksLabelCheckedIn
                      : context
                            .l10n
                            .eventSuccessEventSuccessFeatureBlocksLabelCheckIn,
                  tone: resolvedState.checkedIn
                      ? CatchBadgeTone.success
                      : CatchBadgeTone.warning,
                  icon: CatchIcons.qrCode2Rounded,
                ),
                const SizedBox(height: CatchSpacing.s3),
                Text(
                  resolvedState.eventTitle,
                  style: CatchTextStyles.titleL(context),
                ),
                const SizedBox(height: CatchSpacing.s2),
                Text(
                  resolvedState.podLabel,
                  style: CatchTextStyles.proseM(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: CatchSpacing.s4),
          EventSuccessPromptCard(prompt: resolvedState.prompt),
          const SizedBox(height: CatchSpacing.s4),
          Text(
            context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksTextAskHostForHelp,
            style: CatchTextStyles.sectionTitle(context),
          ),
          const SizedBox(height: CatchSpacing.s2),
          for (final candidate in resolvedState.wingmanRequestCandidates)
            WingmanCandidateRow(candidate: candidate),
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
    final scorecard = resolvedBrief.scorecard;

    return CatchSectionList(
      children: [
        CatchSection.plain(
          title: context
              .l10n
              .eventSuccessEventSuccessFeatureBlocksTitlePostEventHostReport,
          subtitle: context
              .l10n
              .eventSuccessEventSuccessFeatureBlocksSubtitleAConcreteReportSurface,
          trailing: CatchBadge(
            label: context.l10n.eventSuccessEventSuccessFeatureBlocksLabelRound(
              round: (scorecard.experienceScore * 100).round(),
            ),
            tone: CatchBadgeTone.brand,
          ),
          child: CatchAnalyticsMetricGrid(
            metrics: [
              CatchMetricCardData(
                icon: CatchIcons.checkCircleOutlineRounded,
                value: _eventSuccessFeaturePercent(scorecard.checkInRate),
                label: context
                    .l10n
                    .eventSuccessEventSuccessFeatureBlocksLabelCheckIn16e104,
              ),
              CatchMetricCardData(
                icon: CatchIcons.groups2Outlined,
                value: _eventSuccessFeaturePercent(scorecard.introCoverageRate),
                label: context
                    .l10n
                    .eventSuccessEventSuccessFeatureBlocksLabelIntroCoverage,
              ),
              CatchMetricCardData(
                icon: CatchIcons.favoriteOutlineRounded,
                value: _eventSuccessFeaturePercent(scorecard.caughtSomeoneRate),
                label: context
                    .l10n
                    .eventSuccessEventSuccessFeatureBlocksLabelCaughtSomeone,
              ),
              CatchMetricCardData(
                icon: CatchIcons.volunteerActivismOutlined,
                value: _eventSuccessFeaturePercent(
                  scorecard.wingmanRequestRate,
                ),
                label: context
                    .l10n
                    .eventSuccessEventSuccessFeatureBlocksLabelHostHelp,
              ),
              CatchMetricCardData(
                icon: CatchIcons.chatBubbleOutlineRounded,
                value: _eventSuccessFeaturePercent(scorecard.chatStartRate),
                label: context
                    .l10n
                    .eventSuccessEventSuccessFeatureBlocksLabelChatStart,
              ),
            ],
          ),
        ),
        if (resolvedBrief.strengths.isNotEmpty)
          CatchSection.fieldRows(
            title: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksTextWorkingWell,
            children: [
              for (final strength in resolvedBrief.strengths.take(4))
                CatchField.read(
                  title: strength,
                  icon: CatchIcons.checkCircleOutlineRounded,
                ),
            ],
          ),
        if (resolvedBrief.recommendations.isNotEmpty)
          CatchSection.fieldRows(
            title: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksTextImproveNextTime,
            children: [
              for (final recommendation in resolvedBrief.recommendations.take(
                4,
              ))
                EventSuccessRecommendationTile(recommendation: recommendation),
            ],
          ),
      ],
    );
  }
}

String _eventSuccessFeaturePercent(double value) => '${(value * 100).round()}%';

class BlockHeader extends StatelessWidget {
  const BlockHeader({
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
        Text(subtitle, style: CatchTextStyles.supporting(context)),
      ],
    );
  }
}

class PlaybookSummaryCard extends StatelessWidget {
  const PlaybookSummaryCard({required this.draft});

  final EventSuccessHostDraft draft;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.sm,
      borderColor: t.line,
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            draft.playbook.title,
            style: CatchTextStyles.sectionTitle(context),
          ),
          const SizedBox(height: CatchSpacing.s2),
          Text(
            draft.playbook.summary,
            style: CatchTextStyles.supporting(context),
          ),
          const SizedBox(height: CatchSpacing.s3),
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessFeatureBlocksLabelTargetattendeecountTargetAttendees(
                      targetAttendeeCount: draft.targetAttendeeCount,
                    ),
                icon: CatchIcons.confirmationNumberOutlined,
              ),
              CatchBadge(
                label: draft.playbook.socialIntensity.label,
                tone: CatchBadgeTone.brand,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessFeatureBlocksLabelLengthLivePhoneTools(
                      length: draft.livePhoneModules.length,
                    ),
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

class ModuleToggleRow extends StatelessWidget {
  const ModuleToggleRow({
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
      padding: _moduleToggleRowGap,
      child: CatchSurface(
        tone: selected ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
        radius: CatchRadius.sm,
        borderColor: selected
            ? t.surface.withValues(alpha: CatchOpacity.none)
            : t.line,
        padding: _moduleToggleContentPadding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: CatchTextStyles.sectionTitle(context),
                  ),
                  const SizedBox(height: CatchSpacing.s1),
                  Text(
                    module.hostPromise,
                    style: CatchTextStyles.supporting(context),
                  ),
                ],
              ),
            ),
            Semantics(
              label: context.l10n
                  .eventSuccessEventSuccessFeatureBlocksLabelTitleTool(
                    title: module.title,
                  ),
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

class IssueList extends StatelessWidget {
  const IssueList({required this.issues});

  final List<String> issues;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.sm,
      borderColor: t.warning.withValues(
        alpha: CatchOpacity.eventSuccessWarningBorder,
      ),
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchBadge(
            label: context
                .l10n
                .eventSuccessEventSuccessFeatureBlocksLabelBeforeLaunch,
            tone: CatchBadgeTone.warning,
            icon: CatchIcons.warningAmberRounded,
          ),
          const SizedBox(height: CatchSpacing.s2),
          for (final issue in issues)
            Padding(
              padding: _issueListItemGap,
              child: Text(issue, style: CatchTextStyles.supporting(context)),
            ),
        ],
      ),
    );
  }
}

class ProgressRow extends StatelessWidget {
  const ProgressRow({
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
              child: Text(label, style: CatchTextStyles.sectionTitle(context)),
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

class LiveStepRow extends StatelessWidget {
  const LiveStepRow({required this.step, required this.state});

  final EventRunOfShowStep step;
  final CatchProgressCueState state;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = switch (state) {
      CatchProgressCueState.current => t.gold,
      CatchProgressCueState.complete => t.success,
      CatchProgressCueState.future => t.ink3,
    };

    return Padding(
      padding: _liveStepRowGap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            switch (state) {
              CatchProgressCueState.complete => CatchIcons.checkCircleRounded,
              CatchProgressCueState.current =>
                CatchIcons.radioButtonCheckedRounded,
              CatchProgressCueState.future =>
                CatchIcons.radioButtonUncheckedRounded,
            },
            color: color,
            size: CatchIcon.md,
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: CatchTextStyles.sectionTitle(context)),
                const SizedBox(height: CatchSpacing.s1),
                Text(
                  context.l10n
                      .eventSuccessEventSuccessFeatureBlocksTextDurationminutesMinLabel(
                        durationMinutes: step.durationMinutes,
                        label: step.stage.label,
                      ),
                  style: CatchTextStyles.supporting(context),
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
  const EventSuccessPromptCard({super.key, required this.prompt, this.title});

  final String prompt;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.sm,
      borderColor: t.line,
      padding: CatchInsets.contentDense,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CatchIcons.chatBubbleOutlineRounded, color: t.primary),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? context.l10n.eventSuccessSocialMissionTitle,
                  style: CatchTextStyles.sectionTitle(context),
                ),
                const SizedBox(height: CatchSpacing.s1),
                Text(prompt, style: CatchTextStyles.supporting(context)),
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
      EventSuccessConversationCueMoment.live => CatchIcons.forumOutlined,
      EventSuccessConversationCueMoment.postEvent => CatchIcons.chatOutlined,
    };

    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.sm,
      borderColor: t.line,
      padding: CatchInsets.contentDense,
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
                        Text(
                          title,
                          style: CatchTextStyles.sectionTitle(context),
                        ),
                        CatchBadge(
                          label: moment.label(context.l10n),
                          tone: moment == EventSuccessConversationCueMoment.live
                              ? CatchBadgeTone.brand
                              : CatchBadgeTone.brand,
                        ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: CatchSpacing.s1),
                      Text(
                        subtitle!,
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s3),
          for (final cue in cues.take(3)) ConversationCueRow(cue: cue),
        ],
      ),
    );
  }
}

class ConversationCueRow extends StatelessWidget {
  const ConversationCueRow({required this.cue});

  final EventSuccessConversationCue cue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: _conversationCueRowGap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: _conversationCueIconInset,
            child: Icon(
              CatchIcons.arrowForwardRounded,
              size: CatchIcon.xs,
              color: t.ink3,
            ),
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
                    Text(
                      cue.title,
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    CatchBadge(label: cue.contextLabel),
                  ],
                ),
                const SizedBox(height: CatchSpacing.s1),
                Text(cue.body, style: CatchTextStyles.supporting(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WingmanCandidateRow extends StatelessWidget {
  const WingmanCandidateRow({required this.candidate});

  final WingmanRequestCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: _wingmanCandidateGap,
      child: Row(
        children: [
          Icon(
            candidate.marked
                ? CatchIcons.volunteerActivismRounded
                : CatchIcons.volunteerActivismOutlined,
            color: candidate.marked ? t.primary : t.ink3,
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.displayName,
                  style: CatchTextStyles.sectionTitle(context),
                ),
                Text(
                  candidate.context,
                  style: CatchTextStyles.supporting(context),
                ),
              ],
            ),
          ),
          CatchBadge(
            label: candidate.marked
                ? context
                      .l10n
                      .eventSuccessEventSuccessFeatureBlocksLabelRequested
                : context
                      .l10n
                      .eventSuccessEventSuccessFeatureBlocksLabelHostVisible,
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
  EventSuccessRecommendationTile({
    super.key,
    required this.recommendation,
    IconData? icon,
  }) : icon = icon ?? CatchIcons.tipsAndUpdatesOutlined;

  final EventSuccessRecommendation recommendation;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CatchField.content(
      title: recommendation.title,
      body: recommendation.rationale,
      icon: icon,
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
    return CatchBadge(
      label: context.l10n.eventSuccessEventSuccessFeatureBlocksTextLabelRound(
        label: label,
        round: (value * 100).round(),
      ),
      size: CatchBadgeSize.md,
    );
  }
}
