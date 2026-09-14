import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/events/data/organizer_event_venue_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_itinerary.dart';
import 'package:catch_dating_app/events/domain/organizer_event_venue.dart';
import 'package:catch_dating_app/events/domain/route_event_plan.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_guests_section.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_photo_picker.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/event_details_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/when_step.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/where_step.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/widgetbook_harness.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Photo picker states',
  type: CreateEventPhotoPicker,
  path: '[P1 product surfaces]/Host create event',
)
Widget createEventPhotoPickerCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'CreateEventPhotoPicker',
    contractId: 'component.host.event.photo_picker',
    children: [
      WidgetbookHostStateCard(
        label: 'empty',
        child: WidgetbookHostDeviceFrame(
          child: CreateEventPhotoPicker(
            photos: const [],
            organizerName: 'Sea Face Runs',
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'filled',
        child: WidgetbookHostDeviceFrame(
          child: CreateEventPhotoPicker(
            photos: widgetbookOrderedPhotoPreviews('event-photo', 3),
            organizerName: 'Sea Face Runs',
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: '24-photo gallery',
        child: WidgetbookHostDeviceFrame(
          child: CreateEventPhotoPicker(
            photos: widgetbookOrderedPhotoPreviews('large-event-photo', 24),
            organizerName: 'Sea Face Runs',
            onAddPhotos: () {},
            onRemovePhoto: (_) {},
            onReorderPhoto: (_, _) {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Draft sheet states',
  type: DraftPickerSheet,
  path: '[P1 product surfaces]/Host create event',
)
Widget draftPickerSheetCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'DraftPickerSheet',
    contractId: 'component.host.event.draft_picker_sheet',
    children: [
      WidgetbookHostStateCard(
        label: 'with drafts',
        child: WidgetbookHostDeviceFrame(
          child: DraftPickerSheet(
            drafts: [HostOperationsFixtures.eventDraft],
            onSelectDraft: (_) {},
            onStartFresh: () {},
            onDeleteDraft: (_) async {},
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'empty',
        child: WidgetbookHostDeviceFrame(
          child: DraftPickerSheet(
            drafts: const [],
            onSelectDraft: (_) {},
            onStartFresh: () {},
            onDeleteDraft: (_) async {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Draft card states',
  type: DraftCard,
  path: '[P1 product surfaces]/Host create event',
)
Widget draftCardCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'DraftCard',
    contractId: 'component.host.event.draft_card',
    children: [
      WidgetbookHostStateCard(
        label: 'saved draft',
        child: DraftCard(
          draft: HostOperationsFixtures.eventDraft,
          isDeleting: false,
          onSelect: () {},
          onDelete: () {},
        ),
      ),
      WidgetbookHostStateCard(
        label: 'delete pending',
        child: DraftCard(
          draft: HostOperationsFixtures.eventDraft,
          isDeleting: true,
          onSelect: () {},
          onDelete: () {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Details step states',
  type: EventDetailsStep,
  path: '[P1 product surfaces]/Host create event',
)
Widget eventDetailsStepCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'EventDetailsStep',
    contractId: 'component.host.event.details_step',
    children: [
      WidgetbookHostStateCard(
        label: 'run event',
        child: WidgetbookHostDeviceFrame(child: _EventDetailsStepFrame()),
      ),
      WidgetbookHostStateCard(
        label: 'custom activity',
        child: WidgetbookHostDeviceFrame(
          child: _EventDetailsStepFrame(customActivity: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Covered by meeting-location step',
  type: HostSavedPlacesSection,
  path: '[P1 product surfaces]/Host operations/Composed sections',
)
Widget savedPlacesSectionCatalogStates(BuildContext context) =>
    whereStepCatalogStates(context);

@widgetbook.UseCase(
  name: 'Guest import states',
  type: CreateEventGuestsSection,
  path: '[P1 product surfaces]/Host create event',
)
Widget createEventGuestsSectionCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'CreateEventGuestsSection',
    contractId: 'section.host.event_create_guests',
    children: [
      WidgetbookHostStateCard(
        label: 'import later',
        child: WidgetbookHostDeviceFrame(child: _CreateEventGuestsFrame()),
      ),
      WidgetbookHostStateCard(
        label: 'attached roster',
        child: WidgetbookHostDeviceFrame(
          child: _CreateEventGuestsFrame(attached: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Where step states',
  type: WhereStep,
  path: '[P1 product surfaces]/Host create event',
)
Widget whereStepCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'WhereStep',
    contractId: 'component.host.event.where_step',
    children: [
      WidgetbookHostStateCard(
        label: 'selected location',
        child: WidgetbookHostDeviceFrame(child: _WhereStepFrame()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'When step states',
  type: WhenStep,
  path: '[P1 product surfaces]/Host create event',
)
Widget whenStepCatalogStates(BuildContext context) {
  return const WidgetbookHostCatalog(
    title: 'WhenStep',
    contractId: 'component.host.event.when_step',
    children: [
      WidgetbookHostStateCard(
        label: 'scheduled',
        child: WidgetbookHostDeviceFrame(child: _WhenStepFrame()),
      ),
      WidgetbookHostStateCard(
        label: 'schedule error',
        child: WidgetbookHostDeviceFrame(
          child: _WhenStepFrame(scheduleError: true),
        ),
      ),
    ],
  );
}

class _CreateEventGuestsFrame extends StatefulWidget {
  const _CreateEventGuestsFrame({this.attached = false});
  final bool attached;

  @override
  State<_CreateEventGuestsFrame> createState() =>
      _CreateEventGuestsFrameState();
}

class _CreateEventGuestsFrameState extends State<_CreateEventGuestsFrame> {
  final _url = TextEditingController();
  final _id = TextEditingController();
  var _provider = ExternalBookingProvider.generic;
  var _walkIns = EventRuntimeWalkInPolicy.hostApproval;

  @override
  void dispose() {
    _url.dispose();
    _id.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: CreateEventGuestsSection(
      externalEventUrlController: _url,
      externalEventIdController: _id,
      externalBookingProvider: _provider,
      runtimeWalkInPolicy: _walkIns,
      onExternalBookingProviderChanged: (value) =>
          setState(() => _provider = value),
      onRuntimeWalkInPolicyChanged: (value) => setState(() => _walkIns = value),
      rosterFileName: widget.attached ? 'dinner-guests.csv' : null,
      rosterReadyCount: widget.attached ? 24 : null,
      rosterAttached: widget.attached,
      onPickRoster: () {},
    ),
  );
}

class _EventDetailsStepFrame extends StatefulWidget {
  const _EventDetailsStepFrame({this.customActivity = false});

  final bool customActivity;

  @override
  State<_EventDetailsStepFrame> createState() => _EventDetailsStepFrameState();
}

class _EventDetailsStepFrameState extends State<_EventDetailsStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _distanceController;
  late final TextEditingController _customActivityLabelController;
  late final TextEditingController _descriptionController;
  late ActivityKind _activityKind;
  late EventInteractionModel _interactionModel;
  RouteEventPlan? _routePlan;
  List<EventItineraryItem> _itinerary = const [];
  PaceLevel? _pace = PaceLevel.easy;

  @override
  void initState() {
    super.initState();
    _activityKind = widget.customActivity
        ? ActivityKind.openActivity
        : ActivityKind.socialRun;
    _interactionModel = _activityKind.defaultInteractionModel;
    _routePlan = RouteEventPlan.defaultForActivity(_activityKind);
    _nameController = TextEditingController(text: 'Sunset Social Run');
    _distanceController = TextEditingController(text: '5');
    _customActivityLabelController = TextEditingController(text: 'Salsa mixer');
    _descriptionController = TextEditingController(
      text: 'A relaxed format with clear arrival cues and a hosted welcome.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _distanceController.dispose();
    _customActivityLabelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EventDetailsStep(
      formKey: _formKey,
      photoPreviews: widgetbookOrderedPhotoPreviews('event-details-photo', 2),
      onPickPhotos: () {},
      onRemovePhoto: (_) {},
      onReorderPhoto: (_, _) {},
      organizerName: 'Sea Face Runs',
      nameController: _nameController,
      distanceController: _distanceController,
      customActivityLabelController: _customActivityLabelController,
      descriptionController: _descriptionController,
      selectedActivityKind: _activityKind,
      onActivityKindChanged: (activityKind) => setState(() {
        _activityKind = activityKind;
        _interactionModel = activityKind.defaultInteractionModel;
        _routePlan = RouteEventPlan.defaultForActivity(activityKind);
      }),
      selectedInteractionModel: _interactionModel,
      onInteractionModelChanged: (model) =>
          setState(() => _interactionModel = model),
      selectedPace: _pace,
      onPaceChanged: (pace) => setState(() => _pace = pace),
      routePlan: _routePlan,
      onRoutePlanChanged: (plan) => setState(() => _routePlan = plan),
      itinerary: _itinerary,
      onItineraryChanged: (itinerary) => setState(() => _itinerary = itinerary),
      routeInitialCenter: const LocationCoordinate(19.0706, 72.8223),
      loadMapTiles: false,
    );
  }
}

class _WhereStepFrame extends StatefulWidget {
  const _WhereStepFrame();

  @override
  State<_WhereStepFrame> createState() => _WhereStepFrameState();
}

class _WhereStepFrameState extends State<_WhereStepFrame> {
  static const _organizerId = 'design-host-organizer';
  static const _venue = OrganizerEventVenue(
    organizerId: _organizerId,
    venueId: 'carter-road-amphitheatre',
    label: 'Carter Road Amphitheatre',
    meetingLocation: EventMeetingLocation(
      name: 'Carter Road Amphitheatre',
      address: 'Carter Road, Bandra West',
      placeId: 'design-carter-road',
      latitude: 19.0706,
      longitude: 72.8223,
      notes: 'Meet by the sea-facing steps.',
    ),
    defaultEventCapacity: 40,
    status: OrganizerEventVenueStatus.active,
  );

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _meetingPointController;
  late final TextEditingController _locationDetailsController;
  EventMeetingLocation _meetingLocation = _venue.meetingLocation;
  String? _selectedVenueId = _venue.venueId;

  @override
  void initState() {
    super.initState();
    _meetingPointController = TextEditingController(
      text: 'Carter Road Amphitheatre',
    );
    _locationDetailsController = TextEditingController(
      text: 'Meet by the sea-facing steps.',
    );
  }

  @override
  void dispose() {
    _meetingPointController.dispose();
    _locationDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WidgetbookFixtureScope(
      overrides: [
        watchOrganizerEventVenuesProvider(
          _organizerId,
        ).overrideWith((ref) => Stream.value(const [_venue])),
      ],
      child: WhereStep(
        formKey: _formKey,
        organizerId: _organizerId,
        meetingPointController: _meetingPointController,
        locationDetailsController: _locationDetailsController,
        startingPoint: const LocationCoordinate(19.0706, 72.8223),
        onMeetingPointChanged: (name) => setState(
          () => _meetingLocation = _meetingLocation.copyWith(name: name),
        ),
        onLocationDetailsChanged: (notes) => setState(
          () => _meetingLocation = _meetingLocation.copyWith(notes: notes),
        ),
        onPickLocation: () {},
        currentMeetingLocation: _meetingLocation,
        selectedVenueId: _selectedVenueId,
        onVenueSelected: (venue) => setState(() {
          _selectedVenueId = venue.venueId;
          _meetingLocation = venue.meetingLocation;
          _meetingPointController.text = venue.meetingLocation.name;
          _locationDetailsController.text = venue.meetingLocation.notes ?? '';
        }),
        currentCapacity: 40,
      ),
    );
  }
}

class _WhenStepFrame extends StatefulWidget {
  const _WhenStepFrame({this.scheduleError = false});

  final bool scheduleError;

  @override
  State<_WhenStepFrame> createState() => _WhenStepFrameState();
}

class _WhenStepFrameState extends State<_WhenStepFrame> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _startTimeController;
  var _durationMinutes = 75;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: '02/07/2030');
    _startTimeController = TextEditingController(text: '6:30 PM');
  }

  @override
  void dispose() {
    _dateController.dispose();
    _startTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WhenStep(
      formKey: _formKey,
      dateController: _dateController,
      startTimeController: _startTimeController,
      durationMinutes: _durationMinutes,
      onPickDate: () {},
      onPickTime: () {},
      onDecreaseDuration: _durationMinutes > 30
          ? () => setState(() => _durationMinutes -= 15)
          : null,
      onIncreaseDuration: _durationMinutes < 240
          ? () => setState(() => _durationMinutes += 15)
          : null,
      formatDuration: EventFormatters.durationMinutes,
      scheduleErrorText: widget.scheduleError
          ? 'Choose a start time later than now'
          : null,
    );
  }
}
