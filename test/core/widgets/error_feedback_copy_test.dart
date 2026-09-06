import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets('shared error banner uses caller copy without app localization', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.light,
        home: Scaffold(
          body: CatchErrorBanner.withRetry(
            message: 'Enregistrement impossible.',
            retryLabel: 'Réessayer',
            onRetry: () => retries++,
          ),
        ),
      ),
    );
    expect(find.text('Enregistrement impossible.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    expect(retries, 1);
  });

  testWidgets('app error mapping follows locale and preserves retry policy', (
    tester,
  ) async {
    var retries = 0;
    final banners = Column(
      children: [
        CatchLocalizedErrorBanner(
          const NetworkException('timeout', 'Transport diagnostic.'),
          onRetry: () => retries++,
        ),
        CatchLocalizedErrorBanner(
          const PermissionException('Permission diagnostic.'),
          onRetry: () => retries++,
        ),
      ],
    );
    Widget frame(Locale locale) => MaterialApp(
      theme: CatchTheme.light,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('fr')],
      localizationsDelegates: const [
        _ErrorCopyDelegate(),
        ...AppLocalizations.localizationsDelegates,
      ],
      home: Scaffold(body: banners),
    );

    await tester.pumpWidget(frame(const Locale('en')));
    await pumpUntilFound(tester, find.text('Try again'));
    expect(find.text('Try again'), findsOneWidget);

    // Reuse the same banner instances: localization must be read at build time.
    await tester.pumpWidget(frame(const Locale('fr')));
    await pumpUntilFound(tester, find.text('Réessayer'));
    expect(find.text('Délai dépassé.'), findsOneWidget);
    expect(find.text('Accès refusé.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(find.byType(CatchTextButton), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    expect(retries, 1);
  });
}

class _ErrorCopyDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _ErrorCopyDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(
    locale.languageCode == 'fr' ? _FrenchErrorCopy() : AppLocalizationsEn(),
  );

  @override
  bool shouldReload(_ErrorCopyDelegate old) => false;
}

class _FrenchErrorCopy extends AppLocalizationsEn {
  _FrenchErrorCopy() : super('fr');

  @override
  String get coreCatchErrorBannerLabelTryAgain => 'Réessayer';

  @override
  String get coreAppErrorMessageVisiblecopyTheRequestTimedOut =>
      'Délai dépassé.';

  @override
  String get coreAppErrorMessageVisiblecopyYouDoNotHave => 'Accès refusé.';
}
