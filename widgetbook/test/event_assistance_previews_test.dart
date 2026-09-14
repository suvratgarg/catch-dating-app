import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_staff_edit_section.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_visit_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook_workspace/event_success/event_assistance_preview_repositories.dart';
import 'package:widgetbook_workspace/event_success/event_assistance_use_cases.dart';

void main() {
  testWidgets(
    'backend fixture asset mounts real staff and visit previews without Firebase',
    (tester) async {
      // Loading the declared asset verifies the browser-compatible fixture path.
      final fixtures = await tester.runAsync(loadAssistancePreviewFixtures);
      expect(fixtures, contains('manager'));
      for (final preview in [
        assistancePracticeStaffEdit,
        assistanceLiveVisit,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            theme: AppTheme.light,
            home: Builder(builder: preview),
          ),
        );
        await tester.runAsync(loadAssistancePreviewFixtures);
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(tester.takeException(), isNull);
        expect(
          preview == assistancePracticeStaffEdit
              ? find.byType(EventRehearsalStaffEditSection)
              : find.byType(EventAssistanceVisitSection),
          findsOneWidget,
          reason: tester
              .widgetList<Text>(find.byType(Text))
              .map((text) => text.data)
              .join(' | '),
        );
      }
    },
  );
}
