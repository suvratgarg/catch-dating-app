import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/runs/presentation/widgets/field_label.dart';
import 'package:catch_dating_app/runs/presentation/widgets/map_pin_tile.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class WhereStep extends StatelessWidget {
  const WhereStep({
    super.key,
    required this.formKey,
    required this.meetingPointController,
    required this.locationDetailsController,
    required this.startingPoint,
    required this.onPickLocation,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController meetingPointController;
  final TextEditingController locationDetailsController;
  final LatLng? startingPoint;
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
          CatchTextField(
            label: 'Meeting point',
            controller: meetingPointController,
            hintText: 'e.g. Bandstand Promenade, Bandra',
            prefixIcon: const Icon(Icons.location_on_outlined),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          const FieldLabel('Pin on map', isOptional: true),
          const SizedBox(height: 8),
          MapPinTile(startingPoint: startingPoint, onTap: onPickLocation),
          const SizedBox(height: 20),
          CatchTextField(
            label: 'Extra directions',
            isOptional: true,
            controller: locationDetailsController,
            hintText: 'e.g. Meet outside the blue gate, third entrance',
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
