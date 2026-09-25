import 'dart:convert';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/data/private_event_preferences_repository.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';

/// Matches the server's ordered JSON snapshot for inherited defaults.
String organizerEventDefaultsHash({
  required String? cityId,
  required String? marketId,
  required String? timezone,
  required int? revision,
}) {
  final city = cityId != null && cityId.isNotEmpty &&
          marketId != null && marketId.isNotEmpty
      ? {'cityId': cityId, 'marketId': marketId}
      : null;
  return sha256.convert(utf8.encode(jsonEncode({
    'city': city,
    'timezone': timezone,
    'revision': revision,
  }))).toString();
}

/// A field can inherit, be explicitly set, or be explicitly cleared.
///
/// Required first-save fields reject [clear]. Keeping the three intentions
/// distinct prevents an omitted optional value from silently inheriting one.
enum EventSetupValueMode { inherit, set, clear }

class EventSetupValue<T> {
  const EventSetupValue.inherit()
    : mode = EventSetupValueMode.inherit,
      value = null;
  const EventSetupValue.set(this.value)
    : mode = EventSetupValueMode.set;
  const EventSetupValue.clear()
    : mode = EventSetupValueMode.clear,
      value = null;

  final EventSetupValueMode mode;
  final T? value;

  Map<String, Object?> toJson(Object? Function(T) encode) => {
    'mode': mode.name,
    if (mode == EventSetupValueMode.set) 'value': encode(value as T),
  };
}

class EventSetupCity {
  const EventSetupCity({required this.cityId, required this.marketId});

  final String cityId;
  final String marketId;

  Map<String, Object?> toJson() => {
    'cityId': cityId,
    'marketId': marketId,
  };
}

/// The private first-save payload. Venue, end time, capacity and price are
/// deliberately absent from this type and cannot be synthesized by its caller.
class PrivateEventBasics {
  const PrivateEventBasics({
    required this.name,
    required this.city,
    required this.localDate,
    required this.localStartTime,
    required this.timezone,
    this.reviewedDefaultsHash,
  });

  final String name;
  final EventSetupValue<EventSetupCity> city;
  final String localDate;
  final String localStartTime;
  final EventSetupValue<String> timezone;
  final String? reviewedDefaultsHash;

  factory PrivateEventBasics.fromJson(Map<String, dynamic> json) {
    EventSetupValue<T> parseValue<T>(
      Object? raw,
      T Function(Object?) parse,
    ) {
      if (raw is! Map) throw const FormatException('Invalid setup value');
      final value = Map<String, dynamic>.from(raw);
      return switch (value['mode']) {
        'inherit' => EventSetupValue<T>.inherit(),
        'set' => EventSetupValue.set(parse(value['value'])),
        _ => throw const FormatException('Invalid setup value mode'),
      };
    }

    final city = parseValue<EventSetupCity>(json['city'], (raw) {
      if (raw is! Map) throw const FormatException('Invalid city');
      final value = Map<String, dynamic>.from(raw);
      if (value['cityId'] is! String || value['marketId'] is! String) {
        throw const FormatException('Invalid city');
      }
      return EventSetupCity(
        cityId: value['cityId'] as String,
        marketId: value['marketId'] as String,
      );
    });
    final timezone = parseValue<String>(json['timezone'], (raw) {
      if (raw is! String) throw const FormatException('Invalid timezone');
      return raw;
    });
    final basics = PrivateEventBasics(
      name: json['name'] as String,
      city: city,
      localDate: json['localDate'] as String,
      localStartTime: json['localStartTime'] as String,
      timezone: timezone,
      reviewedDefaultsHash: json['reviewedDefaultsHash'] as String?,
    );
    if (!basics.isValid) throw const FormatException('Invalid saved basics');
    return basics;
  }

