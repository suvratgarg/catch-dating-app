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
          CatchEmptyState(
            icon: CatchIcons.insightsOutlined,
            title: context
                .l10n
                .eventSuccessEventSuccessHostReportTitleNoEventReportYet,
            message: context
                .l10n
                .eventSuccessEventSuccessHostReportBodyTheLiveEventGuide,
            layout: CatchEmptyStateLayout.inline,
            surface: true,
            padding: CatchInsets.content,
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
          CatchEmptyState(
            icon: CatchIcons.insightsOutlined,
            title: context
                .l10n
                .eventSuccessEventSuccessHostReportTitlePostEventInsightsAre,
            message: context
                .l10n
                .eventSuccessEventSuccessHostReportBodyThisEventGuideDoes,
            layout: CatchEmptyStateLayout.inline,
            surface: true,
            padding: CatchInsets.content,
          ),
        ],
      );
    }

    final reportScorecard = scorecard;
    if (reportScorecard == null) {
      return EventSuccessHostTabBody(
        embedded: embedded,
        children: [
          CatchEmptyState(
            icon: CatchIcons.insightsOutlined,
            title: context
                .l10n
                .eventSuccessEventSuccessHostReportTitleWaitingForAttendeeFeedback,
            message: context
                .l10n
                .eventSuccessEventSuccessHostReportBodyThePostEventReport,
            layout: CatchEmptyStateLayout.inline,
            surface: true,
            padding: CatchInsets.content,
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
        CatchSurface.message(
          messageIcon: CatchIcons.assignmentTurnedInOutlined,
          title: context.l10n
              .eventSuccessEventSuccessHostReportTitleFeedbackcountAttendeeFeedbackResponse(
                feedbackCount: feedbackCount,
                value2: feedbackCount == 1
                    ? ''
                    : context.l10n.eventSuccessEventSuccessHostReportTitleS,
              ),
          message: context
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
    final scorecard = brief.scorecard;
    return CatchSection.plain(
      title:
          context.l10n.eventSuccessEventSuccessHostReportTextHowReliableIsThis,
      subtitle: context
          .l10n
          .eventSuccessEventSuccessHostReportTextShowsWhetherTheReport,
      child: CatchAnalyticsMetricGrid(
        metrics: [
          CatchMetricCardData(
            icon: CatchIcons.rateReviewOutlined,
            value: _eventSuccessPercent(scorecard.feedbackResponseRate),
            label: context.l10n.eventSuccessEventSuccessHostReportLabelFeedback,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelFeedbackresponsecountCheckedincountFeedback(
                  feedbackResponseCount: scorecard.feedbackResponseCount,
                  checkedInCount: scorecard.checkedInCount,
                ),
          ),
          CatchMetricCardData(
            icon: CatchIcons.favoriteOutlineRounded,
            value: _eventSuccessPercent(scorecard.caughtSomeoneRate),
            label: context
                .l10n
                .eventSuccessEventSuccessHostReportLabelCaughtSomeone,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelAttendeeswhocaughtsomeoneCaughtSomeone(
                  attendeesWhoCaughtSomeone:
                      scorecard.attendeesWhoCaughtSomeone,
                ),
          ),
          CatchMetricCardData(
            icon: CatchIcons.favoriteRounded,
            value: '${scorecard.catchSentCount}',
            label:
                context.l10n.eventSuccessEventSuccessHostReportLabelCatchesSent,
          ),
          CatchMetricCardData(
            icon: CatchIcons.groups2Outlined,
            value: _eventSuccessPercent(scorecard.assignmentCoverageRate),
            label: context
                .l10n
                .eventSuccessEventSuccessHostReportLabelPeopleIncluded,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelAssignmentparticipantcountAssigned(
                  assignmentParticipantCount:
                      scorecard.assignmentParticipantCount,
                ),
          ),
          CatchMetricCardData(
            icon: CatchIcons.visibilityOffOutlined,
            value: _eventSuccessPercent(scorecard.assignmentOptOutRate),
            label: context.l10n.eventSuccessEventSuccessHostReportLabelOptedOut,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelAssignmentoptoutcountOptedOut(
                  assignmentOptOutCount: scorecard.assignmentOptOutCount,
                ),
          ),
          CatchMetricCardData(
            icon: CatchIcons.volunteerActivismOutlined,
            value: _eventSuccessPercent(scorecard.wingmanRequestRate),
            label:
                context.l10n.eventSuccessEventSuccessHostReportLabelWingmanHelp,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelWingmanrequestcountHostHelpRequests(
                  wingmanRequestCount: scorecard.wingmanRequestCount,
                ),
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
    final funnel = brief.scorecard.funnel;
    return CatchSection.plain(
      title: context.l10n.eventSuccessEventSuccessHostReportTextEventFunnel,
      subtitle: _funnelSummaryCopy(funnel),
      child: CatchAnalyticsMetricGrid(
        metrics: [
          CatchMetricCardData(
            icon: CatchIcons.personAddAlt1Rounded,
            value: _eventSuccessPercent(funnel.demandConversionRate),
            label: context
                .l10n
                .eventSuccessEventSuccessHostReportLabelDemandToBooked,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelTotaldemandcountPeopleInDemand(
                  totalDemandCount: funnel.totalDemandCount,
                ),
          ),
          CatchMetricCardData(
            icon: CatchIcons.checkCircleOutlineRounded,
            value: _eventSuccessPercent(funnel.requestApprovalRate),
            label: context
                .l10n
                .eventSuccessEventSuccessHostReportLabelRequestsApproved,
          ),
          CatchMetricCardData(
            icon: CatchIcons.hourglassEmptyRounded,
            value: _eventSuccessPercent(funnel.waitlistOfferAcceptanceRate),
            label: context
                .l10n
                .eventSuccessEventSuccessHostReportLabelOffersAccepted,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelWaitlistjoincountWaitlisted(
                  waitlistJoinCount: funnel.waitlistJoinCount,
                ),
          ),
          CatchMetricCardData(
            icon: CatchIcons.paymentsOutlined,
            value: _eventSuccessPercent(funnel.paymentCompletionRate),
            label: context
                .l10n
                .eventSuccessEventSuccessHostReportLabelPaymentComplete,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelPaymentcompletedcountPaid(
                  paymentCompletedCount: funnel.paymentCompletedCount,
                ),
          ),
          CatchMetricCardData(
            icon: CatchIcons.chatBubbleOutlineRounded,
            value: _eventSuccessPercent(funnel.repeatAttendeeRate),
            label: context
                .l10n
                .eventSuccessEventSuccessHostReportLabelRepeatAttendees,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelChatstartedcountChatsStarted(
                  chatStartedCount: funnel.chatStartedCount,
                ),
          ),
        ],
      ),
    );
  }
}

String _eventSuccessPercent(double value) => '${(value * 100).round()}%';

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
