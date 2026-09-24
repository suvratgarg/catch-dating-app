import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/forms/host_offer_event_targets_gateway.dart';
import 'package:catch_dating_app/hosts/data/host_response_query_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_response_query.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_review_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_workspace_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_query_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  testWidgets('CRM conversion return rechecks exact selected response before '
      'offer preview', (tester) async {
    final query = HostResponseQueryController(_Query());
    final offers = _Offers();
    final offerController = HostEventOfferController(offers);
    addTearDown(query.dispose);
    addTearDown(offerController.dispose);
    await query.apply(const HostResponseQueryRequest(
      organizerId: 'org', formId: 'form', versionId: 'form_v1'));
    query.toggleSelection('response-one');
    String? contactId;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: SingleChildScrollView(
        child: HostEventOfferWorkspaceSection(
          organizerId: 'org', accountId: 'manager',
          queryController: query, offerController: offerController,
          listOffers: ({required organizerId, required eventId,
              afterOfferId}) async => const {
            'items': <Object>[], 'nextCursor': null,
          },
          targets: _Targets(),
          getResponseDetail: (_) async => _detail(contactId),
          openResponseForConversion: (_) async => contactId = 'contact-one',
          openEventSettings: (_) async {},
          copy: _copy,
          now: () => DateTime.fromMillisecondsSinceEpoch(1799990000000),
        ),
      )),
    ));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Create event offers'));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(const ValueKey('offer-target-event-one')));
    await pumpFeatureUi(tester);
    expect(find.text('Convert response first'), findsOneWidget);
    expect(offers.previewCalls, 0);

    await tester.tap(find.byKey(const ValueKey('offer-convert-response-one')));
    await pumpFeatureUi(tester);
    expect(find.text('Preview offers'), findsOneWidget);
    expect(offers.previewCalls, 0);
    await tester.tap(find.text('Preview offers'));
    await pumpFeatureUi(tester);
    expect(offers.previewCalls, 1);
    expect(offers.previewed!.rows.single.contactId, 'contact-one');
    expect(offers.previewed!.rows.single.sourceId, 'response-one');
  });

  testWidgets('changed query result blocks event choice without partial offers',
      (tester) async {
    final source = _Query();
    final query = HostResponseQueryController(source);
    final offers = _Offers();
    final offerController = HostEventOfferController(offers);
    addTearDown(query.dispose);
    addTearDown(offerController.dispose);
    await query.apply(const HostResponseQueryRequest(
      organizerId: 'org', formId: 'form', versionId: 'form_v1'));
    query.toggleSelection('response-one');
    var detailReads = 0;
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
      home: Scaffold(body: SingleChildScrollView(
        child: HostEventOfferWorkspaceSection(
          organizerId: 'org', accountId: 'manager',
          queryController: query, offerController: offerController,
          listOffers: ({required organizerId, required eventId,
              afterOfferId}) async => const {
            'items': <Object>[], 'nextCursor': null,
          },
          targets: _Targets(),
          getResponseDetail: (_) async {
            detailReads++;
            return _detail('contact-one');
          },
          openResponseForConversion: (_) async {},
          openEventSettings: (_) async {}, copy: _copy,
          now: () => DateTime.fromMillisecondsSinceEpoch(1799990000000),
        ),
      )),
    ));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Create event offers'));
    await pumpFeatureUi(tester);
    source.hash = 'changed';
    await tester.tap(find.byKey(const ValueKey('offer-target-event-one')));
    await pumpFeatureUi(tester);
    expect(find.text('Selection changed'), findsOneWidget);
    expect(detailReads, 0);
    expect(offers.previewCalls, 0);
  });
}

class _Query implements HostResponseQueryGateway {
  String hash = 'result';

  @override
  Future<HostResponseQueryPage> query(HostResponseQueryRequest request) async =>
      HostResponseQueryPage(
        form: const HostResponseQueryForm(
          formId: 'form', title: 'Form', versionId: 'form_v1', version: 1),
        items: [HostResponseQueryRow.fromMap(const {
          'responseId': 'response-one', 'formId': 'form',
          'formTitle': 'Form', 'versionId': 'form_v1', 'version': 1,
          'status': 'submitted', 'identityKind': 'phoneVerified',
          'identity': {'displayName': 'Maya', 'email': null,
            'phoneE164': null, 'origin': 'respondentGranted'},
          'sourceLinkId': null, 'submittedAtMillis': 1790000000000,
          'withdrawnAtMillis': null,
        })],
        nextCursor: null, total: 1, selectedIds: const {'response-one'},
        queryHash: 'query', resultHash: hash, fieldCatalog: const [],
      );
}

