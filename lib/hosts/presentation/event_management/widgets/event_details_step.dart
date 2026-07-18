import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_field_accordion.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_photo_picker.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventDetailsStep extends StatefulWidget {
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
  State<EventDetailsStep> createState() => _EventDetailsStepState();
}

class _EventDetailsStepState extends State<EventDetailsStep> {
  static const _activityField = 'activity';
  static const _interactionField = 'interaction';
  static const _paceField = 'pace';

  final CatchFieldAccordion _accordion = CatchFieldAccordion();

  @override
  void initState() {
    super.initState();
    _accordion.addListener(_handleAccordionChanged);
  }

  @override
  void dispose() {
    _accordion
      ..removeListener(_handleAccordionChanged)
      ..dispose();
    super.dispose();
  }

  void _handleAccordionChanged() {
    if (mounted) setState(() {});
  }

  void _setOpen(String field, bool open) {
    if (open && !_accordion.isExpanded(field)) {
      _accordion.toggle(field);
    } else if (!open && _accordion.isExpanded(field)) {
      _accordion.collapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(
      context,
      widget.selectedActivityKind,
    );
    return Form(
      key: widget.formKey,
      autovalidateMode: widget.autovalidateMode,
      child: ListView(
        padding: CatchInsets.formStepBody,
        children: [
          CatchSectionList(
            gap: 0,
            children: [
              CreateEventPhotoPicker(
                photos: widget.photoPreviews,
                onAddPhotos: widget.onPickPhotos,
                onRemovePhoto: widget.onRemovePhoto,
                onReorderPhoto: widget.onReorderPhoto,
              ),
              CatchSection.fieldRows(
                children: [
                  CatchField.choices<ActivityKind>(
                    key: CreateEventFormKeys.activityType,
                    title: context.l10n.hostsEventDetailsStepLabelActivityType,
                    body: widget.selectedActivityKind.label,
                    values: ActivityKind.eventCreationDefaults,
                    itemLabel: (activityKind) => activityKind.label,
                    itemAccent: (activityKind) =>
                        ActivityPalette.resolve(context, activityKind).accent,
                    selected: <ActivityKind>{widget.selectedActivityKind},
                    onSelectionChanged: (selection) {
                      widget.onActivityKindChanged(selection.single);
                    },
                    open: _accordion.isExpanded(_activityField),
                    onOpenChanged: (open) => _setOpen(_activityField, open),
                    icon: activity.glyph,
                    iconColor: activity.accent,
                  ),
                  if (widget.selectedActivityKind ==
                      ActivityKind.openActivity) ...[
                    CatchField.input(
                      key: CreateEventFormKeys.customActivityLabel,
                      title: context.l10n.hostsEventDetailsStepTitleFormatName,
                      controller: widget.customActivityLabelController,
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
                      body: widget.selectedInteractionModel.label,
                      values: EventInteractionModel.values,
                      itemLabel: (model) => model.label,
                      itemAccent: (_) => activity.accent,
                      selected: <EventInteractionModel>{
                        widget.selectedInteractionModel,
                      },
                      onSelectionChanged: (selection) {
                        widget.onInteractionModelChanged(selection.single);
                      },
                      open: _accordion.isExpanded(_interactionField),
                      onOpenChanged: (open) =>
                          _setOpen(_interactionField, open),
                      icon: CatchIcons.tuneRounded,
                      iconColor: activity.accent,
                    ),
                  ],
                  if (widget.selectedActivityKind.isDistanceBased) ...[
                    CatchField.input(
                      key: CreateEventFormKeys.distance,
                      title: context.l10n.hostsEventDetailsStepTitleDistanceKm,
                      controller: widget.distanceController,
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
                      initialValue: widget.selectedPace,
                      validator: (value) => value == null
                          ? context
                                .l10n
                                .hostsEventDetailsStepVisiblecopySelectAPace
                          : null,
                      builder: (field) => CatchField.choices<PaceLevel>(
                        title: context.l10n.hostsEventDetailsStepLabelPaceLevel,
                        body: widget.selectedPace?.label,
                        values: PaceLevel.values,
                        itemLabel: (pace) => pace.label,
                        itemAccent: (_) => activity.accent,
                        selected: widget.selectedPace == null
                            ? const <PaceLevel>{}
                            : <PaceLevel>{widget.selectedPace!},
                        onSelectionChanged: (selection) {
                          final next = selection.isEmpty
                              ? null
                              : selection.single;
                          widget.onPaceChanged(next);
                          field.didChange(next);
                        },
                        allowEmptySelection: true,
                        open: _accordion.isExpanded(_paceField),
                        onOpenChanged: (open) => _setOpen(_paceField, open),
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
                    controller: widget.descriptionController,
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
