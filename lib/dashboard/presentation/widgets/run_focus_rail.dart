import 'dart:async';

import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_sheet.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_arrival_action.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:catch_dating_app/runs/presentation/run_calendar_links.dart';
import 'package:catch_dating_app/runs/presentation/run_check_in_celebration_screen.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/runs/presentation/run_location_links.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

typedef RunFocusClubNameBuilder = String? Function(Run run);

class RunFocusRail extends ConsumerStatefulWidget {
  const RunFocusRail({
    super.key,
    required this.upcomingRuns,
    required this.reviewer,
    this.arrivalAction,
    this.activeSwipeRun,
    this.pendingReviewRun,
    this.clubNameBuilder,
  });

  static const railKey = Key('dashboard-run-focus-rail');
  static const pageIndicatorKey = Key('dashboard-run-focus-page-indicator');

  final List<Run> upcomingRuns;
  final UserProfile reviewer;
  final RunArrivalAction? arrivalAction;
  final Run? activeSwipeRun;
  final Run? pendingReviewRun;
  final RunFocusClubNameBuilder? clubNameBuilder;

  @override
  ConsumerState<RunFocusRail> createState() => _RunFocusRailState();
}

class _RunFocusRailState extends ConsumerState<RunFocusRail> {
  static const _minimumSwipeDistance = 56.0;
  static const _minimumSwipeVelocity = 360.0;

  int _selectedIndex = 0;
  double _dragDistance = 0;