  bool get isValid {
    if (name.trim().isEmpty ||
        name.trim().length > 120 ||
        city.mode == EventSetupValueMode.clear ||
        timezone.mode == EventSetupValueMode.clear) {
      return false;
    }
    if (city.mode == EventSetupValueMode.set &&
        ((city.value?.cityId.trim().isEmpty ?? true) ||
            (city.value?.marketId.trim().isEmpty ?? true))) {
      return false;
    }
    if (timezone.mode == EventSetupValueMode.set &&
        (timezone.value?.trim().isEmpty ?? true)) {
      return false;
    }
    if ((city.mode == EventSetupValueMode.inherit ||
            timezone.mode == EventSetupValueMode.inherit) &&
        (reviewedDefaultsHash?.trim().isEmpty ?? true)) {
      return false;
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(localDate) ||
        !RegExp(r'^\d{2}:\d{2}$').hasMatch(localStartTime)) {
      return false;
    }
    final dateParts = localDate.split('-');
    if (dateParts.length != 3) return false;
    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);
    if (year == null || year < 2000 || year > 2100 ||
        month == null || day == null) {
      return false;
    }
    final date = DateTime.utc(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return false;
    }
    final timeParts = localStartTime.split(':');
    if (timeParts.length != 2) return false;
    final hour = int.tryParse(timeParts[0]);
    final minute = int.tryParse(timeParts[1]);
    return hour != null &&
        minute != null &&
        hour >= 0 &&
        hour <= 23 &&
        minute >= 0 &&
        minute <= 59;
  }

  Map<String, Object?> toJson() => {
    'name': name.trim(),
    'city': city.toJson((value) => value.toJson()),
    'localDate': localDate,
    'localStartTime': localStartTime,
    'timezone': timezone.toJson((value) => value.trim()),
    if (reviewedDefaultsHash != null)
      'reviewedDefaultsHash': reviewedDefaultsHash,
  };
}

class PrivateEventCreateReceipt {
  const PrivateEventCreateReceipt({
    required this.eventId,
    required this.setupRevision,
    required this.replayed,
  });

  final String eventId;
  final int setupRevision;
  final bool replayed;

  factory PrivateEventCreateReceipt.fromResponse(Object? response) {
    if (response is! Map) throw const FormatException('Invalid event receipt');
    final data = Map<String, Object?>.from(response);
    final eventId = data['eventId'];
    final setupRevision = data['setupRevision'];
    final replayed = data['replayed'];
    if (eventId is! String ||
        eventId.isEmpty ||
        setupRevision is! int ||
        setupRevision < 1 ||
        replayed is! bool) {
      throw const FormatException('Invalid event setup receipt');
    }
    return PrivateEventCreateReceipt(
      eventId: eventId,
      setupRevision: setupRevision,
      replayed: replayed,
    );
  }
}

/// The exact update command is caller-owned across retries. In particular,
/// [requestId], [expectedSetupRevision], and [basics] must not change after a
/// request might have reached the server.
class PrivateEventBasicsUpdateRequest {
  const PrivateEventBasicsUpdateRequest({
    required this.organizerId,
    required this.eventId,
    required this.requestId,
    required this.expectedSetupRevision,
    required this.basics,
  });

  final String organizerId;
  final String eventId;
  final String requestId;
  final int expectedSetupRevision;
  final PrivateEventBasics basics;

  factory PrivateEventBasicsUpdateRequest.fromJson(Map<String, dynamic> json) {
    final organizerId = json['organizerId'];
    final eventId = json['eventId'];
    final requestId = json['requestId'];
    final expectedSetupRevision = json['expectedSetupRevision'];
    final rawBasics = json['basics'];
    if (organizerId is! String ||
        eventId is! String ||
        requestId is! String ||
        expectedSetupRevision is! int ||
        rawBasics is! Map) {
      throw const FormatException('Invalid saved basics update');
    }
    final request = PrivateEventBasicsUpdateRequest(
      organizerId: organizerId,
      eventId: eventId,
      requestId: requestId,
      expectedSetupRevision: expectedSetupRevision,
      basics: PrivateEventBasics.fromJson(Map<String, dynamic>.from(rawBasics)),
    );
    if (!request.isValid) {
      throw const FormatException('Invalid saved basics update');
    }
    return request;
  }

  bool get isValid =>
      organizerId.trim().isNotEmpty &&
      eventId.trim().isNotEmpty &&
      requestId.trim().isNotEmpty &&
      expectedSetupRevision >= 1 &&
      basics.isValid;

  Map<String, Object?> toJson() => {
    'organizerId': organizerId,
    'eventId': eventId,
    'requestId': requestId,
    'expectedSetupRevision': expectedSetupRevision,
    'basics': basics.toJson(),
  };
}

/// Actual optional event fields, as opposed to organizer recommendations.
class PrivateEventDetailsSnapshot {
  const PrivateEventDetailsSnapshot({
    this.endTimeMillis,
    this.venueName,
    this.sourceVenueId,
    this.eventFormat,
  });

  final int? endTimeMillis;
  final String? venueName;
  final String? sourceVenueId;
  final EventFormatSnapshot? eventFormat;

