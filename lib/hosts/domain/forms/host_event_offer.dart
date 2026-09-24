import 'package:meta/meta.dart';

enum HostOfferSourceKind { application, formResponse }

enum HostOfferStatus { draft, offered, withdrawn, expired }

enum HostManualPaymentStatus {
  none,
  evidenceSubmitted,
  hostAttestedReceived,
  rejected,
}

/// One reviewed source, one current CRM contact and one canonical event.
/// A form may produce different offers for different events.
@immutable
class HostOfferRow {
  const HostOfferRow({
    required this.organizerId,
    required this.eventId,
    required this.contactId,
    required this.sourceKind,
    required this.sourceId,
    required this.expiresAt,
    this.organizerPaymentLink,
  });

  final String organizerId;
  final String eventId;
  final String contactId;
  final HostOfferSourceKind sourceKind;
  final String sourceId;
  final DateTime expiresAt;
  final Uri? organizerPaymentLink;

  void validate({required DateTime now, required DateTime eventStartsAt}) {
    if (organizerId.isEmpty ||
        eventId.isEmpty ||
        contactId.isEmpty ||
        sourceId.isEmpty ||
        !expiresAt.isAfter(now) ||
        expiresAt.isAfter(eventStartsAt)) {
      throw ArgumentError('Choose a current source, contact and future event.');
    }
    final link = organizerPaymentLink;
    if (link != null &&
        (link.scheme != 'https' ||
            link.host.isEmpty ||
            link.userInfo.isNotEmpty ||
            link.toString().length > 2048)) {
      throw ArgumentError('Use a public HTTPS payment link.');
    }
  }

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'eventId': eventId,
    'contactId': contactId,
    'sourceKind': sourceKind.name,
    // The server service calls this authority-bearing source ID applicationId
    // for both approved applications and eligible direct form responses.
    'applicationId': sourceId,
    'expiresAtMillis': expiresAt.millisecondsSinceEpoch,
    'organizerPaymentLink': organizerPaymentLink?.toString(),
  };
}

@immutable
class HostOfferBatchDraft {
  const HostOfferBatchDraft({
    required this.organizerId,
    required this.eventId,
    required this.rows,
    this.mode = 'offer',
  });

  final String organizerId;
  final String eventId;
  final List<HostOfferRow> rows;
  final String mode;

  void validate({required DateTime now, required DateTime eventStartsAt}) {
    if (organizerId.isEmpty ||
        eventId.isEmpty ||
        (mode != 'offer' && mode != 'draft') ||
        rows.isEmpty ||
        rows.length > 25) {
      throw ArgumentError('Choose one to twenty-five offer recipients.');
    }
    final contacts = <String>{};
    for (final row in rows) {
      if (row.organizerId != organizerId ||
          row.eventId != eventId ||
          !contacts.add(row.contactId)) {
        throw ArgumentError('One contact may receive one offer per event.');
      }
      row.validate(now: now, eventStartsAt: eventStartsAt);
    }
  }

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'eventId': eventId,
    'mode': mode,
    'rows': rows.map((row) => row.toJson()).toList(growable: false),
  };
}

@immutable
class HostOfferPreview {
  const HostOfferPreview({required this.planDigest, required this.rows});

  factory HostOfferPreview.fromCallableData(Object? data) {
    final map = _offerMap(data, 'offer preview');
    final rows = map['rows'];
    if (rows is! List || rows.isEmpty || rows.length > 25) {
      throw const FormatException('Offer preview rows are invalid.');
    }
    return HostOfferPreview(
      planDigest: _offerString(map, 'planDigest'),
      rows: List.unmodifiable(
        rows.map((entry) {
          final row = _offerMap(entry, 'offer preview row');
          return HostOfferPreviewRow(
            offerId: _offerString(row, 'offerId'),
            revision: _offerInt(row, 'revision'),
            generation: _offerInt(row, 'generation'),
            status: _offerString(row, 'status'),
          );
        }),
      ),
    );
  }

  final String planDigest;
  final List<HostOfferPreviewRow> rows;
}

@immutable
class HostOfferPreviewRow {
  const HostOfferPreviewRow({
    required this.offerId,
    required this.revision,
    required this.generation,
    required this.status,
  });

  final String offerId;
  final int revision;
  final int generation;
  final String status;
}

@immutable
class HostOfferCommitReceipt {
  const HostOfferCommitReceipt({
    required this.organizerId,
    required this.eventId,
    required this.requestId,
    required this.results,
  });

  factory HostOfferCommitReceipt.fromCallableData(Object? data) {
    final map = _offerMap(data, 'offer commit');
    final results = map['results'];
    if (results is! List) {
      throw const FormatException('Offer commit results are invalid.');
    }
    return HostOfferCommitReceipt(
      organizerId: _offerString(map, 'organizerId'),
      eventId: _offerString(map, 'eventId'),
      requestId: _offerString(map, 'requestId'),
      results: List.unmodifiable(
        results.map((entry) {
          final result = _offerMap(entry, 'offer commit row');
          return HostOfferPreviewRow(
            offerId: _offerString(result, 'offerId'),
            revision: _offerInt(result, 'revision'),
            generation: _offerInt(result, 'generation'),
            status: 'committed',
          );
        }),
      ),
    );
  }

