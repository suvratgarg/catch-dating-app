import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/events/domain/event_meeting_location.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';

final _detailIdPattern = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$');
final _detailRequestPattern = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{7,127}$');
final _detailHashPattern = RegExp(r'^[a-f0-9]{64}$');

/// A partial command. Missing keys leave the event field unchanged; clear is
/// explicit. Organizer suggestions are copied only by an inherit command.
class PrivateEventDetailsPatch {
  const PrivateEventDetailsPatch({
    this.durationMinutes,
    this.venue,
    this.meetingLocation,
    this.eventFormat,
    this.description,
    this.admissionTerms,
    this.distanceKm,
    this.pace,
  });

  final String? description;
  final PrivateEventAdmissionTerms? admissionTerms;
  final double? distanceKm;
  final String? pace;
  final EventSetupValue<int>? durationMinutes;
  final EventSetupValue<String>? venue;
  final EventMeetingLocation? meetingLocation;
  final EventSetupValue<EventFormatSnapshot>? eventFormat;

  bool get isValid {
    if (durationMinutes == null &&
        venue == null &&
        meetingLocation == null &&
        eventFormat == null &&
        description == null &&
        admissionTerms == null &&
        distanceKm == null &&
        pace == null) {
      return false;
    }
    if ((description != null && description!.length > 2000) ||
        (admissionTerms != null && !admissionTerms!.isValid) ||
        (distanceKm != null &&
            (!distanceKm!.isFinite || distanceKm! < 0 || distanceKm! > 100)) ||
        (pace != null &&
            !const {
              'easy',
              'moderate',
              'fast',
              'competitive',
            }.contains(pace))) {
      return false;
    }
    final duration = durationMinutes;
    if (duration?.mode == EventSetupValueMode.set &&
        (duration!.value == null ||
            duration.value! < 15 ||
            duration.value! > 240)) {
      return false;
    }
    final location = meetingLocation;
    if (location != null &&
        (venue != null ||
            location.name.trim().isEmpty ||
            location.name.length > 240 ||
            !location.latitude.isFinite ||
            location.latitude.abs() > 90 ||
            !location.longitude.isFinite ||
            location.longitude.abs() > 180)) {
      return false;
    }
    final place = venue;
    if (place?.mode == EventSetupValueMode.set &&
        (place!.value == null ||
            place.value!.trim() != place.value ||
            place.value!.isEmpty ||
            place.value!.length > 240)) {
      return false;
    }
    final format = eventFormat;
    if (format?.mode == EventSetupValueMode.inherit ||
        (format?.mode == EventSetupValueMode.set &&
            (format!.value == null || format.value!.version != 1))) {
      return false;
    }
    return true;
  }

  Map<String, Object?> toJson() => {
    if (description != null) 'description': description,
    if (admissionTerms != null) 'admissionTerms': admissionTerms!.toJson(),
    if (distanceKm != null) 'distanceKm': distanceKm,
    if (pace != null) 'pace': pace,
    if (durationMinutes != null)
      'durationMinutes': durationMinutes!.toJson((value) => value),
    if (venue != null) 'venue': venue!.toJson((value) => {'name': value}),
    if (meetingLocation != null)
      'venue': {'mode': 'set', 'value': meetingLocation!.normalized().toJson()},
    if (eventFormat != null)
      'eventFormat': eventFormat!.toJson((value) => value.toJson()),
  };

