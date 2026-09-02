import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_messaging_setup_screen.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import '../clubs/clubs_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  setUp(() => AppConfig.configureEntrypointRole(AppRole.host));
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  testWidgets('setup route uses canonical route and responsive body owners', (
    tester,
  ) async {
    const organizerId = 'organizer-route';
    final club = buildClub(id: organizerId);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchClubProvider(organizerId).overrideWithValue(AsyncData(club)),
          hostMessagingSetupProvider(organizerId).overrideWithValue(
            const AsyncData(
              HostMessagingSetup(
                organizerId: organizerId,
                providerConfigured: false,
                embeddedSignup: HostWhatsappEmbeddedSignupConfig(
                  appId: null,
                  configId: null,
                  graphVersion: null,
                ),
                connection: null,
                templates: [],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HostMessagingSetupScreen(clubId: organizerId),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(CatchRouteScaffold), findsOneWidget);
    expect(find.byType(CatchResponsiveSectionPage), findsOneWidget);
    expect(find.text('WhatsApp Business settings'), findsOneWidget);
  });

  testWidgets('native WhatsApp setup opens the Host web onboarding route', (
    tester,
  ) async {
    const organizerId = 'organizer-1';
    Uri? launchedUri;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hostMessagingSetupProvider(organizerId).overrideWithValue(
            const AsyncData(
              HostMessagingSetup(
                organizerId: organizerId,
                providerConfigured: true,
                embeddedSignup: HostWhatsappEmbeddedSignupConfig(
                  appId: 'app-id',
                  configId: 'config-id',
                  graphVersion: 'v24.0',
                ),
                connection: null,
                templates: [],
              ),
            ),
          ),
          externalUrlLauncherProvider.overrideWithValue((
            uri, {
            mode = LaunchMode.platformDefault,
          }) async {
            launchedUri = uri;
            return true;
          }),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HostWhatsappSetupPane(club: buildClub(id: organizerId)),
            ),
          ),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    await tester.tap(find.text('Connect WhatsApp Business'));
    await pumpFeatureUi(tester);

    expect(
      launchedUri,
      Uri.parse('https://catchdates.com/host/organizer/$organizerId/messaging'),
    );
    expect(
      find.text('Continue WhatsApp setup in the Host web app.'),
      findsOneWidget,
    );
  });
}
