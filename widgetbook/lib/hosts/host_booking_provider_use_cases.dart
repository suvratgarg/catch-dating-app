import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/host_provider_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_operational_roster_controller.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_booking_provider_section.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_luma_connection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/page_preview.dart';
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Connection lifecycle states',
  type: HostBookingProviderSection,
  path: '[P1 product surfaces]/Host/Roster',
)
Widget hostBookingProviderSectionStates(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'HostBookingProviderSection',
      catalogId: 'host.booking_provider',
      children: [
        for (final (label, value) in <(String, AsyncValue<HostProviderSetup>?)>[
          ('Not opened', null),
          ('Loading', const AsyncLoading()),
          (
            'Unavailable',
            AsyncError(Exception('Unavailable'), StackTrace.empty),
          ),
          ('Ready to connect', AsyncData(_setup(connected: false))),
          ('Connected', AsyncData(_setup(connected: true))),
        ])
          WidgetbookPageStateCard(
            label: label,
            child: WidgetbookContentFrame(
              child: HostBookingProviderSection(
                value: value,
                provider: ExternalBookingProvider.luma,
                mutationPending: false,
                allowChanges: true,
                onRetry: _noop,
                onConnect: _noop,
                onSync: _noop,
                onDisconnect: _noop,
                onImport: _noop,
              ),
            ),
          ),
      ],
    );

@widgetbook.UseCase(
  name: 'Credential entry and event choice',
  type: HostLumaConnectionSheet,
  path: '[P1 product surfaces]/Host/Roster',
)
Widget hostLumaConnectionSheetStates(BuildContext context) =>
    const WidgetbookScrollCatalogFrame(
      title: 'HostLumaConnectionSheet',
      catalogId: 'host.luma_connection',
      children: [
        WidgetbookPageStateCard(
          label: 'Local credential form',
          child: WidgetbookViewportFrame.sheet(
            size: Size(390, 760),
            child: HostLumaConnectionSheet(
              organizerId: 'preview-organizer',
              eventId: 'preview-event',
              controller: _PreviewRosterController(),
            ),
          ),
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Available and empty event lists',
  type: HostLumaEventChoiceSheet,
  path: '[P1 product surfaces]/Host/Roster',
)
Widget hostLumaEventChoiceSheetStates(BuildContext context) =>
    WidgetbookScrollCatalogFrame(
      title: 'HostLumaEventChoiceSheet',
      catalogId: 'host.luma_event_choice',
      children: [
        for (final populated in [true, false])
          WidgetbookPageStateCard(
            label: populated ? 'Available events' : 'Empty calendar',
            child: WidgetbookViewportFrame.sheet(
              size: const Size(390, 760),
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(size: const Size(390, 760)),
                child: HostLumaEventChoiceSheet(
                  choices: populated
                      ? _choices
                      : const HostProviderEventChoices(
                          calendarName: 'Preview calendar',
                          events: [],
                          truncated: false,
                        ),
                ),
              ),
            ),
          ),
      ],
    );

const _capabilities = HostProviderCapabilities(
  fileImport: true,
  eventList: true,
  rosterIdentity: true,
  registrationStatus: true,
  providerCheckIn: false,
  orderAmount: false,
  refundStatus: false,
  referralCode: false,
  webhooks: false,
  writeBookings: false,
);

HostProviderSetup _setup({required bool connected}) => HostProviderSetup(
  organizerId: 'preview-organizer',
  eventId: 'preview-event',
  providers: const [
    HostProviderCatalogEntry(
      provider: ExternalBookingProvider.luma,
      displayName: 'Luma',
      adapterClass: 'luma',
      availability: HostProviderAvailability.available,
      importSupport: HostProviderImportSupport.verified,
      connectionMethod: 'apiKey',
      capabilities: _capabilities,
      requirement: 'Connect your calendar to sync its guest list.',
    ),
  ],
  connections: [
    if (connected)
      const HostProviderConnection(
        connectionId: 'preview-connection',
        status: 'active',
        externalAccountId: 'preview-calendar',
        externalAccountName: 'Preview calendar',
        capabilities: _capabilities,
        revision: 1,
        lastHealthSyncAt: null,
        lastSuccessfulSyncAt: null,
      ),
  ],
  mapping: connected
      ? const HostProviderEventMapping(
          mappingId: 'preview-mapping',
          connectionId: 'preview-connection',
          externalEventId: 'preview-external-event',
          status: 'active',
          revision: 1,
          lastSyncAt: null,
          lastSuccessfulSyncAt: null,
          lastSyncStatus: 'pending',
          lastSyncRunId: null,
        )
      : null,
);

final _choices = HostProviderEventChoices(
  calendarName: 'Preview calendar',
  events: [
    HostProviderEventChoice(
      externalEventId: 'preview-external-event',
      name: 'Tuesday trivia',
      startAt: DateTime(2026, 7, 14, 20),
    ),
    HostProviderEventChoice(
      externalEventId: 'preview-next-event',
      name: 'Weekend social',
      startAt: DateTime(2026, 7, 18, 18),
    ),
  ],
  truncated: false,
);

class _PreviewRosterController implements HostOperationalRosterController {
  const _PreviewRosterController();

  @override
  Future<HostProviderEventChoices> listLumaEvents({
    required String organizerId,
    required String eventId,
    required String apiKey,
  }) async => _choices;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnsupportedError(
    'Unexpected preview action: ${invocation.memberName}',
  );
}

void _noop() {}
