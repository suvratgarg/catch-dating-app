import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const double _iconBoxSize = CatchSpacing.s9;
  static const double _tileSpacing = CatchSpacing.s3;

  void _onTap(BuildContext context, _QuickAction action) {
    if (action.route == null) return;
    context.push(action.route!);
  }

  @override
  Widget build(BuildContext context) {
    final actions = _actions;

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
                  opacity: action.route == null ? 0.7 : 1,
                  child: _QuickActionTile(
                    action: action,
                    onTap: action.route == null
                        ? null
                        : () => _onTap(context, action),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<_QuickAction> get _actions => [
    _QuickAction(
      icon: CatchIcons.calendarMonthOutlined,
      label: 'Calendar',
      route: Routes.calendarScreen.path,
    ),
    _QuickAction(
      icon: CatchIcons.bookmarkBorderRounded,
      label: 'Saved events',
      route: Routes.savedEventsScreen.path,
    ),
  ];
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action, required this.onTap});

  final _QuickAction action;
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

class _QuickAction {
  const _QuickAction({required this.icon, required this.label, this.route});

  final IconData icon;
  final String label;
  final String? route;
}
