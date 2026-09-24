import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 9, 24);
  final eventStart = DateTime.utc(2026, 10, 2);

  test(
    'one response may feed event-specific offers, never a duplicate contact',
    () {
      final first = _row(eventId: 'event-one');
      final second = _row(eventId: 'event-two');
      HostOfferBatchDraft(
        organizerId: 'org',
        eventId: 'event-one',
        rows: [first],
      ).validate(now: now, eventStartsAt: eventStart);
      HostOfferBatchDraft(
        organizerId: 'org',
        eventId: 'event-two',
        rows: [second],
      ).validate(now: now, eventStartsAt: eventStart);
      expect(
        () => HostOfferBatchDraft(
          organizerId: 'org',
          eventId: 'event-one',
          rows: [first, first],
        ).validate(now: now, eventStartsAt: eventStart),
        throwsArgumentError,
      );
      expect(first.toJson()['applicationId'], 'response-kabir');
      expect(first.toJson()['sourceKind'], 'formResponse');
    },
  );

  test('expiry and public HTTPS link are validated before review', () {
    expect(
      () => _row(
        eventId: 'event-one',
        expiry: eventStart.add(const Duration(minutes: 1)),
      ).validate(now: now, eventStartsAt: eventStart),
      throwsArgumentError,
    );
    expect(
      () => _row(
        eventId: 'event-one',
        link: Uri.parse('http://example.com/pay'),
      ).validate(now: now, eventStartsAt: eventStart),
      throwsArgumentError,
    );
  });

  test(
    'preview gates commit; uncertain retry keeps the same request ID',
    () async {
      final gateway = _Gateway()..failFirstCommit = true;
      final controller = HostEventOfferController(gateway);
      addTearDown(controller.dispose);
      final draft = HostOfferBatchDraft(
        organizerId: 'org',
        eventId: 'event-one',
        rows: [_row(eventId: 'event-one')],
      );
      await expectLater(controller.commit('request_001'), throwsStateError);
      await controller.preview(
        draft: draft,
        now: now,
        eventStartsAt: eventStart,
      );
      expect(controller.view.canCommit, isTrue);
      expect(gateway.previewCalls, 1);
      expect(gateway.commitCalls, isEmpty);

      await controller.commit('request_001');
      expect(controller.view.status, HostOfferFlowStatus.failure);
      expect(controller.view.pendingRequestId, 'request_001');
      await expectLater(controller.commit('request_002'), throwsStateError);
      await controller.commit('request_001');
      expect(controller.view.status, HostOfferFlowStatus.committed);
      expect(gateway.commitCalls, ['request_001', 'request_001']);
      expect(controller.view.receipt?.results.single.offerId, 'offer-kabir');
    },
  );

  test(
    'reference and Host bank attestation cannot imply provider capture',
    () async {
      final gateway = _Gateway();
      final controller = HostEventOfferController(gateway);
      addTearDown(controller.dispose);
      final offered = _offer(HostManualPaymentStatus.none);
      expect(
        () => controller.recordReference(
          offer: offered,
          reference: 'https://example.com/receipt',
          requestId: 'reference_001',
        ),
        throwsArgumentError,
      );
      await controller.recordReference(
        offer: offered,
        reference: 'BANK-12345',
        requestId: 'reference_001',
      );
      expect(gateway.recordedReferences, ['BANK-12345']);

      final evidence = _offer(HostManualPaymentStatus.evidenceSubmitted);
      expect(
        () => controller.reviewReference(
          offer: evidence,
          decision: HostManualPaymentStatus.hostAttestedReceived,
          note: 'Checked in bank',
          bankReceiptChecked: false,
          requestId: 'review_001',
        ),
        throwsArgumentError,
      );
      expect(gateway.reviewCalls, isEmpty);
      await controller.reviewReference(
        offer: evidence,
        decision: HostManualPaymentStatus.hostAttestedReceived,
        note: 'Checked in bank',
        bankReceiptChecked: true,
        requestId: 'review_001',
      );
      expect(
        gateway.reviewCalls.single,
        HostManualPaymentStatus.hostAttestedReceived,
      );
      expect(gateway.admissionCalls, 0);
    },
  );
}

HostOfferRow _row({required String eventId, DateTime? expiry, Uri? link}) =>
    HostOfferRow(
      organizerId: 'org',
      eventId: eventId,
      contactId: 'contact-kabir',
      sourceKind: HostOfferSourceKind.formResponse,
      sourceId: 'response-kabir',
      expiresAt: expiry ?? DateTime.utc(2026, 9, 30),
      organizerPaymentLink: link,
    );

HostEventOffer _offer(HostManualPaymentStatus paymentStatus) => HostEventOffer(
  offerId: 'offer-kabir',
  organizerId: 'org',
  eventId: 'event-one',
  contactId: 'contact-kabir',
  sourceId: 'response-kabir',
  sourceKind: HostOfferSourceKind.formResponse,
  status: HostOfferStatus.offered,
  effectiveStatus: HostOfferStatus.offered,
  generation: 1,
  revision: 2,
  expiresAt: DateTime.utc(2026, 9, 30),
  organizerPaymentLink: Uri.parse('https://example.com/pay'),
  manualPayment: HostManualPaymentReview(
    status: paymentStatus,
    evidenceReference: paymentStatus == HostManualPaymentStatus.none
        ? null
        : 'BANK-12345',
    evidenceRecordedAt: null,
    reviewedByUid: null,
    reviewedAt: null,
    reviewNote: null,
    bankReceiptChecked: false,
  ),
);

class _Gateway implements HostEventOfferGateway {
  int previewCalls = 0;
  final List<String> commitCalls = [];
  final List<String> recordedReferences = [];
  final List<HostManualPaymentStatus> reviewCalls = [];
  int admissionCalls = 0;
  bool failFirstCommit = false;

  @override
  Future<HostOfferPreview> preview(HostOfferBatchDraft draft) async {
    previewCalls++;
    return const HostOfferPreview(
      planDigest: 'digest-one',
      rows: [
        HostOfferPreviewRow(
          offerId: 'offer-kabir',
          revision: 0,
          generation: 0,
          status: 'new',
        ),
      ],
    );
  }

  @override
  Future<HostOfferCommitReceipt> commit({
    required HostOfferBatchDraft draft,
    required HostOfferPreview preview,
    required String requestId,
  }) async {
    commitCalls.add(requestId);
    if (failFirstCommit && commitCalls.length == 1) {
      throw StateError('uncertain network result');
    }
    return HostOfferCommitReceipt(
      organizerId: draft.organizerId,
      eventId: draft.eventId,
      requestId: requestId,
      results: const [
        HostOfferPreviewRow(
          offerId: 'offer-kabir',
          revision: 2,
          generation: 1,
          status: 'committed',
        ),
      ],
    );
  }

  @override
  Future<HostEventOffer> recordReference({
    required HostEventOffer offer,
    required String reference,
    required String requestId,
  }) async {
    recordedReferences.add(reference);
    return offer;
  }

  @override
  Future<HostEventOffer> reviewReference({
    required HostEventOffer offer,
    required HostManualPaymentStatus decision,
    required String note,
    required bool bankReceiptChecked,
    required String requestId,
  }) async {
    reviewCalls.add(decision);
    return offer;
  }
}
