import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/hosts/presentation/edit_hosted_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_policy_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_edit_screen_state.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/widgetbook_harness.dart';
import 'fixtures.dart';
import 'preview.dart';
import 'role_theme.dart';

final _validationEvent = widgetbookEditableEvent.copyWith(
  id: 'design-host-validation-event',
  meetingPoint: '',
  meetingLocation: const EventMeetingLocation(
    name: '',
    address: 'Carter Road, Bandra West',
    placeId: 'design-carter-road-empty-label',
    latitude: 19.0706,
    longitude: 72.8223,
    notes: 'Meet by the sea-facing steps',
  ),
  startingPointLat: 19.0706,
  startingPointLng: 72.8223,
  distanceKm: 0,
);

final _selectedLocationEvent = widgetbookEditableEvent.copyWith(
  id: 'design-host-selected-location-event',
  meetingPoint: 'Carter Road Amphitheatre',
  meetingLocation: const EventMeetingLocation(
    name: 'Carter Road Amphitheatre',
    address: 'Carter Road, Bandra West',
    placeId: 'design-carter-road',
    latitude: 19.0706,
    longitude: 72.8223,
    notes: 'Meet by the sea-facing steps',
  ),
  startingPointLat: 19.0706,
  startingPointLng: 72.8223,
  locationDetails: 'Meet by the sea-facing steps',
);

