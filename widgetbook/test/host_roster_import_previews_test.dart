import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_roster_import_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_roster_mapping_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widgetbook_workspace/hosts/host_roster_import_use_cases.dart';

import '../../test/test_pump_helpers.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    for (final (name, builder, type) in <(String, WidgetBuilder, Type)>[
      ('import sheet', hostRosterImportSheetStates, HostRosterImportSheet),
      ('mapping field', hostRosterMappingFieldStates, HostRosterMappingField),
    ]) {
      testWidgets('$name previews fit at text scale $scale', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(520, 2000);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        for (final theme in [AppTheme.light, AppTheme.dark]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Builder(
                builder: (context) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale),
                    disableAnimations: true,
                  ),
                  child: Builder(builder: builder),
                ),
              ),
            ),
          );
          await pumpFeatureUi(tester);
          expect(tester.takeException(), isNull);
          expect(find.byType(type), findsNWidgets(2));
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        }
      });
    }
  }
}
