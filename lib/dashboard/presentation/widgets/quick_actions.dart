import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  static const double _tileHeight = 122;
  static const double _iconBoxSize = 36;

  static final _actions = [
    _QuickAction(
      icon: Icons.grid_view_rounded,
      label: 'Browse runs',
      route: Routes.runClubsListScreen.path,
      opensRootTab: true,
    ),
    _QuickAction(
      icon: Icons.map_outlined,
      label: 'Map view',
      route: Routes.runMapScreen.path,
    ),
    _QuickAction(
      icon: Icons.calendar_month_outlined,
      label: 'Calendar',
      route: Routes.calendarScreen.path,
    ),
  ];

  void _onTap(BuildContext context, _QuickAction action) {
    if (action.route == null) return;
    if (action.opensRootTab) {
      context.go(action.route!);
    } else {
      context.push(action.route!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _actions.length; i++) ...[
          Expanded(
            child: Opacity(
              opacity: _actions[i].route == null ? 0.7 : 1,
              child: _QuickActionTile(
                action: _actions[i],
                onTap: _actions[i].route == null
                    ? null
                    : () => _onTap(context, _actions[i]),
              ),
            ),
          ),
          if (i < _actions.length - 1) gapW10,
        ],
      ],
    );
  }
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
      height: QuickActions._tileHeight,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      radius: CatchRadius.md,
      borderColor: t.line,
      backgroundColor: t.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: QuickActions._iconBoxSize,
            height: QuickActions._iconBoxSize,
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(CatchRadius.sm),
            ),
            child: Icon(action.icon, color: t.primary, size: 18),
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
  const _QuickAction({
    required this.icon,
    required this.label,
    this.route,
    this.opensRootTab = false,
  });

  final IconData icon;
  final String label;
  final String? route;
  final bool opensRootTab;
}
