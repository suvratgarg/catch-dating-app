import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 390.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final kind in [
        'badge',
        'wide metadata',
        'action',
        'action with chevron',
      ]) {
        testWidgets(
          'trailing value and $kind share $width at $scale',
          (tester) async {
            var taps = 0;
            const actionKey = ValueKey('trailing-action');
            final interactive = kind.startsWith('action');
            final action = switch (kind) {
              'badge' => const CatchBadge(
                key: actionKey,
                label: 'Payment issues',
              ),
              'wide metadata' => const SizedBox(
                key: actionKey,
                width: 188,
                height: 24,
              ),
              _ => CatchIconButton.icon(
                key: actionKey,
                icon: Icons.more_horiz,
                tooltip: 'More',
                onTap: () => taps++,
              ),
            };
            await tester.pumpWidget(
              MaterialApp(
                theme: AppTheme.light,
                home: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: Scaffold(
                    body: Center(
                      child: SizedBox(
                        width: width,
                        child: CatchField.nav(
                          title: 'Event One',
                          body: '12 Jun · Completed\n20 booked · 16 attended',
                          valueText: '₹1,200',
                          action: action,
                          showChevron: kind == 'action with chevron',
                          onTap: () {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            expect(tester.takeException(), isNull);
            final row = tester.getRect(find.byType(CatchField));
            final value = tester.getRect(find.text('₹1,200'));
            final custom = tester.getRect(find.byKey(actionKey));
            expect(
              value.width,
              greaterThan(0),
              reason: 'Custom metadata must not starve revenue.',
            );
            for (final rect in [value, custom]) {
              expect(rect.left, greaterThanOrEqualTo(row.left));
              expect(rect.right, lessThanOrEqualTo(row.right));
              expect(rect.top, greaterThanOrEqualTo(row.top));
              expect(rect.bottom, lessThanOrEqualTo(row.bottom));
            }
            expect(value.overlaps(custom), isFalse);
            if (interactive) {
              final target = defaultTargetPlatform == TargetPlatform.iOS
                  ? 44.0
                  : 48.0;
              expect(custom.size, Size.square(target));
              await tester.tap(find.byKey(actionKey));
              await tester.pump();
              expect(taps, 1);
            }
            expect(tester.takeException(), isNull);
          },
          variant: const TargetPlatformVariant({
            TargetPlatform.iOS,
            TargetPlatform.android,
          }),
        );
      }
    }
  }
}
