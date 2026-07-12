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
            title: context
                .l10n
                .eventSuccessEventSuccessHostReportTitleNoEventReportYet,
            body: context
                .l10n
                .eventSuccessEventSuccessHostReportBodyTheLiveEventGuide,
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
            title: context
                .l10n
                .eventSuccessEventSuccessHostReportTitlePostEventInsightsAre,
            body: context
                .l10n
                .eventSuccessEventSuccessHostReportBodyThisEventGuideDoes,
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
            title: context
                .l10n
                .eventSuccessEventSuccessHostReportTitleWaitingForAttendeeFeedback,
            body: context
                .l10n
                .eventSuccessEventSuccessHostReportBodyThePostEventReport,
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
          title: context.l10n
              .eventSuccessEventSuccessHostReportTitleFeedbackcountAttendeeFeedbackResponse(
                feedbackCount: feedbackCount,
                value2: feedbackCount == 1
                    ? ''
                    : context.l10n.eventSuccessEventSuccessHostReportTitleS,
              ),
          body: context
              .l10n
              .eventSuccessEventSuccessHostReportBodyTheReportCombinesAttendance,
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
                      context
                          .l10n
                          .eventSuccessEventSuccessHostReportTextHowReliableIsThis,
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    gapH4,
                    Text(
                      context
                          .l10n
                          .eventSuccessEventSuccessHostReportTextShowsWhetherTheReport,
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
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelFeedback,
                value: scorecard.feedbackResponseRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelCaughtSomeone,
                value: scorecard.caughtSomeoneRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelPeopleIncluded,
                value: scorecard.assignmentCoverageRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelOptedOut,
                value: scorecard.assignmentOptOutRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelWingmanHelp,
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
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelFeedbackresponsecountCheckedincountFeedback(
                      feedbackResponseCount: scorecard.feedbackResponseCount,
                      checkedInCount: scorecard.checkedInCount,
                    ),
                icon: CatchIcons.rateReviewOutlined,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelAttendeeswhocaughtsomeoneCaughtSomeone(
                      attendeesWhoCaughtSomeone:
                          scorecard.attendeesWhoCaughtSomeone,
                    ),
                icon: CatchIcons.favoriteOutlineRounded,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelCatchsentcountCatchesSent(
                      catchSentCount: scorecard.catchSentCount,
                    ),
                icon: CatchIcons.favoriteRounded,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelAssignmentparticipantcountAssigned(
                      assignmentParticipantCount:
                          scorecard.assignmentParticipantCount,
                    ),
                icon: CatchIcons.groups2Outlined,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelAssignmentoptoutcountOptedOut(
                      assignmentOptOutCount: scorecard.assignmentOptOutCount,
                    ),
                icon: CatchIcons.visibilityOffOutlined,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelWingmanrequestcountHostHelpRequests(
                      wingmanRequestCount: scorecard.wingmanRequestCount,
                    ),
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
                      context
                          .l10n
                          .eventSuccessEventSuccessHostReportTextEventFunnel,
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
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelDemandToBooked,
                value: funnel.demandConversionRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelRequestsApproved,
                value: funnel.requestApprovalRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelOffersAccepted,
                value: funnel.waitlistOfferAcceptanceRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelPaymentComplete,
                value: funnel.paymentCompletionRate,
              ),
              EventSuccessMetricPill(
                label: context
                    .l10n
                    .eventSuccessEventSuccessHostReportLabelRepeatAttendees,
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
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelInviteopencountInviteOpens(
                      inviteOpenCount: funnel.inviteOpenCount,
                    ),
                icon: CatchIcons.linkRounded,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelTotaldemandcountPeopleInDemand(
                      totalDemandCount: funnel.totalDemandCount,
                    ),
                icon: CatchIcons.personAddAlt1Rounded,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelWaitlistjoincountWaitlisted(
                      waitlistJoinCount: funnel.waitlistJoinCount,
                    ),
                icon: CatchIcons.hourglassEmptyRounded,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelPaymentcompletedcountPaid(
                      paymentCompletedCount: funnel.paymentCompletedCount,
                    ),
                icon: CatchIcons.paymentsOutlined,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelNoshowcountNoShow(
                      noShowCount: funnel.noShowCount,
                    ),
                icon: CatchIcons.visibilityOffOutlined,
              ),
              CatchBadge(
                label: context.l10n
                    .eventSuccessEventSuccessHostReportLabelChatstartedcountChatsStarted(
                      chatStartedCount: funnel.chatStartedCount,
                    ),
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
