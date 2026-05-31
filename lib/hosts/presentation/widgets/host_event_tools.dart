import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/hosts/domain/host_attendance_window.dart';
import 'package:flutter/material.dart';

class HostEventToolItem {
  const HostEventToolItem({required this.event, required this.attendanceState});

  final Event event;
  final HostEventAttendanceState attendanceState;

  bool get canTakeAttendance =>
      attendanceState == HostEventAttendanceState.open;
}

class HostEventToolsCarousel extends StatefulWidget {
  const HostEventToolsCarousel({
    super.key,
    required this.tools,
    required this.onManageEvent,
    required this.onTakeAttendance,
    required this.onViewReport,
  });

  static const railKey = Key('host-event-tools-carousel');
  static const pageIndicatorKey = Key('host-event-tools-page-indicator');

  final List<HostEventToolItem> tools;
  final ValueChanged<Event> onManageEvent;
  final ValueChanged<Event> onTakeAttendance;
  final ValueChanged<Event> onViewReport;

  @override
  State<HostEventToolsCarousel> createState() => _HostEventToolsCarouselState();
}

class _HostEventToolsCarouselState extends State<HostEventToolsCarousel> {
  static const _minimumSwipeDistance = 56.0;
  static const _minimumSwipeVelocity = 360.0;

  int _selectedIndex = 0;
  double _dragDistance = 0;

  @override
  void didUpdateWidget(covariant HostEventToolsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedIndex >= widget.tools.length) {
      _selectedIndex = widget.tools.isEmpty ? 0 : widget.tools.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tools.isEmpty) return const SizedBox.shrink();
    if (_selectedIndex >= widget.tools.length) {
      _selectedIndex = widget.tools.length - 1;
    }

