import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
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
    this.laterEvents = const <HostTodayEventRowData>[],
    this.hasPastEvents = false,
    this.error,
    this.stackTrace,
  });

  final HostTodayStatus status;
  final Event? featuredEvent;
  final List<HostTodayAttentionData> attentionItems;
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
    final event = item.event;
    return switch (item.kind) {
      HostAttentionKind.reviewWaitlist => HostTodayAttentionData(
        item: item,
        title: l10n.hostsHostHomeScreenStateTitleReviewWaitlist,
        body: l10n
            .hostsHostHomeScreenStateBodyTitleWaitlistcountWaitingAvailability(
              title: event.title,
              waitlistCount: event.waitlistCount,
              availability: event.spotsRemaining > 0
                  ? l10n.hostsHostHomeScreenStateVisiblecopySpotsremainingSpotsOpen(
                      spotsRemaining: event.spotsRemaining,
                    )
                  : l10n.hostsHostHomeScreenStateVisiblecopyEventFull,
            ),
        primaryActionLabel: l10n.hostsHostHomeScreenStateVisiblecopyReview,
        icon: CatchIcons.personSearchOutlined,
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
