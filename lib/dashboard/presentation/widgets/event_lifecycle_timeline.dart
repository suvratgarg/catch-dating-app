import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/dashboard/presentation/dashboard_full_view_model.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_arrival_action.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

typedef EventLifecycleClubNameBuilder = String? Function(Event event);
typedef EventFocusEventCallback = void Function(Event event);

class EventFocusActions {
  const EventFocusActions({
    required this.onViewEvent,
    required this.onCheckIn,
    required this.onOpenSwipe,
    required this.onWriteReview,
    required this.onOpenDirections,
    required this.onAddToCalendar,
    required this.onResetCheckInError,
  });

  final EventFocusEventCallback onViewEvent;
  final EventFocusEventCallback onCheckIn;
  final EventFocusEventCallback onOpenSwipe;
  final EventFocusEventCallback onWriteReview;
  final EventFocusEventCallback onOpenDirections;
  final EventFocusEventCallback onAddToCalendar;
  final VoidCallback onResetCheckInError;
}

class EventFocusCheckInState {
  const EventFocusCheckInState({this.isPending = false, this.error});

  static const idle = EventFocusCheckInState();

  final bool isPending;
  final Object? error;
}

class EventLifecycleTimeline extends StatefulWidget {
  const EventLifecycleTimeline({
    super.key,
    required this.upcomingEvents,
    required this.windowedEvents,
    required this.actions,
    this.checkInState = EventFocusCheckInState.idle,
    this.arrivalAction,
    this.pendingReviewEvent,
    this.clubNameBuilder,
  });

  static const timelineKey = Key('dashboard-event-lifecycle-timeline');
  static const listKey = Key('dashboard-event-lifecycle-list');
  static Key actionKey(String actionName) =>
      ValueKey('dashboard-event-lifecycle-action-$actionName');

  final List<Event> upcomingEvents;
  final List<CatchWindowItem> windowedEvents;
  final EventFocusActions actions;
  final EventFocusCheckInState checkInState;
  final EventArrivalAction? arrivalAction;
  final Event? pendingReviewEvent;
  final EventLifecycleClubNameBuilder? clubNameBuilder;

  @override
  State<EventLifecycleTimeline> createState() => _EventLifecycleTimelineState();
}

class _EventLifecycleTimelineState extends State<EventLifecycleTimeline> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant EventLifecycleTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.windowedEvents.length != widget.windowedEvents.length) {
      _syncTicker();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    if (items.isEmpty) return const SizedBox.shrink();

    final cardCountLabel = items.length == 1
        ? '1 phase'
        : '${items.length} phases';

