import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_feed_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum HostTodayRouteStatus { authRequired, loading, error, empty, loaded }

@immutable
class HostTodayRouteState {
  const HostTodayRouteState({
    required this.status,
    this.uid,
    this.organizers = const <Club>[],
    this.error,
    this.stackTrace,
    this.errorContext = AppErrorContext.club,
  });

  final HostTodayRouteStatus status;
  final String? uid;
  final List<Club> organizers;
  final Object? error;
  final StackTrace? stackTrace;
  final AppErrorContext errorContext;
}

enum HostTodayStatus { loading, error, empty, content }

@immutable
class HostTodayState {
  const HostTodayState({
    required this.status,
    this.featuredEvent,
    this.attentionItems = const <HostTodayAttentionData>[],
    this.attentionIssues = const <HostTodayAttentionIssue>[],
    this.laterEvents = const <HostTodayEventRowData>[],
    this.hasPastEvents = false,
    this.error,
    this.stackTrace,
  });

  final HostTodayStatus status;
  final Event? featuredEvent;
  final List<HostTodayAttentionData> attentionItems;
  final List<HostTodayAttentionIssue> attentionIssues;
  final List<HostTodayEventRowData> laterEvents;
  final bool hasPastEvents;
  final Object? error;
  final StackTrace? stackTrace;
}

@immutable
class HostTodayAttentionData {
  const HostTodayAttentionData({
    required this.item,
    required this.title,
    required this.body,
    required this.primaryActionLabel,
    required this.icon,
  });

  factory HostTodayAttentionData.fromItem(
    HostAttentionItem item,
    AppLocalizations l10n,
  ) {
    final eventName =
        item.context.eventName ?? l10n.hostTodayAttentionFallbackEvent;
    final subjectLabel =
        item.context.subjectLabel ?? l10n.hostTodayAttentionFallbackSubject;
    final count = item.context.count ?? 0;
    return switch (item.kind) {
      HostAttentionKind.eventLiveOperations => HostTodayAttentionData(
        item: item,
        title: l10n.hostTodayAttentionLiveTitle,
        body: l10n.hostTodayAttentionLiveBody(eventName: eventName),
        primaryActionLabel: l10n.hostTodayAttentionOpenLive,
        icon: CatchIcons.eventLive,
      ),
      HostAttentionKind.eventWaitlistReview => HostTodayAttentionData(
        item: item,
        title: l10n.hostsHostHomeScreenStateTitleReviewWaitlist,
        body: l10n.hostTodayAttentionWaitlistBody(
          count: count,
          eventName: eventName,
        ),
        primaryActionLabel: l10n.hostsHostHomeScreenStateVisiblecopyReview,
        icon: CatchIcons.personSearchOutlined,
      ),
      HostAttentionKind.eventJoinRequestReview => HostTodayAttentionData(
        item: item,
        title: l10n.hostTodayAttentionJoinTitle,
        body: l10n.hostTodayAttentionJoinBody(
          count: count,
          eventName: eventName,
        ),
        primaryActionLabel: l10n.hostTodayAttentionReview,
        icon: CatchIcons.howToRegOutlined,
      ),
      HostAttentionKind.applicationReview => HostTodayAttentionData(
        item: item,
        title: l10n.hostTodayAttentionApplicationTitle,
        body: l10n.hostTodayAttentionApplicationBody(
          subjectLabel: subjectLabel,
        ),
        primaryActionLabel: l10n.hostTodayAttentionReview,
        icon: CatchIcons.factCheckOutlined,
      ),
      HostAttentionKind.providerSyncFailure => HostTodayAttentionData(
        item: item,
        title: l10n.hostTodayAttentionProviderTitle,
        body: l10n.hostTodayAttentionProviderBody(eventName: eventName),
        primaryActionLabel: l10n.hostTodayAttentionReview,
        icon: CatchIcons.syncAltRounded,
      ),
      HostAttentionKind.formAutomationFailure => HostTodayAttentionData(
        item: item,
        title: l10n.hostTodayAttentionAutomationTitle,
        body: l10n.hostTodayAttentionAutomationBody(subjectLabel: subjectLabel),
        primaryActionLabel: l10n.hostTodayAttentionFix,
        icon: CatchIcons.ruleOutlined,
      ),
      HostAttentionKind.payoutSetup => HostTodayAttentionData(
        item: item,
        title: l10n.hostTodayAttentionPayoutTitle,
        body: l10n.hostTodayAttentionPayoutBody(
          count: count,
          provider: item.context.provider ?? subjectLabel,
        ),
        primaryActionLabel: l10n.hostTodayAttentionSetUpPayouts,
        icon: CatchIcons.paymentsOutlined,
      ),
      HostAttentionKind.attendanceSync => HostTodayAttentionData(
        item: item,
        title: l10n.hostTodayAttentionAttendanceTitle,
        body: l10n.hostTodayAttentionAttendanceBody(eventName: eventName),
        primaryActionLabel: l10n.hostTodayAttentionReviewAttendance,
        icon: CatchIcons.factCheckOutlined,
      ),
      HostAttentionKind.dressRehearsal ||
      HostAttentionKind.eventSuccessPreparation ||
      HostAttentionKind.roomLayoutSetup ||
      HostAttentionKind.eventStaffing ||
      HostAttentionKind.formResponseReview ||
      HostAttentionKind.inboxReply ||
      HostAttentionKind.postEventReconciliation => HostTodayAttentionData(
        item: item,
        title: l10n.hostTodayAttentionGenericTitle,
        body: l10n.hostTodayAttentionGenericBody,
        primaryActionLabel: l10n.hostTodayAttentionOpen,
        icon: CatchIcons.infoOutlineRounded,
      ),
    };
  }

  final HostAttentionItem item;
  final String title;
  final String body;
  final String primaryActionLabel;
  final IconData icon;
}

@immutable
class HostTodayEventRowData {
  const HostTodayEventRowData({
    required this.event,
    required this.isToday,
    required this.isLive,
    required this.fillRatio,
  });

  factory HostTodayEventRowData.fromEvent({
    required Event event,
    required DateTime now,
  }) {
    final capacity = event.capacityLimit;
    return HostTodayEventRowData(
      event: event,
      isToday: DateUtils.isSameDay(event.startTime, now),
      isLive: !event.startTime.isAfter(now) && event.endTime.isAfter(now),
      fillRatio: capacity <= 0
          ? 0
          : (event.signedUpCount / capacity).clamp(0.0, 1.0),
    );
  }

  final Event event;
  final bool isToday;
  final bool isLive;
  final double fillRatio;

  String get dateLabel => '${event.startTime.day}'.padLeft(2, '0');
  String get monthLabel =>
      EventFormatters.shortMonth(event.startTime).toUpperCase();

  String get metaLabel {
    if (isLive) return 'Live · ${event.signedUpCount} going';
    if (isToday) return 'Today · ${event.signedUpCount} going';
    return '${EventFormatters.shortWeekday(event.startTime)} · '
        '${EventFormatters.time(event.startTime)} · '
        '${(fillRatio * 100).round()}% full';
  }
}
