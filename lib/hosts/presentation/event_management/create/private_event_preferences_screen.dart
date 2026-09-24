import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/data/private_event_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_preferences_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Manager-only settings on the same saved private event. Every field shows
/// whether it inherits, overrides, or clears an organizer suggestion.
class PrivateEventPreferencesScreen extends StatelessWidget {
  const PrivateEventPreferencesScreen({
    super.key,
    required this.controller,
    required this.onBack,
  });

  final PrivateEventPreferencesController controller;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final copy = catchFieldCopy(l10n);
    final tokens = CatchTokens.of(context);
    final event = controller.event;
    final defaults = controller.defaults;
    final snapshot = event?.eventPreferences;
    final intents = snapshot?.intents ?? const PrivateEventPreferenceIntents();
    final intentsJson = intents.toJson();
    final suggestions = defaults?.preferences.toSparseJson() ?? const <String, Object?>{};
    final resolved = snapshot?.resolvedValues ?? suggestions;
    final editable = controller.canEdit;

    void saveField(String field, Map<String, Object?> intent) {
      if (!editable) return;
      final next = PrivateEventPreferenceIntents.fromJson({
        ...intentsJson,
        field: intent,
      });
      unawaited(controller.save(next));
    }

    String modeLabel(String mode) => switch (mode) {
      'inherit' => l10n.hostsEventPreferenceInherit,
      'set' => l10n.hostsEventPreferenceOverride,
      _ => l10n.hostsEventPreferenceClear,
    };
    String collectionLabel(EventCollectionPreference value) => switch (value) {
      EventCollectionPreference.manualInstructions =>
        l10n.hostsEventDefaultsManualInstructions,
      EventCollectionPreference.reusablePage =>
        l10n.hostsEventDefaultsReusablePage,
      EventCollectionPreference.personalRequest =>
        l10n.hostsEventDefaultsPersonalRequest,
      EventCollectionPreference.catchCheckout =>
        l10n.hostsEventDefaultsCatchCheckout,
    };
    String admissionLabel(String value) => switch (value) {
      'openCapacity' => l10n.hostsEventPreferenceAdmissionOpen,
      'inviteOnly' => l10n.hostsEventPreferenceAdmissionInvite,
      'balancedSingles' => l10n.hostsEventPreferenceAdmissionBalanced,
      _ => l10n.hostsEventPreferenceAdmissionFixed,
    };
    String inputValue(String key) {
      final value = resolved[key];
      if (key == 'reusablePaymentPage') {
        return value is Map ? (value['url'] as String? ?? '') : '';
      }
      return value?.toString() ?? '';
    }

