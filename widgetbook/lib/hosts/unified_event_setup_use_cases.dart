import 'package:catch_dating_app/hosts/data/event_offer_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/event_offer_preferences_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/host_event_offer_preferences_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_create_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_details_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_details_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_preferences_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_preferences_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_setup_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_private_event_setup_inventory_section.dart';
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

@widgetbook.UseCase(
  name: 'Private event payment preferences',
  type: PrivateEventPreferencesScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget privateEventPreferencesScreenPreview(BuildContext context) {
  final hash = List.filled(64, 'a').join();
  final controller = PrivateEventPreferencesController(
    userId: 'preview-host', organizerId: 'preview-club',
    eventId: 'preview-private-event',
    readEvent: ({required organizerId, required eventId}) async =>
        throw StateError('Preview does not read events'),
    readDefaults: (_) async =>
        throw StateError('Preview does not read defaults'),
    write: (_) async => throw StateError('Preview does not submit settings'),
  );
  controller.event = PrivateEventBasicSummary(
    eventId: 'preview-private-event', organizerId: 'preview-club',
    setupRevision: 1, name: 'Saturday mixer',
    city: const EventSetupCity(cityId: 'in-mh-mumbai', marketId: 'in-mh-mumbai'),
    localDate: '2026-10-03', localStartTime: '19:00',
    timezone: 'Asia/Kolkata', startTimeMillis: 1791043800000,
    status: 'active', setupDefaults: const {}, detailsConfigured: false,
    eventPreferences: null,
  );
  controller.defaults = ManagerEventSetupDefaults(
    organizerId: 'preview-club', cityId: 'in-mh-mumbai',
    marketId: 'in-mh-mumbai', timezone: 'Asia/Kolkata',
    organizerDefaultsRevision: 1, basicsReviewedHash: hash,
    preferencesRevision: 1,
    preferences: const ManagerEventSetupPreferences(
      timezone: 'Asia/Kolkata', offerValidityMinutes: 1440,
      collectionPreference: EventCollectionPreference.manualInstructions,
      currency: 'INR',
      paymentInstructions: 'Pay after your place is offered.',
    ),
    preferencesHash: hash, reviewedDefaultsHash: hash,
  );
  return WidgetbookPageCatalogFrame(
    title: 'PrivateEventPreferencesScreen',
    contractId: 'screen.host.event.private.preferences',
    children: [
      WidgetbookPageStateCard(
        label: 'manager read; payment activation separate',
        child: WidgetbookHostDeviceFrame(
          child: PrivateEventPreferencesScreen(
            controller: controller,
            onBack: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Saved private event details',
  type: PrivateEventDetailsScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget privateEventDetailsScreenPreview(BuildContext context) {
  final hash = List.filled(64, 'a').join();
  final controller = PrivateEventDetailsController(
    userId: 'preview-host', organizerId: 'preview-club',
    eventId: 'preview-private-event',
    readEvent: ({required organizerId, required eventId}) async =>
        throw StateError('Preview does not read events'),
    readDefaults: (_) async =>
        throw StateError('Preview does not read defaults'),
    write: (_) async => throw StateError('Preview does not submit details'),
  );
  controller.event = const PrivateEventBasicSummary(
    eventId: 'preview-private-event', organizerId: 'preview-club',
    setupRevision: 1, name: 'Saturday mixer',
    city: EventSetupCity(cityId: 'in-mh-mumbai', marketId: 'in-mh-mumbai'),
    localDate: '2026-10-03', localStartTime: '19:00',
    timezone: 'Asia/Kolkata', startTimeMillis: 1791043800000,
    status: 'active', setupDefaults: {}, detailsConfigured: false,
    eventPreferences: null,
  );
  controller.defaults = ManagerEventSetupDefaults(
    organizerId: 'preview-club', cityId: 'in-mh-mumbai',
    marketId: 'in-mh-mumbai', timezone: 'Asia/Kolkata',
    organizerDefaultsRevision: 1, basicsReviewedHash: hash,
    preferencesRevision: 1,
    preferences: const ManagerEventSetupPreferences(
      usualDurationMinutes: 90,
    ),
    preferencesHash: hash, reviewedDefaultsHash: hash,
  );
  return WidgetbookPageCatalogFrame(
    title: 'PrivateEventDetailsScreen',
    contractId: 'screen.host.event.private.details',
    children: [
      WidgetbookPageStateCard(
        label: 'saved event with optional detail suggestions',
        child: WidgetbookHostDeviceFrame(
          child: PrivateEventDetailsScreen(
            controller: controller,
            onBack: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Published event offer preferences',
  type: HostEventOfferPreferencesScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostEventOfferPreferencesScreenPreview(BuildContext context) {
  final hash = List.filled(64, 'a').join();
  final controller = EventOfferPreferencesController(
    userId: 'preview-host', organizerId: 'preview-club',
    eventId: 'preview-published-event', displayName: 'Saturday mixer',
    readConfiguration: ({required organizerId, required eventId}) async =>
        throw StateError('Preview does not read offer settings'),
    readDefaults: (_) async =>
        throw StateError('Preview does not read defaults'),
    write: (_) async => throw StateError('Preview does not submit settings'),
  );
  controller.configuration = const EventOfferConfiguration(
    organizerId: 'preview-club', eventId: 'preview-published-event',
    eventSourceRevision: 8, startsAtMillis: 1791043800000,
    nowMillis: 1790000000000, suggestedExpiresAtMillis: null,
    preferencesRevision: 0, preferences: null,
  );
  controller.defaults = ManagerEventSetupDefaults(
    organizerId: 'preview-club', cityId: 'in-mh-mumbai',
    marketId: 'in-mh-mumbai', timezone: 'Asia/Kolkata',
    organizerDefaultsRevision: 1, basicsReviewedHash: hash,
    preferencesRevision: 1,
    preferences: const ManagerEventSetupPreferences(
      timezone: 'Asia/Kolkata', currency: 'INR',
      offerValidityMinutes: 1440,
      collectionPreference: EventCollectionPreference.manualInstructions,
    ),
    preferencesHash: hash, reviewedDefaultsHash: hash,
  );
  return WidgetbookPageCatalogFrame(
    title: 'HostEventOfferPreferencesScreen',
    contractId: 'screen.host.event.published.preferences',
    children: [
      WidgetbookPageStateCard(
        label: 'future offers; existing terms unchanged',
        child: WidgetbookHostDeviceFrame(
          child: ProviderScope(
            child: HostEventOfferPreferencesScreen(
              organizerId: 'preview-club',
              eventId: 'preview-published-event',
              initialController: controller,
              onBack: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Private event manager inventory',
  type: HostPrivateEventSetupInventorySection,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostPrivateEventSetupInventorySectionPreview(BuildContext context) =>
    WidgetbookPageCatalogFrame(
      title: 'HostPrivateEventSetupInventorySection',
      contractId: 'section.host.event.private.inventory',
      children: [
        WidgetbookPageStateCard(
          label: 'upcoming saved private event',
          child: WidgetbookHostDeviceFrame(
            child: Scaffold(
              body: SingleChildScrollView(
                child: HostPrivateEventSetupInventorySection(
                  organizerId: 'preview-club',
                  read: ({required organizerId, required limit, cursor}) async =>
                      const PrivateEventSetupInventoryPage(
                    events: [
                      PrivateEventSetupInventoryItem(
                        eventId: 'preview-private-event',
                        name: 'Saturday mixer',
                        city: EventSetupCity(
                          cityId: 'in-mh-mumbai', marketId: 'in-mh-mumbai',
                        ),
                        localDate: '2026-10-03', localStartTime: '19:00',
                        timezone: 'Asia/Kolkata',
                        startTimeMillis: 1791043800000,
                        setupRevision: 2, detailsConfigured: false,
                      ),
                    ],
                    nextCursor: null,
                  ),
                  openSaved: (_) async {},
                ),
              ),
            ),
          ),
        ),
      ],
    );
