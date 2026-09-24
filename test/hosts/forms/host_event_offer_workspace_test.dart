import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/forms/host_offer_event_targets_gateway.dart';
import 'package:catch_dating_app/hosts/data/host_response_query_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_response_query.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_review_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_workspace_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_event_offer_workspace_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_query_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_responses_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_pump_helpers.dart';

void main() {
  test('response query mount preserves external search and contact scope', () {
    bool allowed({String? search, String? contact}) =>
        canMountHostResponseQuery(enabled: true, formId: 'form',
          searchQuery: search, contactId: contact);
    expect(allowed(), isTrue);
    expect(allowed(search: 'Maya'), isFalse);
    expect(allowed(contact: 'contact-one'), isFalse);
    expect(canMountHostResponseQuery(enabled: true, formId: null,
      searchQuery: null, contactId: null), isFalse);
  });

  test('newly saved manager target bypasses first-page discovery but still '
      'revalidates responses and current event configuration', () async {
    final source = _Query();
    final query = HostResponseQueryController(source);
    final offers = HostEventOfferController(_Offers());
    final targets = _Targets();
    addTearDown(query.dispose);
    addTearDown(offers.dispose);
    await query.apply(const HostResponseQueryRequest(
      organizerId: 'org', formId: 'form', versionId: 'form_v1'));
    query.toggleSelection('response-one');
    final workspace = HostEventOfferWorkspaceController(
      organizerId: 'org', accountId: 'manager',
      queryController: query, offerController: offers,
      listOffers: ({required organizerId, required eventId,
          afterOfferId}) async => const {'items': <Object>[], 'nextCursor': null},
      getOffer: ({required organizerId, required eventId,
          required contactId}) async => _existingOffer(),
      prepareHandoff: ({required offer}) async => const HostOfferHandoff(
        kind: 'blocked', offerId: 'offer-one', blockers: ['fixture']),
      copyMessage: (_) async {}, openHandoff: (_) async => false,
      targets: targets,
      getResponseDetail: (_) async => _detail('contact-one'),
      openResponseForConversion: (_) async {},
      openEventSettings: (_) async => targets.revision = 2,
      now: () => DateTime.fromMillisecondsSinceEpoch(1799990000000),
      initialEventTarget: HostOfferEventTarget(
        eventId: 'event-one', name: 'Freshly saved', startTime: _start,
        timezone: 'Asia/Kolkata', publicationState: 'private',
        setupRevision: 1),
    );
    addTearDown(workspace.dispose);
    await workspace.start();
    expect(targets.listCalls, 0);
    expect(targets.configurationCalls, 1);
    expect(workspace.event?.name, 'Freshly saved');
    await workspace.openSettings();
    expect(workspace.event?.setupRevision, 2);
    expect(targets.configurationCalls, 3);
    source.hash = 'changed';
    await workspace.choose(workspace.event!);
    expect(workspace.selectionStale, isTrue);
    expect(targets.configurationCalls, 3);
  });

  test('workspace controller invalidates selected offer context when the '
      'underlying query selection changes', () async {
    final query = HostResponseQueryController(_Query());
    final offers = HostEventOfferController(_Offers());
    addTearDown(query.dispose);
    addTearDown(offers.dispose);
    await query.apply(const HostResponseQueryRequest(
      organizerId: 'org', formId: 'form', versionId: 'form_v1'));
    query.toggleSelection('response-one');
    final workspace = HostEventOfferWorkspaceController(
      organizerId: 'org', accountId: 'manager',
      queryController: query, offerController: offers,
      listOffers: ({required organizerId, required eventId,
          afterOfferId}) async => const {
        'items': <Object>[], 'nextCursor': null,
      },
      getOffer: ({required organizerId, required eventId,
          required contactId}) async => _existingOffer(),
      prepareHandoff: ({required offer}) async => const HostOfferHandoff(
        kind: 'blocked', offerId: 'offer-one', blockers: ['fixture']),
      copyMessage: (_) async {}, openHandoff: (_) async => false,
      targets: _Targets(), getResponseDetail: (_) async => _detail('contact-one'),
      openResponseForConversion: (_) async {},
      openEventSettings: (_) async {},
      now: () => DateTime.fromMillisecondsSinceEpoch(1799990000000),
    );
    addTearDown(workspace.dispose);

    await workspace.start();
    expect(workspace.ids, ['response-one']);
    expect(workspace.events.single.eventId, 'event-one');
    query.clearSelection();
    expect(workspace.ids, isEmpty);
    expect(workspace.events, isEmpty);
    expect(workspace.draft, isNull);
  });

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
          getOffer: ({required organizerId, required eventId,
              required contactId}) async => _existingOffer(),
          prepareHandoff: ({required offer}) async =>
              const HostOfferHandoff(kind: 'blocked', offerId: 'offer-one',
                blockers: ['fixture']),
          copyMessage: (_) async {}, openHandoff: (_) async => false,
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
          getOffer: ({required organizerId, required eventId,
              required contactId}) async => _existingOffer(),
          prepareHandoff: ({required offer}) async =>
              const HostOfferHandoff(kind: 'blocked', offerId: 'offer-one',
                blockers: ['fixture']),
          copyMessage: (_) async {}, openHandoff: (_) async => false,
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

  testWidgets('existing offer opens reviewed manual state and prepared handoff '
      'without recording a send', (tester) async {
    final query = HostResponseQueryController(_Query());
    final offers = _Offers();
    final controller = HostEventOfferController(offers);
    addTearDown(query.dispose);
    addTearDown(controller.dispose);
    await query.apply(const HostResponseQueryRequest(
      organizerId: 'org', formId: 'form', versionId: 'form_v1'));
    query.toggleSelection('response-one');
    final copied = <String>[];
    final opened = <Uri>[];
    var preparations = 0;
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
      home: Scaffold(body: SingleChildScrollView(
        child: HostEventOfferWorkspaceSection(
          organizerId: 'org', accountId: 'manager',
          queryController: query, offerController: controller,
          listOffers: ({required organizerId, required eventId,
              afterOfferId}) async => const {
            'items': [
              {'offerId': 'offer-one', 'eventId': 'event-one',
                'contactId': 'contact-one', 'effectiveStatus': 'offered'},
              {'offerId': 'unrelated-offer', 'eventId': 'event-one',
                'contactId': 'another-contact', 'effectiveStatus': 'offered'},
            ], 'nextCursor': null,
          },
          getOffer: ({required organizerId, required eventId,
              required contactId}) async => _existingOffer(),
          prepareHandoff: ({required offer}) async {
            preparations++;
            return HostOfferHandoff(kind: 'prepared',
              offerId: offer.offerId, contactId: offer.contactId,
              editableText: 'Hi Maya', copyText: 'Hi Maya',
              whatsappUrl: Uri.parse('https://wa.me/911234567890'));
          },
          copyMessage: (text) async => copied.add(text),
          openHandoff: (uri) async { opened.add(uri); return true; },
          targets: _Targets(),
          getResponseDetail: (_) async => _detail('contact-one'),
          openResponseForConversion: (_) async {},
          openEventSettings: (_) async {}, copy: _copy,
          now: () => DateTime.fromMillisecondsSinceEpoch(1799990000000),
        ),
      )),
    ));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Create event offers'));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(const ValueKey('offer-target-event-one')));
    await pumpFeatureUi(tester);
    expect(find.byKey(const ValueKey('offer-existing-unrelated-offer')),
      findsNothing);
    await tester.tap(find.byKey(const ValueKey('offer-existing-offer-one')));
    await pumpFeatureUi(tester);
    expect(find.text('Payment reference'), findsOneWidget);
    await tester.tap(find.text('Prepare personal handoff'));
    await pumpFeatureUi(tester);
    expect(preparations, 1);
    expect(find.text('Hi Maya'), findsOneWidget);
    await tester.tap(find.text('Copy message'));
    await pumpFeatureUi(tester);
    expect(copied, ['Hi Maya']);
    await tester.tap(find.text('Open WhatsApp'));
    await pumpFeatureUi(tester);
    expect(opened.single.host, 'wa.me');
    expect(find.text('Message copied. Sending is your choice.'),
      findsOneWidget);
    expect(offers.previewCalls, 0);
  });

  testWidgets('existing offer discovers and replays saved manual command',
      (tester) async {
    final query = HostResponseQueryController(_Query());
    final pending = _PendingMutation();
    final controller = HostEventOfferController(_Offers(),
      mutationOutbox: pending, accountId: 'manager');
    addTearDown(query.dispose);
    addTearDown(controller.dispose);
    await query.apply(const HostResponseQueryRequest(
      organizerId: 'org', formId: 'form', versionId: 'form_v1'));
    query.toggleSelection('response-one');
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
      home: Scaffold(body: SingleChildScrollView(
        child: HostEventOfferWorkspaceSection(
          organizerId: 'org', accountId: 'manager',
          queryController: query, offerController: controller,
          listOffers: ({required organizerId, required eventId,
              afterOfferId}) async => const {
            'items': [{'offerId': 'offer-one', 'eventId': 'event-one',
              'contactId': 'contact-one', 'effectiveStatus': 'offered'}],
            'nextCursor': null,
          },
          getOffer: ({required organizerId, required eventId,
              required contactId}) async => _existingOffer(),
          prepareHandoff: ({required offer}) async => HostOfferHandoff(
            kind: 'blocked', offerId: offer.offerId, blockers: const ['fixture']),
          copyMessage: (_) async {}, openHandoff: (_) async => false,
          targets: _Targets(),
          getResponseDetail: (_) async => _detail('contact-one'),
          openResponseForConversion: (_) async {},
          openEventSettings: (_) async {}, copy: _copy,
          now: () => DateTime.fromMillisecondsSinceEpoch(1799990000000),
        ),
      )),
    ));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Create event offers'));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(const ValueKey('offer-target-event-one')));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(const ValueKey('offer-existing-offer-one')));
    await pumpFeatureUi(tester);
    expect(pending.reads, greaterThan(0));
    expect(find.byKey(const ValueKey('offer-retry-saved-mutation')),
      findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('offer-retry-saved-mutation')));
    await pumpFeatureUi(tester);
    expect(pending.replays, 1);
    expect(pending.newMutations, 0);
  });
}

