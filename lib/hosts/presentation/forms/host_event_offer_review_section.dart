import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Supplied by the Forms localization owner when manager offer APIs are live.
class HostEventOfferReviewCopy {
  const HostEventOfferReviewCopy({
    required this.title,
    required this.preview,
    required this.previewing,
    required this.review,
    required this.expires,
    required this.commit,
    required this.committing,
    required this.committed,
    required this.failed,
    required this.noReservation,
    required this.paymentReference,
    required this.recordReference,
    required this.evidenceSubmitted,
    required this.bankReceiptChecked,
    required this.reviewNote,
    required this.attestReceived,
    required this.rejectReference,
    required this.hostAttested,
    required this.rejected,
  });

  final String title;
  final String preview;
  final String previewing;
  final String review;
  final String Function(String) expires;
  final String commit;
  final String committing;
  final String committed;
  final String failed;
  final String noReservation;
  final String paymentReference;
  final String recordReference;
  final String evidenceSubmitted;
  final String bankReceiptChecked;
  final String reviewNote;
  final String attestReceived;
  final String rejectReference;
  final String hostAttested;
  final String rejected;
}

/// One selected current CRM contact and manager-visible future event are
/// supplied by the parent flow. Preview never reserves or admits a guest.
class HostEventOfferReviewSection extends StatelessWidget {
  const HostEventOfferReviewSection({
    super.key,
    required this.controller,
    required this.draft,
    required this.eventTitle,
    required this.contactLabel,
    required this.eventStartsAt,
    required this.now,
    required this.commitRequestId,
    required this.copy,
    this.amountLabel,
    this.showEvent = true,
    this.layoutBuilder,
  });

  final HostEventOfferController controller;
  final HostOfferBatchDraft draft;
  final String eventTitle;
  final String Function(String contactId) contactLabel;
  final DateTime eventStartsAt;
  final DateTime Function() now;
  final String commitRequestId;
  final HostEventOfferReviewCopy copy;
  final String? amountLabel;
  final bool showEvent;
  final Widget Function(Widget body, Widget? primaryAction)? layoutBuilder;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final view = controller.view;
      final sameDraft = identical(view.draft, draft);
      final busy =
          view.status == HostOfferFlowStatus.previewing ||
          view.status == HostOfferFlowStatus.committing;
      final canPreview =
          !sameDraft ||
          (view.status != HostOfferFlowStatus.committed &&
              !view.canCommit &&
              view.pendingRequestId == null);
      final canCommit =
          sameDraft &&
          (view.canCommit ||
              view.status == HostOfferFlowStatus.failure &&
                  view.pendingRequestId == commitRequestId);
      final action = canPreview || canCommit
          ? CatchDockSurface.pageAction(
              label: canCommit ? copy.commit : copy.preview,
              isLoading: busy,
              onPressed: busy
                  ? null
                  : () {
                      if (canCommit) {
                        controller.commit(commitRequestId);
                      } else {
                        controller.preview(
                          draft: draft,
                          now: now(),
                          eventStartsAt: eventStartsAt,
                        );
                      }
                    },
            )
          : null;
      final body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchSection.plain(
            child: Text(
              copy.noReservation,
              style: CatchTextStyles.supporting(context),
            ),
          ),
          CatchFieldLanes.divided(
            children: [
              if (showEvent)
                CatchField.read(
                  copy: catchFieldCopy(context.l10n),
                  title: context.l10n.hostEventOfferSelectEvent,
                  valueText: eventTitle,
                ),
              for (final row in draft.rows)
                CatchField.read(
                  copy: catchFieldCopy(context.l10n),
                  title: context.l10n.hostEventOfferRecipient,
                  valueText: contactLabel(row.contactId),
                ),
              for (final expiry
                  in draft.rows.map((row) => row.expiresAt).toSet())
                CatchField.read(
                  copy: catchFieldCopy(context.l10n),
                  title: context.l10n.hostEventOfferExpiry,
                  valueText:
                      '${AppTimeFormatters.dateTime(expiry.toLocal())} ${expiry.toLocal().timeZoneName}',
                  valueMaxLines: 2,
                ),
              if (amountLabel != null)
                CatchField.read(
                  copy: catchFieldCopy(context.l10n),
                  title: context.l10n.hostEventOfferAmount,
                  valueText: amountLabel!,
                ),
            ],
          ),
          if (view.status == HostOfferFlowStatus.failure && sameDraft)
            CatchSection.plain(
              child: Text(
                copy.failed,
                style: CatchTextStyles.supporting(context),
              ),
            ),
          if (view.status == HostOfferFlowStatus.committed && sameDraft)
            CatchSection.plain(
              child: Text(
                copy.committed,
                style: CatchTextStyles.supporting(context),
              ),
            ),
        ],
      );
      return layoutBuilder?.call(body, action) ??
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [body, ?action],
          );
    },
  );
}