  @override
  void didUpdateWidget(covariant RunFocusRail oldWidget) {
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

    final checkInMutation = ref.watch(RunBookingController.selfCheckInMutation);
    final cardCountLabel = items.length == 1 ? '1 run' : '${items.length} runs';
    final selectedItem = items[_selectedIndex];

    return Column(
      key: RunFocusRail.railKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Run Focus', style: CatchTextStyles.titleL(context)),
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

            return SizedBox(
              width: cardWidth,
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
                  child: _RunFocusCard(
                    key: ValueKey(
                      'run-focus-${selectedItem.kind.name}-'
                      '${selectedItem.run.id}-'
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
            );
          },
        ),
        if (items.length > 1) ...[
          gapH10,
          _RunFocusPageIndicator(
            key: RunFocusRail.pageIndicatorKey,
            selectedIndex: _selectedIndex,
            itemCount: items.length,
          ),
        ],
      ],
    );
  }

  List<_RunFocusItem> _buildItems() {
    final items = <_RunFocusItem>[];
    final checkInRunId =
        widget.arrivalAction?.kind == RunArrivalActionKind.selfCheckIn
        ? widget.arrivalAction?.run.id
        : null;

    for (final run in widget.upcomingRuns) {
      items.add(
        _RunFocusItem(
          run: run,
          kind: run.id == checkInRunId
              ? _RunFocusKind.checkIn
              : _RunFocusKind.upcoming,
          clubName: widget.clubNameBuilder?.call(run),
        ),
      );
    }

    final afterRunIds = <String>{};
    if (widget.activeSwipeRun != null) {
      afterRunIds.add(widget.activeSwipeRun!.id);
      items.add(
        _RunFocusItem(
          run: widget.activeSwipeRun!,
          kind: _RunFocusKind.afterRun,
          canSwipe: true,
          needsReview: widget.pendingReviewRun?.id == widget.activeSwipeRun!.id,
          clubName: widget.clubNameBuilder?.call(widget.activeSwipeRun!),
        ),
      );
    }
    if (widget.pendingReviewRun != null &&
        !afterRunIds.contains(widget.pendingReviewRun!.id)) {
      items.add(
        _RunFocusItem(
          run: widget.pendingReviewRun!,
          kind: _RunFocusKind.afterRun,
          needsReview: true,
          clubName: widget.clubNameBuilder?.call(widget.pendingReviewRun!),
        ),
      );
    }

    items.sort(_compareFocusItems);
    return items;
  }

  int _compareFocusItems(_RunFocusItem a, _RunFocusItem b) {
    final priority = a.priority.compareTo(b.priority);
    if (priority != 0) return priority;
    if (a.kind == _RunFocusKind.afterRun && b.kind == _RunFocusKind.afterRun) {
      return b.run.endTime.compareTo(a.run.endTime);
    }
    return a.run.startTime.compareTo(b.run.startTime);
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
    _RunFocusItem item,
    _RunFocusAction action,
  ) {
    switch (action) {
      case _RunFocusAction.viewRun:
        _openRun(context, item.run);
      case _RunFocusAction.checkIn:
        _checkIn(context, ref, item.run);
      case _RunFocusAction.swipe:
        _openSwipe(context, item.run);
      case _RunFocusAction.review:
        _writeReview(context, item.run);
      case _RunFocusAction.directions:
        _openDirections(ref, item.run);
      case _RunFocusAction.addToCalendar:
        _addToCalendar(ref, item.run);
    }
  }

  void _openRun(BuildContext context, Run run) {
    context.pushNamed(
      Routes.dashboardRunDetailScreen.name,
      pathParameters: {'runClubId': run.runClubId, 'runId': run.id},
    );
  }

  void _openDirections(WidgetRef ref, Run run) {
    unawaited(
      ref
          .read(externalLinkControllerProvider)
          .openExternal(directionsUriForRun(run)),
    );
  }

  void _addToCalendar(WidgetRef ref, Run run) {
    unawaited(ref.read(runCalendarControllerProvider).addToCalendar(run));
  }

  void _openSwipe(BuildContext context, Run run) {
    context.pushNamed(
      Routes.swipeRunScreen.name,
      pathParameters: {'runId': run.id},
    );
  }

  void _writeReview(BuildContext context, Run run) {
    showWriteReviewSheet(
      context: context,
      runClubId: run.runClubId,
      runId: run.id,
      reviewer: widget.reviewer,
    );
  }

  void _checkIn(BuildContext context, WidgetRef ref, Run run) {
    RunBookingController.selfCheckInMutation.run(ref, (tx) async {
      await tx
          .get(runBookingControllerProvider.notifier)
          .selfCheckIn(runId: run.id);
      if (!context.mounted) return;
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (routeContext) => RunCheckInCelebrationScreen(
            run: run,
            onViewRun: () {
              Navigator.of(routeContext).pop();
              GoRouter.of(context).goNamed(
                Routes.runDetailScreen.name,
                pathParameters: {'runClubId': run.runClubId, 'runId': run.id},
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

class _RunFocusPageIndicator extends StatelessWidget {
  const _RunFocusPageIndicator({
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
        label: 'Run ${selectedIndex + 1} of $itemCount',
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

class _RunFocusCard extends StatelessWidget {
  const _RunFocusCard({
    super.key,
    required this.item,
    required this.cardIndex,
    required this.cardCount,
    required this.checkInMutation,
    required this.onActionPressed,
  });

  final _RunFocusItem item;
  final int cardIndex;
  final int cardCount;
  final MutationState checkInMutation;
  final ValueChanged<_RunFocusAction> onActionPressed;

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
                              label: 'Swipe · ${_swipeCountdown(item.run)}',
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
                  item.run.title,
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
                _RunFocusMetaLine(
                  icon: Icons.access_time_rounded,
                  label:
                      '${RunFormatters.shortWeekday(item.run.startTime)}, '
                      '${item.run.startTime.day} '
                      '${RunFormatters.shortMonth(item.run.startTime)} · '
                      '${item.run.timeRangeLabel}',
                ),
                gapH6,
                _RunFocusMetaLine(
                  icon: Icons.location_on_outlined,
                  label: item.run.meetingPoint,
                ),
                gapH6,
                _RunFocusMetaLine(
                  icon: Icons.route_outlined,
                  label:
                      '${item.run.distanceLabel} · ${item.run.pace.label} · '
                      '${item.run.signedUpCount}/${item.run.capacityLimit} spots',
                ),
                gapH16,
                _RunFocusActions(
                  item: item,
                  isPrimaryLoading:
                      item.primaryAction == _RunFocusAction.checkIn &&
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

class _RunFocusActions extends StatelessWidget {
  const _RunFocusActions({
    required this.item,
    required this.isPrimaryLoading,
    required this.onActionPressed,
  });

  final _RunFocusItem item;
  final bool isPrimaryLoading;
  final ValueChanged<_RunFocusAction> onActionPressed;

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

class _RunFocusMetaLine extends StatelessWidget {
  const _RunFocusMetaLine({required this.icon, required this.label});

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

enum _RunFocusKind { upcoming, checkIn, afterRun }

enum _RunFocusAction {
  viewRun,
  checkIn,
  directions,
  addToCalendar,
  swipe,
  review,
}

extension on _RunFocusAction {
  String get label {
    return switch (this) {
      _RunFocusAction.viewRun => 'View run',
      _RunFocusAction.checkIn => 'Check in',
      _RunFocusAction.directions => 'Directions',
      _RunFocusAction.addToCalendar => 'Add to calendar',
      _RunFocusAction.swipe => 'Start catching',
      _RunFocusAction.review => 'Write review',
    };
  }

  IconData get icon {
    return switch (this) {
      _RunFocusAction.viewRun => Icons.chevron_right_rounded,
      _RunFocusAction.checkIn => Icons.location_on_rounded,
      _RunFocusAction.directions => Icons.directions_outlined,
      _RunFocusAction.addToCalendar => Icons.calendar_month_outlined,
      _RunFocusAction.swipe => Icons.favorite_rounded,
      _RunFocusAction.review => Icons.rate_review_outlined,
    };
  }
}

class _RunFocusItem {
  const _RunFocusItem({
    required this.run,
    required this.kind,
    this.clubName,
    this.canSwipe = false,
    this.needsReview = false,
  });

  final Run run;
  final _RunFocusKind kind;
  final String? clubName;
  final bool canSwipe;
  final bool needsReview;

  bool get isUrgent => kind == _RunFocusKind.checkIn || canSwipe || needsReview;

  int get priority {
    if (kind == _RunFocusKind.checkIn) return 0;
    if (canSwipe) return 1;
    if (needsReview) return 2;
    return 3;
  }

  String get badgeLabel {
    return switch (kind) {
      _RunFocusKind.checkIn => 'Check-in open',
      _RunFocusKind.afterRun => 'After the run',
      _RunFocusKind.upcoming => 'Next run',
    };
  }

  _RunFocusAction get primaryAction {
    if (kind == _RunFocusKind.checkIn) return _RunFocusAction.checkIn;
    if (canSwipe) return _RunFocusAction.swipe;
    if (needsReview) return _RunFocusAction.review;
    return _RunFocusAction.viewRun;
  }

  List<_RunFocusAction> get secondaryActions {
    if (kind == _RunFocusKind.checkIn) {
      return const [_RunFocusAction.directions];
    }
    if (kind == _RunFocusKind.upcoming) {
      return const [_RunFocusAction.directions, _RunFocusAction.addToCalendar];
    }
    if (canSwipe && needsReview) return const [_RunFocusAction.review];
    return const [];
  }
}

String _swipeCountdown(Run run) {
  final remaining = swipeWindowClosesAt(run).difference(DateTime.now());
  if (remaining.isNegative) return '0h 00m';
  final h = remaining.inHours;
  final m = remaining.inMinutes.remainder(60);
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}
