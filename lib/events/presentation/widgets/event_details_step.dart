import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/create_event_form_keys.dart';
import 'package:catch_dating_app/events/presentation/widgets/create_event_photo_picker.dart';
import 'package:catch_dating_app/events/presentation/widgets/field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailsStep extends StatelessWidget {
  const EventDetailsStep({
    super.key,
    required this.formKey,
    required this.photoImageBytes,
    required this.onPickPhoto,
    required this.distanceController,
    required this.customActivityLabelController,
    required this.descriptionController,
    required this.selectedActivityKind,
    required this.onActivityKindChanged,
    required this.selectedInteractionModel,
    required this.onInteractionModelChanged,
    required this.selectedPace,
    required this.onPaceChanged,
  });

  final GlobalKey<FormState> formKey;
  final Uint8List? photoImageBytes;
  final VoidCallback? onPickPhoto;
  final TextEditingController distanceController;
  final TextEditingController customActivityLabelController;
  final TextEditingController descriptionController;
  final ActivityKind selectedActivityKind;
  final ValueChanged<ActivityKind> onActivityKindChanged;
  final EventInteractionModel selectedInteractionModel;
  final ValueChanged<EventInteractionModel> onInteractionModelChanged;
  final PaceLevel? selectedPace;
  final ValueChanged<PaceLevel?> onPaceChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          16,
          CatchSpacing.s5,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CreateEventPhotoPicker(
              photoImageBytes: photoImageBytes,
              onTap: onPickPhoto,
            ),
            gapH20,
            const FieldLabel('Activity type'),
            gapH8,
            Wrap(
              key: CreateEventFormKeys.activityType,
              spacing: 8,
              runSpacing: 8,
              children: ActivityKind.eventCreationDefaults
                  .map(
                    (activityKind) => Semantics(
                      button: true,
                      selected: selectedActivityKind == activityKind,
                      label: 'Select ${activityKind.label}',
                      child: GestureDetector(
                        onTap: () => onActivityKindChanged(activityKind),
                        child: VibeTag(
                          label: activityKind.label,
                          active: selectedActivityKind == activityKind,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (selectedActivityKind == ActivityKind.openActivity) ...[
              gapH20,
              CatchTextField(
                key: CreateEventFormKeys.customActivityLabel,
                label: 'Format name',
                controller: customActivityLabelController,
                hintText: 'Salsa night',
                prefixIcon: Icon(CatchIcons.eventAvailableOutlined),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final normalized = value?.trim() ?? '';
                  if (normalized.isEmpty) return 'Required';
                  if (normalized.length < 3) return 'Too short';
                  if (normalized.length > 64) return 'Too long';
                  return null;
                },
              ),
              gapH20,
              const FieldLabel('Format structure'),
              gapH8,
              Wrap(
                key: CreateEventFormKeys.customInteractionModel,
                spacing: 8,
                runSpacing: 8,
                children: EventInteractionModel.values
                    .map(
                      (model) => Semantics(
                        button: true,
                        selected: selectedInteractionModel == model,
                        label: 'Select ${model.label}',
                        child: GestureDetector(
                          key: CreateEventFormKeys.interactionModel(model.name),
                          onTap: () => onInteractionModelChanged(model),
                          child: VibeTag(
                            label: model.label,
                            active: selectedInteractionModel == model,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (selectedActivityKind.isDistanceBased) ...[
              gapH20,
              CatchTextField(
                key: CreateEventFormKeys.distance,
                label: 'Distance (km)',
                controller: distanceController,
                hintText: '10',
                prefixIcon: Icon(CatchIcons.straightenOutlined),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final distance = double.tryParse(v.trim());
                  if (distance == null) return 'Invalid';
                  if (distance <= 0) return 'Must be > 0';
                  return null;
                },
              ),
              gapH20,
              const FieldLabel('Pace level'),
              gapH8,
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
                            (p) => Semantics(
                              button: true,
                              selected: selectedPace == p,
                              label: 'Select ${p.label} pace',
                              child: GestureDetector(
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
                            ),
                          )
                          .toList(),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(
                          field.errorText!,
                          style: CatchTextStyles.supporting(
                            context,
                            color: t.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            gapH20,
            CatchTextField(
              key: CreateEventFormKeys.description,
              label: 'Description',
              isOptional: true,
              controller: descriptionController,
              hintText:
                  'What should attendees expect? Any tips for the route or venue?',
              prefixIcon: Icon(CatchIcons.editNoteOutlined),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
            ),
          ],
        ),
      ),
    );
  }
}