  factory PrivateEventDetailsSnapshot.fromResponse(Object? response) {
    if (response is! Map) throw const FormatException('Invalid event details');
    final data = Map<String, Object?>.from(response);
    if (data.length != 4 ||
        data.keys.toSet().difference({
          'endTimeMillis', 'venueName', 'sourceVenueId', 'eventFormat',
        }).isNotEmpty ||
        (data['endTimeMillis'] != null && data['endTimeMillis'] is! int) ||
        (data['venueName'] != null &&
            (data['venueName'] is! String ||
                (data['venueName'] as String).trim().isEmpty)) ||
        (data['sourceVenueId'] != null &&
            data['sourceVenueId'] is! String)) {
      throw const FormatException('Invalid event details');
    }
    final rawFormat = data['eventFormat'];
    EventFormatSnapshot? format;
    if (rawFormat != null) {
      if (rawFormat is! Map) throw const FormatException('Invalid event format');
      final formatData = Map<String, Object?>.from(rawFormat);
      if (formatData['version'] != 1 ||
          !ActivityKind.values.any((v) => v.name == formatData['activityKind']) ||
          !EventInteractionModel.values.any(
              (v) => v.name == formatData['interactionModel'])) {
        throw const FormatException('Invalid event format');
      }
      format = EventFormatSnapshot.fromJson(
        Map<String, dynamic>.from(formatData),
      );
    }
    return PrivateEventDetailsSnapshot(
      endTimeMillis: data['endTimeMillis'] as int?,
      venueName: data['venueName'] as String?,
      sourceVenueId: data['sourceVenueId'] as String?,
      eventFormat: format,
    );
  }
}

/// Manager-only projection of an already-saved basic event. It intentionally
/// has no rich Event defaults; a partial private setup cannot be decoded as a
/// public event.
class PrivateEventBasicSummary {
  const PrivateEventBasicSummary({
    required this.eventId,
    required this.organizerId,
    required this.setupRevision,
    required this.name,
    required this.city,
    required this.localDate,
    required this.localStartTime,
    required this.timezone,
    required this.startTimeMillis,
    required this.status,
    required this.setupDefaults,
    required this.detailsConfigured,
    required this.eventPreferences,
    this.canEditBasics = false,
    this.canChangeCity = false,
    this.eventDetails = const PrivateEventDetailsSnapshot(),
  });

  final String eventId;
  final String organizerId;
  final int setupRevision;
  final String name;
  final EventSetupCity city;
  final String localDate;
  final String localStartTime;
  final String timezone;
  final int startTimeMillis;
  final String status;
  final Map<String, Object?> setupDefaults;
  final bool detailsConfigured;
  final PrivateEventPreferencesSnapshot? eventPreferences;
  final PrivateEventDetailsSnapshot eventDetails;
  final bool canEditBasics;
  final bool canChangeCity;

  factory PrivateEventBasicSummary.fromResponse(Object? response) {
    if (response is! Map) {
      throw const FormatException('Invalid private event summary');
    }
    final data = Map<String, Object?>.from(response);
    final rawCity = data['city'];
    if (rawCity is! Map) {
      throw const FormatException('Invalid private event city');
    }
    final cityData = Map<String, Object?>.from(rawCity);
    final cityId = cityData['cityId'];
    final marketId = cityData['marketId'];
    final eventId = data['eventId'];
    final organizerId = data['organizerId'];
    final setupRevision = data['setupRevision'];
    final name = data['name'];
    final localDate = data['localDate'];
    final localStartTime = data['localStartTime'];
    final timezone = data['timezone'];
    final startTimeMillis = data['startTimeMillis'];
    final status = data['status'];
    final setupDefaults = data['setupDefaults'];
    final detailsConfigured = data['detailsConfigured'];
    final canEditBasics = data['canEditBasics'];
    final canChangeCity = data['canChangeCity'];
    final rawEventDetails = data['eventDetails'];
    if (eventId is! String ||
        eventId.trim().isEmpty ||
        organizerId is! String ||
        organizerId.trim().isEmpty ||
        setupRevision is! int ||
        setupRevision < 1 ||
        name is! String ||
        cityId is! String ||
        marketId is! String ||
        localDate is! String ||
        localStartTime is! String ||
        timezone is! String ||
        startTimeMillis is! int ||
        (status != 'active' && status != 'cancelled') ||
        data['publicationState'] != 'private' ||
        setupDefaults is! Map ||
        detailsConfigured is! bool ||
        canEditBasics is! bool ||
        canChangeCity is! bool ||
        (canChangeCity && !canEditBasics) ||
        (status == 'cancelled' && (canEditBasics || canChangeCity))) {
      throw const FormatException('Invalid private event summary');
    }
    final city = EventSetupCity(cityId: cityId, marketId: marketId);
    final basics = PrivateEventBasics(
      name: name,
      city: EventSetupValue.set(city),
      localDate: localDate,
      localStartTime: localStartTime,
      timezone: EventSetupValue.set(timezone),
    );
    if (!basics.isValid) {
      throw const FormatException('Invalid private event basics');
    }
    return PrivateEventBasicSummary(
      eventId: eventId,
      organizerId: organizerId,
      setupRevision: setupRevision,
      name: name,
      city: city,
      localDate: localDate,
      localStartTime: localStartTime,
      timezone: timezone,
      startTimeMillis: startTimeMillis,
      status: status as String,
      setupDefaults: Map<String, Object?>.from(setupDefaults),
      detailsConfigured: detailsConfigured,
      canEditBasics: canEditBasics,
      canChangeCity: canChangeCity,
      eventDetails: PrivateEventDetailsSnapshot.fromResponse(rawEventDetails),
      eventPreferences: data['eventPreferences'] == null
          ? null
          : PrivateEventPreferencesSnapshot.fromResponse(
              data['eventPreferences'],
            ),
    );
  }
}