    return Column(
      key: EventLifecycleTimeline.timelineKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Event timeline',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.titleL(context),
              ),
            ),
            gapW8,
            CatchBadge(label: cardCountLabel, tone: CatchBadgeTone.brand),
          ],
        ),
        gapH10,
        Column(
          key: EventLifecycleTimeline.listKey,
          children: [
            for (final (index, item) in items.indexed) ...[
              EventFocusCard(
                key: ValueKey(
                  'event-lifecycle-${item.kind.name}-${item.event.id}-'
                  '${item.canSwipe}-${item.needsReview}',
                ),
                item: item,
                now: _now,
                checkInState: widget.checkInState,
                onActionPressed: (action) => _handleAction(item, action),
              ),
              if (index != items.length - 1) gapH10,
            ],
          ],
        ),
        if (widget.checkInState.error != null) ...[
          gapH10,
          CatchErrorBanner.fromError(
            widget.checkInState.error!,
            context: AppErrorContext.dashboard,
            onRetry: widget.actions.onResetCheckInError,
          ),
        ],
      ],
    );
  }

  void _syncTicker() {
    _ticker?.cancel();
    _ticker = null;
    _now = DateTime.now();

    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion = mediaQuery?.disableAnimations ?? false;
    if (reduceMotion || widget.windowedEvents.isEmpty) return;

    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  List<EventFocusItem> _buildItems() {
    final items = <EventFocusItem>[];
    final checkInEventId =
        widget.arrivalAction?.kind == EventArrivalActionKind.selfCheckIn
        ? widget.arrivalAction?.event.id
        : null;

    final afterEventIds = <String>{};
    for (final window in widget.windowedEvents) {
      afterEventIds.add(window.event.id);
      items.add(
        EventFocusItem(
          event: window.event,
          kind: EventFocusKind.catchWindow,
          windowItem: window,
          needsReview: widget.pendingReviewEvent?.id == window.event.id,
          clubName: widget.clubNameBuilder?.call(window.event),
        ),
      );
    }

    for (final event in widget.upcomingEvents) {
      items.add(
        EventFocusItem(
          event: event,
          kind: event.id == checkInEventId
              ? EventFocusKind.checkIn
              : EventFocusKind.upcoming,
          clubName: widget.clubNameBuilder?.call(event),
        ),
      );
    }

    if (widget.pendingReviewEvent != null &&
        !afterEventIds.contains(widget.pendingReviewEvent!.id)) {
      items.add(
        EventFocusItem(
          event: widget.pendingReviewEvent!,
          kind: EventFocusKind.afterEvent,
          needsReview: true,
          clubName: widget.clubNameBuilder?.call(widget.pendingReviewEvent!),
        ),
      );
    }

    items.sort(_compareFocusItems);
    return items;
  }

  int _compareFocusItems(EventFocusItem a, EventFocusItem b) {
    final priority = a.priority.compareTo(b.priority);
    if (priority != 0) return priority;
    if (a.windowItem != null && b.windowItem != null) {
      return a.windowItem!.windowClosesAt.compareTo(
        b.windowItem!.windowClosesAt,
      );
    }
    if (a.kind == EventFocusKind.afterEvent &&
        b.kind == EventFocusKind.afterEvent) {
      return b.event.endTime.compareTo(a.event.endTime);
    }
    return a.event.startTime.compareTo(b.event.startTime);
  }

  void _handleAction(EventFocusItem item, EventFocusAction action) {
    switch (action) {
      case EventFocusAction.viewEvent:
        widget.actions.onViewEvent(item.event);
      case EventFocusAction.checkIn:
        widget.actions.onCheckIn(item.event);
      case EventFocusAction.swipe:
        widget.actions.onOpenSwipe(item.event);
      case EventFocusAction.review:
        widget.actions.onWriteReview(item.event);
      case EventFocusAction.directions:
        widget.actions.onOpenDirections(item.event);
      case EventFocusAction.addToCalendar:
        widget.actions.onAddToCalendar(item.event);
    }
  }
}

class EventFocusCard extends StatelessWidget {
  const EventFocusCard({
    super.key,
    required this.item,
    required this.now,
    required this.checkInState,
    required this.onActionPressed,
  });

  final EventFocusItem item;
  final DateTime now;
  final EventFocusCheckInState checkInState;
  final ValueChanged<EventFocusAction> onActionPressed;

  @override
  Widget build(BuildContext context) {
    final actions = [item.primaryAction, ...item.secondaryActions];
    final activity = ActivityPalette.resolve(context, item.event.activityKind);
    final window = item.windowItem;
    final countdown = window?.countdownLabel(now);

    return EventActionCard(
      event: item.event,
      topAccentColors: [activity.accent, activity.deep],
      subtitle: item.clubName,
      urgent: item.isUrgent,
      badges: [
        EventActionCardBadge(
          label: item.badgeLabel,
          tone: item.isUrgent ? CatchBadgeTone.brand : CatchBadgeTone.neutral,
        ),
        if (window != null && countdown != null)
          EventActionCardBadge(
            label: '${window.attendedCountLabel} to catch · $countdown left',
            tone: CatchBadgeTone.brand,
            icon: PhosphorIconsFill.heart,
          ),
        if (item.needsReview)
          const EventActionCardBadge(
            label: 'Review pending',
            tone: CatchBadgeTone.warning,
            icon: PhosphorIconsRegular.pencilLine,
          ),
      ],
      metaRows: _metaRows(activity, countdown),
      actions: [
        for (var index = 0; index < actions.length; index += 1)
          EventActionCardAction(
            key: actions[index].key,
            label: actions[index].label,
            icon: actions[index].icon,
            variant: index == 0
                ? CatchButtonVariant.primary
                : CatchButtonVariant.secondary,
            accentColor: index == 0 ? activity.accent : null,
            isLoading:
                index == 0 &&
                item.primaryAction == EventFocusAction.checkIn &&
                checkInState.isPending,
            onPressed:
                index == 0 &&
                    item.primaryAction == EventFocusAction.checkIn &&
                    checkInState.isPending
                ? null
                : () => onActionPressed(actions[index]),
          ),
      ],
    );
  }

