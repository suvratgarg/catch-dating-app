import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
          onOpenFilters: () {},
        ),
      ),
    );

    await tester.tap(find.text('Message these 12'));

    expect(messagesStarted, 1);
  });

  testWidgets('filter summary qualifies counts and explains a blocked bridge', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        HostCustomerFilterSummary(
          filter: HostCustomerFilter.atRisk,
          count: 12,
          countCoverage: HostCustomerMatchCountCoverage.atLeast,
          campaignBlocker: HostCampaignBlockers.senderInactive,
          onMessage: null,
          onOpenFilters: () {},
        ),
      ),
    );

    final button = tester.widget<CatchButton>(
      find.byKey(const ValueKey('host-customers-message-segment')),
    );
    expect(button.label, 'Message these 12+');
    expect(button.onPressed, isNull);
    expect(find.text('Sender verification is incomplete'), findsOneWidget);
  });

  testWidgets('manual tag summary never becomes a computed campaign segment', (
    tester,
  ) async {
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
          onMessage: null,
          onOpenFilters: () {},
        ),
      ),
    );

    expect(find.text('Brings friends · 4 people'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-customers-message-segment')),
      findsNothing,
    );
  });
}

Widget _app(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: child),
);