class _PendingMutation implements HostOfferMutationOutbox {
  bool unresolved = true;
  int reads = 0;
  int replays = 0;
  int newMutations = 0;

  @override
  Future<HostOfferPendingMutation?> pendingMutation({required String accountId,
      required String organizerId, required String eventId}) async {
    reads++;
    return unresolved ? const HostOfferPendingMutation(
      requestId: 'reference_saved', contactId: 'contact-one',
      kind: 'recordEvidence', decision: null) : null;
  }

  @override
  Future<HostEventOffer> replayMutation({required String accountId,
      required String organizerId, required String eventId}) async {
    replays++;
    unresolved = false;
    return _existingOffer();
  }

  @override
  Future<HostEventOffer> mutate({required String accountId,
      required HostEventOffer offer,
      required Map<String, Object?> action}) async {
    newMutations++;
    return offer;
  }
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
  int listCalls = 0;
  int configurationCalls = 0;
  int revision = 1;
  @override
  Future<HostOfferEventTargetPage> list({required String organizerId,
      String? cursor}) async {
    listCalls++;
    return HostOfferEventTargetPage([
        HostOfferEventTarget(
          eventId: 'event-one', name: 'Sunday run',
          startTime: _start, timezone: 'Asia/Kolkata',
          publicationState: 'private', setupRevision: 1),
      ], null);
  }