    final fields = <({String key, String title, String hint, int maxLength})>[
      (key: 'usualDurationMinutes', title: l10n.hostsEventDefaultsUsualDuration,
        hint: '15–240', maxLength: 3),
      (key: 'preferredVenueId', title: l10n.hostsEventDefaultsPreferredVenue,
        hint: l10n.hostsEventDefaultsVenueUnavailable, maxLength: 120),
      (key: 'offerValidityMinutes', title: l10n.hostsEventDefaultsOfferValidity,
        hint: '5–10080', maxLength: 5),
      (key: 'collectionPreference', title: l10n.hostsEventDefaultsCollectionPreference,
        hint: '', maxLength: 0),
      (key: 'currency', title: l10n.hostsEventDefaultsCurrency,
        hint: 'INR', maxLength: 3),
      (key: 'offerMessageTemplate', title: l10n.hostsEventDefaultsMessageTemplate,
        hint: l10n.hostsEventDefaultsMessageTemplateHint, maxLength: 1000),
      (key: 'paymentInstructions', title: l10n.hostsEventDefaultsPaymentInstructions,
        hint: l10n.hostsEventDefaultsPaymentInstructionsHint, maxLength: 1000),
      (key: 'reusablePaymentPage', title: l10n.hostsEventDefaultsReusablePaymentPage,
        hint: l10n.hostsEventDefaultsReusablePageHint, maxLength: 2048),
      (key: 'admissionPreset', title: l10n.hostsEventPreferenceAdmission,
        hint: '', maxLength: 0),
      (key: 'expectedAmountMinor', title: l10n.hostsEventPreferenceExpectedAmountMinor,
        hint: l10n.hostsEventPreferenceExpectedAmountHint, maxLength: 9),
    ];

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
            title: l10n.hostsEventPreferenceTitle,
            subtitle: event?.name ?? l10n.hostsPrivateEventPayments,
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
                          title: l10n.hostsEventPreferenceTitle,
                          children: [
                            CatchField.read(
                              copy: copy,
                              title: l10n.hostsPrivateEventPrivateTitle,
                              body: l10n.hostsEventPreferencePrivateHint,
                              icon: CatchIcons.lockOutline,
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
                            if (controller.error != null)
                              CatchField.read(
                                copy: copy,
                                title: l10n.hostsEventPreferenceError,
                                body: appErrorMessage(controller.error!,
                                  l10n: l10n, context: AppErrorContext.event),
                                icon: CatchIcons.errorOutlineRounded,
                              ),
                            if (controller.pending == null &&
                                controller.error != null)
                              CatchField.action(
                                copy: copy,
                                title: l10n.hostsPrivateEventRetryDefaultsRead,
                                onTap: controller.loading ? null :
                                    () => unawaited(controller.load()),
                              ),
                          ],
                        ),
                        CatchSection.fieldRows(
                          title: l10n.hostsEventDefaultsPaymentHeading,
                          children: [
                            CatchField<EventCollectionPreference>.control(
                              copy: copy,
                              title: l10n.hostsEventDefaultsCollectionPreference,
                              contractExemption: 'Private event collection preference only.',
                              body: resolved['collectionPreference'] is String
                                  ? collectionLabel(EventCollectionPreference.values.byName(
                                      resolved['collectionPreference'] as String))
                                  : l10n.hostsEventDefaultsChooseEachEvent,
                              helperText: l10n.hostsEventDefaultsCollectionSuggestionHint,
                              icon: CatchIcons.paymentsOutlined,
                              child: CatchChoiceInput<EventCollectionPreference>(
                                values: EventCollectionPreference.values,
                                itemLabelBuilder: collectionLabel,
                                selected: resolved['collectionPreference'] is String
                                    ? {EventCollectionPreference.values.byName(
                                        resolved['collectionPreference'] as String)}
                                    : const <EventCollectionPreference>{},
                                mode: CatchChipMode.single,
                                autoClose: true,
                                onChanged: editable ? (selection) {
                                  if (selection.isNotEmpty) {
                                    saveField('collectionPreference',
                                      {'mode': 'set', 'value': selection.single.name});
                                  }
                                } : null,
                              ),
                            ),
                            CatchField<String>.control(
                              copy: copy,
                              title: l10n.hostsEventPreferenceAdmission,
                              contractExemption: 'Private event admission suggestion only.',
                              body: resolved['admissionPreset'] is String
                                  ? admissionLabel(resolved['admissionPreset'] as String)
                                  : l10n.hostsEventDefaultsChooseEachEvent,
                              child: CatchChoiceInput<String>(
                                values: const ['openCapacity', 'inviteOnly',
                                  'balancedSingles', 'fixedCohortCaps'],
                                itemLabelBuilder: admissionLabel,
                                selected: resolved['admissionPreset'] is String
                                    ? {resolved['admissionPreset'] as String}
                                    : const <String>{},
                                mode: CatchChipMode.single,
                                autoClose: true,
                                onChanged: editable ? (selection) {
                                  if (selection.isNotEmpty) {
                                    saveField('admissionPreset',
                                      {'mode': 'set', 'value': selection.single});
                                  }
                                } : null,
                              ),
                            ),
                            for (final field in fields) ...[
                              CatchField<EventSetupValueMode>.control(
                                copy: copy,
                                title: field.title,
                                contractExemption: 'Event-local inherited, set or cleared preference.',
                                body: modeLabel((intentsJson[field.key] as Map)['mode'] as String),
                                child: CatchChoiceInput<EventSetupValueMode>(
                                  values: field.key == 'expectedAmountMinor'
                                      ? const [EventSetupValueMode.set,
                                          EventSetupValueMode.clear]
                                      : EventSetupValueMode.values,
                                  itemLabelBuilder: (mode) => modeLabel(mode.name),
                                  selected: {EventSetupValueMode.values.byName(
                                    (intentsJson[field.key] as Map)['mode'] as String,
                                  )},
                                  mode: CatchChipMode.single,
                                  autoClose: true,
                                  onChanged: editable ? (selection) {
                                    if (selection.isEmpty) return;
                                    final mode = selection.single;
                                    if (mode == EventSetupValueMode.set) {
                                      final value = resolved[field.key];
                                      if (value != null) {
                                        saveField(field.key,
                                          {'mode': 'set', 'value': value});
                                      }
                                      return;
                                    }
                                    saveField(field.key, {'mode': mode.name});
                                  } : null,
                                ),
                              ),
                              if (field.key == 'collectionPreference' ||
                                  field.key == 'admissionPreset')
                                const SizedBox.shrink()
                              else if (field.key == 'preferredVenueId')
                                CatchField.read(
                                  copy: copy,
                                  title: field.title,
                                  body: l10n.hostsEventDefaultsVenueUnavailable,
                                )
                              else
                                CatchField.input(
                                  copy: copy,
                                  key: ValueKey('event-preference-${field.key}-${resolved[field.key]}'),
                                  title: field.title,
                                  contractExemption: 'Event-local private setting.',
                                  initialValue: inputValue(field.key),
                                  inputHint: field.hint,
                                  inputMode: editable
                                      ? CatchTextInputMode.editable
                                      : CatchTextInputMode.inactive,
                                  maxLength: field.maxLength,
                                  maxLines: field.maxLength >= 1000 ? 3 : 1,
                                  onValidate: (text) {
                                    final value = text?.trim() ?? '';
                                    if (value.isEmpty) return null;
                                    try {
                                      final intent = privateEventPreferenceSetIntentForInput(
                                        field.key, value,
                                      );
                                      PrivateEventPreferenceIntents.fromJson({
                                        ...intentsJson,
                                        field.key: intent,
                                      });
                                      return null;
                                    } catch (_) {
                                      return l10n.hostsEventPreferenceInvalidValue;
                                    }
                                  },
                                  onSubmitted: editable ? (text) async {
                                    final value = text.trim();
                                    if (value.isEmpty) {
                                      saveField(field.key, {'mode': 'clear'});
                                      return;
                                    }
                                    Map<String, Object?> intent;
                                    try {
                                      intent = privateEventPreferenceSetIntentForInput(
                                        field.key, value,
                                      );
                                    } catch (error) {
                                      showCatchErrorSnackBar(context, error);
                                      return;
                                    }
                                    if (field.key == 'reusablePaymentPage') {
                                      final confirmed = await showCatchAdaptiveDialog<bool>(
                                        context: context,
                                        title: l10n.hostsEventDefaultsReusableConfirmTitle,
                                        message: l10n.hostsEventDefaultsReusableConfirmBody,
                                        actions: [
                                          CatchDialogAction(
                                            label: l10n.hostsEventDefaultsReusableConfirmCancel,
                                            value: false,
                                          ),
                                          CatchDialogAction(
                                            label: l10n.hostsEventDefaultsReusableConfirmAccept,
                                            value: true,
                                          ),
                                        ],
                                        barrierDismissible: false,
                                      );
                                      if (!context.mounted || confirmed != true) return;
                                    }
                                    try {
                                      final next = PrivateEventPreferenceIntents.fromJson({
                                        ...intentsJson,
                                        field.key: intent,
                                      });
                                      unawaited(controller.save(next));
                                    } catch (error) {
                                      showCatchErrorSnackBar(context, error);
                                    }
                                  } : null,
                                ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    gapH4,
                    Text(l10n.hostsEventPreferenceProviderHint,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: tokens.ink2)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
