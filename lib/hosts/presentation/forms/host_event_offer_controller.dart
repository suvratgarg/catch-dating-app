import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:flutter/foundation.dart';

/// The gateway is bound to manager-only callables after shared contracts land.
/// No client-supplied authority flags, seat holds or provider state are accepted.
abstract interface class HostEventOfferGateway {
  Future<HostOfferPreview> preview(HostOfferBatchDraft draft);

  Future<HostOfferCommitReceipt> commit({
    required HostOfferBatchDraft draft,
    required HostOfferPreview preview,
    required String requestId,
  });

  Future<HostEventOffer> recordReference({
    required HostEventOffer offer,
    required String reference,
    required String requestId,
  });

  Future<HostEventOffer> reviewReference({
    required HostEventOffer offer,
    required HostManualPaymentStatus decision,
    required String note,
    required bool bankReceiptChecked,
    required String requestId,
  });
}

enum HostOfferFlowStatus {
  idle,
  previewing,
  review,
  committing,
  committed,
  failure,
}

@immutable
class HostOfferFlowView {
  const HostOfferFlowView({
    required this.status,
    this.draft,
    this.preview,
    this.receipt,
    this.pendingRequestId,
    this.error,
  });

  final HostOfferFlowStatus status;
  final HostOfferBatchDraft? draft;
  final HostOfferPreview? preview;
  final HostOfferCommitReceipt? receipt;
  final String? pendingRequestId;
  final Object? error;

  bool get canCommit =>
      status == HostOfferFlowStatus.review && draft != null && preview != null;
}

/// Holds one reviewed batch from preview through idempotent commit. A changed
/// source, CRM contact, event or terms requires a fresh preview.
class HostEventOfferController extends ChangeNotifier {
  HostEventOfferController(this._gateway);

  final HostEventOfferGateway _gateway;
  int _generation = 0;
  bool _disposed = false;
  HostOfferFlowView _view = const HostOfferFlowView(
    status: HostOfferFlowStatus.idle,
  );

  HostOfferFlowView get view => _view;

  Future<void> preview({
    required HostOfferBatchDraft draft,
    required DateTime now,
    required DateTime eventStartsAt,
  }) async {
    draft.validate(now: now, eventStartsAt: eventStartsAt);
    final generation = ++_generation;
    _publish(
      HostOfferFlowView(status: HostOfferFlowStatus.previewing, draft: draft),
    );
    try {
      final preview = await _gateway.preview(draft);
      if (!_isCurrent(generation)) return;
      if (preview.rows.length != draft.rows.length ||
          preview.rows.any((row) => row.status != 'new')) {
        throw const FormatException('Offer preview is not a new batch.');
      }
      _publish(
        HostOfferFlowView(
          status: HostOfferFlowStatus.review,
          draft: draft,
          preview: preview,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(generation)) return;
      _publish(
        HostOfferFlowView(
          status: HostOfferFlowStatus.failure,
          draft: draft,
          error: error,
        ),
      );
    }
  }

  Future<void> commit(String requestId) async {
    final current = _view;
    if (current.draft == null ||
        current.preview == null ||
        (current.status != HostOfferFlowStatus.review &&
            current.status != HostOfferFlowStatus.failure) ||
        current.pendingRequestId != null &&
            current.pendingRequestId != requestId ||
        !RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{7,99}$').hasMatch(requestId)) {
      throw StateError('Review the current offer batch before committing.');
    }
    final generation = _generation;
    _publish(
      HostOfferFlowView(
        status: HostOfferFlowStatus.committing,
        draft: current.draft,
        preview: current.preview,
        pendingRequestId: requestId,
      ),
    );
    try {
      final receipt = await _gateway.commit(
        draft: current.draft!,
        preview: current.preview!,
        requestId: requestId,
      );
      if (!_isCurrent(generation)) return;
      if (receipt.requestId != requestId ||
          receipt.organizerId != current.draft!.organizerId ||
          receipt.eventId != current.draft!.eventId ||
          receipt.results.length != current.draft!.rows.length) {
        throw const FormatException('Offer receipt does not match the review.');
      }
      _publish(
        HostOfferFlowView(
          status: HostOfferFlowStatus.committed,
          draft: current.draft,
          preview: current.preview,
          receipt: receipt,
          pendingRequestId: requestId,
        ),
      );
    } on Object catch (error) {
      if (!_isCurrent(generation)) return;
      // Preserve the exact request ID for an uncertain network retry.
      _publish(
        HostOfferFlowView(
          status: HostOfferFlowStatus.failure,
          draft: current.draft,
          preview: current.preview,
          pendingRequestId: requestId,
          error: error,
        ),
      );
    }
  }

  Future<HostEventOffer> recordReference({
    required HostEventOffer offer,
    required String reference,
    required String requestId,
  }) {
    final normalized = reference.trim();
    if (offer.manualPayment.status != HostManualPaymentStatus.none ||
        normalized.length < 3 ||
        normalized.length > 240 ||
        RegExp(r'^[a-z]+://', caseSensitive: false).hasMatch(normalized)) {
      throw ArgumentError('Enter a new payment reference, not a URL.');
    }
    return _gateway.recordReference(
      offer: offer,
      reference: normalized,
      requestId: requestId,
    );
  }

  Future<HostEventOffer> reviewReference({
    required HostEventOffer offer,
    required HostManualPaymentStatus decision,
    required String note,
    required bool bankReceiptChecked,
    required String requestId,
  }) {
    final normalized = note.trim();
    if (offer.manualPayment.status !=
            HostManualPaymentStatus.evidenceSubmitted ||
        decision != HostManualPaymentStatus.hostAttestedReceived &&
            decision != HostManualPaymentStatus.rejected ||
        normalized.length < 3 ||
        normalized.length > 240 ||
        decision == HostManualPaymentStatus.hostAttestedReceived &&
            !bankReceiptChecked) {
      throw ArgumentError('Check bank evidence and record a review reason.');
    }
    return _gateway.reviewReference(
      offer: offer,
      decision: decision,
      note: normalized,
      bankReceiptChecked: bankReceiptChecked,
      requestId: requestId,
    );
  }

  void _publish(HostOfferFlowView next) {
    if (_disposed) return;
    _view = next;
    notifyListeners();
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    super.dispose();
  }
}
