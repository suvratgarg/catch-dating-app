import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
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
      appBar: AppBar(title: const Text('Event Success Lab')),
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
                title: 'System modules',
                child: _ModuleGrid(modules: EventSuccessModuleCatalog.all),
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
      child: CatchSurface(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [t.accent, t.ink],
        ),
        borderColor: Colors.transparent,
        padding: const EdgeInsets.all(CatchSpacing.s5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: const [
                CatchBadge(
                  label: 'Work in progress',
                  tone: CatchBadgeTone.live,
                  icon: Icons.construction_rounded,
                ),
                CatchBadge(
                  label: 'Preview only',
                  tone: CatchBadgeTone.solid,
                  icon: Icons.visibility_outlined,
                ),
              ],
            ),
            const SizedBox(height: CatchSpacing.s5),
            Text(
              'Event Success Layer',
              style: CatchTextStyles.displayL(context, color: t.accentInk),
            ),
            const SizedBox(height: CatchSpacing.s3),
            Text(
              'A first-pass workspace for improving what happens during events: host scripts, check-in, social pods, private crushes, decomposed reviews, and coaching.',
              style: CatchTextStyles.bodyL(
                context,
                color: t.accentInk.withValues(alpha: 0.86),
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
        final columns = constraints.maxWidth >= 640 ? 3 : 1;
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
                icon: Icons.favorite_border_rounded,
                title: 'Attendees',
                body: playbook.attendeePromise,
              ),
            ),
            SizedBox(
              width: width,
              child: _PromiseCard(
                icon: Icons.groups_2_outlined,
                title: 'Hosts',
                body: playbook.hostPromise,
              ),
            ),
            SizedBox(
              width: width,
              child: const _PromiseCard(
                icon: Icons.science_outlined,
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
          Text(title, style: CatchTextStyles.titleM(context)),
          const SizedBox(height: CatchSpacing.s2),
          Text(body, style: CatchTextStyles.bodyS(context)),
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
          Text(playbook.title, style: CatchTextStyles.displayS(context)),
          const SizedBox(height: CatchSpacing.s2),
          Text(playbook.summary, style: CatchTextStyles.bodyM(context)),
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
          Icon(Icons.confirmation_number_outlined, color: t.accent),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${capacity.min}-${capacity.max} attendees',
                  style: CatchTextStyles.titleS(context),
                ),
                const SizedBox(height: CatchSpacing.s1),
                Text(capacity.rationale, style: CatchTextStyles.bodyS(context)),
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
        Text('Run of show', style: CatchTextStyles.titleM(context)),
        const SizedBox(height: CatchSpacing.s3),
        for (final step in playbook.runOfShow) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.primarySoft,
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                    ),
                    child: SizedBox(
                      width: 34,
                      height: 34,
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
                  ),
                  if (step != playbook.runOfShow.last)
                    Container(width: 1, height: 34, color: t.line2),
                ],
              ),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: CatchTextStyles.titleS(context)),
                      const SizedBox(height: CatchSpacing.s1),
                      Text(
                        step.hostInstruction,
                        style: CatchTextStyles.bodyS(context),
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
  const _ModuleGrid({required this.modules});

  final List<EventSuccessModule> modules;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 2 : 1;
        final width =
            (constraints.maxWidth - (CatchSpacing.s3 * (columns - 1))) /
            columns;
        return Wrap(
          spacing: CatchSpacing.s3,
          runSpacing: CatchSpacing.s3,
          children: [
            for (final module in modules)
              SizedBox(
                width: width,
                child: _ModuleCard(module: module),
              ),
          ],
        );
      },
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
                  style: CatchTextStyles.titleM(context),
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
          Text(module.hostPromise, style: CatchTextStyles.bodyS(context)),
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
              Icon(Icons.insights_outlined, color: t.primary),
              const SizedBox(width: CatchSpacing.s2),
              Expanded(
                child: Text(
                  'Sample debrief',
                  style: CatchTextStyles.titleM(context),
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
                label: 'Private crush',
                value: brief.scorecard.privateCrushRate,
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
        Text(title, style: CatchTextStyles.titleS(context)),
        const SizedBox(height: CatchSpacing.s2),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: CatchSpacing.s1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.primary,
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                    ),
                    child: const SizedBox.square(dimension: 5),
                  ),
                ),
                const SizedBox(width: CatchSpacing.s2),
                Expanded(
                  child: Text(item, style: CatchTextStyles.bodyS(context)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.titleL(context)),
          const SizedBox(height: CatchSpacing.s3),
          child,
        ],
      ),
    );
  }
}

IconData _activityIcon(ActivityKind type) => switch (type) {
  ActivityKind.socialRun => Icons.directions_run_rounded,
  ActivityKind.running => Icons.directions_run_rounded,
  ActivityKind.walking => Icons.directions_walk_rounded,
  ActivityKind.pickleball => Icons.sports_tennis_rounded,
  ActivityKind.padel => Icons.sports_tennis_rounded,
  ActivityKind.tennis => Icons.sports_tennis_rounded,
  ActivityKind.badminton => Icons.sports_tennis_rounded,
  ActivityKind.cycling => Icons.directions_bike_rounded,
  ActivityKind.spinClass => Icons.fitness_center_rounded,
  ActivityKind.yoga => Icons.self_improvement_rounded,
  ActivityKind.strengthTraining => Icons.fitness_center_rounded,
  ActivityKind.pubQuiz => Icons.quiz_outlined,
  ActivityKind.barCrawl => Icons.local_bar_outlined,
  ActivityKind.dinner => Icons.restaurant_outlined,
  ActivityKind.singlesMixer => Icons.favorite_border_rounded,
  ActivityKind.openActivity => Icons.event_available_outlined,
};

IconData _priorityIcon(EventRecommendationPriority priority) =>
    switch (priority) {
      EventRecommendationPriority.critical =>
        Icons.report_gmailerrorred_rounded,
      EventRecommendationPriority.high => Icons.priority_high_rounded,
      EventRecommendationPriority.medium => Icons.tune_rounded,
      EventRecommendationPriority.low => Icons.check_circle_outline_rounded,
    };
