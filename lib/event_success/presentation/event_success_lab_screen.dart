import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_hero_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

const EdgeInsets _labRunStepContentGap = EdgeInsets.only(
  bottom: CatchSpacing.s3,
);
const EdgeInsets _labLayerHeaderPadding = EdgeInsets.only(top: CatchSpacing.s2);
const EdgeInsets _labBulletItemGap = EdgeInsets.only(bottom: CatchSpacing.s1);
const EdgeInsets _labBulletDotInset = EdgeInsets.only(top: CatchSpacing.s2);
final EdgeInsets _labSectionPadding = CatchInsets.pageBody.copyWith(
  top: CatchSpacing.s4,
  bottom: 0,
);

/// Work-in-progress preview for the event success layer.
///
/// This screen is registered only behind dev/staging preview gates and should
/// not be exposed in distribution until the product model, safety controls, and
/// backend ownership rules are approved.
class EventSuccessLabScreen extends StatelessWidget {
  const EventSuccessLabScreen({
    super.key,
    this.playbooks = EventSuccessPlaybookLibrary.all,
    this.brief,
  });

  final List<EventSuccessPlaybook> playbooks;
  final EventSuccessBrief? brief;

  @override
  Widget build(BuildContext context) {
    final resolvedBrief = brief ?? sampleEventSuccessBrief();
    final featured = playbooks.isEmpty
        ? EventSuccessPlaybookLibrary.socialRun
        : playbooks.first;

    return Scaffold(
      appBar: CatchTopBar(
        title:
            context.l10n.eventSuccessEventSuccessLabScreenTitleEventSuccessLab,
        border: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: LabHero(playbookCount: playbooks.length)),
            SliverToBoxAdapter(
              child: Section(
                title: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenTitleActualWipFeatureBlocks,
                child: Column(
                  children: [
                    const EventSuccessHostSetupFlow(),
                    const SizedBox(height: CatchSpacing.s4),
                    const EventSuccessLiveHostMode(),
                    const SizedBox(height: CatchSpacing.s4),
                    const EventSuccessAttendeeCompanionPreview(),
                    const SizedBox(height: CatchSpacing.s4),
                    EventSuccessPostEventReport(brief: resolvedBrief),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Section(
                title: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenTitleProductPromise,
                child: PromiseGrid(playbook: featured),
              ),
            ),
            SliverToBoxAdapter(
              child: Section(
                title: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenTitlePlaybooks,
                child: Column(
                  children: [
                    for (final playbook in playbooks) ...[
                      PlaybookCard(playbook: playbook),
                      const SizedBox(height: CatchSpacing.s4),
                    ],
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Section(
                title: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenTitleArchitectureLayers,
                child: ModuleGrid(
                  moduleGroups: EventSuccessModuleCatalog.allByProductLayer,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Section(
                title: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenTitleHostCoachSample,
                child: CoachPanel(brief: resolvedBrief),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s8)),
          ],
        ),
      ),
    );
  }
}

class LabHero extends StatelessWidget {
  const LabHero({required this.playbookCount});

  final int playbookCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: CatchInsets.pageHeaderBody,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: EventSuccessHeroSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    CatchBadge(
                      label: context
                          .l10n
                          .eventSuccessEventSuccessLabScreenLabelWorkInProgress,
                      tone: CatchBadgeTone.live,
                      icon: CatchIcons.constructionRounded,
                    ),
                    CatchBadge(
                      label: context
                          .l10n
                          .eventSuccessEventSuccessLabScreenLabelPreviewOnly,
                      tone: CatchBadgeTone.solid,
                      icon: CatchIcons.visibilityOutlined,
                    ),
                  ],
                ),
                const SizedBox(height: CatchSpacing.s5),
                Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessLabScreenTextEventSuccessLayer,
                  style: CatchTextStyles.headline(context, color: t.accentInk),
                ),
                const SizedBox(height: CatchSpacing.s3),
                Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessLabScreenTextAFirstPassWorkspace,
                  style: CatchTextStyles.proseL(
                    context,
                    color: t.accentInk.withValues(
                      alpha: CatchOpacity.profileHeroMuted,
                    ),
                  ),
                ),
                const SizedBox(height: CatchSpacing.s5),
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    EventSuccessDarkPill(
                      label: context.l10n
                          .eventSuccessEventSuccessLabScreenLabelPlaybookcountPlaybooks(
                            playbookCount: playbookCount,
                          ),
                    ),
                    EventSuccessDarkPill(
                      label: context
                          .l10n
                          .eventSuccessEventSuccessLabScreenLabelDevStagingRoute,
                    ),
                    EventSuccessDarkPill(
                      label: context
                          .l10n
                          .eventSuccessEventSuccessLabScreenLabelNoFirestoreWrites,
                    ),
                    EventSuccessDarkPill(
                      label: context
                          .l10n
                          .eventSuccessEventSuccessLabScreenLabelNoBookingChanges,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PromiseGrid extends StatelessWidget {
  const PromiseGrid({required this.playbook});

  final EventSuccessPlaybook playbook;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >=
                ComponentBreakpoints.eventSuccessLabPromiseBreakpoint
            ? 3
            : 1;
        final width =
            (constraints.maxWidth - (CatchSpacing.s3 * (columns - 1))) /
            columns;
        return Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          children: [
            SizedBox(
              width: width,
              child: PromiseCard(
                icon: CatchIcons.favoriteBorderRounded,
                title: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenTitleAttendees,
                body: playbook.attendeePromise,
              ),
            ),
            SizedBox(
              width: width,
              child: PromiseCard(
                icon: CatchIcons.groups2Outlined,
                title: context.l10n.eventSuccessEventSuccessLabScreenTitleHosts,
                body: playbook.hostPromise,
              ),
            ),
            SizedBox(
              width: width,
              child: PromiseCard(
                icon: CatchIcons.scienceOutlined,
                title: context.l10n.eventSuccessEventSuccessLabScreenTitleCatch,
                body: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenBodyLearnWhichLiveStructures,
              ),
            ),
          ],
        );
      },
    );
  }
}

