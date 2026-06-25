import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

void main() => runApp(const ProviderScope(child: CatchWidgetbookApp()));

@widgetbook.App()
class CatchWidgetbookApp extends StatelessWidget {
  const CatchWidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      lightTheme: AppTheme.light,
      darkTheme: AppTheme.dark,
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Catch Light', data: AppTheme.light),
            WidgetbookTheme(name: 'Catch Dark', data: AppTheme.dark),
          ],
        ),
        ViewportAddon([
          Viewports.none,
          IosViewports.iPhoneSE,
          IosViewports.iPhone13,
          AndroidViewports.samsungGalaxyA50,
        ]),
        TextScaleAddon(initialScale: 1, min: 0.85, max: 2.0, divisions: 6),
        LocalizationAddon(
          locales: const [Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
        InspectorAddon(),
      ],
    );
  }
}
