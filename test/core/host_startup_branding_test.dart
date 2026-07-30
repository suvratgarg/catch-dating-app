import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_startup_loading_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    AppConfig.configureEntrypointRole(AppRole.host);
  });

  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  test('Host startup resolves dedicated light and dark marks', () {
    expect(
      CatchStartupLoadingScreen.iconAssetForBrightness(
        Brightness.light,
        appRole: AppRole.host,
      ),
      CatchStartupLoadingScreen.hostLightIconAsset,
    );
    expect(
      CatchStartupLoadingScreen.iconAssetForBrightness(
        Brightness.dark,
        appRole: AppRole.host,
      ),
      CatchStartupLoadingScreen.hostDarkIconAsset,
    );
  });

  testWidgets('Host startup paints the Host mark and semantic product name', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.light,
        home: const CatchStartupLoadingScreen(),
      ),
    );

    final logo = tester.widget<Image>(find.byType(Image));
    expect(
      (logo.image as AssetImage).assetName,
      CatchStartupLoadingScreen.hostLightIconAsset,
    );
    expect(find.bySemanticsLabel('Catch Host'), findsOneWidget);
  });
}
