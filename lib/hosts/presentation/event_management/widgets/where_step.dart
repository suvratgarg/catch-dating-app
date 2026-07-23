import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';

class WhereStep extends StatelessWidget {
  const WhereStep({
    super.key,
    required this.formKey,
    this.autovalidateMode = AutovalidateMode.disabled,
    required this.meetingPointController,
    required this.locationDetailsController,
    required this.startingPoint,
    required this.onMeetingPointChanged,
    required this.onPickLocation,
  });

  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  final TextEditingController meetingPointController;
  final TextEditingController locationDetailsController;
  final LocationCoordinate? startingPoint;
  final ValueChanged<String> onMeetingPointChanged;
  final VoidCallback onPickLocation;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: ListView(
        padding: CatchInsets.formStepBody,
        children: [
          CatchSection.fieldRows(
            first: true,
            children: [
              FormField<LocationCoordinate>(
                key: ValueKey(startingPoint),
                validator: (_) => startingPoint == null
                    ? context
                          .l10n
                          .hostsWhereStepVisiblecopyChooseAMeetingLocation
                    : null,
                builder: (field) => CatchField.nav(
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
