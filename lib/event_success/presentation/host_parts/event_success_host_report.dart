part of '../event_success_host_screen.dart';

class ReportTab extends StatelessWidget {
  const ReportTab({
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    this.scorecard,
    required this.assignments,
    required this.rotationAssignments,
    required this.preferences,
    required this.wingmanRequests,
    required this.embedded,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventSuccessScorecard? scorecard;
  final List<EventSuccessAssignment> assignments;
  final List<EventSuccessAssignment> rotationAssignments;
  final List<EventSuccessPreference> preferences;
  final List<EventSuccessWingmanRequest> wingmanRequests;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (!planIsPersisted) {
      return EventSuccessHostTabBody(
        embedded: embedded,
        children: [
          NoticeCard(
            icon: CatchIcons.insightsOutlined,
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
      return EventSuccessHostTabBody(
        embedded: embedded,
        children: [
          NoticeCard(
            icon: CatchIcons.insightsOutlined,
            title: 'Post-event insights are off',
            body:
                'This event guide does not include post-event coaching for the host.',
          ),
        ],
      );
    }

    final reportScorecard = scorecard;
    if (reportScorecard == null) {
      return EventSuccessHostTabBody(
        embedded: embedded,
        children: [
          NoticeCard(
            icon: CatchIcons.insightsOutlined,
            title: 'Waiting for attendee feedback',
            body:
                'The post-event report appears once checked-in attendees '
                'share feedback. There is no signal to summarize yet.',
          ),
        ],
      );
    }

    final brief = plan.buildBriefFromScorecard(
      event: event,
      scorecard: reportScorecard,
      assignments: assignments,
      rotationAssignments: rotationAssignments,
      preferences: preferences,
      wingmanRequests: wingmanRequests,
    );
    final feedbackCount = brief.scorecard.feedbackResponseCount;

    return EventSuccessHostTabBody(
      embedded: embedded,
      children: [
        NoticeCard(
          icon: CatchIcons.assignmentTurnedInOutlined,
          title:
              '$feedbackCount attendee feedback response${feedbackCount == 1 ? '' : 's'}',
          body:
              'The report combines attendance, safe aggregate feedback, assignment coverage, and explicit host-help requests. Private notes, safety concerns, and individual opener choices are not shown to hosts.',
        ),
        gapH16,
        HostReportSignalGrid(brief: brief),
        gapH16,
        HostFunnelSummary(brief: brief),
        gapH16,
        EventSuccessPostEventReport(brief: brief),
      ],
    );
  }
}

class HostReportSignalGrid extends StatelessWidget {
  const HostReportSignalGrid({required this.brief});

  final EventSuccessBrief brief;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final scorecard = brief.scorecard;
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CatchIcons.queryStatsRounded, color: t.primary),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How reliable is this report?',
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    gapH4,
                    Text(
                      'Shows whether the report is based on enough live data to trust.',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
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
                label: 'Caught someone',
                value: scorecard.caughtSomeoneRate,
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
                icon: CatchIcons.rateReviewOutlined,
              ),
              CatchBadge(
                label: '${scorecard.attendeesWhoCaughtSomeone} caught someone',
                icon: CatchIcons.favoriteOutlineRounded,
              ),
              CatchBadge(
                label: '${scorecard.catchSentCount} catches sent',
                icon: CatchIcons.favoriteRounded,
              ),
              CatchBadge(
                label: '${scorecard.assignmentParticipantCount} assigned',
                icon: CatchIcons.groups2Outlined,
              ),
              CatchBadge(
                label: '${scorecard.assignmentOptOutCount} opted out',
                icon: CatchIcons.visibilityOffOutlined,
              ),
              CatchBadge(
                label: '${scorecard.wingmanRequestCount} host-help requests',
                icon: CatchIcons.volunteerActivismOutlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HostFunnelSummary extends StatelessWidget {
  const HostFunnelSummary({required this.brief});

  final EventSuccessBrief brief;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final funnel = brief.scorecard.funnel;
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CatchIcons.routeRounded, color: t.primary),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event funnel',
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    gapH4,
                    Text(
                      _funnelSummaryCopy(funnel),
                      style: CatchTextStyles.supporting(context, color: t.ink2),
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
                label: 'Demand to booked',
                value: funnel.demandConversionRate,
              ),
              EventSuccessMetricPill(
                label: 'Requests approved',
                value: funnel.requestApprovalRate,
              ),
              EventSuccessMetricPill(
                label: 'Offers accepted',
                value: funnel.waitlistOfferAcceptanceRate,
              ),
              EventSuccessMetricPill(
                label: 'Payment complete',
                value: funnel.paymentCompletionRate,
              ),
              EventSuccessMetricPill(
                label: 'Repeat attendees',
                value: funnel.repeatAttendeeRate,
              ),
            ],
          ),
          gapH12,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              CatchBadge(
                label: '${funnel.inviteOpenCount} invite opens',
                icon: CatchIcons.linkRounded,
              ),
              CatchBadge(
                label: '${funnel.totalDemandCount} people in demand',
                icon: CatchIcons.personAddAlt1Rounded,
              ),
              CatchBadge(
                label: '${funnel.waitlistJoinCount} waitlisted',
                icon: CatchIcons.hourglassEmptyRounded,
              ),
              CatchBadge(
                label: '${funnel.paymentCompletedCount} paid',
                icon: CatchIcons.paymentsOutlined,
              ),
              CatchBadge(
                label: '${funnel.noShowCount} no-show',
                icon: CatchIcons.visibilityOffOutlined,
              ),
              CatchBadge(
                label: '${funnel.chatStartedCount} chats started',
                icon: CatchIcons.chatBubbleOutlineRounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _funnelSummaryCopy(EventSuccessHostFunnel funnel) {
  if (funnel.totalDemandCount == 0 && funnel.inviteOpenCount == 0) {
    return 'Waiting for booking and attribution data to build the operating funnel.';
  }
  if (funnel.requestCount > 0 && funnel.pendingRequestCount > 0) {
    return '${funnel.pendingRequestCount} request${funnel.pendingRequestCount == 1 ? '' : 's'} still need a host decision before demand can convert.';
  }
  if (funnel.waitlistOfferCount > 0 &&
      funnel.waitlistOfferAcceptanceRate < 0.5) {
    return 'Waitlist offers are the weak point; tighten timing or send clearer offer copy before the next release.';
  }
  if (funnel.noShowRate >= 0.2 && funnel.bookedCount >= 5) {
    return 'Attendance is leaking after booking; send stronger arrival reminders and make check-in easier.';
  }
  if (funnel.connectionRate < 0.4 && funnel.checkedInCount >= 5) {
    return 'Attendance converted, but connection needs stronger live prompts or post-event openers.';
  }
  return 'Demand, booking, attendance, and connection are now measured in one loop.';
}
