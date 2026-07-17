import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
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
    final activity = ActivityPalette.resolve(context, selectedActivityKind);
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: ListView(
        padding: CatchInsets.formStepBody,
        children: [
          CatchSectionList(
            gap: 0,
            children: [
              CreateEventPhotoPicker(
                photos: photoPreviews,
                onAddPhotos: onPickPhotos,
                onRemovePhoto: onRemovePhoto,
                onReorderPhoto: onReorderPhoto,
              ),
              CatchSection.fieldRows(
                children: [
                  CatchField.choices<ActivityKind>(
                    key: CreateEventFormKeys.activityType,
                    title: context.l10n.hostsEventDetailsStepLabelActivityType,
                    body: selectedActivityKind.label,
                    values: ActivityKind.eventCreationDefaults,
                    itemLabel: (activityKind) => activityKind.label,
                    selected: <ActivityKind>{selectedActivityKind},
                    onSelectionChanged: (selection) {
                      onActivityKindChanged(selection.single);
                    },
                    initiallyOpen: true,
                    icon: activity.glyph,
                    iconColor: activity.accent,
                  ),
                  if (selectedActivityKind == ActivityKind.openActivity) ...[
                    CatchField.input(
                      key: CreateEventFormKeys.customActivityLabel,
                      title: context.l10n.hostsEventDetailsStepTitleFormatName,
                      controller: customActivityLabelController,
                      inputHint: context
                          .l10n
                          .hostsEventDetailsStepPlaceholderSalsaNight,
                      icon: CatchIcons.eventAvailableOutlined,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final normalized = value?.trim() ?? '';
                        if (normalized.isEmpty) {
                          return context
                              .l10n
                              .hostsEventDetailsStepVisiblecopyRequired;
                        }
                        if (normalized.length < 3) {
                          return context
                              .l10n
                              .hostsEventDetailsStepVisiblecopyTooShort;
                        }
                        if (normalized.length > 64) {
                          return context
                              .l10n
                              .hostsEventDetailsStepVisiblecopyTooLong;
                        }
                        return null;
                      },
                    ),
                    CatchField.choices<EventInteractionModel>(
                      key: CreateEventFormKeys.customInteractionModel,
                      title: context
                          .l10n
                          .hostsEventDetailsStepLabelFormatStructure,
                      body: selectedInteractionModel.label,
                      values: EventInteractionModel.values,
                      itemLabel: (model) => model.label,
                      selected: <EventInteractionModel>{
                        selectedInteractionModel,
                      },
                      onSelectionChanged: (selection) {
                        onInteractionModelChanged(selection.single);
                      },
                      initiallyOpen: true,
                      icon: CatchIcons.tuneRounded,
                      iconColor: activity.accent,
                    ),
                  ],
                  if (selectedActivityKind.isDistanceBased) ...[
                    CatchField.input(
                      key: CreateEventFormKeys.distance,
                      title: context.l10n.hostsEventDetailsStepTitleDistanceKm,
                      controller: distanceController,
                      inputHint: '10',
                      icon: CatchIcons.straightenOutlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(
                            context.l10n.hostsEventDetailsStepVisiblecopyDD,
                          ),
                        ),
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return context
                              .l10n
                              .hostsEventDetailsStepVisiblecopyRequired;
                        }
                        final distance = double.tryParse(value.trim());
                        if (distance == null) {
                          return context
                              .l10n
                              .hostsEventDetailsStepVisiblecopyInvalid;
                        }
                        if (distance <= 0) {
                          return context
                              .l10n
                              .hostsEventDetailsStepVisiblecopyMustBe0;
                        }
                        return null;
                      },
                    ),
                    FormField<PaceLevel>(
                      initialValue: selectedPace,
                      validator: (value) => value == null
                          ? context
                                .l10n
                                .hostsEventDetailsStepVisiblecopySelectAPace
                          : null,
                      builder: (field) => CatchField.choices<PaceLevel>(
                        title: context.l10n.hostsEventDetailsStepLabelPaceLevel,
                        body: selectedPace?.label,
                        values: PaceLevel.values,
                        itemLabel: (pace) => pace.label,
                        selected: selectedPace == null
                            ? const <PaceLevel>{}
                            : <PaceLevel>{selectedPace!},
                        onSelectionChanged: (selection) {
                          final next = selection.isEmpty
                              ? null
                              : selection.single;
                          onPaceChanged(next);
                          field.didChange(next);
                        },
                        allowEmptySelection: true,
                        initiallyOpen: true,
                        icon: CatchIcons.speedOutlined,
                        iconColor: activity.accent,
                        error: field.errorText,
                      ),
                    ),
                  ],
                  CatchField.input(
                    key: CreateEventFormKeys.description,
                    title: context.l10n.hostsEventDetailsStepTitleDescription,
                    isOptional: true,
                    controller: descriptionController,
                    inputHint: context
                        .l10n
                        .hostsEventDetailsStepPlaceholderWhatShouldAttendeesExpect,
                    icon: CatchIcons.editNoteOutlined,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
