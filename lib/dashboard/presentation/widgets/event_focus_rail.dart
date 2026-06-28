import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_page_dots.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

typedef EventFocusClubNameBuilder = String? Function(Event event);
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

class EventFocusRail extends StatefulWidget {
  const EventFocusRail({
    super.key,
    required this.upcomingEvents,
    required this.actions,
    this.checkInState = EventFocusCheckInState.idle,
    this.arrivalAction,
    this.activeSwipeEvent,
    this.pendingReviewEvent,
    this.clubNameBuilder,
  });

  static const railKey = Key('dashboard-event-focus-rail');
  static const pageIndicatorKey = Key('dashboard-event-focus-page-indicator');
  static Key actionKey(String actionName) =>
      ValueKey('dashboard-event-focus-action-$actionName');

  final List<Event> upcomingEvents;
  final EventFocusActions actions;
  final EventFocusCheckInState checkInState;
  final EventArrivalAction? arrivalAction;
  final Event? activeSwipeEvent;
  final Event? pendingReviewEvent;
  final EventFocusClubNameBuilder? clubNameBuilder;

  @override
  State<EventFocusRail> createState() => _EventFocusRailState();
}

class _EventFocusRailState extends State<EventFocusRail> {
  static const _minimumSwipeDistance = 56.0;
  static const _minimumSwipeVelocity = 360.0;

  int _selectedIndex = 0;
  double _dragDistance = 0;

