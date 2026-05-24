import 'dart:async';

import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/event_success_companion_launcher.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_arrival_action.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_calendar_links.dart';
import 'package:catch_dating_app/events/presentation/event_check_in_celebration_screen.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/event_location_links.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef EventFocusClubNameBuilder = String? Function(Event event);

class EventFocusRail extends ConsumerStatefulWidget {
  const EventFocusRail({
    super.key,
    required this.upcomingEvents,
    required this.reviewer,
    this.arrivalAction,
    this.activeSwipeEvent,
    this.pendingReviewEvent,
    this.clubNameBuilder,
  });

  static const railKey = Key('dashboard-event-focus-rail');
  static const pageIndicatorKey = Key('dashboard-event-focus-page-indicator');

  final List<Event> upcomingEvents;
  final UserProfile reviewer;
  final EventArrivalAction? arrivalAction;
  final Event? activeSwipeEvent;
  final Event? pendingReviewEvent;
  final EventFocusClubNameBuilder? clubNameBuilder;

  @override
  ConsumerState<EventFocusRail> createState() => _EventFocusRailState();
}

class _EventFocusRailState extends ConsumerState<EventFocusRail> {
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

    final checkInMutation = ref.watch(
      EventBookingController.selfCheckInMutation,
    );
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
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: _EventFocusCard(
                      key: ValueKey(
                        'event-focus-${selectedItem.kind.name}-'
                        '${selectedItem.event.id}-'
                        '${selectedItem.canSwipe}-${selectedItem.needsReview}',
                      ),
                      item: selectedItem,
                      cardIndex: _selectedIndex,
                      cardCount: items.length,
                      checkInMutation: checkInMutation,
                      onActionPressed: (action) =>
                          _handleAction(context, ref, selectedItem, action),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (items.length > 1) ...[
          gapH10,
          _EventFocusPageIndicator(
            key: EventFocusRail.pageIndicatorKey,
            selectedIndex: _selectedIndex,
            itemCount: items.length,
          ),
        ],
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

  void _handleAction(
    BuildContext context,
    WidgetRef ref,
    _EventFocusItem item,
    _EventFocusAction action,
  ) {
    switch (action) {
      case _EventFocusAction.viewEvent:
        _openEvent(context, item.event);
      case _EventFocusAction.checkIn:
        _checkIn(context, ref, item.event);
      case _EventFocusAction.swipe:
        _openSwipe(context, item.event);
      case _EventFocusAction.review:
        _writeReview(context, item.event);
      case _EventFocusAction.directions:
        _openDirections(ref, item.event);
      case _EventFocusAction.addToCalendar:
        _addToCalendar(ref, item.event);
    }
  }

  void _openEvent(BuildContext context, Event event) {
    context.pushNamed(
      Routes.dashboardEventDetailScreen.name,
      pathParameters: {'clubId': event.clubId, 'eventId': event.id},
      extra: event,
    );
  }

  void _openDirections(WidgetRef ref, Event event) {
    unawaited(
      ref
          .read(externalLinkControllerProvider)
          .openExternal(directionsUriForEvent(event)),
    );
  }

  void _addToCalendar(WidgetRef ref, Event event) {
    unawaited(ref.read(eventCalendarControllerProvider).addToCalendar(event));
  }

  void _openSwipe(BuildContext context, Event event) {
    context.pushNamed(
      Routes.swipeEventScreen.name,
      pathParameters: {'eventId': event.id},
    );
  }

  void _writeReview(BuildContext context, Event event) {
    showWriteReviewSheet(
      context: context,
      clubId: event.clubId,
      eventId: event.id,
      reviewer: widget.reviewer,
    );
  }

  void _checkIn(BuildContext context, WidgetRef ref, Event event) {
    EventBookingController.selfCheckInMutation.run(ref, (tx) async {
      await tx
          .get(eventBookingControllerProvider.notifier)
          .selfCheckIn(eventId: event.id);
      if (!context.mounted) return;
      final launchResult = await launchEventSuccessCompanionIfAvailable(
        context: context,
        ref: ref,
        uid: widget.reviewer.uid,
        event: event,
      );
      if (!context.mounted ||
          launchResult != EventSuccessCompanionLaunchResult.unavailable) {
        return;
      }
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (routeContext) => EventCheckInCelebrationScreen(
            event: event,
            onViewEvent: () {
              Navigator.of(routeContext).pop();
              GoRouter.of(context).goNamed(
                Routes.eventDetailScreen.name,
                pathParameters: {'clubId': event.clubId, 'eventId': event.id},
                extra: event,
              );
            },
            onBackHome: () {
              Navigator.of(routeContext).pop();
              GoRouter.of(context).goNamed(Routes.dashboardScreen.name);
            },
          ),
        ),
      );
    });
  }
}

class _EventFocusPageIndicator extends StatelessWidget {
  const _EventFocusPageIndicator({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
  });

