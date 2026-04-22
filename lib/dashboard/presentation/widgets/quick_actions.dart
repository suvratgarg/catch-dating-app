import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key, required this.tokens});

  final CatchTokens tokens;

  static const _actions = [
    (Icons.grid_view_rounded, 'Browse runs'),
    (Icons.map_outlined, 'Map view'),
    (Icons.calendar_month_outlined, 'Calendar'),
  ];

  void _onTap(BuildContext context, String label) {
    switch (label) {
      case 'Browse runs':
        context.go(Routes.runClubsListScreen.path);
      // Map view and Calendar screens are not yet built.
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    return Row(
      children: _actions.map((a) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: a == _actions.last ? 0 : 10),
            child: GestureDetector(
              onTap: () => _onTap(context, a.$2),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.surface,
                  border: Border.all(color: t.line),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: t.primarySoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a.$1, color: t.primary, size: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a.$2,
                      style: CatchTextStyles.labelMd(context),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