  factory PrivateEventDetailsPatch.fromJson(Map<String, Object?> json) {
    if (json.keys.toSet().difference({
      'durationMinutes',
      'venue',
      'eventFormat',
      'description',
      'admissionTerms',
      'distanceKm',
      'pace',
    }).isNotEmpty) {
      throw const FormatException('Unknown private event detail');
    }
    EventSetupValue<T> parse<T>(
      Object? raw,
      T Function(Object?) decode, {
      bool allowInherit = true,
    }) {
      if (raw is! Map) throw const FormatException('Invalid detail intent');
      final intent = Map<String, Object?>.from(raw);
      if (intent.length == 1 && intent['mode'] == 'clear') {
        return const EventSetupValue.clear();
      }
      if (allowInherit && intent.length == 1 && intent['mode'] == 'inherit') {
        return const EventSetupValue.inherit();
      }
      if (intent.length == 2 &&
          intent['mode'] == 'set' &&
          intent.containsKey('value')) {
        return EventSetupValue.set(decode(intent['value']));
      }
      throw const FormatException('Invalid detail intent');
    }

    final rawVenue = json['venue'];
    final rawLocation = rawVenue is Map ? rawVenue['value'] : null;
    final hasLocation =
        rawLocation is Map &&
        (rawLocation.containsKey('latitude') ||
            rawLocation.containsKey('longitude'));
    final patch = PrivateEventDetailsPatch(
      description: json['description'] as String?,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      pace: json['pace'] as String?,
      admissionTerms: json['admissionTerms'] == null
          ? null
          : PrivateEventAdmissionTerms.fromResponse(json['admissionTerms']),
      meetingLocation: hasLocation
          ? parse<EventMeetingLocation>(rawVenue, (raw) {
              if (raw is! Map ||
                  raw.keys.toSet().difference({
                    'name',
                    'address',
                    'placeId',
                    'latitude',
                    'longitude',
                    'notes',
                  }).isNotEmpty) {
                throw const FormatException('Invalid meeting location');
              }
              return EventMeetingLocation.fromJson(
                Map<String, dynamic>.from(raw),
              );
            }, allowInherit: false).value
          : null,
      durationMinutes: json.containsKey('durationMinutes')
          ? parse<int>(json['durationMinutes'], (raw) {
              if (raw is! int) throw const FormatException('Invalid duration');
              return raw;
            })
          : null,
      venue: json.containsKey('venue') && !hasLocation
          ? parse<String>(json['venue'], (raw) {
              if (raw is! Map) throw const FormatException('Invalid venue');
              final data = Map<String, Object?>.from(raw);
              if (data.length != 1 || data['name'] is! String) {
                throw const FormatException('Invalid venue');
              }
              return data['name'] as String;
            })
          : null,
      eventFormat: json.containsKey('eventFormat')
          ? parse<EventFormatSnapshot>(json['eventFormat'], (raw) {
              if (raw is! Map) throw const FormatException('Invalid format');
              final data = Map<String, Object?>.from(raw);
              if (data['version'] != 1 ||
                  !ActivityKind.values.any(
                    (v) => v.name == data['activityKind'],
                  ) ||
                  !EventInteractionModel.values.any(
                    (v) => v.name == data['interactionModel'],
                  )) {
                throw const FormatException('Invalid format');
              }
              return EventFormatSnapshot.fromJson(
                Map<String, dynamic>.from(data),
              );
            }, allowInherit: false)
          : null,
    );
    if (!patch.isValid) throw const FormatException('Invalid details patch');
    return patch;
  }
}

class PrivateEventDetailsUpdateRequest {
  const PrivateEventDetailsUpdateRequest({
    required this.organizerId,
    required this.eventId,
    required this.requestId,
    required this.expectedSetupRevision,
    required this.reviewedDefaultsHash,
    required this.details,
    this.discard = false,
  });

  final String organizerId;
  final String eventId;
  final String requestId;
  final int expectedSetupRevision;
  final String reviewedDefaultsHash;
  final PrivateEventDetailsPatch details;
  final bool discard;
  PrivateEventDetailsUpdateRequest withDiscard(bool value) =>
      PrivateEventDetailsUpdateRequest(
        organizerId: organizerId,
        eventId: eventId,
        requestId: requestId,
        expectedSetupRevision: expectedSetupRevision,
        reviewedDefaultsHash: reviewedDefaultsHash,
        details: details,
        discard: value,
      );