    final selectedTool = widget.tools[_selectedIndex];
    return SizedBox(
      key: HostEventToolsCarousel.railKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final canAdvance = _selectedIndex < widget.tools.length - 1;
          final canRetreat = _selectedIndex > 0;

          return SizedBox(
            width: cardWidth,
            child: Semantics(
              label: 'Host event tools carousel',
              value:
                  'Hosted event ${_selectedIndex + 1} of ${widget.tools.length}',
              increasedValue: canAdvance
                  ? 'Hosted event ${_selectedIndex + 2} of ${widget.tools.length}'
                  : null,
              decreasedValue: canRetreat
                  ? 'Hosted event $_selectedIndex of ${widget.tools.length}'
                  : null,
              onIncrease: widget.tools.length > 1 && canAdvance
                  ? () => setState(() => _selectedIndex += 1)
                  : null,
              onDecrease: widget.tools.length > 1 && canRetreat
                  ? () => setState(() => _selectedIndex -= 1)
                  : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: widget.tools.length > 1
                    ? (_) => _dragDistance = 0
                    : null,
                onHorizontalDragUpdate: widget.tools.length > 1
                    ? (details) => _dragDistance += details.primaryDelta ?? 0
                    : null,
                onHorizontalDragEnd: widget.tools.length > 1
                    ? (details) => _handleHorizontalDragEnd(
                        details: details,
                        itemCount: widget.tools.length,
                      )
                    : null,
                onHorizontalDragCancel: widget.tools.length > 1
                    ? () => _dragDistance = 0
                    : null,
                child: AnimatedSwitcher(
                  duration: CatchMotion.base,
                  switchInCurve: CatchMotion.easeOutCubicCurve,
                  switchOutCurve: CatchMotion.easeInCubicCurve,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: HostEventToolCard(
                    key: ValueKey(
                      'host-event-tool-${selectedTool.event.id}-'
                      '${selectedTool.attendanceState.name}',
                    ),
                    item: selectedTool,
                    cardIndex: _selectedIndex,
                    cardCount: widget.tools.length,
                    onManageEvent: widget.onManageEvent,
                    onTakeAttendance: widget.onTakeAttendance,
                    onViewReport: widget.onViewReport,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
}

class HostEventToolsPageIndicator extends StatelessWidget {
  const HostEventToolsPageIndicator({
    super.key,
    required this.selectedIndex,
    required this.itemCount,
  });

  final int selectedIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final progress = ((selectedIndex + 1) / itemCount).clamp(0.0, 1.0);

    return Semantics(
      label: 'Host event ${selectedIndex + 1} of $itemCount',
      child: Row(
        children: [
          Text(
            '${selectedIndex + 1} of $itemCount',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.labelS(context, color: t.ink2),
          ),
          gapW10,
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: t.line2.withValues(
                  alpha: CatchOpacity.pageDotInactive,
                ),
                valueColor: AlwaysStoppedAnimation<Color>(t.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HostEventToolCard extends StatelessWidget {
  const HostEventToolCard({
    super.key,
    required this.item,
    required this.cardIndex,
    required this.cardCount,
    required this.onManageEvent,
    required this.onTakeAttendance,
    required this.onViewReport,
  });

  final HostEventToolItem item;
  final int cardIndex;
  final int cardCount;
  final ValueChanged<Event> onManageEvent;
  final ValueChanged<Event> onTakeAttendance;
  final ValueChanged<Event> onViewReport;

  @override
  Widget build(BuildContext context) {
    final palette = HostToolPalette.forAttendanceState(
      context,
      item.attendanceState,
    );
    final event = item.event;
    final action = _hostEventActionForState(item.attendanceState);

    return EventActionCard(
      event: event,
      radius: 22,
      backgroundColor: palette.background,
      borderColor: palette.border,
      gradientColors: palette.gradientColors,
      badges: [
        const EventActionCardBadge(
          label: 'Host event',
          tone: CatchBadgeTone.brand,
        ),
        EventActionCardBadge(
          label: item.attendanceState.badgeLabel,
          tone: item.attendanceState.badgeTone,
          icon: item.canTakeAttendance ? CatchIcons.checklistRounded : null,
        ),
      ],
      headerAccessory: cardCount > 1
          ? HostEventToolsPageIndicator(
              key: HostEventToolsCarousel.pageIndicatorKey,
              selectedIndex: cardIndex,
              itemCount: cardCount,
            )
          : null,
      metaRows: [
        [
          CatchMetaEntry(
            icon: CatchIcons.accessTimeRounded,
            label: '${event.shortDateLabel} · ${event.timeRangeLabel}',
          ),
        ],
        [
          CatchMetaEntry(
            icon: CatchIcons.locationOnOutlined,
            label: event.locationName,
          ),
        ],
        [
          CatchMetaEntry(
            icon: CatchIcons.groupsOutlined,
            label:
                '${event.signedUpCount}/${event.capacityLimit} booked · '
                '${event.waitlistCount} waitlist',
          ),
        ],
      ],
      actions: [
        EventActionCardAction(
          label: action.label,
          icon: action.icon,
          variant: CatchButtonVariant.primary,
          onPressed: () => _handleAction(action),
        ),
      ],
    );
  }

  void _handleAction(_HostEventAction action) {
    switch (action) {
      case _HostEventAction.manage:
        onManageEvent(item.event);
      case _HostEventAction.takeAttendance:
        onTakeAttendance(item.event);
      case _HostEventAction.viewReport:
        onViewReport(item.event);
    }
  }
}

class HostToolPalette {
  const HostToolPalette({
    required this.background,
    required this.border,
    required this.gradientColors,
  });

  final Color background;
  final Color border;
  final List<Color> gradientColors;

  factory HostToolPalette.forAttendanceState(
    BuildContext context,
    HostEventAttendanceState state,
  ) {
    final t = CatchTokens.of(context);
    final isOpen = state == HostEventAttendanceState.open;

    return HostToolPalette(
      background: isOpen ? t.primarySoft : t.surface,
      border: isOpen
          ? t.primary.withValues(alpha: CatchOpacity.gradientBandSoft)
          : t.line2,
      gradientColors: [
        isOpen
            ? t.primarySoft.withValues(
                alpha: CatchOpacity.revealMutedForeground,
              )
            : t.primarySoft.withValues(
                alpha: CatchOpacity.clubCoverPaletteLine,
              ),
        t.surface,
        t.raised.withValues(alpha: CatchOpacity.eventHeroMutedInk),
      ],
    );
  }

  factory HostToolPalette.defaultPanel(BuildContext context) {
    final t = CatchTokens.of(context);

    return HostToolPalette(
      background: t.surface,
      border: t.primary.withValues(
        alpha: CatchOpacity.eventSuccessSubtleBorder,
      ),
      gradientColors: [
        t.primarySoft.withValues(alpha: CatchOpacity.eventSuccessMuted),
        t.surface,
        t.raised.withValues(alpha: CatchOpacity.eventHeroMutedInk),
      ],
    );
  }
}

enum _HostEventAction { manage, takeAttendance, viewReport }

_HostEventAction _hostEventActionForState(HostEventAttendanceState state) {
  return switch (state) {
    HostEventAttendanceState.open => _HostEventAction.takeAttendance,
    HostEventAttendanceState.opensLater => _HostEventAction.manage,
    HostEventAttendanceState.closed => _HostEventAction.viewReport,
  };
}

extension on _HostEventAction {
  IconData get icon {
    return switch (this) {
      _HostEventAction.manage => CatchIcons.tuneRounded,
      _HostEventAction.takeAttendance => CatchIcons.checklistRounded,
      _HostEventAction.viewReport => CatchIcons.insightsOutlined,
    };
  }

  String get label {
    return switch (this) {
      _HostEventAction.manage => 'Manage event',
      _HostEventAction.takeAttendance => 'Take attendance',
      _HostEventAction.viewReport => 'View report',
    };
  }
}

extension HostEventAttendanceStateLabels on HostEventAttendanceState {
  String get badgeLabel {
    return switch (this) {
      HostEventAttendanceState.open => 'Attendance open',
      HostEventAttendanceState.opensLater => 'Upcoming',
      HostEventAttendanceState.closed => 'Attendance closed',
    };
  }

  CatchBadgeTone get badgeTone {
    return switch (this) {
      HostEventAttendanceState.open => CatchBadgeTone.live,
      HostEventAttendanceState.opensLater => CatchBadgeTone.neutral,
      HostEventAttendanceState.closed => CatchBadgeTone.neutral,
    };
  }
}
