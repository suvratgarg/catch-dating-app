import 'dart:async';
import 'dart:math' as math;

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:catch_dating_app/hosts/data/private_event_preferences_repository.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/event_offer_preferences_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/host_offer_payment_mode_tile.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/host_offer_payment_review_sheet.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Modeled as a decision, not a preference grid: the host picks how guests pay,
/// sees only the fields that mode needs, and reads how payment confirmation
/// works before saving. Draft edits stage on the controller; Save runs the
/// server preview and an explicit confirm keeps the reviewed commit.
class HostOfferPaymentSetupBody extends StatefulWidget {
  const HostOfferPaymentSetupBody({
    super.key,
    required this.controller,
    required this.onBack,
    this.catchCheckoutAvailable = false,
  });

  final EventOfferPreferencesController controller;
  final VoidCallback onBack;

  /// First-party checkout needs verified provider activation. Until that
  /// lands the option stays visible but cannot be selected.
  final bool catchCheckoutAvailable;

  @override
  State<HostOfferPaymentSetupBody> createState() =>
      _HostOfferPaymentSetupBodyState();
}

class _HostOfferPaymentSetupBodyState
    extends State<HostOfferPaymentSetupBody> {
  static const _validityChips = <int>[1440, 2880, 4320];
  static const _customValiditySentinel = -1;

  HostOfferPaymentMode? _mode;
  bool _hydrated = false;
  bool _reuseAttested = false;
  bool _validityCustom = false;
  int? _validityMinutes;
  final _amount = TextEditingController();
  final _currency = TextEditingController();
  final _pageUrl = TextEditingController();
  final _instructions = TextEditingController();
  final _message = TextEditingController();
  final _customValidity = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _amount,
      _currency,
      _pageUrl,
      _instructions,
      _message,
      _customValidity,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isPaid =>
      _mode == HostOfferPaymentMode.catchCheckout ||
      _mode == HostOfferPaymentMode.reusablePage ||
      _mode == HostOfferPaymentMode.personalRequest ||
      _mode == HostOfferPaymentMode.manualInstructions;

  EventCollectionPreference? get _collection => switch (_mode) {
    HostOfferPaymentMode.reusablePage =>
      EventCollectionPreference.reusablePage,
    HostOfferPaymentMode.personalRequest =>
      EventCollectionPreference.personalRequest,
    HostOfferPaymentMode.manualInstructions =>
      EventCollectionPreference.manualInstructions,
    HostOfferPaymentMode.catchCheckout =>
      EventCollectionPreference.catchCheckout,
    _ => null,
  };

  int get _currencyDigits =>
      NumberFormat.currency(
        name: _currency.text.trim().isEmpty ? 'INR' : _currency.text.trim(),
      ).decimalDigits ??
      2;

  int? get _amountMinor {
    final parsed = double.tryParse(_amount.text.trim());
    if (parsed == null || parsed.isNaN || parsed.isInfinite) return null;
    return (parsed * math.pow(10, _currencyDigits)).round();
  }

  void _hydrate() {
    final resolved = widget.controller.resolvedValues;
    final amount = resolved['expectedAmountMinor'];
    final collection = resolved['collectionPreference'];
    if (amount is int && amount == 0) {
      _mode = HostOfferPaymentMode.free;
    } else if (collection is String) {
      _mode = switch (collection) {
        'reusablePage' => HostOfferPaymentMode.reusablePage,
        'personalRequest' => HostOfferPaymentMode.personalRequest,
        'manualInstructions' => HostOfferPaymentMode.manualInstructions,
        'catchCheckout' => HostOfferPaymentMode.catchCheckout,
        _ => null,
      };
    }
    if (amount is int && amount > 0) {
      final currency = resolved['currency'];
      _amount.text = _majorText(amount, currency is String ? currency : 'INR');
    }
    _currency.text = resolved['currency'] as String? ?? 'INR';
    final validity = resolved['offerValidityMinutes'];
    if (validity is int) {
      _validityMinutes = validity;
      _validityCustom = !_validityChips.contains(validity);
      if (_validityCustom) _customValidity.text = '$validity';
    }
    final page = resolved['reusablePaymentPage'];
    if (page is Map && page['url'] is String) {
      _pageUrl.text = page['url'] as String;
      _reuseAttested = true;
    }
    _instructions.text = resolved['paymentInstructions'] as String? ?? '';
    _message.text = resolved['offerMessageTemplate'] as String? ?? '';
    _hydrated = true;
  }

  String _majorText(int minor, String currency) {
    final digits =
        NumberFormat.currency(name: currency).decimalDigits ?? 2;
    final factor = math.pow(10, digits).toInt();
    if (minor % factor == 0) return '${minor ~/ factor}';
    return (minor / factor).toStringAsFixed(digits);
  }

  /// Rebuild the staged intents after every edit. Fields this screen does not
  /// manage keep their current intents; dependents outside the chosen mode
  /// are cleared so the saved snapshot only carries what applies.
  void _stage() {
    if (!_hydrated || !widget.controller.canEdit) return;
    final current = widget.controller.editorIntents;
    final amount = _amountMinor;
    final currency = _currency.text.trim().toUpperCase();
    final message = _message.text.trim();
    final instructions = _instructions.text.trim();
    final pageUrl = _pageUrl.text.trim();
    widget.controller.stage(
      PrivateEventPreferenceIntents(
        usualDurationMinutes: current.usualDurationMinutes,
        preferredVenueId: current.preferredVenueId,
        admissionPreset: current.admissionPreset,
        offerValidityMinutes: _validityMinutes != null
            ? EventSetupValue.set(_validityMinutes!)
            : const EventSetupValue.clear(),
        offerMessageTemplate: message.isEmpty
            ? const EventSetupValue.clear()
            : EventSetupValue.set(message),
        expectedAmountMinor: switch (_mode) {
          HostOfferPaymentMode.free => const EventSetupValue.set(0),
          null => current.expectedAmountMinor,
          _ => amount != null
              ? EventSetupValue.set(amount)
              : const EventSetupValue.clear(),
        },
        currency: !_isPaid
            ? current.currency
            : RegExp(r'^[A-Z]{3}$').hasMatch(currency)
            ? EventSetupValue.set(currency)
            : const EventSetupValue.clear(),
        collectionPreference: switch (_mode) {
          null => current.collectionPreference,
          HostOfferPaymentMode.free => const EventSetupValue.clear(),
          _ => EventSetupValue.set(_collection!),
        },
        paymentInstructions:
            _mode == HostOfferPaymentMode.manualInstructions &&
                instructions.isNotEmpty
            ? EventSetupValue.set(instructions)
            : const EventSetupValue.clear(),
        reusablePaymentPage:
            _mode == HostOfferPaymentMode.reusablePage &&
                _reuseAttested &&
                isCanonicalPublicPaymentPageUrl(pageUrl)
            ? EventSetupValue.set(
                ReusableOrganizerPaymentPage(pageUrl, reusableForEvents: true),
              )
            : const EventSetupValue.clear(),
      ),
    );
  }

  /// Offer expiry mirrors the server rule: validity counted from now, clamped
  /// at the event start. Hidden while validity is unset or already past.
  int? get _resolvedExpiryMillis {
    final validity = _validityMinutes;
    final configuration = widget.controller.configuration;
    if (validity == null ||
        validity < 5 ||
        validity > 10080 ||
        configuration == null) {
      return null;
    }
    final expiry = math.min(
      configuration.nowMillis + validity * 60_000,
      configuration.startsAtMillis,
    );
    return expiry > configuration.nowMillis ? expiry : null;
  }

  List<String> _blockers(AppLocalizations l10n) {
    final blockers = <String>[];
    if (_mode == null) blockers.add(l10n.hostOfferPaymentChooseMode);
    if (_mode == HostOfferPaymentMode.catchCheckout &&
        !widget.catchCheckoutAvailable) {
      blockers.add(l10n.hostOfferPaymentCheckoutUnavailable);
    }
    if (_isPaid) {
      final amount = _amountMinor;
      if (amount == null || amount <= 0 || amount > 100000000) {
        blockers.add(l10n.hostOfferPaymentSetAmount);
      }
      if (!RegExp(r'^[A-Z]{3}$').hasMatch(_currency.text.trim().toUpperCase())) {
        blockers.add(l10n.hostOfferPaymentSetCurrency);
      }
      if (_mode == HostOfferPaymentMode.reusablePage) {
        final page = _pageUrl.text.trim();
        if (page.isEmpty) {
          blockers.add(l10n.hostOfferPaymentSetPage);
        } else if (!isCanonicalPublicPaymentPageUrl(page)) {
          blockers.add(l10n.hostsEventDefaultsInvalidReusablePage);
        } else if (!_reuseAttested) {
          blockers.add(l10n.hostOfferPaymentConfirmReuse);
        }
      }
      if (_mode == HostOfferPaymentMode.manualInstructions &&
          _instructions.text.trim().isEmpty) {
        blockers.add(l10n.hostOfferPaymentSetInstructions);
      }
    }
    final validity = _validityMinutes;
    if (validity == null || validity < 5 || validity > 10080) {
      blockers.add(l10n.hostOfferPaymentSetValidity);
    }
    return blockers;
  }

  String _summary(AppLocalizations l10n) {
    if (_mode == HostOfferPaymentMode.free) {
      return l10n.hostOfferPaymentReadyFree;
    }
    final amount = _amountMinor;
    final currency = _currency.text.trim().toUpperCase();
    final amountText = amount == null
        ? ''
        : offerAmountDisplay(amount, currency.isEmpty ? 'INR' : currency);
    return l10n.hostOfferPaymentReadyPaid(
      amount: amountText,
      collection:
          _mode == null ? '' : hostOfferPaymentModeTitle(l10n, _mode!).toLowerCase(),
    );
  }

  Future<void> _save() async {
    if (!widget.controller.canEdit) return;
    // Preview binds the reviewed revision fences; without a preview endpoint
    // the command journal still guards the write itself.
    if (widget.controller.readPreview == null) {
      await widget.controller.save(widget.controller.editorIntents);
      if (!mounted) return;
      if (widget.controller.error == null && !widget.controller.hasPending) {
        widget.onBack();
      }
      return;
    }
    await widget.controller.previewChanges();
    if (!mounted || widget.controller.review == null) return;
    final summary = _summary(context.l10n);
    final confirmed = await showCatchBottomSheet<bool>(
      context: context,
      builder: (context) => HostOfferPaymentReviewSheet(
        review: widget.controller.review!,
        summary: summary,
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.controller.applyReview();
    if (!mounted) return;
    if (widget.controller.error == null && !widget.controller.hasPending) {
      widget.onBack();
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final copy = catchFieldCopy(l10n);
    final tokens = CatchTokens.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        if (!_hydrated &&
            controller.hasLoadedEvent &&
            controller.defaults != null) {
          _hydrate();
        }
        if (controller.loading && !controller.hasLoadedEvent) {
          return const CatchScaffold.stepFlow(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final blockers = _blockers(l10n);
        final editable = controller.canEdit;
        final saving = controller.saving || controller.previewing;
        return CatchScaffold.stepFlow(
          backgroundColor: tokens.bg,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              CatchStepHeader(
                title: l10n.hostOfferPaymentTitle,
                subtitle: controller.eventName ??
                    l10n.hostsPrivateEventPayments,
                stepLabelBuilder: catchStepHeaderLabelBuilder(l10n),
                compactStepLabelBuilder:
                    catchStepHeaderCompactLabelBuilder(l10n),
                onBack: widget.onBack,
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
                            if (controller.hasPending ||
                                controller.error != null)
                              CatchSection.fieldRows(
                                first: true,
                                children: [
                                  if (controller.hasPending)
                                    CatchField.read(
                                      copy: copy,
                                      title:
                                          l10n.hostsEventPreferencePending,
                                      body: l10n
                                          .hostsEventPreferencePendingBody,
                                      icon: CatchIcons.scheduleOutlined,
                                    ),
                                  if (controller.hasPending)
                                    CatchField.action(
                                      copy: copy,
                                      title:
                                          l10n.hostsEventPreferenceRetry,
                                      onTap: controller.saving
                                          ? null
                                          : () => unawaited(
                                              controller.retryPending(),
                                            ),
                                    ),
                                  if (controller.error != null)
                                    CatchField.read(
                                      copy: copy,
                                      title: l10n.hostsEventPreferenceError,
                                      body: appErrorMessage(
                                        controller.error!,
                                        l10n: l10n,
                                        context: AppErrorContext.event,
                                      ),
                                      icon: CatchIcons.errorOutlineRounded,
                                    ),
                                ],
                              ),
                            CatchSection.choiceGroup(
                              first: !controller.hasPending &&
                                  controller.error == null,
                              title: l10n.hostOfferPaymentModeHeading,
                              child: Column(
                                children: [
                                  for (final mode
                                      in HostOfferPaymentMode.values) ...[
                                    HostOfferPaymentModeTile(
                                      mode: mode,
                                      selected: _mode == mode,
                                      editable: editable,
                                      checkoutAvailable:
                                          widget.catchCheckoutAvailable,
                                      onSelected: (mode) {
                                        setState(() => _mode = mode);
                                        _stage();
                                      },
                                    ),
                                    if (mode !=
                                        HostOfferPaymentMode
                                            .manualInstructions)
                                      const SizedBox(
                                        height: CatchSpacing.s3,
                                      ),
                                  ],
                                ],
                              ),
                            ),
                            if (_mode != null) _detailsSection(l10n, copy),
                            if (_mode != null) _confirmationSection(l10n, copy),
                          ],
                        ),
                        if (_mode != null) ...[
                          gapH4,
                          Text(
                            l10n.hostsEventPreferenceProviderHint,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: tokens.ink2),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              CatchDockSurface.primaryContent(
                label: l10n.hostOfferPaymentSave,
                buttonKey: const ValueKey('offer-payment-setup-save'),
                catchLine: blockers.isEmpty
                    ? _summary(l10n)
                    : blockers.first.toUpperCase(),
                footnote: l10n.hostsEventPreferencePublishedHint,
                isLoading: saving,
                onPressed: editable && blockers.isEmpty ? _save : null,
              ),
            ],
          ),
        );
      },
    );
  }

  CatchSection _detailsSection(AppLocalizations l10n, CatchFieldCopy copy) {
    final editable = widget.controller.canEdit;
    return CatchSection.fieldRows(
      title: l10n.hostOfferPaymentDetailsHeading,
      children: [
        if (_mode == HostOfferPaymentMode.free)
          CatchField.read(
            copy: copy,
            title: l10n.hostEventOfferFree,
            body: l10n.hostOfferPaymentFreeBody,
            icon: CatchIcons.confirmationNumberOutlined,
          )
        else ...[
          CatchField.input(
            copy: copy,
            key: const ValueKey('offer-payment-amount'),
            title: l10n.hostOfferPaymentAmount,
            controller: _amount,
            inputHint: '1200',
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputMode: editable
                ? CatchTextInputMode.editable
                : CatchTextInputMode.inactive,
            onChanged: editable ? (_) => _stage() : null,
            onValidate: (text) {
              final parsed = double.tryParse(text?.trim() ?? '');
              if (parsed == null || parsed <= 0) {
                return l10n.hostsEventPreferenceInvalidValue;
              }
              return null;
            },
            helperText: l10n.hostOfferPaymentAmountHint,
          ),
          CatchField.input(
            copy: copy,
            key: const ValueKey('offer-payment-currency'),
            title: l10n.hostsEventDefaultsCurrency,
            controller: _currency,
            inputHint: 'INR',
            maxLength: 3,
            inputMode: editable
                ? CatchTextInputMode.editable
                : CatchTextInputMode.inactive,
            onChanged: editable ? (_) => _stage() : null,
            onValidate: (text) =>
                RegExp(r'^[A-Za-z]{3}$').hasMatch(text?.trim() ?? '')
                ? null
                : l10n.hostsEventDefaultsInvalidCurrency,
          ),
        ],
        CatchField<int>.choices(
          copy: copy,
          title: l10n.hostOfferPaymentValidity,
          disclosureMode: CatchFieldMode.localExpanded,
          helperText: l10n.hostOfferPaymentValidityHint,
          values: const [..._validityChips, _customValiditySentinel],
          itemLabelBuilder: (minutes) => minutes == _customValiditySentinel
              ? l10n.hostOfferPaymentValidityCustom
              : l10n.hostOfferPaymentValidityHours(hours: minutes ~/ 60),
          selected: {
            if (_validityCustom)
              _customValiditySentinel
            else
              ?_validityMinutes,
          },
          allowEmptySelection: true,
          onSelectionChanged: editable
              ? (selection) {
                  final minutes = selection.isEmpty ? null : selection.first;
                  setState(() {
                    _validityCustom = minutes == _customValiditySentinel;
                    _validityMinutes = minutes == _customValiditySentinel
                        ? int.tryParse(_customValidity.text.trim())
                        : minutes;
                  });
                  _stage();
                }
              : null,
        ),
        if (_validityCustom)
          CatchField.input(
            copy: copy,
            key: const ValueKey('offer-payment-validity-minutes'),
            title: l10n.hostOfferPaymentValidityMinutes,
            controller: _customValidity,
            inputHint: '5–10080',
            maxLength: 5,
            keyboardType: TextInputType.number,
            inputMode: editable
                ? CatchTextInputMode.editable
                : CatchTextInputMode.inactive,
            onChanged: editable
                ? (text) {
                    _validityMinutes = int.tryParse(text.trim());
                    _stage();
                  }
                : null,
            onValidate: (text) {
              final value = int.tryParse(text?.trim() ?? '');
              if (value == null || value < 5 || value > 10080) {
                return l10n.hostsEventPreferenceInvalidValue;
              }
              return null;
            },
          ),
        if (_resolvedExpiryMillis case final millis?)
          CatchField.read(
            copy: copy,
            title: l10n.hostOfferPaymentExpires,
            body: DateFormat.yMMMd().add_jm().format(
              DateTime.fromMillisecondsSinceEpoch(millis),
            ),
            icon: CatchIcons.scheduleOutlined,
          ),
        if (_mode == HostOfferPaymentMode.reusablePage) ...[
          CatchField.input(
            copy: copy,
            key: const ValueKey('offer-payment-page-url'),
            title: l10n.hostOfferPaymentPageLink,
            controller: _pageUrl,
            inputHint: l10n.hostsEventDefaultsReusablePageHint,
            keyboardType: TextInputType.url,
            inputMode: editable
                ? CatchTextInputMode.editable
                : CatchTextInputMode.inactive,
            onChanged: editable ? (_) => _stage() : null,
            onValidate: (text) =>
                isCanonicalPublicPaymentPageUrl(text?.trim() ?? '')
                ? null
                : l10n.hostsEventDefaultsInvalidReusablePage,
            helperText: l10n.hostOfferPaymentPageLinkHint,
          ),
          CatchField.toggle(
            copy: copy,
            key: const ValueKey('offer-payment-page-reuse'),
            title: l10n.hostOfferPaymentPageReuse,
            body: l10n.hostOfferPaymentPageReuseBody,
            value: _reuseAttested,
            onChanged: editable
                ? (value) {
                    setState(() => _reuseAttested = value);
                    _stage();
                  }
                : null,
          ),
        ],
        if (_mode == HostOfferPaymentMode.personalRequest)
          CatchField.read(
            copy: copy,
            title: l10n.hostsEventDefaultsPersonalRequest,
            body: l10n.hostOfferPaymentRequestLinksBody,
            icon: CatchIcons.linkOutlined,
          ),
        if (_mode == HostOfferPaymentMode.manualInstructions)
          CatchField.input(
            copy: copy,
            key: const ValueKey('offer-payment-instructions'),
            title: l10n.hostsEventDefaultsPaymentInstructions,
            controller: _instructions,
            inputHint: l10n.hostOfferPaymentInstructionsHint,
            maxLength: 1000,
            maxLines: 3,
            inputMode: editable
                ? CatchTextInputMode.editable
                : CatchTextInputMode.inactive,
            onChanged: editable ? (_) => _stage() : null,
            onValidate: (text) => (text?.trim().isEmpty ?? true)
                ? l10n.hostsEventPreferenceInvalidValue
                : null,
            helperText: l10n.hostOfferPaymentInstructionsHelper,
          ),
        CatchField.input(
          copy: copy,
          key: const ValueKey('offer-payment-message'),
          title: l10n.hostOfferPaymentMessage,
          labelMode: CatchFieldLabelTextMode.optional,
          controller: _message,
          inputHint: l10n.hostOfferPaymentMessageHint,
          maxLength: 1000,
          maxLines: 3,
          inputMode: editable
              ? CatchTextInputMode.editable
              : CatchTextInputMode.inactive,
          onChanged: editable ? (_) => _stage() : null,
        ),
      ],
    );
  }

  CatchSection _confirmationSection(
    AppLocalizations l10n,
    CatchFieldCopy copy,
  ) {
    final (title, body, icon) = switch (_mode) {
      HostOfferPaymentMode.free => (
        l10n.hostOfferPaymentConfirmFreeTitle,
        l10n.hostOfferPaymentConfirmFreeBody,
        CatchIcons.confirmationNumberOutlined,
      ),
      HostOfferPaymentMode.catchCheckout => (
        l10n.hostOfferPaymentConfirmAutoTitle,
        l10n.hostOfferPaymentConfirmAutoBody,
        CatchIcons.verifiedUserOutlined,
      ),
      HostOfferPaymentMode.reusablePage => (
        l10n.hostOfferPaymentConfirmManualTitle,
        l10n.hostOfferPaymentConfirmPageBody,
        CatchIcons.assignmentTurnedInOutlined,
      ),
      HostOfferPaymentMode.personalRequest => (
        l10n.hostOfferPaymentConfirmManualTitle,
        l10n.hostOfferPaymentConfirmRequestBody,
        CatchIcons.assignmentTurnedInOutlined,
      ),
      _ => (
        l10n.hostOfferPaymentConfirmManualTitle,
        l10n.hostOfferPaymentConfirmManualBody,
        CatchIcons.assignmentTurnedInOutlined,
      ),
    };
    return CatchSection.fieldRows(
      title: l10n.hostOfferPaymentConfirmationHeading,
      children: [
        CatchField.read(
          copy: copy,
          title: title,
          body: body,
          titleMaxLines: 2,
          bodyMaxLines: 8,
          icon: icon,
        ),
      ],
    );
  }
}