  bool get isValid =>
      _detailIdPattern.hasMatch(organizerId) &&
      _detailIdPattern.hasMatch(eventId) &&
      _detailRequestPattern.hasMatch(requestId) &&
      expectedSetupRevision >= 1 &&
      expectedSetupRevision <= 999999999 &&
      _detailHashPattern.hasMatch(reviewedDefaultsHash) &&
      details.isValid &&
      (!discard ||
          (details.admissionTerms != null && details.toJson().length == 1));

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'eventId': eventId,
    'requestId': requestId,
    'expectedSetupRevision': expectedSetupRevision,
    'reviewedDefaultsHash': reviewedDefaultsHash,
    'details': details.toJson(),
    if (discard) 'discard': true,
  };

  factory PrivateEventDetailsUpdateRequest.fromJson(Map<String, dynamic> json) {
    if (json.keys.toSet().difference({
          'organizerId',
          'eventId',
          'requestId',
          'expectedSetupRevision',
          'reviewedDefaultsHash',
          'details',
          'discard',
        }).isNotEmpty ||
        (json.length != 6 && json.length != 7) ||
        (json.containsKey('discard') && json['discard'] != true) ||
        json['details'] is! Map) {
      throw const FormatException('Invalid details command');
    }
    final request = PrivateEventDetailsUpdateRequest(
      organizerId: json['organizerId'] as String,
      eventId: json['eventId'] as String,
      requestId: json['requestId'] as String,
      expectedSetupRevision: json['expectedSetupRevision'] as int,
      reviewedDefaultsHash: json['reviewedDefaultsHash'] as String,
      discard: json['discard'] == true,
      details: PrivateEventDetailsPatch.fromJson(
        Map<String, Object?>.from(json['details'] as Map),
      ),
    );
    if (!request.isValid) {
      throw const FormatException('Invalid details command');
    }
    return request;
  }
}

class PrivateEventDetailsRepository {
  const PrivateEventDetailsRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<PrivateSeatReconciliationResult> reconcile(
    PrivateEventDetailsUpdateRequest request,
  ) {
    if (!request.isValid ||
        request.details.admissionTerms == null ||
        request.details.toJson().length != 1) {
      throw ArgumentError.value(request, 'request');
    }
    return withBackendErrorContext(
      () async {
        final response = await _functions
            .httpsCallable('reconcilePrivateEventSeats')
            .call<Object?>(request.toJson());
        final result = PrivateSeatReconciliationResult.fromResponse(
          response.data,
        );
        if ((result.receipt?.eventId ??
                result.progress?.eventId ??
                result.discardedEventId) !=
            request.eventId) {
          throw const FormatException('Guest reconciliation changed identity');
        }
        return result;
      },
      context: const BackendErrorContext(
        service: BackendService.functions,
        action: 'save admission settings and reconcile guests',
        resource: 'reconcilePrivateEventSeats',
      ),
    );
  }

  Future<PrivateEventCreateReceipt> update(
    PrivateEventDetailsUpdateRequest request,
  ) {
    if (!request.isValid) throw ArgumentError.value(request, 'request');
    return withBackendErrorContext(
      () async {
        final response = await _functions
            .httpsCallable('updatePrivateEventDetails')
            .call<Object?>(request.toJson());
        final receipt = PrivateEventCreateReceipt.fromResponse(response.data);
        if (receipt.eventId != request.eventId ||
            receipt.setupRevision <= request.expectedSetupRevision) {
          throw const FormatException('Details receipt changed event identity');
        }
        return receipt;
      },
      context: const BackendErrorContext(
        service: BackendService.functions,
        action: 'update private event details',
        resource: 'updatePrivateEventDetails',
      ),
    );
  }
}

class PrivateSeatReconciliationProgress {
  const PrivateSeatReconciliationProgress({
    required this.eventId,
    required this.phase,
    required this.scannedRows,
  });
  final String eventId;
  final String phase;
  final int scannedRows;
}

