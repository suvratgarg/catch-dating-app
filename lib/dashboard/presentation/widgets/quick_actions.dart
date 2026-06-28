import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.actions, this.columns});

  final List<DashboardQuickAction> actions;
  final int? columns;

  static const double _iconBoxSize = CatchSpacing.s9;
  static const double _tileSpacing = CatchSpacing.s3;

  @override
  Widget build(BuildContext context) {
    final fixedColumns = columns;
    if (fixedColumns != null) {
      return _buildFixedColumns(fixedColumns);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >=
                ComponentBreakpoints.quickActionsWideBreakpoint
            ? actions.length
            : 2;
        final tileWidth =
            (constraints.maxWidth - (_tileSpacing * (columns - 1))) / columns;

        return Wrap(
          spacing: _tileSpacing,
          runSpacing: _tileSpacing,
          children: [
            for (final action in actions)
              SizedBox(
                width: tileWidth,
                child: Opacity(
                  opacity: action.isEnabled ? 1 : 0.7,
                  child: DashboardQuickActionTile(
                    key: action.key,
                    action: action,
                    onTap: action.onPressed,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFixedColumns(int columns) {
    if (actions.isEmpty) return const SizedBox.shrink();
    final safeColumns = columns.clamp(1, actions.length);
    final rows = <Widget>[];

    for (var start = 0; start < actions.length; start += safeColumns) {
      final rowActions = actions
          .skip(start)
          .take(safeColumns)
          .toList(growable: false);
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < rowActions.length; index++) ...[
              Expanded(
                child: Opacity(
                  opacity: rowActions[index].isEnabled ? 1 : 0.7,
                  child: DashboardQuickActionTile(
                    key: rowActions[index].key,
                    action: rowActions[index],
                    onTap: rowActions[index].onPressed,
                  ),
                ),
              ),
              if (index < rowActions.length - 1)
                const SizedBox(width: _tileSpacing),
            ],
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          rows[index],
          if (index < rows.length - 1) const SizedBox(height: _tileSpacing),
        ],
      ],
    );
  }
}

class DashboardQuickActionTile extends StatelessWidget {
  const DashboardQuickActionTile({
    super.key,
    required this.action,
    required this.onTap,
  });

  final DashboardQuickAction action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      onTap: onTap,
      padding: CatchInsets.content,
      radius: CatchRadius.md,
      borderColor: t.line,
      backgroundColor: t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchIconTile(
            icon: action.icon,
            iconColor: t.primary,
            backgroundColor: t.primarySoft,
            borderColor: t.primarySoft,
            size: QuickActions._iconBoxSize,
            iconSize: CatchIcon.md,
            radius: CatchRadius.sm,
          ),
          gapH8,
          Text(
            action.label,
            style: CatchTextStyles.labelL(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class DashboardQuickAction {
  const DashboardQuickAction({
    this.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final Key? key;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  bool get isEnabled => onPressed != null;
}

List<DashboardQuickAction> dashboardQuickActions({
  required VoidCallback onCalendarPressed,
  required VoidCallback onSavedEventsPressed,
}) {
  return [
    DashboardQuickAction(
      icon: CatchIcons.calendarMonthOutlined,
      label: 'Calendar',
      onPressed: onCalendarPressed,
    ),
    DashboardQuickAction(
      icon: CatchIcons.bookmarkBorderRounded,
      label: 'Saved events',
      onPressed: onSavedEventsPressed,
    ),
  ];
}