class _Targets implements HostOfferEventTargetsGateway {
  @override
  Future<HostOfferEventTargetPage> list({required String organizerId,
      String? cursor}) async => HostOfferEventTargetPage([
        HostOfferEventTarget(
          eventId: 'event-one', name: 'Sunday run',
          startTime: _start, timezone: 'Asia/Kolkata',
          publicationState: 'private', setupRevision: 1),
      ], null);

  @override
  Future<HostOfferEventConfiguration> configuration({
    required String organizerId, required String eventId,
  }) async => HostOfferEventConfiguration(
    organizerId: organizerId, eventId: eventId,
    eventSourceRevision: 1, startsAt: _start,
    serverNow: DateTime.fromMillisecondsSinceEpoch(1799990000000),
    paymentTerms: const {'preferredCollection': 'manualInstructions'},
    suggestedExpiresAt: DateTime.fromMillisecondsSinceEpoch(1799995000000),
  );
}

final _start = DateTime.fromMillisecondsSinceEpoch(1800000000000);

HostFormResponseDetail _detail(String? contactId) => HostFormResponseDetail(
  response: HostFormResponseSummary(
    responseId: 'response-one', formId: 'form', formTitle: 'Form',
    versionId: 'form_v1', version: 1,
    status: HostFormResponseStatus.submitted,
    identityKind: HostFormResponseIdentityKind.phoneVerified,
    identity: const HostFormResponseIdentity(
      displayName: 'Maya', email: null, phoneE164: null,
      origin: HostFormDataOrigin.respondentGranted),
    sourceLinkId: null, sourceLabel: null,
    submittedAt: DateTime.fromMillisecondsSinceEpoch(1790000000000),
    withdrawnAt: null, highlights: const [], conversionKinds: const {},
  ),
  contactId: contactId, answers: const [], consentVersion: 'v1',
  completionMillis: 1790000000000,
);

class _Offers implements HostEventOfferGateway {
  int previewCalls = 0;
  HostOfferBatchDraft? previewed;

  @override
  Future<HostOfferPreview> preview(HostOfferBatchDraft draft) async {
    previewCalls++;
    previewed = draft;
    return const HostOfferPreview(planDigest: 'digest', rows: [
      HostOfferPreviewRow(offerId: 'offer-one', revision: 0,
        generation: 0, status: 'new'),
    ]);
  }

  @override
  Future<HostOfferCommitReceipt> commit({required HostOfferBatchDraft draft,
      required HostOfferPreview preview, required String requestId}) =>
      throw UnimplementedError();

  @override
  Future<HostEventOffer> recordReference({required HostEventOffer offer,
      required String reference, required String requestId}) =>
      throw UnimplementedError();

  @override
  Future<HostEventOffer> reviewReference({required HostEventOffer offer,
      required HostManualPaymentStatus decision, required String note,
      required bool bankReceiptChecked, required String requestId}) =>
      throw UnimplementedError();
}

final _copy = HostEventOfferWorkspaceCopy(
  create: 'Create event offers', selectEvent: 'Choose an event',
  emptyEvents: 'No events', untitledEvent: 'Untitled event',
  loadMoreEvents: 'Load more events', needsContact: 'Convert response first',
  convertContact: 'Create CRM contact', selectionChanged: 'Selection changed',
  loadFailed: 'Load failed', issued: 'Offers recorded', refresh: 'Refresh',
  existing: 'Existing offers', noOffers: 'No offers',
  configurePayment: 'Configure payment', openSettings: 'Open settings',
  statusDraft: 'Draft', statusOffered: 'Offered',
  statusWithdrawn: 'Withdrawn', statusExpired: 'Expired',
  personalPaymentLink: (name) => 'Personal payment link for $name',
  review: HostEventOfferReviewCopy(
    title: 'Event offer', preview: 'Preview offers',
    previewing: 'Checking', review: 'Review offer details',
    expires: (date) => 'Expires $date', commit: 'Record offers',
    committing: 'Recording', committed: 'Recorded', failed: 'Failed',
    noReservation: 'No seat or admission', paymentReference: 'Reference',
    recordReference: 'Record', evidenceSubmitted: 'Submitted',
    bankReceiptChecked: 'Checked', reviewNote: 'Note',
    attestReceived: 'Attest', rejectReference: 'Reject',
    hostAttested: 'Attested', rejected: 'Rejected',
  ),
);
