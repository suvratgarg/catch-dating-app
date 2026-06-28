import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_photo_picker.dart';
import 'package:catch_dating_app/image_uploads/presentation/widgets/ordered_photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailsStep extends StatelessWidget {
  const EventDetailsStep({
    super.key,
    required this.formKey,
    this.autovalidateMode = AutovalidateMode.disabled,
    required this.photoPreviews,
    required this.onPickPhotos,
    required this.onRemovePhoto,
    required this.onReorderPhoto,
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
  final AutovalidateMode autovalidateMode;
  final List<OrderedPhotoPreview> photoPreviews;
  final VoidCallback? onPickPhotos;
  final ValueChanged<int>? onRemovePhoto;
  final void Function(int fromIndex, int toIndex)? onReorderPhoto;
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
    final activityAccent = ActivityPalette.resolve(
      context,
      selectedActivityKind,
    ).accent;
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: SingleChildScrollView(
        padding: CatchInsets.formStepBody,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CreateEventPhotoPicker(
              photos: photoPreviews,
              onAddPhotos: onPickPhotos,
              onRemovePhoto: onRemovePhoto,
              onReorderPhoto: onReorderPhoto,
            ),
            gapH20,
            const CatchFormFieldLabel(label: 'Activity type', large: true),
            gapH8,
            Wrap(
              key: CreateEventFormKeys.activityType,
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: ActivityKind.eventCreationDefaults
                  .map(
                    (activityKind) => CatchSelectChip(
                      label: activityKind.label,
                      active: selectedActivityKind == activityKind,
                      accentColor: ActivityPalette.resolve(
                        context,
                        activityKind,
                      ).accent,
                      semanticsLabel: 'Select ${activityKind.label}',
                      onTap: () => onActivityKindChanged(activityKind),
                    ),
                  )
                  .toList(),
            ),
            if (selectedActivityKind == ActivityKind.openActivity) ...[
              gapH20,
              CatchField.input(
                key: CreateEventFormKeys.customActivityLabel,
                title: 'Format name',
                controller: customActivityLabelController,
                placeholder: 'Salsa night',
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
              const CatchFormFieldLabel(label: 'Format structure', large: true),
              gapH8,
              Wrap(
                key: CreateEventFormKeys.customInteractionModel,
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: EventInteractionModel.values
                    .map(
                      (model) => CatchSelectChip(
                        key: CreateEventFormKeys.interactionModel(model.name),
                        label: model.label,
                        active: selectedInteractionModel == model,
                        accentColor: activityAccent,
                        semanticsLabel: 'Select ${model.label}',
                        onTap: () => onInteractionModelChanged(model),
                      ),
                    )
                    .toList(),
              ),
            ],
            if (selectedActivityKind.isDistanceBased) ...[
              gapH20,
              CatchField.input(
                key: CreateEventFormKeys.distance,
                title: 'Distance (km)',
                controller: distanceController,
                placeholder: '10',
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
              const CatchFormFieldLabel(label: 'Pace level', large: true),
              gapH8,
              FormField<PaceLevel>(
                initialValue: selectedPace,
                validator: (v) => v == null ? 'Select a pace' : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: CatchSpacing.s2,
                      runSpacing: CatchSpacing.s2,
                      children: PaceLevel.values
                          .map(
                            (p) => CatchSelectChip(
                              label: p.label,
                              active: selectedPace == p,
                              accentColor: activityAccent,
                              semanticsLabel: 'Select ${p.label} pace',
                              onTap: () {
                                final next = selectedPace == p ? null : p;
                                onPaceChanged(next);
                                field.didChange(next);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: CatchSpacing.micro6,
                          left: CatchSpacing.s1,
                        ),
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
            CatchField.input(
              key: CreateEventFormKeys.description,
              title: 'Description',
              isOptional: true,
              controller: descriptionController,
              placeholder:
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
