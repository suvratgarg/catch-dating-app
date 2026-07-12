import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/events/shared/map_pin_tile.dart';
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
          CatchFormFieldLabel(
            label: context.l10n.hostsWhereStepLabelMeetingLocation,
            large: true,
          ),
          gapH8,
          FormField<LocationCoordinate>(
            key: ValueKey(startingPoint),
            validator: (_) => startingPoint == null
                ? context.l10n.hostsWhereStepVisiblecopyChooseAMeetingLocation
                : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MapPinTile(
                  key: CreateEventFormKeys.mapPicker,
                  startingPoint: startingPoint,
                  selectedLabel: _trimToNull(meetingPointController.text),
                  onTap: onPickLocation,
                ),
                if (field.hasError) ...[
                  gapH8,
                  Text(
                    field.errorText!,
                    style: CatchTextStyles.supporting(
                      context,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          gapH16,
          CatchField.input(
            key: CreateEventFormKeys.meetingPoint,
            title: context.l10n.hostsWhereStepTitleLocationName,
            controller: meetingPointController,
            placeholder:
                context.l10n.hostsWhereStepPlaceholderEGBandstandPromenade,
            helperText: startingPoint == null
                ? context.l10n.hostsWhereStepHelpertextPickAMapLocation
                : context.l10n.hostsWhereStepHelpertextEditThisIfAttendees,
            prefixIcon: Icon(CatchIcons.locationOnOutlined),
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
          gapH20,
          CatchField.input(
            key: CreateEventFormKeys.locationDetails,
            title: context.l10n.hostsWhereStepTitleExtraDirections,
            isOptional: true,
            controller: locationDetailsController,
            placeholder: context.l10n.hostsWhereStepPlaceholderEGMeetOutside,
            helperText:
                context.l10n.hostsWhereStepHelpertextGateEntranceFloorOr,
            prefixIcon: Icon(CatchIcons.infoOutline),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
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