class PrivateEventSetupRepository {
  const PrivateEventSetupRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<PrivateEventCreateReceipt> create({
    required String organizerId,
    required String requestId,
    required PrivateEventBasics basics,
  }) {
    if (!basics.isValid) {
      throw ArgumentError.value(basics, 'basics', 'Invalid first-save fields');
    }
    return withBackendErrorContext(
      () async {
        final response = await _functions
            .httpsCallable('createPrivateEventSetup')
            .call<Object?>({
              'organizerId': organizerId,
              'requestId': requestId,
              'basics': basics.toJson(),
            });
        return PrivateEventCreateReceipt.fromResponse(response.data);
      },
      context: const BackendErrorContext(
        service: BackendService.functions,
        action: 'create private event',
        resource: 'createPrivateEventSetup',
      ),
    );
  }

  Future<PrivateEventCreateReceipt> update(
    PrivateEventBasicsUpdateRequest request,
  ) {
    if (!request.isValid) {
      throw ArgumentError.value(request, 'request', 'Invalid basics update');
    }
    return withBackendErrorContext(
      () async {
        final response = await _functions
            .httpsCallable('updatePrivateEventBasics')
            .call<Object?>(request.toJson());
        final receipt = PrivateEventCreateReceipt.fromResponse(response.data);
        if (receipt.eventId != request.eventId) {
          throw const FormatException('Basics update changed event identity');
        }
        return receipt;
      },
      context: const BackendErrorContext(
        service: BackendService.functions,
        action: 'update private event basics',
        resource: 'updatePrivateEventBasics',
      ),
    );
  }

  Future<PrivateEventBasicSummary> get({
    required String organizerId,
    required String eventId,
  }) {
    if (organizerId.trim().isEmpty || eventId.trim().isEmpty) {
      throw ArgumentError('Organizer and event ids are required');
    }
    return withBackendErrorContext(
      () async {
        final response = await _functions
            .httpsCallable('getPrivateEventSetup')
            .call<Object?>({'organizerId': organizerId, 'eventId': eventId});
        final summary = PrivateEventBasicSummary.fromResponse(response.data);
        if (summary.organizerId != organizerId || summary.eventId != eventId) {
          throw const FormatException('Private event read changed identity');
        }
        return summary;
      },
      context: const BackendErrorContext(
        service: BackendService.functions,
        action: 'read private event setup',
        resource: 'getPrivateEventSetup',
      ),
    );
  }

  /// Manager inventory for basics-only private events that cannot be decoded
  /// through the public rich Event model or a device-local draft list.
  Future<PrivateEventSetupInventoryPage> list({
    required String organizerId,
    int limit = ReadLimitPolicy.privateEventSetupPage,
    String? cursor,
  }) {
    if (!_setupInventoryId.hasMatch(organizerId) ||
        limit < 1 || limit > 50 ||
        (cursor != null && !_setupInventoryCursor.hasMatch(cursor))) {
      throw ArgumentError('Invalid private event inventory request');
    }
    return withBackendErrorContext(
      () async {
        final response = await _functions
            .httpsCallable('listPrivateEventSetups')
            .call<Object?>({
              'organizerId': organizerId,
              'limit': limit,
              'cursor': ?cursor,
            });
        return PrivateEventSetupInventoryPage.fromResponse(response.data);
      },
      context: const BackendErrorContext(
        service: BackendService.functions,
        action: 'list private event setups',
        resource: 'listPrivateEventSetups',
      ),
    );
  }
}

