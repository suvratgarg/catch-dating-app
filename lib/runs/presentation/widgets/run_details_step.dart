import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RunDetailsStep extends StatelessWidget {
  const RunDetailsStep({
    super.key,
    required this.formKey,
    required this.distanceController,
    required this.capacityController,
    required this.priceController,
    required this.descriptionController,
    required this.selectedPace,
    required this.onPaceChanged,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController distanceController;
  final TextEditingController capacityController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final PaceLevel? selectedPace;
  final ValueChanged<PaceLevel?> onPaceChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            CatchSpacing.screenH, 16, CatchSpacing.screenH, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Distance (km)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: distanceController,
                      decoration: InputDecoration(
                        hintText: '10',
                        prefixIcon: Icon(Icons.straighten_outlined,
                            color: t.ink2),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel('Max runners'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: capacityController,
                      decoration: InputDecoration(
                        hintText: '20',
                        prefixIcon:
                            Icon(Icons.people_outline, color: t.ink2),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = int.tryParse(v.trim());
                        if (n == null || n < 1) return 'Min 1';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const FieldLabel('Price (₹) — enter 0 for free'),
          const SizedBox(height: 8),
          TextFormField(
            controller: priceController,
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon:
                  Icon(Icons.currency_rupee_outlined, color: t.ink2),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Required';
              if (double.tryParse(v.trim()) == null) return 'Invalid';
              return null;
            },
          ),
          const SizedBox(height: 20),
          const FieldLabel('Pace level'),
          const SizedBox(height: 8),
          FormField<PaceLevel>(
            initialValue: selectedPace,
            validator: (v) => v == null ? 'Select a pace' : null,
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: PaceLevel.values
                      .map(
                        (p) => GestureDetector(
                          onTap: () {
                            final next = selectedPace == p ? null : p;
                            onPaceChanged(next);
                            field.didChange(next);
                          },
                          child: VibeTag(
                            label: p.label,
                            active: selectedPace == p,
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(field.errorText!,
                        style: TextStyle(fontSize: 12, color: t.primary)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const FieldLabel('Description (optional)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText:
                  'What should runners expect? Any tips for the route?',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.edit_note_outlined, color: t.ink2),
            ),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
          ),
        ],
      ),
    );
  }
}