  @override
  Future<HostOfferEventConfiguration> configuration({
    required String organizerId, required String eventId,
  }) async {
    configurationCalls++;
    return HostOfferEventConfiguration(
    organizerId: organizerId, eventId: eventId,
    eventSourceRevision: revision, startsAt: _start,
    serverNow: DateTime.fromMillisecondsSinceEpoch(1799990000000),
    paymentTerms: const {'preferredCollection': 'manualInstructions'},
    suggestedExpiresAt: DateTime.fromMillisecondsSinceEpoch(1799995000000),
  );
  }
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
  openExisting: 'Review offer',
  handoffPrepare: 'Prepare personal handoff',
  handoffBlocked: 'Handoff unavailable',
  handoffDisclosure: 'Review and send in WhatsApp; Catch cannot track it.',
  openWhatsapp: 'Open WhatsApp', copyMessage: 'Copy message',
  messageCopied: 'Message copied. Sending is your choice.',
  handoffOpenFailed: 'Could not open WhatsApp.',
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

HostEventOffer _existingOffer() => HostEventOffer(
  offerId: 'offer-one', organizerId: 'org', eventId: 'event-one',
  contactId: 'contact-one', sourceId: 'response-one',
  sourceKind: HostOfferSourceKind.formResponse,
  status: HostOfferStatus.offered,
  effectiveStatus: HostOfferStatus.offered,
  generation: 1, revision: 2,
  expiresAt: DateTime.fromMillisecondsSinceEpoch(1799995000000),
  organizerPaymentLink: null,
  manualPayment: const HostManualPaymentReview(
    status: HostManualPaymentStatus.none, evidenceReference: null,
    evidenceRecordedAt: null, reviewedByUid: null, reviewedAt: null,
    reviewNote: null, bankReceiptChecked: false),
);