@widgetbook.UseCase(
  name: 'Route and section states',
  type: EditHostedEventRouteScreen,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostEditEventRouteAndFormStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'EditHostedEventRouteScreen',
    contractId: 'screen.host.event.edit',
    children: [
      WidgetbookHostStateCard(
        label: 'route loading',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            clubValue: const AsyncLoading<Club?>(),
            eventValue: const AsyncLoading<Event?>(),
            child: EditHostedEventRouteScreen(
              clubId: widgetbookClub.id,
              eventId: widgetbookEditableEvent.id,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'route error',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            clubValue: AsyncError<Club?>(
              StateError('Club fetch failed'),
              StackTrace.empty,
            ),
            child: EditHostedEventRouteScreen(
              clubId: widgetbookClub.id,
              eventId: widgetbookEditableEvent.id,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'route offline',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            clubValue: AsyncError<Club?>(
              obviousOfflineException(),
              StackTrace.empty,
            ),
            child: EditHostedEventRouteScreen(
              clubId: widgetbookClub.id,
              eventId: widgetbookEditableEvent.id,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'event not found',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            eventValue: const AsyncData<Event?>(null),
            child: EditHostedEventRouteScreen(
              clubId: widgetbookClub.id,
              eventId: widgetbookEditableEvent.id,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'unauthorized host',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            uid: HostOperationsFixtures.guestUid,
            child: EditHostedEventRouteScreen(
              clubId: widgetbookClub.id,
              eventId: widgetbookEditableEvent.id,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'editable prefilled form',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: widgetbookClub,
              event: widgetbookEditableEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'schedule locked form',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: widgetbookClub,
              event: widgetbookPrivateEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'cancelled disabled form',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: widgetbookClub,
              event: HostOperationsFixtures.cancelledEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'private access loading',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            privateAccessValue: const AsyncLoading<EventPrivateAccess?>(),
            child: EditHostedEventScreen(
              club: widgetbookClub,
              event: widgetbookPrivateEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'validation errors',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: widgetbookClub,
              event: _validationEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
              formAutovalidateMode: AutovalidateMode.always,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'selected location',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: widgetbookClub,
              event: _selectedLocationEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'text scale 2.0',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookMediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _HostEditEventScope(
              child: EditHostedEventScreen(
                club: widgetbookClub,
                event: widgetbookEditableEvent,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'reduced motion',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookMediaOverride(
            disableAnimations: true,
            child: _HostEditEventScope(
              child: EditHostedEventScreen(
                club: widgetbookClub,
                event: widgetbookEditableEvent,
                loadMapTiles: false,
                now: () => HostOperationsFixtures.now,
              ),
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'dark theme',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            themeMode: ThemeMode.dark,
            child: EditHostedEventScreen(
              club: widgetbookClub,
              event: widgetbookEditableEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Direct screen states',
  type: EditHostedEventScreen,
  path: '[P1 product surfaces]/Host edit event',
)
Widget editHostedEventScreenCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'EditHostedEventScreen',
    contractId: 'screen.host.event.edit.form',
    children: [
      WidgetbookHostStateCard(
        label: 'editable',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: widgetbookClub,
              event: widgetbookEditableEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'policy locked',
        child: WidgetbookHostDeviceFrame(
          child: _HostEditEventScope(
            child: EditHostedEventScreen(
              club: widgetbookClub,
              event: widgetbookPrivateEvent,
              loadMapTiles: false,
              now: () => HostOperationsFixtures.now,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Scope notice states',
  type: EditHostedEventScopeNotice,
  path: '[P1 product surfaces]/Host edit event',
)
Widget editHostedEventScopeNoticeCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'EditHostedEventScopeNotice',
    contractId: 'component.host.event.edit_scope_notice',
    children: [
      WidgetbookHostStateCard(
        label: 'fully editable',
        child: WidgetbookHostDeviceFrame(
          child: EditHostedEventScopeNotice(
            isCancelled: false,
            scheduleLocked: false,
            policyLocked: false,
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'schedule locked',
        child: WidgetbookHostDeviceFrame(
          child: EditHostedEventScopeNotice(
            isCancelled: false,
            scheduleLocked: true,
            policyLocked: true,
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'cancelled',
        child: WidgetbookHostDeviceFrame(
          child: EditHostedEventScopeNotice(
            isCancelled: true,
            scheduleLocked: true,
            policyLocked: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Editable policy states',
  type: EditableHostedEventPolicyCard,
  path: '[P1 product surfaces]/Host edit event',
)
Widget editableHostedEventPolicyCardCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'EditableHostedEventPolicyCard',
    contractId: 'component.host.event.edit_policy_card',
    children: [
      WidgetbookHostStateCard(
        label: 'open capacity',
        child: WidgetbookHostDeviceFrame(
          child: _EditableHostedEventPolicyCardFrame(),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'open capacity with cohort caps',
        child: WidgetbookHostDeviceFrame(
          child: _EditableHostedEventPolicyCardFrame(cohortCapsEnabled: true),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'invite only',
        child: WidgetbookHostDeviceFrame(
          child: _EditableHostedEventPolicyCardFrame(
            admissionPreset: EventAdmissionPreset.inviteOnly,
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'request to join',
        child: WidgetbookHostDeviceFrame(
          child: _EditableHostedEventPolicyCardFrame(
            admissionPreset: EventAdmissionPreset.requestToJoin,
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'balanced singles with demand pricing',
        child: WidgetbookHostDeviceFrame(
          child: _EditableHostedEventPolicyCardFrame(
            admissionPreset: EventAdmissionPreset.balancedSingles,
            dynamicPricingEnabled: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Read-only policy states',
  type: ReadOnlyHostedEventPolicyCard,
  path: '[P1 product surfaces]/Host edit event',
)
Widget readOnlyHostedEventPolicyCardCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'ReadOnlyHostedEventPolicyCard',
    contractId: 'component.host.event.read_only_policy_card',
    children: [
      WidgetbookHostStateCard(
        label: 'locked policy',
        child: WidgetbookHostDeviceFrame(
          child: ReadOnlyHostedEventPolicyCard(event: widgetbookPrivateEvent),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Read-only schedule states',
  type: ReadOnlyHostedEventScheduleCard,
  path: '[P1 product surfaces]/Host edit event',
)
Widget readOnlyHostedEventScheduleCardCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'ReadOnlyHostedEventScheduleCard',
    contractId: 'component.host.event.read_only_schedule_card',
    children: [
      WidgetbookHostStateCard(
        label: 'started event',
        child: WidgetbookHostDeviceFrame(
          child: ReadOnlyHostedEventScheduleCard(event: widgetbookPrivateEvent),
        ),
      ),
    ],
  );
}

class _EditableHostedEventPolicyCardFrame extends StatefulWidget {
  const _EditableHostedEventPolicyCardFrame({
    this.admissionPreset = EventAdmissionPreset.openCapacity,
    this.cohortCapsEnabled = false,
    this.dynamicPricingEnabled = false,
  });

  final EventAdmissionPreset admissionPreset;
  final bool cohortCapsEnabled;
  final bool dynamicPricingEnabled;

  @override
  State<_EditableHostedEventPolicyCardFrame> createState() =>
      _EditableHostedEventPolicyCardFrameState();
}

class _EditableHostedEventPolicyCardFrameState
    extends State<_EditableHostedEventPolicyCardFrame> {
  late final TextEditingController _capacityController;
  late final TextEditingController _priceController;
  late final TextEditingController _minAgeController;
  late final TextEditingController _maxAgeController;
  late final TextEditingController _maxMenController;
  late final TextEditingController _maxWomenController;
  late final TextEditingController _inviteCodeController;
  late final TextEditingController _dynamicPricingStepController;
  late final TextEditingController _dynamicPricingMaxController;
  late EventAdmissionPreset _admissionPreset;
  var _cohortCapsEnabled = false;
  var _dynamicPricingEnabled = false;
  var _cancellationPolicyId = EventCancellationPolicyId.standard;

  @override
  void initState() {
    super.initState();
    _admissionPreset = widget.admissionPreset;
    _cohortCapsEnabled = widget.cohortCapsEnabled;
    _dynamicPricingEnabled = widget.dynamicPricingEnabled;
    _capacityController = TextEditingController(text: '24');
    _priceController = TextEditingController(text: '0');
    _minAgeController = TextEditingController(text: '24');
    _maxAgeController = TextEditingController(text: '38');
    _maxMenController = TextEditingController(text: '12');
    _maxWomenController = TextEditingController(text: '12');
    _inviteCodeController = TextEditingController(text: 'SEAFACE');
    _dynamicPricingStepController = TextEditingController(text: '250');
    _dynamicPricingMaxController = TextEditingController(text: '1500');
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _priceController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxMenController.dispose();
    _maxWomenController.dispose();
    _inviteCodeController.dispose();
    _dynamicPricingStepController.dispose();
    _dynamicPricingMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.content,
      child: EditableHostedEventPolicyCard(
        state: HostEventEditPolicyFieldState.from(
          currencyCode: currencyCodeForCityName(widgetbookClub.location),
          admissionPreset: _admissionPreset,
          cohortCapsEnabled: _cohortCapsEnabled,
          dynamicPricingEnabled: _dynamicPricingEnabled,
          cancellationPolicyId: _cancellationPolicyId,
        ),
        capacityController: _capacityController,
        priceController: _priceController,
        minAgeController: _minAgeController,
        maxAgeController: _maxAgeController,
        maxMenController: _maxMenController,
        maxWomenController: _maxWomenController,
        inviteCodeController: _inviteCodeController,
        dynamicPricingStepController: _dynamicPricingStepController,
        dynamicPricingMaxController: _dynamicPricingMaxController,
        onAdmissionPresetChanged: (preset) =>
            setState(() => _admissionPreset = preset),
        onCohortCapsEnabledChanged: (enabled) =>
            setState(() => _cohortCapsEnabled = enabled),
        onDynamicPricingChanged: (enabled) =>
            setState(() => _dynamicPricingEnabled = enabled),
        onCancellationPolicyChanged: (policyId) =>
            setState(() => _cancellationPolicyId = policyId),
        privateAccessAsync: const CatchAsyncState<EventPrivateAccess?>.data(
          null,
        ),
      ),
    );
  }
}

class _HostEditEventScope extends StatelessWidget {
  const _HostEditEventScope({
    required this.child,
    this.uid,
    this.clubValue,
    this.eventValue,
    this.privateAccessValue,
    this.themeMode = ThemeMode.light,
  });

  final Widget child;
  final String? uid;
  final AsyncValue<Club?>? clubValue;
  final AsyncValue<Event?>? eventValue;
  final AsyncValue<EventPrivateAccess?>? privateAccessValue;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final effectiveUid = uid ?? widgetbookHostUid;
    return WidgetbookAppRoleBoundary(
      role: AppRole.host,
      child: WidgetbookFixtureScope(
        overrides: [
          uidProvider.overrideWithValue(AsyncData<String?>(effectiveUid)),
          fetchClubProvider(
            widgetbookClub.id,
          ).overrideWithValue(clubValue ?? AsyncData<Club?>(widgetbookClub)),
          watchEventProvider(widgetbookEditableEvent.id).overrideWithValue(
            eventValue ?? AsyncData<Event?>(widgetbookEditableEvent),
          ),
          watchEventProvider(
            widgetbookPrivateEvent.id,
          ).overrideWithValue(AsyncData<Event?>(widgetbookPrivateEvent)),
          watchEventPrivateAccessProvider(
            widgetbookPrivateEvent.id,
          ).overrideWithValue(
            privateAccessValue ??
                AsyncData<EventPrivateAccess?>(
                  HostOperationsFixtures.privateAccess,
                ),
          ),
        ],
        child: WidgetbookThemedHostPreview(themeMode: themeMode, child: child),
      ),
    );
  }
}
