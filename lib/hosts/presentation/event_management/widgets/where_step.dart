import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_pin_tile.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
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
          const CatchFormFieldLabel(label: 'Meeting location', large: true),
          gapH8,
          FormField<LocationCoordinate>(
            key: ValueKey(startingPoint),
            validator: (_) =>
                startingPoint == null ? 'Choose a meeting location' : null,
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
          CatchField(
            key: CreateEventFormKeys.meetingPoint,
            title: 'Location name',
            controller: meetingPointController,
            placeholder: 'e.g. Bandstand Promenade, Bandra',
            helperText: startingPoint == null
                ? 'Pick a map location first. Google Places fills this when available.'
                : 'Edit this if attendees need a clearer name.',
            prefixIcon: Icon(CatchIcons.locationOnOutlined),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onChanged: onMeetingPointChanged,
            validator: (value) {
              if (startingPoint == null) return null;
              return value == null || value.trim().isEmpty
                  ? 'Add a location name'
                  : null;
            },
          ),
          gapH20,
          CatchField(
            key: CreateEventFormKeys.locationDetails,
            title: 'Extra directions',
            isOptional: true,
            controller: locationDetailsController,
            placeholder: 'e.g. Meet outside the blue gate, third entrance',
            helperText: 'Gate, entrance, floor, or landmark for the group.',
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
