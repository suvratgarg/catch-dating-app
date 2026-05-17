import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:flutter/material.dart';

enum HostEventAttendanceState { open, opensLater, closed }

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
    this.title = 'Host tools',
  });

  static const railKey = Key('host-event-tools-carousel');
  static const pageIndicatorKey = Key('host-event-tools-page-indicator');

  final List<HostEventToolItem> tools;
  final ValueChanged<Event> onManageEvent;
  final ValueChanged<Event> onTakeAttendance;
  final String title;

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
    final countLabel = widget.tools.length == 1
        ? '1 event'
        : '${widget.tools.length} events';

    return Column(
      key: HostEventToolsCarousel.railKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.title, style: CatchTextStyles.titleL(context)),
            gapW8,
            CatchBadge(label: countLabel, tone: CatchBadgeTone.brand),
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
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
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
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.tools.length > 1) ...[
          gapH10,
          HostEventToolsPageIndicator(
            key: HostEventToolsCarousel.pageIndicatorKey,
            selectedIndex: _selectedIndex,
            itemCount: widget.tools.length,
          ),
        ],
      ],
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

    return Center(
      child: Semantics(
        label: 'Host event ${selectedIndex + 1} of $itemCount',
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

class HostEventToolCard extends StatelessWidget {
  const HostEventToolCard({
    super.key,
    required this.item,
    required this.cardIndex,
    required this.cardCount,
    required this.onManageEvent,
    required this.onTakeAttendance,
  });

  final HostEventToolItem item;
  final int cardIndex;
  final int cardCount;
  final ValueChanged<Event> onManageEvent;
  final ValueChanged<Event> onTakeAttendance;

  @override
  Widget build(BuildContext context) {
    final palette = HostToolPalette.forAttendanceState(
      context,
      item.attendanceState,
    );
    final event = item.event;

    return CatchSurface(
      padding: EdgeInsets.zero,
      backgroundColor: palette.background,
      borderColor: palette.border,
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
                  colors: palette.gradientColors,
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
                            label: 'Host tools',
                            tone: CatchBadgeTone.brand,
                            uppercase: true,
                          ),
                          CatchBadge(
                            label: item.attendanceState.badgeLabel,
                            tone: item.attendanceState.badgeTone,
                            uppercase: true,
                            icon: item.canTakeAttendance
                                ? Icons.checklist_rounded
                                : null,
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
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.displayM(context),
                ),
                gapH12,
                _HostEventMetaLine(
                  icon: Icons.access_time_rounded,
                  label: '${event.shortDateLabel} · ${event.timeRangeLabel}',
                ),
                gapH6,
                _HostEventMetaLine(
                  icon: Icons.location_on_outlined,
                  label: event.meetingPoint,
                ),
                gapH6,
                _HostEventMetaLine(
                  icon: Icons.groups_outlined,
                  label:
                      '${event.signedUpCount}/${event.capacityLimit} booked · '
                      '${event.waitlistCount} waitlist',
                ),
                gapH16,
                _HostEventToolActions(
                  item: item,
                  onManageEvent: onManageEvent,
                  onTakeAttendance: onTakeAttendance,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HostEventBottomActions extends StatelessWidget {
  const HostEventBottomActions({
    super.key,
    required this.item,
    required this.onManageEvent,
    required this.onTakeAttendance,
  });

  final HostEventToolItem item;
  final ValueChanged<Event> onManageEvent;
  final ValueChanged<Event> onTakeAttendance;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      color: t.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: t.line, height: 1, thickness: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              CatchSpacing.s3,
              CatchSpacing.s4,
              CatchSpacing.s3 + bottomPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s1,
                  children: [
                    const CatchBadge(
                      label: 'Host tools',
                      tone: CatchBadgeTone.brand,
                      uppercase: true,
                    ),
                    CatchBadge(
                      label: item.attendanceState.badgeLabel,
                      tone: item.attendanceState.badgeTone,
                      uppercase: true,
                      icon: item.canTakeAttendance
                          ? Icons.checklist_rounded
                          : null,
                    ),
                  ],
                ),
                gapH10,
                _HostEventToolActions(
                  item: item,
                  onManageEvent: onManageEvent,
                  onTakeAttendance: onTakeAttendance,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HostEventToolActions extends StatelessWidget {
  const _HostEventToolActions({
    required this.item,
    required this.onManageEvent,
    required this.onTakeAttendance,
  });

  final HostEventToolItem item;
  final ValueChanged<Event> onManageEvent;
  final ValueChanged<Event> onTakeAttendance;

  @override
  Widget build(BuildContext context) {
    final primaryAction = item.canTakeAttendance
        ? _HostEventAction.takeAttendance
        : _HostEventAction.manage;
    final secondaryAction = item.canTakeAttendance
        ? _HostEventAction.manage
        : _HostEventAction.attendanceUnavailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HostEventActionButton(
          action: primaryAction,
          item: item,
          isPrimary: true,
          onManageEvent: onManageEvent,
          onTakeAttendance: onTakeAttendance,
        ),
        gapH10,
        _HostEventActionButton(
          action: secondaryAction,
          item: item,
          isPrimary: false,
          onManageEvent: onManageEvent,
          onTakeAttendance: onTakeAttendance,
        ),
      ],
    );
  }
}

class _HostEventActionButton extends StatelessWidget {
  const _HostEventActionButton({
    required this.action,
    required this.item,
    required this.isPrimary,
    required this.onManageEvent,
    required this.onTakeAttendance,
  });

  final _HostEventAction action;
  final HostEventToolItem item;
  final bool isPrimary;
  final ValueChanged<Event> onManageEvent;
  final ValueChanged<Event> onTakeAttendance;

  @override
  Widget build(BuildContext context) {
    return CatchButton(
      label: action.label(item.attendanceState),
      icon: Icon(action.icon, size: 18),
      variant: isPrimary
          ? CatchButtonVariant.primary
          : CatchButtonVariant.secondary,
      fullWidth: true,
      onPressed: action.isEnabled(item.attendanceState)
          ? () => _handleAction()
          : null,
    );
  }

  void _handleAction() {
    switch (action) {
      case _HostEventAction.manage:
        onManageEvent(item.event);
      case _HostEventAction.takeAttendance:
        onTakeAttendance(item.event);
      case _HostEventAction.attendanceUnavailable:
        break;
    }
  }
}

class _HostEventMetaLine extends StatelessWidget {
  const _HostEventMetaLine({required this.icon, required this.label});

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
      border: isOpen ? t.primary.withValues(alpha: 0.28) : t.line2,
      gradientColors: [
        isOpen
            ? t.primarySoft.withValues(alpha: 0.78)
            : t.primarySoft.withValues(alpha: 0.30),
        t.surface,
        t.raised.withValues(alpha: 0.72),
      ],
    );
  }

  factory HostToolPalette.defaultPanel(BuildContext context) {
    final t = CatchTokens.of(context);

    return HostToolPalette(
      background: t.surface,
      border: t.primary.withValues(alpha: 0.18),
      gradientColors: [
        t.primarySoft.withValues(alpha: 0.34),
        t.surface,
        t.raised.withValues(alpha: 0.72),
      ],
    );
  }
}

enum _HostEventAction { manage, takeAttendance, attendanceUnavailable }

extension on _HostEventAction {
  IconData get icon {
    return switch (this) {
      _HostEventAction.manage => Icons.tune_rounded,
      _HostEventAction.takeAttendance => Icons.checklist_rounded,
      _HostEventAction.attendanceUnavailable => Icons.schedule_rounded,
    };
  }

  String label(HostEventAttendanceState state) {
    return switch (this) {
      _HostEventAction.manage => 'Manage event',
      _HostEventAction.takeAttendance => 'Take attendance',
      _HostEventAction.attendanceUnavailable => switch (state) {
        HostEventAttendanceState.open => 'Take attendance',
        HostEventAttendanceState.opensLater => 'Attendance opens later',
        HostEventAttendanceState.closed => 'Attendance closed',
      },
    };
  }

  bool isEnabled(HostEventAttendanceState state) {
    return switch (this) {
      _HostEventAction.manage => true,
      _HostEventAction.takeAttendance => state == HostEventAttendanceState.open,
      _HostEventAction.attendanceUnavailable => false,
    };
  }
}

extension HostEventAttendanceStateLabels on HostEventAttendanceState {
  String get badgeLabel {
    return switch (this) {
      HostEventAttendanceState.open => 'Attendance open',
      HostEventAttendanceState.opensLater => 'Upcoming',
      HostEventAttendanceState.closed => 'Closed',
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
