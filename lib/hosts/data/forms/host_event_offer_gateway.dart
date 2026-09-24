import 'dart:convert';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/persistence/command_journal_storage.dart';
import 'package:catch_dating_app/core/persistence/local_command_journal.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_event_offer.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Manager-only callable transport. Rollout stays gated by the Host route.
class CallableHostEventOfferGateway implements HostEventOfferGateway {
  const CallableHostEventOfferGateway(this._functions);

  final FirebaseFunctions _functions;

  Future<T> _call<T>(String name, Map<String, Object?> payload,
      String action, T Function(Object?) decode) =>
      withBackendErrorContext(
        () async => decode((await _functions.httpsCallable(name)
                .call<Object?>(payload))
            .data),
        context: BackendErrorContext(
          service: BackendService.functions,
          action: action,
          resource: 'event_offers',
        ),
        mapper: mapMissingCallableAsUnavailable,
      );

  @override
  Future<HostOfferPreview> preview(HostOfferBatchDraft draft) => _call(
        'previewEventOffers',
        draft.toJson(),
        'preview event offers',
        HostOfferPreview.fromCallableData,
      );

  @override
  Future<HostOfferCommitReceipt> commit({
    required HostOfferBatchDraft draft,
    required HostOfferPreview preview,
    required String requestId,
  }) => _call(
        'commitEventOffers',
        {...draft.toJson(), 'planDigest': preview.planDigest,
          'requestId': requestId},
        'commit event offers',
        HostOfferCommitReceipt.fromCallableData,
      );

  Map<String, Object?> _row(HostEventOffer offer) => {
        'organizerId': offer.organizerId,
        'eventId': offer.eventId,
        'contactId': offer.contactId,
        'applicationId': offer.sourceId,
        'sourceKind': offer.sourceKind.name,
      };

  Future<HostEventOffer> _mutate(
    HostEventOffer offer,
    Map<String, Object?> action,
  ) async {
    await mutateWrite({'row': _row(offer), 'action': action});
    return getOffer(organizerId: offer.organizerId, eventId: offer.eventId,
      contactId: offer.contactId);
  }

  /// Returns only after a matching server action receipt is observed.
  Future<void> mutateWrite(Map<String, Object?> payload) => _call(
    'mutateEventOffer', payload, 'review event offer', (value) {
      final action = payload['action'];
      if (value is! Map || value['offer'] is! Map ||
          value['receipt'] is! Map || action is! Map ||
          (value['receipt'] as Map)['requestId'] != action['requestId']) {
        throw const FormatException('Event offer receipt is invalid.');
      }
    },
  );

  @override
  Future<HostEventOffer> recordReference({
    required HostEventOffer offer,
    required String reference,
    required String requestId,
  }) => _mutate(offer, {
        'kind': 'recordEvidence',
        'requestId': requestId,
        'expectedRevision': offer.revision,
        'expectedGeneration': offer.generation,
        'evidenceReference': reference,
      });

  @override
  Future<HostEventOffer> reviewReference({
    required HostEventOffer offer,
    required HostManualPaymentStatus decision,
    required String note,
    required bool bankReceiptChecked,
    required String requestId,
  }) => _mutate(offer, {
        'kind': 'reconcileEvidence',
        'requestId': requestId,
        'expectedRevision': offer.revision,
        'expectedGeneration': offer.generation,
        'decision': decision.name,
        'reviewNote': note,
        'bankReceiptChecked': bankReceiptChecked,
      });

  Future<HostEventOffer> getOffer({
    required String organizerId,
    required String eventId,
    required String contactId,
  }) => _call('getEventOffer', {
        'organizerId': organizerId,
        'eventId': eventId,
        'contactId': contactId,
      }, 'load event offer', HostEventOffer.fromCallableData);

  Future<Map<String, Object?>> listOffers({
    required String organizerId,
    required String eventId,
    String? afterOfferId,
    int limit = 50,
  }) => _call('listEventOffers', {
        'organizerId': organizerId,
        'eventId': eventId,
        if (afterOfferId != null) 'afterOfferId': afterOfferId,
        'limit': limit,
      }, 'list event offers', (value) {
        if (value is! Map || value['items'] is! List) {
          throw const FormatException('Event offer list is invalid.');
        }
        return value.cast<String, Object?>();
      });

