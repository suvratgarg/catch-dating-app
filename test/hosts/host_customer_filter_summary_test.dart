import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('campaign bridge fails closed while customer history is incomplete', () {
    expect(
      hostCampaignBridgeBlocker(
        hasPersistableAudience: true,
        messagingSetup: null,
        audienceCoverageComplete: false,
      ),
      HostCampaignBlockers.audienceCoveragePartial,
    );
  });

  testWidgets('filter summary enables the exact-count campaign bridge', (
    tester,
  ) async {
    var messagesStarted = 0;

    await tester.pumpWidget(
      _app(
        HostCustomerFilterSummary(
          filter: HostCustomerFilter.atRisk,
          count: 12,
          countCoverage: HostCustomerMatchCountCoverage.exact,
          campaignBlocker: null,
          onMessage: () => messagesStarted += 1,
          onOpenMessaging: () {},
        ),
      ),
    );

    await tester.tap(find.text('Message these 12 people'));

    expect(messagesStarted, 1);
  });

  testWidgets('filter summary qualifies counts and explains a blocked bridge', (
    tester,
  ) async {
    var messagingOpens = 0;

    await tester.pumpWidget(
      _app(
        HostCustomerFilterSummary(
          filter: HostCustomerFilter.atRisk,
          count: 12,
          countCoverage: HostCustomerMatchCountCoverage.atLeast,
          campaignBlocker: HostCampaignBlockers.senderInactive,
          onMessage: null,
          onOpenMessaging: () => messagingOpens += 1,
        ),
      ),
    );

    final button = tester.widget<CatchButton>(
      find.byKey(const ValueKey('host-customers-messaging-action')),
    );
    expect(button.label, 'Open messaging');
    expect(button.onPressed, isNotNull);
    expect(find.text('Sender verification is incomplete'), findsOneWidget);

    await tester.tap(find.text('Open messaging'));
    expect(messagingOpens, 1);
  });

  testWidgets('all customers never claims the directory is one campaign', (
    tester,
  ) async {
    var messagingOpens = 0;

    await tester.pumpWidget(
      _app(
        HostCustomerFilterSummary(
          filter: HostCustomerFilter.all,
          count: 2,
          countCoverage: HostCustomerMatchCountCoverage.exact,
          campaignBlocker: null,
          onMessage: null,
          onOpenMessaging: () => messagingOpens += 1,
        ),
      ),
    );

    expect(find.text('All · 2 people'), findsOneWidget);
    expect(find.text('Message these 2'), findsNothing);
    expect(find.text('Open messaging'), findsOneWidget);

    await tester.tap(find.text('Open messaging'));
    expect(messagingOpens, 1);
  });

  testWidgets('manual tag summary can become its own saved audience', (
    tester,
  ) async {
    var messagesStarted = 0;

    await tester.pumpWidget(
      _app(
        HostCustomerFilterSummary(
          filter: HostCustomerFilter.all,
          manualTag: const HostCustomerManualTag(
            tagId: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            label: 'Brings friends',
          ),
          count: 4,
          countCoverage: HostCustomerMatchCountCoverage.exact,
          campaignBlocker: null,
          onMessage: () => messagesStarted += 1,
          onOpenMessaging: () {},
        ),
      ),
    );

    expect(find.text('Brings friends · 4 people'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-customers-messaging-action')),
      findsOneWidget,
    );
    await tester.tap(find.text('Message these 4 people'));
    expect(messagesStarted, 1);
  });
}

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);
