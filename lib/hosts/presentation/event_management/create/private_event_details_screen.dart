import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/hosts/data/private_event_details_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_details_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Actual optional schedule, place and format of one saved private event.
/// Organizer defaults appear only as explicit copy-on-save choices.
class PrivateEventDetailsScreen extends StatelessWidget {
  const PrivateEventDetailsScreen({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final PrivateEventDetailsController controller;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final l10n = context.l10n;
      final copy = catchFieldCopy(l10n);
      final tokens = CatchTokens.of(context);
      final event = controller.event;
      final details = event?.eventDetails;
      final defaults = controller.defaults?.preferences;
      final editable = controller.canEdit;
      final end = details?.endTimeMillis;
      final duration = end == null || event == null
          ? null : (end - event.startTimeMillis) ~/ 60000;
      final suggestedDuration = defaults?.usualDurationMinutes;
      final suggestedVenue = defaults?.preferredVenueId;
      final currentVenue = details?.venueName;
      final currentFormat = details?.eventFormat;
      if (controller.loading && event == null) {
        return const CatchScaffold.stepFlow(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return CatchScaffold.stepFlow(
        backgroundColor: tokens.bg,
        body: Column(
          children: [
            CatchStepHeader(
              title: l10n.hostsPrivateEventDetails,
              subtitle: event?.name ?? l10n.hostsPrivateEventSavedTitle,
              stepLabelBuilder: catchStepHeaderLabelBuilder(l10n),
              compactStepLabelBuilder: catchStepHeaderCompactLabelBuilder(l10n),
              onBack: onBack,
              leadingType: CatchTopBarNavigationMode.back,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: CatchLayout.hostCreateEventFormLaneMaxWidth,
                  ),
                  child: ListView(
                    padding: CatchInsets.formStepBodyWithBottomActions,
                    children: [
                      CatchSectionList(
                        emptyStateOmitted: true,
                        children: [
                          CatchSection.fieldRows(
                            first: true,
                            title: l10n.hostsPrivateEventDetails,
                            children: [
                              CatchField.read(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetails,
                                body: l10n.hostsPrivateEventDetailActualHint,
                                icon: CatchIcons.eventAvailableOutlined,
                              ),
                              if (controller.pending != null) ...[
                                CatchField.read(
                                  copy: copy,
                                  title: l10n.hostsEventPreferencePending,
                                  body: l10n.hostsEventPreferencePendingBody,
                                  icon: CatchIcons.scheduleOutlined,
                                ),
                                CatchField.action(
                                  copy: copy,
                                  title: l10n.hostsEventPreferenceRetry,
                                  onTap: controller.saving ? null :
                                      () => unawaited(controller.retryPending()),
                                ),
                              ],
                              if (controller.error != null) ...[
                                CatchField.read(
                                  copy: copy,
                                  title: l10n.hostsEventPreferenceError,
                                  body: appErrorMessage(controller.error!,
                                    l10n: l10n, context: AppErrorContext.event),
                                  icon: CatchIcons.errorOutlineRounded,
                                ),
                                if (controller.pending == null)
                                  CatchField.action(
                                    copy: copy,
                                    title: l10n.hostsPrivateEventRetryDefaultsRead,
                                    onTap: controller.loading ? null :
                                        () => unawaited(controller.load()),
                                  ),
                              ],
                            ],
                          ),
                          CatchSection.fieldRows(
                            title: l10n.hostsEventDefaultsUsualDuration,
                            children: [
                              CatchField.read(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailCurrentDuration,
                                body: duration == null
                                    ? l10n.hostsPrivateEventDetailNotSet
                                    : l10n.hostsPrivateEventDetailMinutes(minutes: duration),
                                icon: CatchIcons.scheduleOutlined,
                              ),
                              CatchField.input(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailDuration,
                                contractExemption: 'Optional duration writes actual end time.',
                                initialValue: duration?.toString() ?? '',
                                inputHint: l10n.hostsPrivateEventDetailDurationHint,
                                inputMode: editable
                                    ? CatchTextInputMode.editable
                                    : CatchTextInputMode.inactive,
                                maxLength: 3,
                                onValidate: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) return null;
                                  final minutes = int.tryParse(text);
                                  return minutes != null && minutes >= 15 &&
                                          minutes <= 240
                                      ? null : l10n.hostsEventPreferenceInvalidValue;
                                },
                                onSubmitted: editable ? (text) {
                                  final minutes = int.tryParse(text.trim());
                                  if (minutes == null || minutes < 15 ||
                                      minutes > 240) {
                                    controller.reportValidationError(const FormatException(
                                      'Invalid event duration'));
                                    return;
                                  }
                                  unawaited(controller.save(
                                    PrivateEventDetailsPatch(
                                      durationMinutes: EventSetupValue.set(minutes),
                                    ),
                                  ));
                                } : null,
                              ),
                              CatchField.action(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailUseDuration,
                                body: suggestedDuration == null
                                    ? l10n.hostsPrivateEventDetailNoDurationSuggestion
                                    : l10n.hostsPrivateEventDetailMinutes(
                                        minutes: suggestedDuration),
                                onTap: editable && suggestedDuration != null
                                    ? () => unawaited(controller.save(
                                        const PrivateEventDetailsPatch(
                                          durationMinutes: EventSetupValue.inherit(),
                                        ),
                                      ))
                                    : null,
                              ),
                              CatchField.action(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailClearDuration,
                                onTap: editable && end != null
                                    ? () => unawaited(controller.save(
                                        const PrivateEventDetailsPatch(
                                          durationMinutes: EventSetupValue.clear(),
                                        ),
                                      ))
                                    : null,
                              ),
                            ],
                          ),
                          CatchSection.fieldRows(
                            title: l10n.hostsEventDefaultsPreferredVenue,
                            children: [
                              CatchField.read(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailCurrentVenue,
                                body: currentVenue ??
                                    l10n.hostsPrivateEventDetailNotSet,
                                icon: CatchIcons.locationOnOutlined,
                              ),
                              CatchField.input(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailVenueName,
                                contractExemption: 'Named venue only; no GPS location inferred.',
                                initialValue: currentVenue ?? '',
                                inputHint: l10n.hostsPrivateEventDetailVenueHint,
                                inputMode: editable
                                    ? CatchTextInputMode.editable
                                    : CatchTextInputMode.inactive,
                                maxLength: 240,
                                onValidate: (value) =>
                                    (value?.trim().isEmpty ?? true)
                                        ? l10n.hostsEventPreferenceInvalidValue
                                        : null,
                                onSubmitted: editable ? (text) {
                                  final name = text.trim();
                                  if (name.isEmpty || name.length > 240) {
                                    controller.reportValidationError(const FormatException(
                                      'Invalid event venue'));
                                    return;
                                  }
                                  unawaited(controller.save(
                                    PrivateEventDetailsPatch(
                                      venue: EventSetupValue.set(name),
                                    ),
                                  ));
                                } : null,
                              ),
                              CatchField.action(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailUseSavedPlace,
                                body: suggestedVenue == null
                                    ? l10n.hostsPrivateEventDetailNoSavedPlace
                                    : l10n.hostsPrivateEventDetailSavedPlaceHint,
                                onTap: editable && suggestedVenue != null
                                    ? () => unawaited(controller.save(
                                        const PrivateEventDetailsPatch(
                                          venue: EventSetupValue.inherit(),
                                        ),
                                      ))
                                    : null,
                              ),
                              CatchField.action(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailClearVenue,
                                onTap: editable && currentVenue != null
                                    ? () => unawaited(controller.save(
                                        const PrivateEventDetailsPatch(
                                          venue: EventSetupValue.clear(),
                                        ),
                                      ))
                                    : null,
                              ),
                            ],
                          ),
                          CatchSection.fieldRows(
                            title: l10n.hostsPrivateEventDetailFormat,
                            children: [
                              CatchField.read(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailCurrentFormat,
                                body: currentFormat?.label ??
                                    l10n.hostsPrivateEventDetailNotSet,
                                icon: CatchIcons.eventAvailableOutlined,
                              ),
                              CatchField<ActivityKind>.control(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailFormat,
                                contractExemption: 'Activity choice writes a versioned event format.',
                                child: CatchChoiceInput<ActivityKind>(
                                  values: ActivityKind.values,
                                  itemLabelBuilder: (kind) => kind.label,
                                  selected: currentFormat == null
                                      ? const <ActivityKind>{}
                                      : {currentFormat.activityKind},
                                  mode: CatchChipMode.single,
                                  autoClose: true,
                                  onChanged: controller.canEditFormat ? (selection) {
                                    if (selection.isEmpty) return;
                                    unawaited(controller.save(
                                      PrivateEventDetailsPatch(
                                        eventFormat: EventSetupValue.set(
                                          EventFormatSnapshot.fromActivityKind(
                                            selection.single,
                                          ),
                                        ),
                                      ),
                                    ));
                                  } : null,
                                ),
                              ),
                              CatchField.action(
                                copy: copy,
                                title: l10n.hostsPrivateEventDetailClearFormat,
                                onTap: controller.canEditFormat && currentFormat != null
                                    ? () => unawaited(controller.save(
                                        const PrivateEventDetailsPatch(
                                          eventFormat: EventSetupValue.clear(),
                                        ),
                                      ))
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
