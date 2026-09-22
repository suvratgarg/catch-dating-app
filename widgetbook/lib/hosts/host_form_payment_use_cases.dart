import 'package:catch_dating_app/hosts/domain/forms/host_form_definition.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_payment.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_payment_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_payment_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_payment_sheet.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/page_preview.dart';
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

const _ready = HostFormPaymentConnection(
  connectionId: 'rpc_demo',
  status: HostFormPaymentConnectionStatus.ready,
  mode: HostFormPaymentMode.test,
  accountId: 'acc_rsvp_demo',
  webhookVerified: true,
);

@widgetbook.UseCase(
  name: 'Unconfigured and connected account',
  type: HostFormPaymentSetupSection,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormPaymentSetupPreview(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'Form payment setup',
      catalogId: 'host.form_payment_setup',
      children: [
        for (final available in [false, true])
          WidgetbookPageStateCard(
            label: available
                ? 'Ready test account'
                : 'Partner setup unavailable',
            child: WidgetbookContentFrame(
              child: HostFormPaymentSetupSection(
                state: HostFormPaymentSetupState(
                  setup: HostFormPaymentSetup(
                    available: available,
                    connections: available ? [_ready] : [],
                  ),
                ),
                definition: HostFormDefinition.fromMap(const {
                  'identityPolicy': 'phoneVerified',
                }),
                onChanged: (_) {},
                onConnect: () {},
                onRefresh: () {},
                onDisconnect: (_) {},
              ),
            ),
          ),
      ],
    );

@widgetbook.UseCase(
  name: 'Manager connection boundary',
  type: HostFormPaymentSection,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormPaymentSectionPreview(BuildContext context) =>
    WidgetbookFixtureScope(
      overrides: [
        hostFormPaymentControllerProvider(
          'org_demo',
        ).overrideWith(_PaymentSetup.new),
      ],
      child: WidgetbookScrollCatalogFrame(
        title: 'Form payment',
        catalogId: 'host.form_payment',
        children: [
          WidgetbookContentFrame(
            child: HostFormPaymentSection(
              organizerId: 'org_demo',
              definition: HostFormDefinition.fromMap(const {
                'identityPolicy': 'phoneVerified',
              }),
              onChanged: (_) {},
            ),
          ),
        ],
      ),
    );

@widgetbook.UseCase(
  name: 'Amount and mandatory refund policy',
  type: HostFormPaymentSheet,
  path: '[P1 product surfaces]/Host operations/Forms',
)
Widget hostFormPaymentSheetPreview(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'Form payment fee',
      catalogId: 'host.form_payment_sheet',
      children: [
        Builder(
          builder: (context) => CatchButton(
            label: 'Set a submission fee',
            onPressed: () => showCatchBottomSheet<HostFormPayment>(
              context: context,
              builder: (_) => const HostFormPaymentSheet(
                payment: null,
                connections: [_ready],
              ),
            ),
          ),
        ),
      ],
    );

class _PaymentSetup extends HostFormPaymentController {
  @override
  Future<HostFormPaymentSetupState> build(String organizerId) async =>
      const HostFormPaymentSetupState(
        setup: HostFormPaymentSetup(available: false, connections: []),
      );
}
