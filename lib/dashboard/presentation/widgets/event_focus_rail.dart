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
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_arrival_action.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
        ? context.l10n.dashboardEventFocusRailVisiblecopy1Event
        : context.l10n.dashboardEventFocusRailVisiblecopyLengthEvents(
            length: items.length,
          );
    final selectedItem = items[_selectedIndex];

    return Column(
      key: EventFocusRail.railKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.dashboardEventFocusRailTextEventFocus,
              style: CatchTextStyles.titleL(context),
            ),
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
                label:
                    context.l10n.dashboardEventFocusRailLabelEventFocusCarousel,
                value: context.l10n
                    .dashboardEventFocusRailVisiblecopyEventValue1OfLength(
                      value1: _selectedIndex + 1,
                      length: items.length,
                    ),
                increasedValue: canAdvance
                    ? context.l10n
                          .dashboardEventFocusRailVisiblecopyEventValue1OfLength(
                            value1: _selectedIndex + 2,
                            length: items.length,
                          )
                    : null,
                decreasedValue: canRetreat
                    ? context.l10n
                          .dashboardEventFocusRailVisiblecopyEventSelectedindexOfLength(
                            selectedIndex: _selectedIndex,
                            length: items.length,
                          )
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
                    child: EventFocusCard(
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
          Center(
            key: EventFocusRail.pageIndicatorKey,
            child: CatchPageDots(
              selectedIndex: _selectedIndex,
              itemCount: items.length,
              semanticLabel: context.l10n
                  .dashboardEventFocusRailSemanticlabelEventValue1OfLength(
                    value1: _selectedIndex + 1,
                    length: items.length,
                  ),
            ),
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

  List<EventFocusItem> _buildItems() {
    final items = <EventFocusItem>[];
    final checkInEventId =
        widget.arrivalAction?.kind == EventArrivalActionKind.selfCheckIn
        ? widget.arrivalAction?.event.id
        : null;

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

    final afterEventIds = <String>{};
    if (widget.activeSwipeEvent != null) {
      afterEventIds.add(widget.activeSwipeEvent!.id);
      items.add(
        EventFocusItem(
          event: widget.activeSwipeEvent!,
          kind: EventFocusKind.afterEvent,
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
    if (a.kind == EventFocusKind.afterEvent &&
        b.kind == EventFocusKind.afterEvent) {
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
    required this.cardIndex,
    required this.cardCount,
    required this.checkInState,
    required this.onActionPressed,
  });

  final EventFocusItem item;
  final int cardIndex;
  final int cardCount;
  final EventFocusCheckInState checkInState;
  final ValueChanged<EventFocusAction> onActionPressed;

  @override
  Widget build(BuildContext context) {
    final actions = [item.primaryAction, ...item.secondaryActions];
    final activity = ActivityPalette.resolve(context, item.event.activityKind);

    return EventActionCard(
      event: item.event,
      topAccentColors: [activity.accent, activity.deep],
      subtitle: item.clubName,
      urgent: item.isUrgent,
      indexLabel: cardCount > 1
          ? context.l10n.dashboardEventFocusRailVisiblecopyValue1Cardcount(
              value1: cardIndex + 1,
              cardCount: cardCount,
            )
          : null,
      badges: [
        EventActionCardBadge(
          label: item.badgeLabel(context.l10n),
          tone: item.isUrgent ? CatchBadgeTone.brand : CatchBadgeTone.neutral,
        ),
        if (item.canSwipe)
          EventActionCardBadge(
            label: context.l10n.dashboardEventFocusRailLabelCatchSwipecountdown(
              swipeCountdown: _swipeCountdown(item.event),
            ),
            tone: CatchBadgeTone.brand,
            icon: PhosphorIconsFill.heart,
          ),
        if (item.needsReview)
          EventActionCardBadge(
            label: context.l10n.dashboardEventFocusRailLabelReviewPending,
            tone: CatchBadgeTone.warning,
            icon: PhosphorIconsRegular.pencilLine,
          ),
      ],
      metaRows: [
        [
          CatchMetaEntry(
            icon: CatchIcons.clock,
            label: context.l10n
                .dashboardEventFocusRailLabelShortweekdayDayShortmonthTimerangelabel(
                  shortWeekday: EventFormatters.shortWeekday(
                    item.event.startTime,
                  ),
                  day: item.event.startTime.day,
                  shortMonth: EventFormatters.shortMonth(item.event.startTime),
                  timeRangeLabel: item.event.timeRangeLabel,
                ),
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
            label: context.l10n
                .dashboardEventFocusRailLabelSignedupcountCapacitylimit(
                  signedUpCount: item.event.signedUpCount,
                  capacityLimit: item.event.capacityLimit,
                ),
          ),
        ],
      ],
      actions: [
        for (var index = 0; index < actions.length; index += 1)
          EventActionCardAction(
            key: actions[index].key,
            label: actions[index].label(context.l10n),
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
}

enum EventFocusKind { upcoming, checkIn, afterEvent }

enum EventFocusAction {
  viewEvent,
  checkIn,
  directions,
  addToCalendar,
  swipe,
  review,
}

extension on EventFocusAction {
  String label(AppLocalizations l10n) {
    return switch (this) {
      EventFocusAction.viewEvent => l10n.dashboardEventFocusRailLabelViewEvent,
      EventFocusAction.checkIn => l10n.dashboardEventFocusRailLabelCheckIn,
      EventFocusAction.directions =>
        l10n.dashboardEventFocusRailLabelDirections,
      EventFocusAction.addToCalendar =>
        l10n.dashboardEventFocusRailLabelAddToCalendar,
      EventFocusAction.swipe => l10n.dashboardEventFocusRailLabelStartCatching,
      EventFocusAction.review => l10n.dashboardEventFocusRailLabelWriteReview,
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

  Key get key => EventFocusRail.actionKey(name);
}

class EventFocusItem {
  const EventFocusItem({
    required this.event,
    required this.kind,
    this.clubName,
    this.canSwipe = false,
    this.needsReview = false,
  });

  final Event event;
  final EventFocusKind kind;
  final String? clubName;
  final bool canSwipe;
  final bool needsReview;

  bool get isUrgent =>
      kind == EventFocusKind.checkIn || canSwipe || needsReview;

  int get priority {
    if (canSwipe) return 0;
    if (kind == EventFocusKind.checkIn) return 1;
    if (needsReview) return 2;
    return 3;
  }

  String badgeLabel(AppLocalizations l10n) {
    return switch (kind) {
      EventFocusKind.checkIn =>
        l10n.dashboardEventFocusRailBadgelabelCheckInOpen,
      EventFocusKind.afterEvent =>
        l10n.dashboardEventFocusRailBadgelabelAfterTheEvent,
      EventFocusKind.upcoming =>
        l10n.dashboardEventFocusRailBadgelabelNextEvent,
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

String _swipeCountdown(Event event) {
  final remaining = swipeWindowClosesAt(event).difference(DateTime.now());
  if (remaining.isNegative) return '0h 00m';
  final h = remaining.inHours;
  final m = remaining.inMinutes.remainder(60);
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}
