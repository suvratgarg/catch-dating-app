import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';

enum HostRunAttendanceState { open, opensLater, closed }

class HostRunToolItem {
  const HostRunToolItem({required this.run, required this.attendanceState});

  final Run run;
  final HostRunAttendanceState attendanceState;

  bool get canTakeAttendance => attendanceState == HostRunAttendanceState.open;
}

class HostRunToolsCarousel extends StatefulWidget {
  const HostRunToolsCarousel({
    super.key,
    required this.tools,
    required this.onManageRun,
    required this.onTakeAttendance,
    this.title = 'Host tools',
  });

  static const railKey = Key('host-run-tools-carousel');
  static const pageIndicatorKey = Key('host-run-tools-page-indicator');

  final List<HostRunToolItem> tools;
  final ValueChanged<Run> onManageRun;
  final ValueChanged<Run> onTakeAttendance;
  final String title;

  @override
  State<HostRunToolsCarousel> createState() => _HostRunToolsCarouselState();
}

class _HostRunToolsCarouselState extends State<HostRunToolsCarousel> {
  static const _minimumSwipeDistance = 56.0;
  static const _minimumSwipeVelocity = 360.0;

  int _selectedIndex = 0;
  double _dragDistance = 0;

  @override
  void didUpdateWidget(covariant HostRunToolsCarousel oldWidget) {
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
        ? '1 run'
        : '${widget.tools.length} runs';

    return Column(
      key: HostRunToolsCarousel.railKey,
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
                  child: HostRunToolCard(
                    key: ValueKey(
                      'host-run-tool-${selectedTool.run.id}-'
                      '${selectedTool.attendanceState.name}',
                    ),
                    item: selectedTool,
                    cardIndex: _selectedIndex,
                    cardCount: widget.tools.length,
                    onManageRun: widget.onManageRun,
                    onTakeAttendance: widget.onTakeAttendance,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.tools.length > 1) ...[
          gapH10,
          HostRunToolsPageIndicator(
            key: HostRunToolsCarousel.pageIndicatorKey,
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

class HostRunToolsPageIndicator extends StatelessWidget {
  const HostRunToolsPageIndicator({
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
        label: 'Host run ${selectedIndex + 1} of $itemCount',
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

class HostRunToolCard extends StatelessWidget {
  const HostRunToolCard({
    super.key,
    required this.item,
    required this.cardIndex,
    required this.cardCount,
    required this.onManageRun,
    required this.onTakeAttendance,
  });

  final HostRunToolItem item;
  final int cardIndex;
  final int cardCount;
  final ValueChanged<Run> onManageRun;
  final ValueChanged<Run> onTakeAttendance;

  @override
  Widget build(BuildContext context) {
    final palette = HostToolPalette.forAttendanceState(
      context,
      item.attendanceState,
    );
    final run = item.run;

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
                  run.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.displayM(context),
                ),
                gapH12,
                _HostRunMetaLine(
                  icon: Icons.access_time_rounded,
                  label: '${run.shortDateLabel} · ${run.timeRangeLabel}',
                ),
                gapH6,
                _HostRunMetaLine(
                  icon: Icons.location_on_outlined,
                  label: run.meetingPoint,
                ),
                gapH6,
                _HostRunMetaLine(
                  icon: Icons.groups_outlined,
                  label:
                      '${run.signedUpCount}/${run.capacityLimit} booked · '
                      '${run.waitlistCount} waitlist',
                ),
                gapH16,
                _HostRunToolActions(
                  item: item,
                  onManageRun: onManageRun,
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

class HostRunBottomActions extends StatelessWidget {
  const HostRunBottomActions({
    super.key,
    required this.item,
    required this.onManageRun,
    required this.onTakeAttendance,
  });

  final HostRunToolItem item;
  final ValueChanged<Run> onManageRun;
  final ValueChanged<Run> onTakeAttendance;

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
                _HostRunToolActions(
                  item: item,
                  onManageRun: onManageRun,
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

class _HostRunToolActions extends StatelessWidget {
  const _HostRunToolActions({
    required this.item,
    required this.onManageRun,
    required this.onTakeAttendance,
  });

  final HostRunToolItem item;
  final ValueChanged<Run> onManageRun;
  final ValueChanged<Run> onTakeAttendance;

  @override
  Widget build(BuildContext context) {
    final primaryAction = item.canTakeAttendance
        ? _HostRunAction.takeAttendance
        : _HostRunAction.manage;
    final secondaryAction = item.canTakeAttendance
        ? _HostRunAction.manage
        : _HostRunAction.attendanceUnavailable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HostRunActionButton(
          action: primaryAction,
          item: item,
          isPrimary: true,
          onManageRun: onManageRun,
          onTakeAttendance: onTakeAttendance,
        ),
        gapH10,
        _HostRunActionButton(
          action: secondaryAction,
          item: item,
          isPrimary: false,
          onManageRun: onManageRun,
          onTakeAttendance: onTakeAttendance,
        ),
      ],
    );
  }
}

class _HostRunActionButton extends StatelessWidget {
  const _HostRunActionButton({
    required this.action,
    required this.item,
    required this.isPrimary,
    required this.onManageRun,
    required this.onTakeAttendance,
  });

  final _HostRunAction action;
  final HostRunToolItem item;
  final bool isPrimary;
  final ValueChanged<Run> onManageRun;
  final ValueChanged<Run> onTakeAttendance;

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
      case _HostRunAction.manage:
        onManageRun(item.run);
      case _HostRunAction.takeAttendance:
        onTakeAttendance(item.run);
      case _HostRunAction.attendanceUnavailable:
        break;
    }
  }
}

class _HostRunMetaLine extends StatelessWidget {
  const _HostRunMetaLine({required this.icon, required this.label});

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
    HostRunAttendanceState state,
  ) {
    final t = CatchTokens.of(context);
    final isOpen = state == HostRunAttendanceState.open;

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

enum _HostRunAction { manage, takeAttendance, attendanceUnavailable }

extension on _HostRunAction {
  IconData get icon {
    return switch (this) {
      _HostRunAction.manage => Icons.tune_rounded,
      _HostRunAction.takeAttendance => Icons.checklist_rounded,
      _HostRunAction.attendanceUnavailable => Icons.schedule_rounded,
    };
  }

  String label(HostRunAttendanceState state) {
    return switch (this) {
      _HostRunAction.manage => 'Manage run',
      _HostRunAction.takeAttendance => 'Take attendance',
      _HostRunAction.attendanceUnavailable => switch (state) {
        HostRunAttendanceState.open => 'Take attendance',
        HostRunAttendanceState.opensLater => 'Attendance opens later',
        HostRunAttendanceState.closed => 'Attendance closed',
      },
    };
  }

  bool isEnabled(HostRunAttendanceState state) {
    return switch (this) {
      _HostRunAction.manage => true,
      _HostRunAction.takeAttendance => state == HostRunAttendanceState.open,
      _HostRunAction.attendanceUnavailable => false,
    };
  }
}

extension HostRunAttendanceStateLabels on HostRunAttendanceState {
  String get badgeLabel {
    return switch (this) {
      HostRunAttendanceState.open => 'Attendance open',
      HostRunAttendanceState.opensLater => 'Upcoming',
      HostRunAttendanceState.closed => 'Closed',
    };
  }

  CatchBadgeTone get badgeTone {
    return switch (this) {
      HostRunAttendanceState.open => CatchBadgeTone.live,
      HostRunAttendanceState.opensLater => CatchBadgeTone.neutral,
      HostRunAttendanceState.closed => CatchBadgeTone.neutral,
    };
  }
}
