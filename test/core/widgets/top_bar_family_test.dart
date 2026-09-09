import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets('keyed root and route recipes retain the active search', (
    tester,
  ) async {
    const key = ValueKey('shared-top-bar');
    var query = '';
    Future<void> pump(bool root) => tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            final search = CatchTopBarSearch(
              copy: catchSearchFieldCopy(AppLocalizationsEn()),
              value: query,
              onChanged: (value) => query = value,
              placeholder: 'Find people',
              tooltip: 'Search people',
            );
            return Scaffold(
              appBar: root
                  ? CatchTopBar.screen(
                      key: key,
                      context: context,
                      title: 'People',
                      search: search,
                    )
                  : CatchTopBar(key: key, title: 'People', search: search),
            );
          },
        ),
      ),
    );
    await pump(true);
    final state = tester.state(find.byKey(key));
    await tester.tap(find.byTooltip('Search people'));
    await pumpFeatureUi(tester);
    await tester.enterText(find.byType(TextField), 'Ananya');
    expect(query, 'Ananya');
    await pump(false);
    await pumpFeatureUi(tester);
    expect(tester.state(find.byKey(key)), same(state));
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Ananya',
    );
    expect(tester.takeException(), isNull);
  });
}
