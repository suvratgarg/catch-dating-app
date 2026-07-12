import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_photo_picker.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
            CatchFormFieldLabel(
              label: context.l10n.hostsEventDetailsStepLabelActivityType,
              large: true,
            ),
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
                      semanticsLabel: context.l10n
                          .hostsEventDetailsStepVisiblecopySelectLabel(
                            label: activityKind.label,
                          ),
                      onTap: () => onActivityKindChanged(activityKind),
                    ),
                  )
                  .toList(),
            ),
            if (selectedActivityKind == ActivityKind.openActivity) ...[
              gapH20,
              CatchField.input(
                key: CreateEventFormKeys.customActivityLabel,
                title: context.l10n.hostsEventDetailsStepTitleFormatName,
                controller: customActivityLabelController,
                placeholder:
                    context.l10n.hostsEventDetailsStepPlaceholderSalsaNight,
                prefixIcon: Icon(CatchIcons.eventAvailableOutlined),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final normalized = value?.trim() ?? '';
                  if (normalized.isEmpty)
                    return context
                        .l10n
                        .hostsEventDetailsStepVisiblecopyRequired;
                  if (normalized.length < 3)
                    return context
                        .l10n
                        .hostsEventDetailsStepVisiblecopyTooShort;
                  if (normalized.length > 64)
                    return context.l10n.hostsEventDetailsStepVisiblecopyTooLong;
                  return null;
                },
              ),
              gapH20,
              CatchFormFieldLabel(
                label: context.l10n.hostsEventDetailsStepLabelFormatStructure,
                large: true,
              ),
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
                        semanticsLabel: context.l10n
                            .hostsEventDetailsStepVisiblecopySelectLabel(
                              label: model.label,
                            ),
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
                title: context.l10n.hostsEventDetailsStepTitleDistanceKm,
                controller: distanceController,
                placeholder: '10',
                prefixIcon: Icon(CatchIcons.straightenOutlined),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(context.l10n.hostsEventDetailsStepVisiblecopyDD),
                  ),
                ],
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return context
                        .l10n
                        .hostsEventDetailsStepVisiblecopyRequired;
                  final distance = double.tryParse(v.trim());
                  if (distance == null)
                    return context.l10n.hostsEventDetailsStepVisiblecopyInvalid;
                  if (distance <= 0)
                    return context.l10n.hostsEventDetailsStepVisiblecopyMustBe0;
                  return null;
                },
              ),
              gapH20,
              CatchFormFieldLabel(
                label: context.l10n.hostsEventDetailsStepLabelPaceLevel,
                large: true,
              ),
              gapH8,
              FormField<PaceLevel>(
                initialValue: selectedPace,
                validator: (v) => v == null
                    ? context.l10n.hostsEventDetailsStepVisiblecopySelectAPace
                    : null,
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
                              semanticsLabel: context.l10n
                                  .hostsEventDetailsStepVisiblecopySelectLabelPace(
                                    label: p.label,
                                  ),
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
                        padding: CatchInsets.formFieldError,
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
              title: context.l10n.hostsEventDetailsStepTitleDescription,
              isOptional: true,
              controller: descriptionController,
              placeholder: context
                  .l10n
                  .hostsEventDetailsStepPlaceholderWhatShouldAttendeesExpect,
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