  List<List<CatchMetaEntry>> _metaRows(
    CatchActivity activity,
    String? countdown,
  ) {
    final window = item.windowItem;
    if (window != null) {
      return [
        [
          CatchMetaEntry(
            icon: CatchIcons.clock,
            label: countdown == null ? 'Catch window open' : '$countdown left',
          ),
        ],
        [
          CatchMetaEntry(
            icon: CatchIcons.group,
            label: window.dateAttendeeLabel,
          ),
        ],
        [
          CatchMetaEntry(
            icon: CatchIcons.pinOutlined,
            label: item.event.locationName,
          ),
        ],
      ];
    }

    return [
      [
        CatchMetaEntry(
          icon: CatchIcons.clock,
          label:
              '${EventFormatters.shortWeekday(item.event.startTime)}, '
              '${item.event.startTime.day} '
              '${EventFormatters.shortMonth(item.event.startTime)} · '
              '${item.event.timeRangeLabel}',
        ),
      ],
      [
        CatchMetaEntry(
          icon: CatchIcons.pinOutlined,
          label: item.event.locationName,
        ),
      ],
      [
        CatchMetaEntry(
          icon: activityKindGlyph(item.event.activityKind),
          label: item.event.activitySummaryLabel,
        ),
        CatchMetaEntry(
          icon: CatchIcons.group,
          label: '${item.event.signedUpCount}/${item.event.capacityLimit}',
        ),
      ],
    ];
  }
}

enum EventFocusKind { catchWindow, checkIn, upcoming, afterEvent }

enum EventFocusAction {
  viewEvent,
  checkIn,
  directions,
  addToCalendar,
  swipe,
  review,
}

extension on EventFocusAction {
  String get label {
    return switch (this) {
      EventFocusAction.viewEvent => 'View event',
      EventFocusAction.checkIn => 'Check in',
      EventFocusAction.directions => 'Directions',
      EventFocusAction.addToCalendar => 'Add to calendar',
      EventFocusAction.swipe => 'Start catching',
      EventFocusAction.review => 'Write review',
    };
  }

  IconData get icon {
    return switch (this) {
      EventFocusAction.viewEvent => CatchIcons.forwardArrow,
      EventFocusAction.checkIn => CatchIcons.pin,
      EventFocusAction.directions => PhosphorIconsRegular.compass,
      EventFocusAction.addToCalendar => CatchIcons.calendarAdd,
      EventFocusAction.swipe => PhosphorIconsFill.heart,
      EventFocusAction.review => PhosphorIconsRegular.pencilLine,
    };
  }

  Key get key => EventLifecycleTimeline.actionKey(name);
}

class EventFocusItem {
  const EventFocusItem({
    required this.event,
    required this.kind,
    this.clubName,
    this.windowItem,
    this.needsReview = false,
  });

  final Event event;
  final EventFocusKind kind;
  final String? clubName;
  final CatchWindowItem? windowItem;
  final bool needsReview;

  bool get canSwipe => windowItem != null;

  bool get isUrgent =>
      kind == EventFocusKind.checkIn || canSwipe || needsReview;

  int get priority {
    if (canSwipe) return 0;
    if (kind == EventFocusKind.checkIn) return 1;
    if (kind == EventFocusKind.upcoming) return 2;
    return 3;
  }

  String get badgeLabel {
    return switch (kind) {
      EventFocusKind.catchWindow => 'Catch window open',
      EventFocusKind.checkIn => 'Check-in open',
      EventFocusKind.afterEvent => 'After the event',
      EventFocusKind.upcoming => 'Next event',
    };
  }

  EventFocusAction get primaryAction {
    if (kind == EventFocusKind.checkIn) return EventFocusAction.checkIn;
    if (canSwipe) return EventFocusAction.swipe;
    if (needsReview) return EventFocusAction.review;
    return EventFocusAction.viewEvent;
  }

  List<EventFocusAction> get secondaryActions {
    if (kind == EventFocusKind.checkIn) {
      return const [EventFocusAction.directions];
    }
    if (kind == EventFocusKind.upcoming) {
      return const [
        EventFocusAction.directions,
        EventFocusAction.addToCalendar,
      ];
    }
    if (canSwipe && needsReview) return const [EventFocusAction.review];
    return const [];
  }
}