  final String organizerId;
  final String eventId;
  final String requestId;
  final List<HostOfferPreviewRow> results;
}

@immutable
class HostManualPaymentReview {
  const HostManualPaymentReview({
    required this.status,
    required this.evidenceReference,
    required this.evidenceRecordedAt,
    required this.reviewedByUid,
    required this.reviewedAt,
    required this.reviewNote,
    required this.bankReceiptChecked,
  });

  factory HostManualPaymentReview.fromMap(Object? data) {
    final map = _offerMap(data, 'manual payment review');
    return HostManualPaymentReview(
      status: HostManualPaymentStatus.values.byName(
        _offerString(map, 'status'),
      ),
      evidenceReference: _offerNullableString(map['evidenceReference']),
      evidenceRecordedAt: _offerNullableTime(map['evidenceRecordedAtMillis']),
      reviewedByUid: _offerNullableString(map['reviewedByUid']),
      reviewedAt: _offerNullableTime(map['reviewedAtMillis']),
      reviewNote: _offerNullableString(map['reviewNote']),
      bankReceiptChecked: map['bankReceiptChecked'] == true,
    );
  }

  final HostManualPaymentStatus status;
  final String? evidenceReference;
  final DateTime? evidenceRecordedAt;
  final String? reviewedByUid;
  final DateTime? reviewedAt;
  final String? reviewNote;
  final bool bankReceiptChecked;
}

@immutable
class HostEventOffer {
  const HostEventOffer({
    required this.offerId,
    required this.organizerId,
    required this.eventId,
    required this.contactId,
    required this.sourceId,
    required this.sourceKind,
    required this.status,
    required this.effectiveStatus,
    required this.generation,
    required this.revision,
    required this.expiresAt,
    required this.organizerPaymentLink,
    required this.manualPayment,
  });

  factory HostEventOffer.fromCallableData(Object? data) {
    final wrapper = _offerMap(data, 'event offer detail');
    final offer = _offerMap(wrapper['offer'], 'event offer');
    return HostEventOffer(
      offerId: _offerString(offer, 'offerId'),
      organizerId: _offerString(offer, 'organizerId'),
      eventId: _offerString(offer, 'eventId'),
      contactId: _offerString(offer, 'contactId'),
      sourceId: _offerString(offer, 'applicationId'),
      sourceKind: HostOfferSourceKind.values.byName(
        _offerString(offer, 'sourceKind'),
      ),
      status: HostOfferStatus.values.byName(_offerString(offer, 'status')),
      effectiveStatus: HostOfferStatus.values.byName(
        _offerString(wrapper, 'effectiveStatus'),
      ),
      generation: _offerInt(offer, 'generation'),
      revision: _offerInt(offer, 'revision'),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        _offerInt(offer, 'expiresAtMillis'),
      ),
      organizerPaymentLink: switch (offer['organizerPaymentLink']) {
        String value => Uri.parse(value),
        null => null,
        _ => throw const FormatException('Offer payment link is invalid.'),
      },
      manualPayment: HostManualPaymentReview.fromMap(offer['manualPayment']),
    );
  }

  final String offerId;
  final String organizerId;
  final String eventId;
  final String contactId;
  final String sourceId;
  final HostOfferSourceKind sourceKind;
  final HostOfferStatus status;
  final HostOfferStatus effectiveStatus;
  final int generation;
  final int revision;
  final DateTime expiresAt;
  final Uri? organizerPaymentLink;
  final HostManualPaymentReview manualPayment;

  bool get hasOffer => status == HostOfferStatus.offered;
  bool get isHostAttested =>
      manualPayment.status == HostManualPaymentStatus.hostAttestedReceived;
}

Map<String, Object?> _offerMap(Object? value, String label) {
  if (value is! Map) throw FormatException('$label is invalid.');
  return value.map((key, item) {
    if (key is! String) throw FormatException('$label key is invalid.');
    return MapEntry(key, item);
  });
}

String _offerString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('Offer $key is invalid.');
  }
  return value;
}

int _offerInt(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! int || value < 0) {
    throw FormatException('Offer $key is invalid.');
  }
  return value;
}

String? _offerNullableString(Object? value) {
  if (value == null) return null;
  if (value is! String) throw const FormatException('Offer text is invalid.');
  return value;
}

DateTime? _offerNullableTime(Object? value) {
  if (value == null) return null;
  if (value is! int || value < 0) {
    throw const FormatException('Offer time is invalid.');
  }
  return DateTime.fromMillisecondsSinceEpoch(value);
}
