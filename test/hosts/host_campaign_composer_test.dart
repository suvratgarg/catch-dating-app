import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../clubs/clubs_test_helpers.dart';

void main() {
  testWidgets('initialSegments preselects the requested campaign audience', (
    tester,
  ) async {
    const organizerId = 'organizer-1';
    final club = buildClub(id: organizerId);
    final countRequests = <HostCustomerSegmentCountRequest>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hostCustomerSegmentCountProvider.overrideWith((ref, request) async {
            countRequests.add(request);
            return HostCustomerSegmentCount(
              count: request.filter == HostCustomerFilter.atRisk ? 12 : 3,
              coverage: request.filter == HostCustomerFilter.atRisk
                  ? HostCustomerMatchCountCoverage.exact
                  : HostCustomerMatchCountCoverage.atLeast,
            );
          }),
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
                connection: HostWhatsappConnection(
                  connectionId: 'connection-1',
                  status: 'active',
                  displayPhoneNumber: '+91 98765 43210',
                  verifiedName: 'Catch Social',
                  qualityRating: 'GREEN',
                  messagingLimitTier: 'TIER_1K',
                  templateSyncStatus: 'ready',
                  webhookStatus: 'healthy',
                  testStatus: 'verified',
                  revision: 1,
                ),
                templates: [
                  HostWhatsappTemplate(
                    templateId: 'template-1',
                    name: 'organizer_update',
                    language: 'en_US',
                    category: 'MARKETING',
                    status: 'APPROVED',
                    variableNames: [],
                    hasMediaHeader: false,
                    buttonKinds: [],
                  ),
                ],
              ),
            ),
          ),
          hostCrmSummaryProvider(organizerId).overrideWithValue(
            const AsyncData(
              HostCrmSummary(
                organizerId: organizerId,
                contactCount: 12,
                pastAttendeeCount: 10,
                repeatAttendeeCount: 5,
                linkedAccountCount: 8,
                importedContactCount: 4,
                whatsappOptInCount: 7,
                smsOptInCount: 0,
                truncated: false,
                inAppReadiness: HostCrmChannelReadiness.currentEventOnly,
                whatsappReadiness: HostCrmChannelReadiness.currentEventOnly,
                smsReadiness:
                    HostCrmChannelReadiness.providerAndDltSetupRequired,
              ),
            ),
          ),
          watchEventsForClubProvider(
            organizerId,
          ).overrideWith((ref) => Stream.value(const <Event>[])),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: HostCampaignComposer(
                club: club,
                initialSegments: const {HostAudienceSegment.lapsedRegular},
                initialSearch: 'asha',
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final selected = tester.widget<CatchChip>(
      find.byKey(const ValueKey('host-campaign-segment-lapsed_regular')),
    );
    final whatsapp = tester.widget<CatchChip>(
      find.byKey(const ValueKey('host-campaign-segment-whatsapp_reachable')),
    );

    expect(selected.selected, isTrue);
    expect(whatsapp.selected, isFalse);
    expect(selected.label, contains('12 people'));
    expect(whatsapp.label, contains('3+ people'));
    expect(
      countRequests,
      contains(
        const HostCustomerSegmentCountRequest(
          organizerId: organizerId,
          search: 'asha',
          filter: HostCustomerFilter.atRisk,
        ),
      ),
    );
  });
}
