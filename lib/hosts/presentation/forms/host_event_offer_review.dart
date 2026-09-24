import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
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
class HostEventOfferReview extends StatelessWidget {
  const HostEventOfferReview({
    super.key,
    required this.controller,
    required this.draft,
    required this.eventTitle,
    required this.contactLabel,
    required this.eventStartsAt,
    required this.now,
    required this.commitRequestId,
    required this.copy,
  });

  final HostEventOfferController controller;
  final HostOfferBatchDraft draft;
  final String eventTitle;
  final String Function(String contactId) contactLabel;
  final DateTime eventStartsAt;
  final DateTime Function() now;
  final String commitRequestId;
  final HostEventOfferReviewCopy copy;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final view = controller.view;
      final sameDraft = identical(view.draft, draft);
      return CatchSection.content(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(copy.title, style: CatchTextStyles.sectionTitle(context)),
            gapH8,
            Text(
              copy.noReservation,
              style: CatchTextStyles.supporting(context),
            ),
            gapH16,
            if (view.status == HostOfferFlowStatus.previewing)
              Text(copy.previewing, style: CatchTextStyles.supporting(context)),
            if (view.status == HostOfferFlowStatus.review && sameDraft) ...[
              Text(copy.review, style: CatchTextStyles.supporting(context)),
              gapH8,
              Text(eventTitle, style: CatchTextStyles.bodyM(context)),
              for (final row in draft.rows)
                Text(
                  '${contactLabel(row.contactId)} · ${copy.expires(MaterialLocalizations.of(context).formatMediumDate(row.expiresAt.toLocal()))}',
                  style: CatchTextStyles.bodyM(context),
                ),
              gapH16,
            ],
            if (view.status == HostOfferFlowStatus.committing && sameDraft)
              Text(copy.committing, style: CatchTextStyles.supporting(context)),
            if (view.status == HostOfferFlowStatus.committed && sameDraft)
              Text(copy.committed, style: CatchTextStyles.supporting(context)),
            if (view.status == HostOfferFlowStatus.failure && sameDraft)
              Text(copy.failed, style: CatchTextStyles.supporting(context)),
            gapH16,
            if (view.status != HostOfferFlowStatus.committed || !sameDraft)
              CatchButton(
                label: copy.preview,
                variant: CatchButtonVariant.secondary,
                onPressed:
                    view.status == HostOfferFlowStatus.previewing ||
                        view.status == HostOfferFlowStatus.committing
                    ? null
                    : () => controller.preview(
                        draft: draft,
                        now: now(),
                        eventStartsAt: eventStartsAt,
                      ),
              ),
            if (sameDraft && view.canCommit) ...[
              gapH8,
              CatchButton(
                label: copy.commit,
                onPressed: () => controller.commit(commitRequestId),
              ),
            ],
            if (sameDraft &&
                view.status == HostOfferFlowStatus.failure &&
                view.pendingRequestId == commitRequestId) ...[
              gapH8,
              CatchButton(
                label: copy.commit,
                onPressed: () => controller.commit(commitRequestId),
              ),
            ],
          ],
        ),
      );
    },
  );
}

/// Reference text is an unverified assertion. Host review is a deliberate
/// manual bank check, with no provider capture or event admission consequence.
class HostManualPaymentReviewPanel extends StatefulWidget {
  const HostManualPaymentReviewPanel({
    super.key,
    required this.controller,
    required this.offer,
    required this.copy,
    required this.referenceRequestId,
    required this.reviewRequestId,
    required this.onUpdated,
  });

  final HostEventOfferController controller;
  final HostEventOffer offer;
  final HostEventOfferReviewCopy copy;
  final String referenceRequestId;
  final String reviewRequestId;
  final ValueChanged<HostEventOffer> onUpdated;

  @override
  State<HostManualPaymentReviewPanel> createState() =>
      _HostManualPaymentReviewPanelState();
}

class _HostManualPaymentReviewPanelState
    extends State<HostManualPaymentReviewPanel> {
  String _reference = '';
  String _note = '';
  bool _bankReceiptChecked = false;
  bool _busy = false;
  Object? _error;
  HostManualPaymentStatus? _pendingDecision;

  Future<void> _recordReference() async {
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
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _review(HostManualPaymentStatus decision) async {
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
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.offer.manualPayment.status;
    final copy = widget.copy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchSection.content(
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
                onChanged: (value) => _reference = value,
              ),
            ],
          ),
          CatchSection.content(
            child: CatchButton(
              label: copy.recordReference,
              onPressed: _busy ? null : _recordReference,
            ),
          ),
        ],
        if (status == HostManualPaymentStatus.evidenceSubmitted) ...[
          CatchSection.content(
            child: Text(
              '${copy.evidenceSubmitted}: ${widget.offer.manualPayment.evidenceReference ?? ''}',
              style: CatchTextStyles.bodyM(context),
            ),
          ),
          CatchSection.fieldRows(
            children: [
              CatchField.input(
                copy: catchFieldCopy(context.l10n),
                title: copy.reviewNote,
                maxLength: 240,
                contractExemption: 'Host manual review note only.',
                states: {if (_pendingDecision != null) WidgetState.disabled},
                onChanged: _pendingDecision == null
                    ? (value) => _note = value
                    : null,
              ),
              CatchField.toggle(
                copy: catchFieldCopy(context.l10n),
                title: copy.bankReceiptChecked,
                value: _bankReceiptChecked,
                contractExemption:
                    'Explicit Host attestation after checking the bank receipt.',
                onChanged: _busy || _pendingDecision != null
                    ? null
                    : (value) => setState(() => _bankReceiptChecked = value),
              ),
            ],
          ),
          CatchSection.content(
            child: Wrap(
              children: [
                CatchButton(
                  label: copy.attestReceived,
                  onPressed:
                      _busy ||
                          !_bankReceiptChecked ||
                          _pendingDecision == HostManualPaymentStatus.rejected
                      ? null
                      : () => _review(
                          HostManualPaymentStatus.hostAttestedReceived,
                        ),
                ),
                CatchButton(
                  label: copy.rejectReference,
                  variant: CatchButtonVariant.secondary,
                  onPressed:
                      _busy ||
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
          CatchSection.content(
            child: Text(
              copy.hostAttested,
              style: CatchTextStyles.supporting(context),
            ),
          ),
        if (status == HostManualPaymentStatus.rejected)
          CatchSection.content(
            child: Text(
              copy.rejected,
              style: CatchTextStyles.supporting(context),
            ),
          ),
        if (_error != null)
          CatchSection.content(
            child: Text(
              copy.failed,
              style: CatchTextStyles.supporting(context),
            ),
          ),
      ],
    );
  }
}