  final int selectedIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Center(
      child: Semantics(
        label: 'Event ${selectedIndex + 1} of $itemCount',
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: CatchSpacing.s1,
          runSpacing: CatchSpacing.s1,
          children: [
            for (var index = 0; index < itemCount; index += 1)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: index == selectedIndex ? 22 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index == selectedIndex
                      ? t.primary
                      : t.line2.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EventFocusCard extends StatelessWidget {
  const _EventFocusCard({
    super.key,
    required this.item,
    required this.cardIndex,
    required this.cardCount,
    required this.checkInMutation,
    required this.onActionPressed,
  });

  final _EventFocusItem item;
  final int cardIndex;
  final int cardCount;
  final MutationState checkInMutation;
  final ValueChanged<_EventFocusAction> onActionPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: EdgeInsets.zero,
      backgroundColor: t.surface,
      borderColor: item.isUrgent ? t.primary.withValues(alpha: 0.24) : t.line2,
      radius: 22,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item.isUrgent
                        ? t.primarySoft.withValues(alpha: 0.82)
                        : t.primarySoft.withValues(alpha: 0.42),
                    t.surface,
                    t.raised.withValues(alpha: 0.74),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Sizes.p18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: CatchSpacing.s2,
                        runSpacing: CatchSpacing.s1,
                        children: [
                          CatchBadge(
                            label: item.badgeLabel,
                            tone: item.isUrgent
                                ? CatchBadgeTone.live
                                : CatchBadgeTone.brand,
                            uppercase: true,
                          ),
                          if (item.needsReview)
                            const CatchBadge(
                              label: 'Review pending',
                              tone: CatchBadgeTone.warning,
                              icon: Icons.rate_review_outlined,
                            ),
                          if (item.canSwipe)
                            CatchBadge(
                              label: 'Swipe · ${_swipeCountdown(item.event)}',
                              tone: CatchBadgeTone.brand,
                              icon: Icons.favorite_rounded,
                            ),
                        ],
                      ),
                    ),
                    if (cardCount > 1) ...[
                      gapW8,
                      CatchBadge(
                        label: '${cardIndex + 1}/$cardCount',
                        tone: CatchBadgeTone.neutral,
                      ),
                    ],
                  ],
                ),
                gapH14,
                Text(
                  item.event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.displayM(context),
                ),
                if (item.clubName != null) ...[
                  gapH6,
                  Text(
                    item.clubName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.labelM(context, color: t.ink2),
                  ),
                ],
                gapH12,
                _EventFocusMetaLine(
                  icon: Icons.access_time_rounded,
                  label:
                      '${EventFormatters.shortWeekday(item.event.startTime)}, '
                      '${item.event.startTime.day} '
                      '${EventFormatters.shortMonth(item.event.startTime)} · '
                      '${item.event.timeRangeLabel}',
                ),
                gapH6,
                _EventFocusMetaLine(
                  icon: Icons.location_on_outlined,
                  label: item.event.locationName,
                ),
                gapH6,
                _EventFocusMetaLine(
                  icon: Icons.route_outlined,
                  label:
                      '${item.event.activitySummaryLabel} · '
                      '${item.event.signedUpCount}/${item.event.capacityLimit} spots',
                ),
                gapH16,
                _EventFocusActions(
                  item: item,
                  isPrimaryLoading:
                      item.primaryAction == _EventFocusAction.checkIn &&
                      checkInMutation.isPending,
                  onActionPressed: onActionPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventFocusActions extends StatelessWidget {
  const _EventFocusActions({
    required this.item,
    required this.isPrimaryLoading,
    required this.onActionPressed,
  });

  final _EventFocusItem item;
  final bool isPrimaryLoading;
  final ValueChanged<_EventFocusAction> onActionPressed;

  @override
  Widget build(BuildContext context) {
    final actions = [item.primaryAction, ...item.secondaryActions];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < actions.length; index += 1) ...[
          if (index > 0) gapH10,
          CatchButton(
            label: actions[index].label,
            icon: Icon(actions[index].icon, size: 18),
            variant: index == 0
                ? CatchButtonVariant.primary
                : CatchButtonVariant.secondary,
            fullWidth: true,
            isLoading: index == 0 && isPrimaryLoading,
            onPressed: index == 0 && isPrimaryLoading
                ? null
                : () => onActionPressed(actions[index]),
          ),
        ],
      ],
    );
  }
}

class _EventFocusMetaLine extends StatelessWidget {
  const _EventFocusMetaLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        Icon(icon, size: 16, color: t.ink3),
        gapW6,
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ),
      ],
    );
  }
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
      _EventFocusAction.viewEvent => Icons.chevron_right_rounded,
      _EventFocusAction.checkIn => Icons.location_on_rounded,
      _EventFocusAction.directions => Icons.directions_outlined,
      _EventFocusAction.addToCalendar => Icons.calendar_month_outlined,
      _EventFocusAction.swipe => Icons.favorite_rounded,
      _EventFocusAction.review => Icons.rate_review_outlined,
    };
  }
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
