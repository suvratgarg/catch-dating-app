import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/events/data/organizer_event_venue_repository.dart';
import 'package:catch_dating_app/events/domain/event_meeting_location.dart';
import 'package:catch_dating_app/events/domain/organizer_event_venue.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhereStep extends ConsumerWidget {
  const WhereStep({
    super.key,
    required this.formKey,
    required this.organizerId,
    this.autovalidateMode = AutovalidateMode.disabled,
    required this.meetingPointController,
    required this.locationDetailsController,
    required this.startingPoint,
    required this.onMeetingPointChanged,
    required this.onLocationDetailsChanged,
    required this.onPickLocation,
    required this.currentMeetingLocation,
    required this.selectedVenueId,
    required this.onVenueSelected,
    required this.currentCapacity,
  });

  final GlobalKey<FormState> formKey;
  final String organizerId;
  final AutovalidateMode autovalidateMode;
  final TextEditingController meetingPointController;
  final TextEditingController locationDetailsController;
  final LocationCoordinate? startingPoint;
  final ValueChanged<String> onMeetingPointChanged;
  final ValueChanged<String> onLocationDetailsChanged;
  final VoidCallback onPickLocation;
  final EventMeetingLocation? currentMeetingLocation;
  final String? selectedVenueId;
  final ValueChanged<OrganizerEventVenue> onVenueSelected;
  final int? currentCapacity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venuesAsync = ref.watch(
      watchOrganizerEventVenuesProvider(organizerId),
    );
    final saveMutation = ref.watch(CreateEventController.saveVenueMutation);

    Future<void> saveCurrentPlace() async {
      final location = currentMeetingLocation;
      if (location == null) return;
      try {
        final saved = await CreateEventController.saveVenueMutation.run(
          ref,
          (tx) => tx
              .get(createEventControllerProvider.notifier)
              .saveVenue(
                organizerId: organizerId,
                venueId: selectedVenueId,
                meetingLocation: location,
                defaultEventCapacity: currentCapacity,
              ),
        );
        onVenueSelected(saved);
      } catch (_) {
        // The mutation-owned error banner is the user-facing failure surface.
      }
    }

    Widget savedPlacesSection({
      required List<OrganizerEventVenue> venues,
      Object? loadError,
    }) {
      return CatchSection.fieldRows(
        first: true,
        title: context.l10n.hostsWhereStepSavedPlacesTitle,
        footer: Text(
          context.l10n.hostsWhereStepSavedPlacesSubtitle,
          style: CatchTextStyles.supporting(context),
        ),
        children: [
          if (loadError != null)
            CatchErrorBanner.fromError(
              loadError,
              context: AppErrorContext.event,
            ),
          for (final venue in venues)
            CatchField.nav(
              title: venue.label,
              body: venue.meetingLocation.address ?? venue.meetingLocation.name,
              valueText: selectedVenueId == venue.venueId
                  ? context.l10n.hostsWhereStepSavedPlaceSelected
                  : null,
              showChevron: false,
              icon: CatchIcons.locationOnOutlined,
              onTap: () => onVenueSelected(venue),
            ),
          CatchField.add(
            title: selectedVenueId == null
                ? context.l10n.hostsWhereStepSaveCurrentPlace
                : context.l10n.hostsWhereStepUpdateSavedPlace,
            onTap: currentMeetingLocation == null || saveMutation.isPending
                ? null
                : saveCurrentPlace,
          ),
          if (saveMutation.hasError)
            CatchErrorBanner.fromError(
              (saveMutation as MutationError).error,
              context: AppErrorContext.event,
            ),
        ],
      );
    }

    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: ListView(
        padding: CatchInsets.formStepBodyWithBottomActions,
        children: [
          CatchAsyncValueView<List<OrganizerEventVenue>>(
            value: venuesAsync,
            errorContext: AppErrorContext.event,
            onRetry: () =>
                ref.invalidate(watchOrganizerEventVenuesProvider(organizerId)),
            loadingBuilder: (_) => savedPlacesSection(venues: const []),
            errorBuilder: (_, error, _) =>
                savedPlacesSection(venues: const [], loadError: error),
            builder: (_, venues) => savedPlacesSection(venues: venues),
          ),
          CatchFieldLanes.divided(
            children: [
              FormField<LocationCoordinate>(
                key: ValueKey(startingPoint),
                validator: (_) => startingPoint == null
                    ? context
                          .l10n
                          .hostsWhereStepVisiblecopyChooseAMeetingLocation
                    : null,
                builder: (field) => CatchFieldLanes.single(
                  child: CatchField.nav(
                    key: CreateEventFormKeys.mapPicker,
                    title: context.l10n.hostsWhereStepLabelMeetingLocation,
                    body: startingPoint == null
                        ? context.l10n.eventsMapPinTileTitleChooseOnMap
                        : _trimToNull(meetingPointController.text) ??
                              context.l10n.eventsMapPinTileTitlePinnedLocation,
                    icon: startingPoint == null
                        ? CatchIcons.mapOutlined
                        : CatchIcons.editLocationAltOutlined,
                    error: field.errorText,
                    onTap: onPickLocation,
                  ),
                ),
              ),
              CatchField.input(
                key: CreateEventFormKeys.meetingPoint,
                title: context.l10n.hostsWhereStepTitleLocationName,
                contract: CatchContractConstraints
                    .createEventCallablePayloadMeetingPoint,
                controller: meetingPointController,
                inputHint:
                    context.l10n.hostsWhereStepPlaceholderEGBandstandPromenade,
                helperText: startingPoint == null
                    ? context.l10n.hostsWhereStepHelpertextPickAMapLocation
                    : context.l10n.hostsWhereStepHelpertextEditThisIfAttendees,
                icon: CatchIcons.locationOnOutlined,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onChanged: onMeetingPointChanged,
                validator: (value) {
                  if (startingPoint == null) return null;
                  return value == null || value.trim().isEmpty
                      ? context.l10n.hostsWhereStepVisiblecopyAddALocationName
                      : null;
                },
              ),
              CatchField.input(
                key: CreateEventFormKeys.locationDetails,
                title: context.l10n.hostsWhereStepTitleExtraDirections,
                contract: CatchContractConstraints
                    .createEventCallablePayloadLocationDetails,
                isOptional: true,
                controller: locationDetailsController,
                inputHint: context.l10n.hostsWhereStepPlaceholderEGMeetOutside,
                helperText:
                    context.l10n.hostsWhereStepHelpertextGateEntranceFloorOr,
                icon: CatchIcons.infoOutline,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onChanged: onLocationDetailsChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String? _trimToNull(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return trimmed;
}
