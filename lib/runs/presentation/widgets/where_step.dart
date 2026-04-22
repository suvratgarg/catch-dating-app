import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
    final t = CatchTokens.of(context);
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            CatchSpacing.screenH, 16, CatchSpacing.screenH, 24),
        children: [
          const FieldLabel('Meeting point'),
          const SizedBox(height: 8),
          TextFormField(
            controller: meetingPointController,
            decoration: InputDecoration(
              hintText: 'e.g. Bandstand Promenade, Bandra',
              prefixIcon: Icon(Icons.location_on_outlined, color: t.ink2),
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          const FieldLabel('Pin on map (optional)'),
          const SizedBox(height: 8),
          MapPinTile(
            startingPoint: startingPoint,
            onTap: onPickLocation,
          ),
          const SizedBox(height: 20),
          const FieldLabel('Extra directions (optional)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: locationDetailsController,
            decoration: InputDecoration(
              hintText: 'e.g. Meet outside the blue gate, third entrance',
              prefixIcon: Icon(Icons.info_outline, color: t.ink2),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