/// Reference text is an unverified assertion. Host review is a deliberate
/// manual bank check, with no provider capture or event admission consequence.
class HostManualPaymentReviewSection extends StatefulWidget {
  const HostManualPaymentReviewSection({
    super.key,
    required this.controller,
    required this.offer,
    required this.copy,
    required this.referenceRequestId,
    required this.reviewRequestId,
    required this.onUpdated,
    this.layoutBuilder,
  });

  final HostEventOfferController controller;
  final HostEventOffer offer;
  final HostEventOfferReviewCopy copy;
  final String referenceRequestId;
  final String reviewRequestId;
  final ValueChanged<HostEventOffer> onUpdated;
  final Widget Function(Widget body, Widget? primaryAction)? layoutBuilder;

  @override
  State<HostManualPaymentReviewSection> createState() =>
      _HostManualPaymentReviewSectionState();
}

class _HostManualPaymentReviewSectionState
    extends State<HostManualPaymentReviewSection> {
  String _reference = '';
  String _note = '';
  bool _bankReceiptChecked = false;
  bool _busy = false;
  Object? _error;
  HostManualPaymentStatus? _pendingDecision;
  HostOfferPendingMutation? _pendingMutation;
  bool _checkingPending = true;
  int _recoveryGeneration = 0;

  @override
  void initState() {
    super.initState();
    _recoverMutation();
  }

  @override
  void didUpdateWidget(covariant HostManualPaymentReviewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.offer.eventId != widget.offer.eventId ||
        oldWidget.offer.contactId != widget.offer.contactId ||
        oldWidget.controller != widget.controller) {
      _recoverMutation();
    }
  }

  Future<void> _recoverMutation() async {
    final generation = ++_recoveryGeneration;
    final organizerId = widget.offer.organizerId;
    final eventId = widget.offer.eventId;
    setState(() {
      _checkingPending = true;
      _error = null;
    });
    try {
      final pending = await widget.controller.recoverPendingMutation(
        organizerId: organizerId,
        eventId: eventId,
      );
      if (mounted && generation == _recoveryGeneration) {
        setState(() => _pendingMutation = pending);
      }
    } on Object catch (error) {
      if (mounted && generation == _recoveryGeneration) {
        setState(() => _error = error);
      }
    } finally {
      if (mounted && generation == _recoveryGeneration) {
        setState(() => _checkingPending = false);
      }
    }
  }

  Future<void> _retrySavedMutation() async {
    if (_pendingMutation?.contactId != widget.offer.contactId) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await widget.controller.retryPendingMutation(
        organizerId: widget.offer.organizerId,
        eventId: widget.offer.eventId,
      );
      if (mounted) {
        setState(() => _pendingMutation = null);
        widget.onUpdated(updated);
      }
    } on Object catch (error) {
      if (mounted) {
        await _recoverMutation();
        if (mounted) setState(() => _error = error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recordReference() async {
    if (_checkingPending || _pendingMutation != null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await widget.controller.recordReference(
        offer: widget.offer,
        reference: _reference,
        requestId: widget.referenceRequestId,
      );
      if (mounted) widget.onUpdated(updated);
    } on Object catch (error) {
      if (mounted) {
        await _recoverMutation();
        if (mounted) setState(() => _error = error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review(HostManualPaymentStatus decision) async {
    if (_checkingPending || _pendingMutation != null) return;
    if (_pendingDecision != null && _pendingDecision != decision) return;
    setState(() {
      _busy = true;
      _error = null;
      _pendingDecision ??= decision;
    });
    try {
      final updated = await widget.controller.reviewReference(
        offer: widget.offer,
        decision: decision,
        note: _note,
        bankReceiptChecked:
            decision == HostManualPaymentStatus.hostAttestedReceived &&
            _bankReceiptChecked,
        requestId: widget.reviewRequestId,
      );
      if (mounted) {
        _pendingDecision = null;
        widget.onUpdated(updated);
      }
    } on Object catch (error) {
      if (mounted) {
        await _recoverMutation();
        if (mounted) setState(() => _error = error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.offer.manualPayment.status;
    final copy = widget.copy;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_pendingMutation != null) ...[
          CatchSection.plain(
            child: Text(
              copy.failed,
              style: CatchTextStyles.supporting(context),
            ),
          ),
        ],
        CatchSection.plain(
          child: Text(
            copy.noReservation,
            style: CatchTextStyles.supporting(context),
          ),
        ),
        if (status == HostManualPaymentStatus.none) ...[
          CatchSection.fieldRows(
            children: [
              CatchField.input(
                copy: catchFieldCopy(context.l10n),
                title: copy.paymentReference,
                maxLength: 240,
                contractExemption:
                    'Only a reference string is recorded; no URL or payment token.',
                onChanged: (value) => setState(() => _reference = value),
              ),
            ],
          ),
        ],
        if (status == HostManualPaymentStatus.evidenceSubmitted) ...[
          CatchSection.plain(
            child: Text(
              '${copy.evidenceSubmitted}: ${widget.offer.manualPayment.evidenceReference ?? ''}',
              style: CatchTextStyles.supporting(context),
            ),
          ),
          CatchSection.fieldRows(
            children: [
              CatchField.input(
                copy: catchFieldCopy(context.l10n),
                title: copy.reviewNote,
                maxLength: 240,
                contractExemption: 'Host manual review note only.',
                states: {
                  if (_pendingDecision != null ||
                      _checkingPending ||
                      _pendingMutation != null)
                    WidgetState.disabled,
                },
                onChanged:
                    _pendingDecision == null &&
                        !_checkingPending &&
                        _pendingMutation == null
                    ? (value) => _note = value
                    : null,
              ),
              CatchField.toggle(
                copy: catchFieldCopy(context.l10n),
                title: copy.bankReceiptChecked,
                value: _bankReceiptChecked,
                contractExemption:
                    'Explicit Host attestation after checking the bank receipt.',
                onChanged:
                    _busy ||
                        _checkingPending ||
                        _pendingMutation != null ||
                        _pendingDecision != null
                    ? null
                    : (value) => setState(() => _bankReceiptChecked = value),
              ),
            ],
          ),
          CatchSection.plain(
            child: Wrap(
              children: [
                CatchButton(
                  label: copy.rejectReference,
                  variant: CatchButtonVariant.secondary,
                  onPressed:
                      _busy ||
                          _checkingPending ||
                          _pendingMutation != null ||
                          _pendingDecision ==
                              HostManualPaymentStatus.hostAttestedReceived
                      ? null
                      : () => _review(HostManualPaymentStatus.rejected),
                ),
              ],
            ),
          ),
        ],
        if (status == HostManualPaymentStatus.hostAttestedReceived)
          CatchSection.plain(
            child: Text(
              copy.hostAttested,
              style: CatchTextStyles.supporting(context),
            ),
          ),
        if (status == HostManualPaymentStatus.rejected)
          CatchSection.plain(
            child: Text(
              copy.rejected,
              style: CatchTextStyles.supporting(context),
            ),
          ),
        if (_error != null)
          CatchSection.plain(
            child: Text(
              copy.failed,
              style: CatchTextStyles.supporting(context),
            ),
          ),
      ],
    );
    final canRetry = _pendingMutation?.contactId == widget.offer.contactId;
    final canRecord = status == HostManualPaymentStatus.none;
    final canAttest = status == HostManualPaymentStatus.evidenceSubmitted;
    final action = canRetry || canRecord || canAttest
        ? CatchDockSurface.pageAction(
            buttonKey: canRetry
                ? const ValueKey('offer-retry-saved-mutation')
                : null,
            label: canRetry
                ? (_pendingMutation!.kind ==
                          HostOfferMutationKind.recordEvidence.name
                      ? copy.recordReference
                      : _pendingMutation!.decision ==
                            HostManualPaymentStatus.rejected.name
                      ? copy.rejectReference
                      : copy.attestReceived)
                : canRecord
                ? copy.recordReference
                : copy.attestReceived,
            isLoading: _busy || _checkingPending,
            onPressed: _busy || _checkingPending
                ? null
                : canRetry
                ? _retrySavedMutation
                : _pendingMutation != null
                ? null
                : canRecord
                ? (_reference.trim().isEmpty ? null : _recordReference)
                : !_bankReceiptChecked ||
                      _pendingDecision == HostManualPaymentStatus.rejected
                ? null
                : () => _review(HostManualPaymentStatus.hostAttestedReceived),
          )
        : null;
    return widget.layoutBuilder?.call(body, action) ??
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [body, ?action],
        );
  }
}
