part of '../event_success_host_screen.dart';

class _ReportTab extends StatelessWidget {
  const _ReportTab({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    required this.feedback,
    this.scorecard,
    required this.assignments,
    required this.rotationAssignments,
    required this.preferences,
    required this.wingmanRequests,
    required this.shrinkWrap,
    required this.physics,
    required this.padding,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final List<EventSuccessFeedback> feedback;
  final EventSuccessScorecard? scorecard;
  final List<EventSuccessAssignment> assignments;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (!planIsPersisted) {
      return ListView(
        shrinkWrap: shrinkWrap,
        primary: shrinkWrap ? false : null,
        physics: physics,
        padding: padding,
        children: const [
          _NoticeCard(
            icon: Icons.insights_outlined,
            title: 'No event report yet',
            body:
                'The live event guide was not saved for this event, so there is no post-event report to review. Attendance reporting remains available on this screen.',
          ),
        ],
      );
    }

    final runtime = EventSuccessRuntime(
      plan: plan,
      event: event,
      now: DateTime.now(),
    );
    if (!runtime.hostReportEnabled) {
      return ListView(
        shrinkWrap: shrinkWrap,
        primary: shrinkWrap ? false : null,
        physics: physics,
        padding: padding,
        children: const [
          _NoticeCard(
            icon: Icons.insights_outlined,
            title: 'Post-event insights are off',
            body:
                'This event guide does not include post-event coaching for the host.',
          ),
        ],
      );
    }

    final brief = scorecard == null
        ? plan.buildBrief(
            event: event,
            feedback: feedback,
            assignments: assignments,
            rotationAssignments: rotationAssignments,
            preferences: preferences,
            wingmanRequests: wingmanRequests,
          )
        : plan.buildBriefFromScorecard(
            event: event,
            scorecard: scorecard,
            assignments: assignments,
            rotationAssignments: rotationAssignments,
            preferences: preferences,
            wingmanRequests: wingmanRequests,
          );
    final feedbackCount = brief.scorecard.feedbackResponseCount;

    return ListView(
      shrinkWrap: shrinkWrap,
      primary: shrinkWrap ? false : null,
      physics: physics,
      padding: padding,
      children: [
        _NoticeCard(
          icon: Icons.assignment_turned_in_outlined,
          title:
              '$feedbackCount attendee feedback response${feedbackCount == 1 ? '' : 's'}',
          body:
              'The report combines attendance, safe aggregate feedback, assignment coverage, and explicit host-help requests.',
        ),
        gapH16,
        _HostReportSignalGrid(brief: brief),
        gapH16,
        EventSuccessPostEventReport(brief: brief),
      ],
    );
  }
}

class _HostReportSignalGrid extends StatelessWidget {
  const _HostReportSignalGrid({required this.brief});

  final EventSuccessBrief brief;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final scorecard = brief.scorecard;
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.query_stats_rounded, color: t.primary),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How reliable is this report?',
                      style: CatchTextStyles.titleM(context),
                    ),
                    gapH4,
                    Text(
                      'Shows whether the report is based on enough live data to trust.',
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          gapH14,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              EventSuccessMetricPill(
                label: 'Feedback',
                value: scorecard.feedbackResponseRate,
              ),
              EventSuccessMetricPill(
                label: 'People included',
                value: scorecard.assignmentCoverageRate,
              ),
              EventSuccessMetricPill(
                label: 'Opted out',
                value: scorecard.assignmentOptOutRate,
              ),
              EventSuccessMetricPill(
                label: 'Wingman help',
                value: scorecard.wingmanRequestRate,
              ),
            ],
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label:
                    '${scorecard.feedbackResponseCount}/${scorecard.checkedInCount} feedback',
                tone: CatchBadgeTone.neutral,
                icon: Icons.rate_review_outlined,
              ),
              CatchBadge(
                label: '${scorecard.assignmentParticipantCount} assigned',
                tone: CatchBadgeTone.neutral,
                icon: Icons.groups_2_outlined,
              ),
              CatchBadge(
                label: '${scorecard.assignmentOptOutCount} opted out',
                tone: CatchBadgeTone.neutral,
                icon: Icons.visibility_off_outlined,
              ),
              CatchBadge(
                label: '${scorecard.wingmanRequestCount} host-help requests',
                tone: CatchBadgeTone.neutral,
                icon: Icons.volunteer_activism_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
