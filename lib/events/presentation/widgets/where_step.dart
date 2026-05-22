import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/events/presentation/create_event_form_keys.dart';
import 'package:catch_dating_app/events/presentation/widgets/field_label.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_pin_tile.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';

class WhereStep extends StatelessWidget {
  const WhereStep({
    super.key,
    required this.formKey,
    required this.meetingPointController,
    required this.locationDetailsController,
    required this.startingPoint,
    required this.onMeetingPointChanged,
    required this.onPickLocation,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController meetingPointController;
  final TextEditingController locationDetailsController;
  final LocationCoordinate? startingPoint;
  final ValueChanged<String> onMeetingPointChanged;
  final VoidCallback onPickLocation;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          16,
          CatchSpacing.s5,
          24,
        ),
        children: [
          const FieldLabel('Meeting location'),
          const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
                  Text(
                    field.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          CatchTextField(
            key: CreateEventFormKeys.meetingPoint,
            label: 'Location name',
            controller: meetingPointController,
            hintText: 'e.g. Bandstand Promenade, Bandra',
            helperText: startingPoint == null
                ? 'Pick a map location first. Google Places fills this when available.'
                : 'Edit this if attendees need a clearer name.',
            prefixIcon: const Icon(Icons.location_on_outlined),
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
          const SizedBox(height: 20),
          CatchTextField(
            key: CreateEventFormKeys.locationDetails,
            label: 'Extra directions',
            isOptional: true,
            controller: locationDetailsController,
            hintText: 'e.g. Meet outside the blue gate, third entrance',
            helperText: 'Gate, entrance, floor, or landmark for the group.',
            prefixIcon: const Icon(Icons.info_outline),
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