class PromiseCard extends StatelessWidget {
  const PromiseCard({
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
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: t.primary, size: CatchIcon.lg),
          const SizedBox(height: CatchSpacing.s3),
          Text(title, style: CatchTextStyles.sectionTitle(context)),
          const SizedBox(height: CatchSpacing.s2),
          Text(body, style: CatchTextStyles.supporting(context)),
        ],
      ),
    );
  }
}

class PlaybookCard extends StatelessWidget {
  const PlaybookCard({required this.playbook});

  final EventSuccessPlaybook playbook;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchBadge(
                label: playbook.activityType.label,
                tone: CatchBadgeTone.brand,
                icon: _activityIcon(playbook.activityType),
              ),
              CatchBadge(label: playbook.socialIntensity.label),
              if (playbook.hasLivePhoneUse)
                CatchBadge(
                  label: context
                      .l10n
                      .eventSuccessEventSuccessLabScreenLabelSomeLivePhoneUse,
                  tone: CatchBadgeTone.warning,
                ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s3),
          Text(playbook.title, style: CatchTextStyles.titleL(context)),
          const SizedBox(height: CatchSpacing.s2),
          Text(playbook.summary, style: CatchTextStyles.proseM(context)),
          const SizedBox(height: CatchSpacing.s4),
          CapacityRow(capacity: playbook.capacity),
          const SizedBox(height: CatchSpacing.s4),
          RunOfShow(playbook: playbook),
          const SizedBox(height: CatchSpacing.s4),
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final module in playbook.modules.take(6))
                CatchBadge(label: module.title),
              if (playbook.modules.length > 6)
                CatchBadge(
                  label: context.l10n
                      .eventSuccessEventSuccessLabScreenLabelValue1More(
                        value1: playbook.modules.length - 6,
                      ),
                ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s4),
          NotesList(
            title: context
                .l10n
                .eventSuccessEventSuccessLabScreenTitleIterationQuestions,
            items: playbook.iterationQuestions,
          ),
          const SizedBox(height: CatchSpacing.s3),
          NotesList(
            title:
                context.l10n.eventSuccessEventSuccessLabScreenTitleAntiPatterns,
            items: playbook.antiPatterns,
          ),
        ],
      ),
    );
  }
}