  Future<HostOfferHandoff> prepareHandoff({
    required HostEventOffer offer,
  }) => _call('prepareEventOfferHandoff', {
        'organizerId': offer.organizerId,
        'eventId': offer.eventId,
        'contactId': offer.contactId,
        'expectedOfferRevision': offer.revision,
        'expectedGeneration': offer.generation,
      }, 'prepare event offer handoff', HostOfferHandoff.fromCallableData);
}

class _OfferCommitCommand {
  const _OfferCommitCommand({required this.draft, required this.preview,
    required this.requestId, required this.createdAtMillis});

  factory _OfferCommitCommand.fromJson(Map<String, Object?> map) =>
      _OfferCommitCommand(
        draft: HostOfferBatchDraft.fromJson(
          (map['draft']! as Map).cast<String, Object?>(),
        ),
        preview: HostOfferPreview.fromCallableData(map['preview']),
        requestId: map['clientOperationId']! as String,
        createdAtMillis: map['createdAtMillis']! as int,
      );

  final HostOfferBatchDraft draft;
  final HostOfferPreview preview;
  final String requestId;
  final int createdAtMillis;

  String get scope => '${draft.organizerId}|${draft.eventId}';

  Map<String, Object?> toJson() => {
    'clientOperationId': requestId,
    'createdAtMillis': createdAtMillis,
    'status': 'pending',
    'draft': draft.toJson(),
    'preview': preview.toJson(),
  };
}

/// Replays the exact reviewed batch and request ID from durable app storage.
class JournalHostOfferCommitOutbox implements HostOfferCommitOutbox {
  JournalHostOfferCommitOutbox({
    required Future<CommandJournalStorage> Function() storage,
    required String? Function() currentAccountId,
    required HostEventOfferGateway gateway,
  }) : _gateway = gateway,
       _journal = LocalCommandJournal<_OfferCommitCommand>(
         storage: storage,
         namespace: 'host_event_offer_commit',
         currentAccountId: currentAccountId,
         codec: LocalCommandCodec(
           encode: (entry) => entry.toJson(),
           decode: _OfferCommitCommand.fromJson,
           scope: (entry) => entry.scope,
           resources: (entry) => {'event:${entry.draft.eventId}'},
         ),
       );

  final HostEventOfferGateway _gateway;
  final LocalCommandJournal<_OfferCommitCommand> _journal;

  @override
  Future<HostOfferPendingCommit?> pending({
    required String accountId,
    required String organizerId,
    required String eventId,
  }) async {
    final entries = await _journal.load(accountId,
      scope: '$organizerId|$eventId');
    if (entries.isEmpty) return null;
    final entry = entries.first;
    return HostOfferPendingCommit(draft: entry.draft,
      preview: entry.preview, requestId: entry.requestId);
  }