class PrivateSeatReconciliationResult {
  const PrivateSeatReconciliationResult.complete(
    PrivateEventCreateReceipt value,
  ) : receipt = value,
      progress = null,
      discardedEventId = null,
      discardedRequestId = null;
  const PrivateSeatReconciliationResult.pending(
    PrivateSeatReconciliationProgress value,
  ) : progress = value,
      receipt = null,
      discardedEventId = null,
      discardedRequestId = null;
  const PrivateSeatReconciliationResult.discarded(
    this.discardedEventId,
    this.discardedRequestId,
  ) : receipt = null,
      progress = null;
  final String? discardedEventId;
  final String? discardedRequestId;
  final PrivateEventCreateReceipt? receipt;
  final PrivateSeatReconciliationProgress? progress;
  factory PrivateSeatReconciliationResult.fromResponse(Object? raw) {
    if (raw is Map &&
        raw.length == 3 &&
        raw['kind'] == 'discarded' &&
        raw['eventId'] is String &&
        _detailIdPattern.hasMatch(raw['eventId'] as String) &&
        raw['requestId'] is String &&
        _detailRequestPattern.hasMatch(raw['requestId'] as String)) {
      return PrivateSeatReconciliationResult.discarded(
        raw['eventId'] as String,
        raw['requestId'] as String,
      );
    }
    if (raw is! Map || raw.length != 2) {
      throw const FormatException('Invalid guest reconciliation result');
    }
    if (raw['kind'] == 'complete' && raw.containsKey('receipt')) {
      return PrivateSeatReconciliationResult.complete(
        PrivateEventCreateReceipt.fromResponse(raw['receipt']),
      );
    }
    final progress = raw['progress'];
    bool count(Object? value, int max) =>
        value is int && value >= 0 && value <= max;
    if (raw['kind'] != 'progress' ||
        progress is! Map ||
        progress.length != 7 ||
        progress['eventId'] is! String ||
        !_detailIdPattern.hasMatch(progress['eventId'] as String) ||
        !const {
          'scan',
          'plan',
          'apply',
          'cleanup',
          'discard',
        }.contains(progress['phase']) ||
        !count(progress['migrationRevision'], 1000000000) ||
        progress['migrationRevision'] == 0 ||
        !count(progress['scannedRows'], 750) ||
        !count(progress['appliedRows'], 1500) ||
        !count(progress['outputRows'], 1500) ||
        (progress['appliedRows'] as int) > (progress['outputRows'] as int) ||
        !progress.containsKey('occupied') ||
        progress['occupied'] != null) {
      throw const FormatException('Invalid guest reconciliation progress');
    }
    return PrivateSeatReconciliationResult.pending(
      PrivateSeatReconciliationProgress(
        eventId: progress['eventId'] as String,
        phase: progress['phase'] as String,
        scannedRows: progress['scannedRows'] as int,
      ),
    );
  }
}

/// Only the exact server rejection after receipt/run checks can release an
/// uncertain command. Connectivity and later permission errors cannot.
bool isDefinitiveDetailsRejection(
  Object error,
  PrivateEventDetailsUpdateRequest request,
) => _matchesDetailsOutcome(error, request, 'aborted', {
  'event-details-review-stale',
  'event-details-discarded',
});

bool isDiscardUnavailable(
  Object error,
  PrivateEventDetailsUpdateRequest request,
) => _matchesDetailsOutcome(error, request, 'failed-precondition', {
  'seat-reconciliation-discard-unavailable',
});

bool _matchesDetailsOutcome(
  Object error,
  PrivateEventDetailsUpdateRequest request,
  String code,
  Set<String> reasons,
) {
  Object? cause = error;
  for (var depth = 0; depth < 8 && cause is AppException; depth++) {
    cause = cause.cause;
  }
  if (cause is! FirebaseFunctionsException || cause.code != code) {
    return false;
  }
  final details = cause.details;
  return details is Map &&
      reasons.contains(details['reason']) &&
      details['requestId'] == request.requestId &&
      details['eventId'] == request.eventId &&
      details['organizerId'] == request.organizerId &&
      details['expectedSetupRevision'] == request.expectedSetupRevision &&
      details['reviewedDefaultsHash'] == request.reviewedDefaultsHash;
}
