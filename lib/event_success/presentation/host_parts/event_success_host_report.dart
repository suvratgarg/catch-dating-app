part of '../event_success_host_screen.dart';

class ReportTab extends StatelessWidget {
  const ReportTab({
    super.key,
    required this.event,
    required this.plan,
    required this.planIsPersisted,
    this.scorecard,
    this.assignments,
    this.rotationAssignments,
    this.preferences,
    this.wingmanRequests,
    required this.resourceFailures,
    required this.onRetryResource,
    required this.embedded,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool planIsPersisted;
  final EventSuccessScorecard? scorecard;
  final List<EventSuccessAssignment>? assignments;
  final List<EventSuccessAssignment>? rotationAssignments;
  final List<EventSuccessPreference>? preferences;
  final List<EventSuccessWingmanRequest>? wingmanRequests;
  final List<EventSuccessHostResourceFailure> resourceFailures;
  final ValueChanged<EventSuccessHostRetryIntent>? onRetryResource;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    if (!planIsPersisted) {
      return EventSuccessHostTabBody(
        embedded: embedded,
        children: [
          _EventSuccessReportEmptyState(
            icon: CatchIcons.insightsOutlined,
            title: context
                .l10n
                .eventSuccessEventSuccessHostReportTitleNoEventReportYet,
            message: context
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
          _EventSuccessReportEmptyState(
            icon: CatchIcons.insightsOutlined,
            title: context
                .l10n
                .eventSuccessEventSuccessHostReportTitlePostEventInsightsAre,
            message: context
                .l10n
                .eventSuccessEventSuccessHostReportBodyThisEventGuideDoes,
          ),
        ],
      );
    }

    final reportScorecard = scorecard;
    final reportFailures = resourceFailures
        .where(
          (failure) => switch (failure.retryIntent) {
            EventSuccessHostRetryIntent.assignments ||
            EventSuccessHostRetryIntent.rotationAssignments ||
            EventSuccessHostRetryIntent.preferences ||
            EventSuccessHostRetryIntent.wingmanRequests ||
            EventSuccessHostRetryIntent.scorecard => true,
            _ => false,
          },
        )
        .toList(growable: false);
    final errorStates = [
      for (final failure in reportFailures)
        EventSuccessHostResourceError(
          failure: failure,
          onRetry: onRetryResource == null
              ? null
              : () => onRetryResource!(failure.retryIntent),
        ),
    ];
    if (reportScorecard == null) {
      return EventSuccessHostTabBody(
        embedded: embedded,
        children: [
          ...errorStates.expand((error) => [error, gapH16]),
          if (!reportFailures.any(
            (failure) =>
                failure.retryIntent == EventSuccessHostRetryIntent.scorecard,
          ))
            _EventSuccessReportEmptyState(
              icon: CatchIcons.insightsOutlined,
              title: context
                  .l10n
                  .eventSuccessEventSuccessHostReportTitleWaitingForAttendeeFeedback,
              message: context
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
        ...errorStates.expand((error) => [error, gapH16]),
        CatchBanner(
          icon: CatchIcons.assignmentTurnedInOutlined,
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

class _EventSuccessReportEmptyState extends StatelessWidget {
  const _EventSuccessReportEmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => CatchSection.contained(
    child: CatchEmptyState(
      icon: icon,
      title: title,
      message: message,
      variant: CatchEmptyStateVariant.inline,
      padding: EdgeInsets.zero,
    ),
  );
}

class HostReportSignalGrid extends StatelessWidget {
  const HostReportSignalGrid({super.key, required this.brief});

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
      child: CatchMetricSection.dataQuality(
        metrics: [
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
            icon: CatchIcons.rateReviewOutlined,
            value: _eventSuccessPercent(scorecard.feedbackResponseRate),
            label: context.l10n.eventSuccessEventSuccessHostReportLabelFeedback,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelFeedbackresponsecountCheckedincountFeedback(
                  feedbackResponseCount: scorecard.feedbackResponseCount,
                  checkedInCount: scorecard.checkedInCount,
                ),
          ),
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
            icon: CatchIcons.groups2Outlined,
            value: '${scorecard.conversationExcludedAttendeeCount}',
            label: context
                .l10n
                .eventSuccessEventSuccessHostReportLabelConversationExclusions,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelConversationgraphresponsecountCheckedincountResponses(
                  conversationGraphResponseCount:
                      scorecard.conversationGraphResponseCount,
                  checkedInCount: scorecard.checkedInCount,
                ),
          ),
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
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
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
            icon: CatchIcons.favoriteRounded,
            value: '${scorecard.catchSentCount}',
            label:
                context.l10n.eventSuccessEventSuccessHostReportLabelCatchesSent,
          ),
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
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
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
            icon: CatchIcons.visibilityOffOutlined,
            value: _eventSuccessPercent(scorecard.assignmentOptOutRate),
            label: context.l10n.eventSuccessEventSuccessHostReportLabelOptedOut,
            caption: context.l10n
                .eventSuccessEventSuccessHostReportLabelAssignmentoptoutcountOptedOut(
                  assignmentOptOutCount: scorecard.assignmentOptOutCount,
                ),
          ),
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
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
  const HostFunnelSummary({super.key, required this.brief});

  final EventSuccessBrief brief;

  @override
  Widget build(BuildContext context) {
    final funnel = brief.scorecard.funnel;
    return CatchSection.plain(
      title: context.l10n.eventSuccessEventSuccessHostReportTextEventFunnel,
      subtitle: _funnelSummaryCopy(funnel),
      child: CatchMetricSection.dataQuality(
        metrics: [
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
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
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
            icon: CatchIcons.checkCircleOutlineRounded,
            value: _eventSuccessPercent(funnel.requestApprovalRate),
            label: context
                .l10n
                .eventSuccessEventSuccessHostReportLabelRequestsApproved,
          ),
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
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
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
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
          CatchMetricData(
            partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
            missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
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
