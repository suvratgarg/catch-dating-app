import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_create_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_setup_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations/host_manager_event_setup_preferences_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../support/page_preview.dart';
import 'operations/fixtures.dart';
import 'operations/preview.dart';

@widgetbook.UseCase(
  name: 'Required private basics',
  type: PrivateEventCreateScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget privateEventCreateScreenPreview(BuildContext context) =>
    WidgetbookPageCatalogFrame(
      title: 'PrivateEventCreateScreen',
      contractId: 'screen.host.event.private.basics',
      children: [
        WidgetbookPageStateCard(
          label: 'first save',
          child: WidgetbookHostDeviceFrame(
            child: ProviderScope(
              child: PrivateEventCreateScreen(
                club: widgetbookClub,
                promptForDraftsOnStart: false,
                create: ({
                  required organizerId,
                  required requestId,
                  required basics,
                }) => Future<PrivateEventCreateReceipt>.error(
                  StateError('Preview does not submit events'),
                ),
              ),
            ),
          ),
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Saved private event setup',
  type: PrivateEventSetupScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget privateEventSetupScreenPreview(BuildContext context) =>
    WidgetbookPageCatalogFrame(
      title: 'PrivateEventSetupScreen',
      contractId: 'screen.host.event.private.setup',
      children: [
        WidgetbookPageStateCard(
          label: 'private with optional capabilities',
          child: WidgetbookHostDeviceFrame(
            child: PrivateEventSetupScreen(
              club: widgetbookClub,
              receipt: const PrivateEventCreateReceipt(
                eventId: 'preview-private-event',
                setupRevision: 1,
                replayed: false,
              ),
              name: 'Saturday mixer',
              date: DateTime(2026, 10, 3),
              start: const TimeOfDay(hour: 19, minute: 0),
              cityLabel: 'Mumbai',
              pendingRosterFileName: 'guests.csv',
              onClose: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
    );

@widgetbook.UseCase(
  name: 'Manager-only future event preferences',
  type: HostManagerEventSetupPreferencesSection,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostManagerEventSetupPreferencesSectionPreview(BuildContext context) =>
    WidgetbookPageCatalogFrame(
      title: 'HostManagerEventSetupPreferencesSection',
      contractId: 'section.host.event.manager-preferences',
      children: [
        WidgetbookPageStateCard(
          label: 'authorized read, save unavailable',
          child: WidgetbookHostDeviceFrame(
            child: Scaffold(
              body: SingleChildScrollView(
                child: HostManagerEventSetupPreferencesSection(
                  preferences: const ManagerEventSetupPreferences(
                    usualDurationMinutes: 90,
                    offerValidityMinutes: 1440,
                    collectionPreference:
                        EventCollectionPreference.manualInstructions,
                    currency: 'INR',
                    paymentInstructions: 'Pay after your place is offered.',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
