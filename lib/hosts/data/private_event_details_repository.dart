import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
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
    this.eventFormat,
  });

  final EventSetupValue<int>? durationMinutes;
  final EventSetupValue<String>? venue;
  final EventSetupValue<EventFormatSnapshot>? eventFormat;

  bool get isValid {
    if (durationMinutes == null && venue == null && eventFormat == null) {
      return false;
    }
    final duration = durationMinutes;
    if (duration?.mode == EventSetupValueMode.set &&
        (duration!.value == null || duration.value! < 15 ||
            duration.value! > 240)) {
      return false;
    }
    final place = venue;
    if (place?.mode == EventSetupValueMode.set &&
        (place!.value == null || place.value!.trim() != place.value ||
            place.value!.isEmpty || place.value!.length > 240)) {
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
    if (durationMinutes != null)
      'durationMinutes': durationMinutes!.toJson((value) => value),
    if (venue != null)
      'venue': venue!.toJson((value) => {'name': value}),
    if (eventFormat != null)
      'eventFormat': eventFormat!.toJson((value) => value.toJson()),
  };

  factory PrivateEventDetailsPatch.fromJson(Map<String, Object?> json) {
    if (json.keys.toSet().difference({'durationMinutes', 'venue',
      'eventFormat'}).isNotEmpty) {
      throw const FormatException('Unknown private event detail');
    }
    EventSetupValue<T> parse<T>(Object? raw, T Function(Object?) decode,
        {bool allowInherit = true}) {
      if (raw is! Map) throw const FormatException('Invalid detail intent');
      final intent = Map<String, Object?>.from(raw);
      if (intent.length == 1 && intent['mode'] == 'clear') {
        return const EventSetupValue.clear();
      }
      if (allowInherit && intent.length == 1 && intent['mode'] == 'inherit') {
        return const EventSetupValue.inherit();
      }
      if (intent.length == 2 && intent['mode'] == 'set' &&
          intent.containsKey('value')) {
        return EventSetupValue.set(decode(intent['value']));
      }
      throw const FormatException('Invalid detail intent');
    }
    final patch = PrivateEventDetailsPatch(
      durationMinutes: json.containsKey('durationMinutes')
          ? parse<int>(json['durationMinutes'], (raw) {
              if (raw is! int) throw const FormatException('Invalid duration');
              return raw;
            })
          : null,
      venue: json.containsKey('venue')
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
                  !ActivityKind.values.any((v) => v.name == data['activityKind']) ||
                  !EventInteractionModel.values.any(
                      (v) => v.name == data['interactionModel'])) {
                throw const FormatException('Invalid format');
              }
              return EventFormatSnapshot.fromJson(Map<String, dynamic>.from(data));
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
  });

  final String organizerId;
  final String eventId;
  final String requestId;
  final int expectedSetupRevision;
  final String reviewedDefaultsHash;
  final PrivateEventDetailsPatch details;

  bool get isValid => _detailIdPattern.hasMatch(organizerId) &&
      _detailIdPattern.hasMatch(eventId) &&
      _detailRequestPattern.hasMatch(requestId) &&
      expectedSetupRevision >= 1 && expectedSetupRevision <= 999999999 &&
      _detailHashPattern.hasMatch(reviewedDefaultsHash) && details.isValid;

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'eventId': eventId,
    'requestId': requestId,
    'expectedSetupRevision': expectedSetupRevision,
    'reviewedDefaultsHash': reviewedDefaultsHash,
    'details': details.toJson(),
  };

  factory PrivateEventDetailsUpdateRequest.fromJson(Map<String, dynamic> json) {
    if (json.keys.toSet().difference({
      'organizerId', 'eventId', 'requestId', 'expectedSetupRevision',
      'reviewedDefaultsHash', 'details',
    }).isNotEmpty || json.length != 6 || json['details'] is! Map) {
      throw const FormatException('Invalid details command');
    }
    final request = PrivateEventDetailsUpdateRequest(
      organizerId: json['organizerId'] as String,
      eventId: json['eventId'] as String,
      requestId: json['requestId'] as String,
      expectedSetupRevision: json['expectedSetupRevision'] as int,
      reviewedDefaultsHash: json['reviewedDefaultsHash'] as String,
      details: PrivateEventDetailsPatch.fromJson(
        Map<String, Object?>.from(json['details'] as Map),
      ),
    );
    if (!request.isValid) throw const FormatException('Invalid details command');
    return request;
  }
}

class PrivateEventDetailsRepository {
  const PrivateEventDetailsRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<PrivateEventCreateReceipt> update(
      PrivateEventDetailsUpdateRequest request) {
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