class CapacityRow extends StatelessWidget {
  const CapacityRow({required this.capacity});

  final EventCapacityGuidance capacity;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      padding: CatchInsets.contentDense,
      radius: CatchRadius.sm,
      borderColor: t.line,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CatchIcons.confirmationNumberOutlined, color: t.accent),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n
                      .eventSuccessEventSuccessLabScreenTextMinMaxAttendees(
                        min: capacity.min,
                        max: capacity.max,
                      ),
                  style: CatchTextStyles.sectionTitle(context),
                ),
                const SizedBox(height: CatchSpacing.s1),
                Text(
                  capacity.rationale,
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

class RunOfShow extends StatelessWidget {
  const RunOfShow({required this.playbook});

  final EventSuccessPlaybook playbook;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.eventSuccessEventSuccessLabScreenTextRunOfShow,
          style: CatchTextStyles.sectionTitle(context),
        ),
        const SizedBox(height: CatchSpacing.s3),
        for (final step in playbook.runOfShow) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  CatchSurface(
                    width: CatchLayout.eventSuccessLabStepMarkerExtent,
                    height: CatchLayout.eventSuccessLabStepMarkerExtent,
                    radius: CatchRadius.pill,
                    backgroundColor: t.primarySoft,
                    borderWidth: 0,
                    child: Center(
                      child: Text(
                        context.l10n
                            .eventSuccessEventSuccessLabScreenTextDurationminutes(
                              durationMinutes: step.durationMinutes,
                            ),
                        style: CatchTextStyles.labelL(
                          context,
                          color: t.primary,
                        ),
                      ),
                    ),
                  ),
                  if (step != playbook.runOfShow.last)
                    SizedBox(
                      width: CatchStroke.hairline,
                      height: CatchLayout.eventSuccessLabStepMarkerExtent,
                      child: ColoredBox(color: t.line2),
                    ),
                ],
              ),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Padding(
                  padding: _labRunStepContentGap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: CatchTextStyles.sectionTitle(context),
                      ),
                      const SizedBox(height: CatchSpacing.s1),
                      Text(
                        step.hostInstruction,
                        style: CatchTextStyles.supporting(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class ModuleGrid extends StatelessWidget {
  const ModuleGrid({required this.moduleGroups});

  final Map<EventSuccessProductLayer, List<EventSuccessModule>> moduleGroups;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >=
                ComponentBreakpoints.eventSuccessLabModuleBreakpoint
            ? 2
            : 1;
        final width =
            (constraints.maxWidth - (CatchSpacing.s3 * (columns - 1))) /
            columns;
        return Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          children: [
            for (final entry in moduleGroups.entries) ...[
              SizedBox(
                width: constraints.maxWidth,
                child: LayerHeader(layer: entry.key),
              ),
              for (final module in entry.value)
                SizedBox(
                  width: width,
                  child: ModuleCard(module: module),
                ),
            ],
          ],
        );
      },
    );
  }
}

class LayerHeader extends StatelessWidget {
  const LayerHeader({required this.layer});