final _setupInventoryId = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]{0,119}$');
final _setupInventoryCursor = RegExp(r'^[A-Za-z0-9_-]{1,1024}$');

class PrivateEventSetupInventoryItem {
  const PrivateEventSetupInventoryItem({
    required this.eventId,
    required this.name,
    required this.city,
    required this.localDate,
    required this.localStartTime,
    required this.timezone,
    required this.startTimeMillis,
    required this.setupRevision,
    required this.detailsConfigured,
  });

  final String eventId;
  final String name;
  final EventSetupCity city;
  final String localDate;
  final String localStartTime;
  final String timezone;
  final int startTimeMillis;
  final int setupRevision;
  final bool detailsConfigured;

  factory PrivateEventSetupInventoryItem.fromResponse(Object? response) {
    if (response is! Map) {
      throw const FormatException('Invalid private event inventory item');
    }
    final data = Map<String, Object?>.from(response);
    const keys = {
      'eventId', 'name', 'city', 'localDate', 'localStartTime',
      'timezone', 'startTimeMillis', 'setupRevision', 'status',
      'detailsConfigured',
    };
    final rawCity = data['city'];
    if (data.length != keys.length ||
        data.keys.any((key) => !keys.contains(key)) ||
        rawCity is! Map) {
      throw const FormatException('Invalid private event inventory item');
    }
    final city = Map<String, Object?>.from(rawCity);
    final eventId = data['eventId'];
    final name = data['name'];
    final localDate = data['localDate'];
    final localStartTime = data['localStartTime'];
    final timezone = data['timezone'];
    final startTimeMillis = data['startTimeMillis'];
    final revision = data['setupRevision'];
    final configured = data['detailsConfigured'];
    if (city.length != 2 ||
        city['cityId'] is! String ||
        city['marketId'] is! String ||
        eventId is! String || !_setupInventoryId.hasMatch(eventId) ||
        name is! String || name.trim().isEmpty || name.length > 120 ||
        localDate is! String || localStartTime is! String ||
        timezone is! String || timezone.isEmpty || timezone.length > 100 ||
        startTimeMillis is! int || revision is! int || revision < 1 ||
        data['status'] != 'active' || configured is! bool) {
      throw const FormatException('Invalid private event inventory item');
    }
    final basics = PrivateEventBasics(
      name: name,
      city: EventSetupValue.set(EventSetupCity(
        cityId: city['cityId'] as String,
        marketId: city['marketId'] as String,
      )),
      localDate: localDate,
      localStartTime: localStartTime,
      timezone: EventSetupValue.set(timezone),
    );
    if (!basics.isValid ||
        !_setupInventoryId.hasMatch(city['cityId'] as String) ||
        !_setupInventoryId.hasMatch(city['marketId'] as String)) {
      throw const FormatException('Invalid private event inventory item');
    }
    return PrivateEventSetupInventoryItem(
      eventId: eventId,
      name: name,
      city: basics.city.value!,
      localDate: localDate,
      localStartTime: localStartTime,
      timezone: timezone,
      startTimeMillis: startTimeMillis,
      setupRevision: revision,
      detailsConfigured: configured,
    );
  }
}

class PrivateEventSetupInventoryPage {
  const PrivateEventSetupInventoryPage({
    required this.events,
    required this.nextCursor,
  });

  final List<PrivateEventSetupInventoryItem> events;
  final String? nextCursor;

  factory PrivateEventSetupInventoryPage.fromResponse(Object? response) {
    if (response is! Map) {
      throw const FormatException('Invalid private event inventory');
    }
    final data = Map<String, Object?>.from(response);
    final rawEvents = data['events'];
    final cursor = data['nextCursor'];
    if (data.length != 2 || rawEvents is! List || rawEvents.length > 50 ||
        (cursor != null &&
            (cursor is! String || !_setupInventoryCursor.hasMatch(cursor)))) {
      throw const FormatException('Invalid private event inventory');
    }
    final events = rawEvents
        .map(PrivateEventSetupInventoryItem.fromResponse)
        .toList(growable: false);
    if (events.map((event) => event.eventId).toSet().length != events.length) {
      throw const FormatException('Duplicate private event inventory item');
    }
    return PrivateEventSetupInventoryPage(
      events: events,
      nextCursor: cursor as String?,
    );
  }
}
