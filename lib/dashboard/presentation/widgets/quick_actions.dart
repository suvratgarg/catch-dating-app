import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.tokens});

  final CatchTokens tokens;

  static final _actions = [
    _QuickAction(
      icon: Icons.grid_view_rounded,
      label: 'Browse runs',
      route: Routes.runClubsListScreen.path,
    ),
    const _QuickAction(
      icon: Icons.map_outlined,
      label: 'Map view',
      badge: 'Soon',
    ),
    const _QuickAction(
      icon: Icons.calendar_month_outlined,
      label: 'Calendar',
      badge: 'Soon',
    ),
  ];

  void _onTap(BuildContext context, _QuickAction action) {
    if (action.route == null) return;
    context.go(action.route!);
  }

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Row(
      children: _actions.map((a) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: a == _actions.last ? 0 : 10),
            child: Opacity(
              opacity: a.route == null ? 0.7 : 1,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: a.route == null ? null : () => _onTap(context, a),
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.surface,
                      border: Border.all(color: t.line),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: t.primarySoft,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(a.icon, color: t.primary, size: 18),
                            ),
                            const Spacer(),
                            if (a.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: t.raised,
                                  borderRadius: BorderRadius.circular(
                                    CatchRadius.button,
                                  ),
                                  border: Border.all(color: t.line2),
                                ),
                                child: Text(
                                  a.badge!,
                                  style: CatchTextStyles.caption(
                                    context,
                                    color: t.ink2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.label,
                          style: CatchTextStyles.labelMd(context),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    this.route,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String? route;
  final String? badge;
}