  @override
  void didUpdateWidget(covariant EventFocusRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    final itemCount = _buildItems().length;
    if (_selectedIndex >= itemCount) {
      _selectedIndex = itemCount == 0 ? 0 : itemCount - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    if (items.isEmpty) return const SizedBox.shrink();
    if (_selectedIndex >= items.length) _selectedIndex = items.length - 1;

    final cardCountLabel = items.length == 1
        ? '1 event'
        : '${items.length} events';
    final selectedItem = items[_selectedIndex];

    return Column(
      key: EventFocusRail.railKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Event Focus', style: CatchTextStyles.titleL(context)),
            gapW8,
            CatchBadge(label: cardCountLabel, tone: CatchBadgeTone.brand),
          ],
        ),
        gapH10,
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.hasBoundedWidth
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final canAdvance = _selectedIndex < items.length - 1;
            final canRetreat = _selectedIndex > 0;

            return SizedBox(
              width: cardWidth,
              child: Semantics(
                label: 'Event focus carousel',
                value: 'Event ${_selectedIndex + 1} of ${items.length}',
                increasedValue: canAdvance
                    ? 'Event ${_selectedIndex + 2} of ${items.length}'
                    : null,
                decreasedValue: canRetreat
                    ? 'Event $_selectedIndex of ${items.length}'
                    : null,
                onIncrease: items.length > 1 && canAdvance
                    ? () => setState(() => _selectedIndex += 1)
                    : null,
                onDecrease: items.length > 1 && canRetreat
                    ? () => setState(() => _selectedIndex -= 1)
                    : null,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragStart: items.length > 1
                      ? (_) => _dragDistance = 0
                      : null,
                  onHorizontalDragUpdate: items.length > 1
                      ? (details) => _dragDistance += details.primaryDelta ?? 0
                      : null,
                  onHorizontalDragEnd: items.length > 1
                      ? (details) => _handleHorizontalDragEnd(
                          details: details,
                          itemCount: items.length,
                        )
                      : null,
                  onHorizontalDragCancel: items.length > 1
                      ? () => _dragDistance = 0
                      : null,
                  child: AnimatedSwitcher(
                    duration: CatchMotion.base,
                    switchInCurve: CatchMotion.easeOutCubicCurve,
                    switchOutCurve: CatchMotion.easeInCubicCurve,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _buildEventFocusCard(
                      context,
                      key: ValueKey(
                        'event-focus-${selectedItem.kind.name}-'
                        '${selectedItem.event.id}-'
                        '${selectedItem.canSwipe}-${selectedItem.needsReview}',
                      ),
                      item: selectedItem,
                      cardIndex: _selectedIndex,
                      cardCount: items.length,
                      checkInState: widget.checkInState,
                      onActionPressed: (action) =>
                          _handleAction(selectedItem, action),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (items.length > 1) ...[
          gapH10,
          _buildEventFocusPageIndicator(
            key: EventFocusRail.pageIndicatorKey,
            selectedIndex: _selectedIndex,
            itemCount: items.length,
          ),
        ],
        if (widget.checkInState.error != null)
          CatchErrorBanner.fromError(
            widget.checkInState.error!,
            context: AppErrorContext.dashboard,
            onRetry: widget.actions.onResetCheckInError,
          ),
      ],
    );
  }

  List<_EventFocusItem> _buildItems() {
    final items = <_EventFocusItem>[];
    final checkInEventId =
        widget.arrivalAction?.kind == EventArrivalActionKind.selfCheckIn
        ? widget.arrivalAction?.event.id
        : null;

    for (final event in widget.upcomingEvents) {
      items.add(
        _EventFocusItem(
          event: event,
          kind: event.id == checkInEventId
              ? _EventFocusKind.checkIn
              : _EventFocusKind.upcoming,
          clubName: widget.clubNameBuilder?.call(event),
        ),
      );
    }

    final afterEventIds = <String>{};
    if (widget.activeSwipeEvent != null) {
      afterEventIds.add(widget.activeSwipeEvent!.id);
      items.add(
        _EventFocusItem(
          event: widget.activeSwipeEvent!,
          kind: _EventFocusKind.afterEvent,
          canSwipe: true,
          needsReview:
              widget.pendingReviewEvent?.id == widget.activeSwipeEvent!.id,
          clubName: widget.clubNameBuilder?.call(widget.activeSwipeEvent!),
        ),
      );
    }
    if (widget.pendingReviewEvent != null &&
        !afterEventIds.contains(widget.pendingReviewEvent!.id)) {
      items.add(
        _EventFocusItem(
          event: widget.pendingReviewEvent!,
          kind: _EventFocusKind.afterEvent,
          needsReview: true,
          clubName: widget.clubNameBuilder?.call(widget.pendingReviewEvent!),
        ),
      );
    }

    items.sort(_compareFocusItems);
    return items;
  }

  int _compareFocusItems(_EventFocusItem a, _EventFocusItem b) {
    final priority = a.priority.compareTo(b.priority);
    if (priority != 0) return priority;
    if (a.kind == _EventFocusKind.afterEvent &&
        b.kind == _EventFocusKind.afterEvent) {
      return b.event.endTime.compareTo(a.event.endTime);
    }
    return a.event.startTime.compareTo(b.event.startTime);
  }

  void _handleHorizontalDragEnd({
    required DragEndDetails details,
    required int itemCount,
  }) {
    final velocity = details.primaryVelocity ?? 0;
    final shouldAdvance =
        velocity < -_minimumSwipeVelocity ||
        _dragDistance < -_minimumSwipeDistance;
    final shouldRetreat =
        velocity > _minimumSwipeVelocity ||
        _dragDistance > _minimumSwipeDistance;
    int boundIndex(int value) => value.clamp(0, itemCount - 1).toInt();
    final nextIndex = switch ((shouldAdvance, shouldRetreat)) {
      (true, _) => boundIndex(_selectedIndex + 1),
      (_, true) => boundIndex(_selectedIndex - 1),
      _ => _selectedIndex,
    };

    _dragDistance = 0;
    if (nextIndex == _selectedIndex) return;
    setState(() => _selectedIndex = nextIndex);
  }

  void _handleAction(_EventFocusItem item, _EventFocusAction action) {
    switch (action) {
      case _EventFocusAction.viewEvent:
        widget.actions.onViewEvent(item.event);
      case _EventFocusAction.checkIn:
        widget.actions.onCheckIn(item.event);
      case _EventFocusAction.swipe:
        widget.actions.onOpenSwipe(item.event);
      case _EventFocusAction.review:
        widget.actions.onWriteReview(item.event);
      case _EventFocusAction.directions:
        widget.actions.onOpenDirections(item.event);
      case _EventFocusAction.addToCalendar:
        widget.actions.onAddToCalendar(item.event);
    }
  }
}

Widget _buildEventFocusPageIndicator({
  Key? key,
  required int selectedIndex,
  required int itemCount,
}) {
  return Center(
    key: key,
    child: CatchPageDots(
      selectedIndex: selectedIndex,
      itemCount: itemCount,
      semanticLabel: 'Event ${selectedIndex + 1} of $itemCount',
    ),
  );
}

Widget _buildEventFocusCard(
  BuildContext context, {
  Key? key,
  required _EventFocusItem item,
  required int cardIndex,
  required int cardCount,
  required EventFocusCheckInState checkInState,
  required ValueChanged<_EventFocusAction> onActionPressed,
}) {
  final actions = [item.primaryAction, ...item.secondaryActions];
  final activity = ActivityPalette.resolve(context, item.event.activityKind);

  return EventActionCard(
    key: key,
    event: item.event,
    topAccentColors: [activity.accent, activity.deep],
    subtitle: item.clubName,
    urgent: item.isUrgent,
    indexLabel: cardCount > 1 ? '${cardIndex + 1}/$cardCount' : null,
    badges: [
      EventActionCardBadge(
        label: item.badgeLabel,
        tone: item.isUrgent ? CatchBadgeTone.brand : CatchBadgeTone.neutral,
      ),
      if (item.canSwipe)
        EventActionCardBadge(
          label: 'Catch · ${_swipeCountdown(item.event)}',
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
    metaRows: [
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
    ],
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
              item.primaryAction == _EventFocusAction.checkIn &&
              checkInState.isPending,
          onPressed:
              index == 0 &&
                  item.primaryAction == _EventFocusAction.checkIn &&
                  checkInState.isPending
              ? null
              : () => onActionPressed(actions[index]),
        ),
    ],
  );
}

enum _EventFocusKind { upcoming, checkIn, afterEvent }

enum _EventFocusAction {
  viewEvent,
  checkIn,
  directions,
  addToCalendar,
  swipe,
  review,
}

extension on _EventFocusAction {
  String get label {
    return switch (this) {
      _EventFocusAction.viewEvent => 'View event',
      _EventFocusAction.checkIn => 'Check in',
      _EventFocusAction.directions => 'Directions',
      _EventFocusAction.addToCalendar => 'Add to calendar',
      _EventFocusAction.swipe => 'Start catching',
      _EventFocusAction.review => 'Write review',
    };
  }

  IconData get icon {
    return switch (this) {
      _EventFocusAction.viewEvent => CatchIcons.forwardArrow,
      _EventFocusAction.checkIn => CatchIcons.pin,
      _EventFocusAction.directions => PhosphorIconsRegular.compass,
      _EventFocusAction.addToCalendar => CatchIcons.calendarAdd,
      _EventFocusAction.swipe => PhosphorIconsFill.heart,
      _EventFocusAction.review => PhosphorIconsRegular.pencilLine,
    };
  }

  Key get key => EventFocusRail.actionKey(name);
}

class _EventFocusItem {
  const _EventFocusItem({
    required this.event,
    required this.kind,
    this.clubName,
    this.canSwipe = false,
    this.needsReview = false,
  });

  final Event event;
  final _EventFocusKind kind;
  final String? clubName;
  final bool canSwipe;
  final bool needsReview;

  bool get isUrgent =>
      kind == _EventFocusKind.checkIn || canSwipe || needsReview;

  int get priority {
    if (kind == _EventFocusKind.checkIn) return 0;
    if (canSwipe) return 1;
    if (needsReview) return 2;
    return 3;
  }

  String get badgeLabel {
    return switch (kind) {
      _EventFocusKind.checkIn => 'Check-in open',
      _EventFocusKind.afterEvent => 'After the event',
      _EventFocusKind.upcoming => 'Next event',
    };
  }

  _EventFocusAction get primaryAction {
    if (kind == _EventFocusKind.checkIn) return _EventFocusAction.checkIn;
    if (canSwipe) return _EventFocusAction.swipe;
    if (needsReview) return _EventFocusAction.review;
    return _EventFocusAction.viewEvent;
  }

  List<_EventFocusAction> get secondaryActions {
    if (kind == _EventFocusKind.checkIn) {
      return const [_EventFocusAction.directions];
    }
    if (kind == _EventFocusKind.upcoming) {
      return const [
        _EventFocusAction.directions,
        _EventFocusAction.addToCalendar,
      ];
    }
    if (canSwipe && needsReview) return const [_EventFocusAction.review];
    return const [];
  }
}

String _swipeCountdown(Event event) {
  final remaining = swipeWindowClosesAt(event).difference(DateTime.now());
  if (remaining.isNegative) return '0h 00m';
  final h = remaining.inHours;
  final m = remaining.inMinutes.remainder(60);
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}