  @override
  Future<HostOfferCommitReceipt?> submit({
    required String accountId,
    required HostOfferBatchDraft draft,
    required HostOfferPreview preview,
    required String requestId,
  }) async {
    final scope = '${draft.organizerId}|${draft.eventId}';
    final entries = await _journal.load(accountId, scope: scope);
    if (entries.isNotEmpty) {
      final saved = entries.first;
      if (entries.length != 1 || saved.requestId != requestId ||
          jsonEncode(saved.draft.toJson()) != jsonEncode(draft.toJson()) ||
          jsonEncode(saved.preview.toJson()) != jsonEncode(preview.toJson())) {
        throw StateError('Resolve the saved offer operation before editing.');
      }
    } else {
      await _journal.append(accountId, _OfferCommitCommand(
        draft: draft, preview: preview, requestId: requestId,
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    HostOfferCommitReceipt? receipt;
    await _journal.flush(accountId, scope, (entry) async {
      receipt = await _gateway.commit(draft: entry.draft,
        preview: entry.preview, requestId: entry.requestId);
    });
    return receipt;
  }
}

class _OfferMutationCommand {
  const _OfferMutationCommand({required this.payload,
    required this.requestId, required this.createdAtMillis});

  factory _OfferMutationCommand.fromJson(Map<String, Object?> map) =>
      _OfferMutationCommand(
        payload: (map['payload']! as Map).cast<String, Object?>(),
        requestId: map['clientOperationId']! as String,
        createdAtMillis: map['createdAtMillis']! as int,
      );

  final Map<String, Object?> payload;
  final String requestId;
  final int createdAtMillis;

  Map<String, Object?> get row => (payload['row']! as Map)
      .cast<String, Object?>();
  String get scope => '${row['organizerId']}|${row['eventId']}';
  String get contactId => row['contactId']! as String;

  Map<String, Object?> toJson() => {
    'clientOperationId': requestId,
    'createdAtMillis': createdAtMillis,
    'status': 'pending',
    'payload': payload,
  };
}

/// Saves manual receipt/review mutations before network I/O. Detail refresh
/// follows acknowledgement, so a failed read cannot turn into a new write.
class JournalHostOfferMutationOutbox implements HostOfferMutationOutbox {
  JournalHostOfferMutationOutbox({
    required Future<CommandJournalStorage> Function() storage,
    required String? Function() currentAccountId,
    required Future<void> Function(Map<String, Object?>) write,
    required Future<HostEventOffer> Function(HostEventOffer) refresh,
  }) : _write = write, _refresh = refresh,
       _journal = LocalCommandJournal<_OfferMutationCommand>(
         storage: storage,
         namespace: 'host_event_offer_mutation',
         currentAccountId: currentAccountId,
         codec: LocalCommandCodec(
           encode: (entry) => entry.toJson(),
           decode: _OfferMutationCommand.fromJson,
           scope: (entry) => entry.scope,
           resources: (entry) => {'contact:${entry.contactId}'},
         ),
       );

  factory JournalHostOfferMutationOutbox.forGateway({
    required Future<CommandJournalStorage> Function() storage,
    required String? Function() currentAccountId,
    required CallableHostEventOfferGateway gateway,
  }) => JournalHostOfferMutationOutbox(
    storage: storage, currentAccountId: currentAccountId,
    write: gateway.mutateWrite,
    refresh: (offer) => gateway.getOffer(organizerId: offer.organizerId,
      eventId: offer.eventId, contactId: offer.contactId),
  );

  final Future<void> Function(Map<String, Object?>) _write;
  final Future<HostEventOffer> Function(HostEventOffer) _refresh;
  final LocalCommandJournal<_OfferMutationCommand> _journal;

  @override
  Future<HostEventOffer> mutate({
    required String accountId,
    required HostEventOffer offer,
    required Map<String, Object?> action,
  }) async {
    final requestId = action['requestId'];
    if (requestId is! String || requestId.isEmpty) {
      throw ArgumentError('A stable offer request ID is required.');
    }
    final payload = <String, Object?>{
      'row': {
        'organizerId': offer.organizerId,
        'eventId': offer.eventId,
        'contactId': offer.contactId,
        'applicationId': offer.sourceId,
        'sourceKind': offer.sourceKind.name,
      },
      'action': action,
    };
    final scope = '${offer.organizerId}|${offer.eventId}';
    final existing = await _journal.load(accountId, scope: scope);
    if (existing.isNotEmpty) {
      final saved = existing.first;
      if (existing.length != 1 || saved.requestId != requestId ||
          jsonEncode(saved.payload) != jsonEncode(payload)) {
        throw StateError('Resolve the saved payment review before editing.');
      }
    } else {
      await _journal.append(accountId, _OfferMutationCommand(
        payload: payload, requestId: requestId,
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    var acknowledged = false;
    await _journal.flush(accountId, scope, (entry) async {
      await _write(entry.payload);
      acknowledged = true;
    });
    if (!acknowledged) {
      throw StateError('Payment review result is uncertain. Retry the saved '
          'request before editing.');
    }
    return _refresh(offer);
  }
}
