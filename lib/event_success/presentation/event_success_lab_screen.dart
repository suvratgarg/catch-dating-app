import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_feature_blocks.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: Text(
          'Event Success Lab',
          style: CatchTextStyles.titleL(context),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _LabHero(playbookCount: playbooks.length),
            ),
            SliverToBoxAdapter(
              child: _Section(
                title: 'Actual WIP feature blocks',
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
              child: _Section(
                title: 'Product promise',
                child: _PromiseGrid(playbook: featured),
              ),
            ),
            SliverToBoxAdapter(
              child: _Section(
                title: 'Playbooks',
                child: Column(
                  children: [
                    for (final playbook in playbooks) ...[
                      _PlaybookCard(playbook: playbook),
                      const SizedBox(height: CatchSpacing.s4),
                    ],
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _Section(
                title: 'Architecture layers',
                child: _ModuleGrid(
                  moduleGroups: EventSuccessModuleCatalog.allByProductLayer,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _Section(
                title: 'Host coach sample',
                child: _CoachPanel(brief: resolvedBrief),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: CatchSpacing.s8)),
          ],
        ),
      ),
    );
  }
}

class _LabHero extends StatelessWidget {
  const _LabHero({required this.playbookCount});

  final int playbookCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s4,
        CatchSpacing.s5,
        CatchSpacing.s3,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: CatchSurface(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [t.accent, t.ink],
            ),
            borderColor: t.surface.withValues(alpha: CatchOpacity.none),
            padding: const EdgeInsets.all(CatchSpacing.s5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    CatchBadge(
                      label: 'Work in progress',
                      tone: CatchBadgeTone.live,
                      icon: CatchIcons.constructionRounded,
                    ),
                    CatchBadge(
                      label: 'Preview only',
                      tone: CatchBadgeTone.solid,
                      icon: CatchIcons.visibilityOutlined,
                    ),
                  ],
                ),
                const SizedBox(height: CatchSpacing.s5),
                Text(
                  'Event Success Layer',
                  style: CatchTextStyles.headline(context, color: t.accentInk),
                ),
                const SizedBox(height: CatchSpacing.s3),
                Text(
                  'A first-pass workspace for improving what happens during events: structure, attendance, assignments, live reveal moments, host help, feedback, and coaching.',
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
                    EventSuccessDarkPill(label: '$playbookCount playbooks'),
                    const EventSuccessDarkPill(label: 'Dev/staging route'),
                    const EventSuccessDarkPill(label: 'No Firestore writes'),
                    const EventSuccessDarkPill(label: 'No booking changes'),
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

class _PromiseGrid extends StatelessWidget {
  const _PromiseGrid({required this.playbook});

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
              child: _PromiseCard(
                icon: CatchIcons.favoriteBorderRounded,
                title: 'Attendees',
                body: playbook.attendeePromise,
              ),
            ),
            SizedBox(
              width: width,
              child: _PromiseCard(
                icon: CatchIcons.groups2Outlined,
                title: 'Hosts',
                body: playbook.hostPromise,
              ),
            ),
            SizedBox(
              width: width,
              child: _PromiseCard(
                icon: CatchIcons.scienceOutlined,
                title: 'Catch',
                body:
                    'Learn which live structures improve check-in, mixing, matches, chat starts, repeats, and safety.',
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PromiseCard extends StatelessWidget {
  const _PromiseCard({
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
      padding: const EdgeInsets.all(CatchSpacing.s4),
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

class _PlaybookCard extends StatelessWidget {
  const _PlaybookCard({required this.playbook});

  final EventSuccessPlaybook playbook;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
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
              CatchBadge(
                label: playbook.socialIntensity.label,
                tone: CatchBadgeTone.neutral,
              ),
              if (playbook.hasLivePhoneUse)
                const CatchBadge(
                  label: 'some live phone use',
                  tone: CatchBadgeTone.warning,
                ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s3),
          Text(playbook.title, style: CatchTextStyles.titleL(context)),
          const SizedBox(height: CatchSpacing.s2),
          Text(playbook.summary, style: CatchTextStyles.proseM(context)),
          const SizedBox(height: CatchSpacing.s4),
          _CapacityRow(capacity: playbook.capacity),
          const SizedBox(height: CatchSpacing.s4),
          _RunOfShow(playbook: playbook),
          const SizedBox(height: CatchSpacing.s4),
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final module in playbook.modules.take(6))
                CatchChip(label: module.title),
              if (playbook.modules.length > 6)
                CatchChip(label: '+${playbook.modules.length - 6} more'),
            ],
          ),
          const SizedBox(height: CatchSpacing.s4),
          _NotesList(
            title: 'Iteration questions',
            items: playbook.iterationQuestions,
          ),
          const SizedBox(height: CatchSpacing.s3),
          _NotesList(title: 'Anti-patterns', items: playbook.antiPatterns),
        ],
      ),
    );
  }
}

class _CapacityRow extends StatelessWidget {
  const _CapacityRow({required this.capacity});

  final EventCapacityGuidance capacity;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      padding: const EdgeInsets.all(CatchSpacing.s3),
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
                  '${capacity.min}-${capacity.max} attendees',
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

class _RunOfShow extends StatelessWidget {
  const _RunOfShow({required this.playbook});

  final EventSuccessPlaybook playbook;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Run of show', style: CatchTextStyles.sectionTitle(context)),
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
                        '${step.durationMinutes}',
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
                  padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
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

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.moduleGroups});

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
                child: _LayerHeader(layer: entry.key),
              ),
              for (final module in entry.value)
                SizedBox(
                  width: width,
                  child: _ModuleCard(module: module),
                ),
            ],
          ],
        );
      },
    );
  }
}

class _LayerHeader extends StatelessWidget {
  const _LayerHeader({required this.layer});

  final EventSuccessProductLayer layer;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: CatchSpacing.s2),
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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final EventSuccessModule module;

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
                const CatchBadge(
                  label: 'live phone',
                  tone: CatchBadgeTone.warning,
                ),
              if (!module.enabledByDefault)
                const CatchBadge(
                  label: 'later experiment',
                  tone: CatchBadgeTone.neutral,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoachPanel extends StatelessWidget {
  const _CoachPanel({required this.brief});

  final EventSuccessBrief brief;

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
            children: [
              Icon(CatchIcons.insightsOutlined, color: t.primary),
              const SizedBox(width: CatchSpacing.s2),
              Expanded(
                child: Text(
                  'Sample debrief',
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
              CatchBadge(
                label: '${(brief.scorecard.experienceScore * 100).round()}%',
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
                label: 'Check-in',
                value: brief.scorecard.checkInRate,
              ),
              EventSuccessMetricPill(
                label: 'Intro coverage',
                value: brief.scorecard.introCoverageRate,
              ),
              EventSuccessMetricPill(
                label: 'Host help',
                value: brief.scorecard.wingmanRequestRate,
              ),
              EventSuccessMetricPill(
                label: 'Chat start',
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
            _NotesList(title: 'Strengths', items: brief.strengths),
          ],
        ],
      ),
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({required this.title, required this.items});

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
            padding: const EdgeInsets.only(bottom: CatchSpacing.s1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: CatchSpacing.s2),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s4,
        CatchSpacing.s5,
        0,
      ),
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