  final EventSuccessProductLayer layer;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: _labLayerHeaderPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(layer.label, style: CatchTextStyles.sectionTitle(context)),
          const SizedBox(height: CatchSpacing.s1),
          Text(
            layer.description,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class ModuleCard extends StatelessWidget {
  const ModuleCard({required this.module});

  final EventSuccessModule module;

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
                child: Text(
                  module.title,
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
              const SizedBox(width: CatchSpacing.s2),
              CatchBadge(
                label: module.stage.label,
                tone: module.enabledByDefault
                    ? CatchBadgeTone.success
                    : CatchBadgeTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s3),
          Text(module.hostPromise, style: CatchTextStyles.supporting(context)),
          const SizedBox(height: CatchSpacing.s3),
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              if (module.requiresLivePhoneUse)
                CatchBadge(
                  label: context
                      .l10n
                      .eventSuccessEventSuccessLabScreenLabelLivePhone,
                  tone: CatchBadgeTone.warning,
                ),
              if (!module.enabledByDefault)
                CatchBadge(
                  label: context
                      .l10n
                      .eventSuccessEventSuccessLabScreenLabelLaterExperiment,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class CoachPanel extends StatelessWidget {
  const CoachPanel({required this.brief});

  final EventSuccessBrief brief;

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
            children: [
              Icon(CatchIcons.insightsOutlined, color: t.primary),
              const SizedBox(width: CatchSpacing.s2),
              Expanded(
                child: Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessLabScreenTextSampleDebrief,
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
              CatchBadge(
                label: context.l10n.eventSuccessEventSuccessLabScreenLabelRound(
                  round: (brief.scorecard.experienceScore * 100).round(),
                ),
                tone: CatchBadgeTone.brand,
              ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s4),
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              EventSuccessMetricPill(
                label:
                    context.l10n.eventSuccessEventSuccessLabScreenLabelCheckIn,
                value: brief.scorecard.checkInRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenLabelIntroCoverage,
                value: brief.scorecard.introCoverageRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenLabelCaughtSomeone,
                value: brief.scorecard.caughtSomeoneRate,
              ),
              EventSuccessMetricPill(
                label:
                    context.l10n.eventSuccessEventSuccessLabScreenLabelHostHelp,
                value: brief.scorecard.wingmanRequestRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessLabScreenLabelChatStart,
                value: brief.scorecard.chatStartRate,
              ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s4),
          for (final recommendation in brief.recommendations) ...[
            EventSuccessRecommendationTile(
              recommendation: recommendation,
              icon: _priorityIcon(recommendation.priority),
            ),
            if (recommendation != brief.recommendations.last)
              const SizedBox(height: CatchSpacing.s3),
          ],
          if (brief.strengths.isNotEmpty) ...[
            const SizedBox(height: CatchSpacing.s4),
            NotesList(
              title:
                  context.l10n.eventSuccessEventSuccessLabScreenTitleStrengths,
              items: brief.strengths,
            ),
          ],
        ],
      ),
    );
  }
}

class NotesList extends StatelessWidget {
  const NotesList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CatchTextStyles.sectionTitle(context)),
        const SizedBox(height: CatchSpacing.s2),
        for (final item in items)
          Padding(
            padding: _labBulletItemGap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: _labBulletDotInset,
                  child: CatchStatusDot(color: t.primary, size: 5),
                ),
                const SizedBox(width: CatchSpacing.s2),
                Expanded(
                  child: Text(item, style: CatchTextStyles.supporting(context)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class Section extends StatelessWidget {
  const Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _labSectionPadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CatchTextStyles.titleL(context)),
              const SizedBox(height: CatchSpacing.s3),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

IconData _activityIcon(ActivityKind type) => switch (type) {
  ActivityKind.socialRun => CatchIcons.directionsRunRounded,
  ActivityKind.running => CatchIcons.directionsRunRounded,
  ActivityKind.walking => CatchIcons.directionsWalkRounded,
  ActivityKind.pickleball => CatchIcons.sportsTennisRounded,
  ActivityKind.padel => CatchIcons.sportsTennisRounded,
  ActivityKind.tennis => CatchIcons.sportsTennisRounded,
  ActivityKind.badminton => CatchIcons.sportsTennisRounded,
  ActivityKind.cycling => CatchIcons.directionsBikeRounded,
  ActivityKind.spinClass => CatchIcons.fitnessCenterRounded,
  ActivityKind.yoga => CatchIcons.selfImprovementRounded,
  ActivityKind.strengthTraining => CatchIcons.fitnessCenterRounded,
  ActivityKind.pubQuiz => CatchIcons.quizOutlined,
  ActivityKind.barCrawl => CatchIcons.localBarOutlined,
  ActivityKind.dinner => CatchIcons.restaurantOutlined,
  ActivityKind.singlesMixer => CatchIcons.favoriteBorderRounded,
  ActivityKind.openActivity => CatchIcons.eventAvailableOutlined,
};

IconData _priorityIcon(EventRecommendationPriority priority) =>
    switch (priority) {
      EventRecommendationPriority.critical =>
        CatchIcons.reportGmailerrorredRounded,
      EventRecommendationPriority.high => CatchIcons.priorityHighRounded,
      EventRecommendationPriority.medium => CatchIcons.tuneRounded,
      EventRecommendationPriority.low => CatchIcons.checkCircleOutlineRounded,
    };
