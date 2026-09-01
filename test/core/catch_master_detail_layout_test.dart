import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_master_detail_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('adaptive layout resolves against its route-body constraints', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    Future<void> pumpAt(double width) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              height: 700,
              child: CatchAdaptiveMasterDetailLayout(
                minimumExpandedWidth: 720,
                masterBuilder: (context, expanded) =>
                    Text(expanded ? 'Split master' : 'Compact master'),
                detail: const Text('Detail'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpAt(700);
    expect(find.text('Compact master'), findsOneWidget);
    expect(find.text('Detail'), findsNothing);
    expect(
      find.byKey(const ValueKey('catch-master-detail-divider')),
      findsNothing,
    );

    await pumpAt(720);
    expect(find.text('Split master'), findsOneWidget);
    expect(find.text('Detail'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('catch-master-detail-divider')),
      findsOneWidget,
    );
  });
}
