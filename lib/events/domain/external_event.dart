import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'external_event.freezed.dart';
part 'external_event.g.dart';

@freezed
abstract class ExternalEvent with _$ExternalEvent {
  const ExternalEvent._();

  const factory ExternalEvent({
    required String id,
    required String canonicalHostId,
    required String compatibilityClubId,
    required String title,
    required String description,
    @TimestampConverter() required DateTime startTime,
    @NullableTimestampConverter() DateTime? endTime,
    String? timezone,
    required String meetingPoint,
    String? locationDetails,
    String? photoUrl,
    required double latitude,
    required double longitude,
    required ActivityKind activityKind,
    required EventInteractionModel interactionModel,
    String? priceDisplayText,
    int? parsedPriceInPaise,
    @Default(defaultCurrencyCode) String currency,
    required String status,
    required String publicationStatus,
    String? citySlug,
    required List<ExternalEventLink> externalLinks,
    String? sourcePlatform,
  }) = _ExternalEvent;

  factory ExternalEvent.fromJson(Map<String, dynamic> json) {
    final meetingLocation = _map(json['meetingLocation']);
    final activity = _map(json['activity']);
    final price = _map(json['price']);
    final booking = _map(json['booking']);
    final discovery = _map(json['discovery']);
    final externalSource = _map(json['externalSource']);

    return _ExternalEvent(
      id: _string(json['eventId']) ?? '',
      canonicalHostId: _string(json['canonicalHostId']) ?? '',
      compatibilityClubId: _string(json['compatibilityClubId']) ?? '',
      title: _string(json['title']) ?? '',
      description: _string(json['description']) ?? '',
      startTime: _requiredTimestamp(json['startTime'], 'startTime'),
      endTime: _nullableTimestamp(json['endTime']),
      timezone: _string(json['timezone']),
      meetingPoint: _requiredString(
        _string(meetingLocation['name']) ?? json['meetingPoint'],
        'meetingLocation.name',
      ),
      locationDetails:
          _string(meetingLocation['notes']) ?? _string(json['locationDetails']),
      photoUrl: _string(json['photoUrl']),
      latitude: _requiredNumber(
        meetingLocation['latitude'],
        'meetingLocation.latitude',
        minimum: -90,
        maximum: 90,
      ),
      longitude: _requiredNumber(
        meetingLocation['longitude'],
        'meetingLocation.longitude',
        minimum: -180,
        maximum: 180,
      ),
      activityKind: _enumByName(
        ActivityKind.values,
        _string(activity['activityKind']),
        ActivityKind.openActivity,
      ),
      interactionModel: _enumByName(
        EventInteractionModel.values,
        _string(activity['interactionModel']),
        ActivityKind.openActivity.defaultInteractionModel,
      ),
      priceDisplayText: _string(price['displayText']),
      parsedPriceInPaise: _integer(price['parsedPriceInPaise']),
      currency: _string(price['currency']) ?? defaultCurrencyCode,
      status: _string(json['status']) ?? '',
      publicationStatus: _string(json['publicationStatus']) ?? '',
      citySlug: _string(discovery['citySlug']),
      externalLinks: (_list(booking['externalLinks']))
          .map(ExternalEventLink.fromJson)
          .where((link) => link.url.isNotEmpty)
          .toList(growable: false),
      sourcePlatform: _string(externalSource['platform']),
    );
  }

  bool get isPublic => publicationStatus == 'public';
  bool get isActive => status == 'active';
  bool isUpcomingAt(DateTime now) => isActive && startTime.isAfter(now);
  bool isDiscoverableAt(DateTime now) => isPublic && isUpcomingAt(now);

  ExternalEventLink? get primaryExternalLink {
    for (final link in externalLinks) {
      if (link.primary) return link;
    }
    return externalLinks.firstOrNull;
  }

  Uri? get primaryExternalUri {
    final url = primaryExternalLink?.url.trim();
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  String get priceLabel {
    final display = priceDisplayText?.trim();
    if (display != null && display.isNotEmpty) return display;
    final parsed = parsedPriceInPaise;
    if (parsed == null) return 'Price on source';
    if (parsed <= 0) return 'Free';
    return formatMinorCurrency(parsed, currencyCode: currency);
  }

  String get platformLabel =>
      platformDisplayLabel(primaryExternalLink?.platform ?? sourcePlatform);
}

@freezed
abstract class ExternalEventLink with _$ExternalEventLink {
  const factory ExternalEventLink({
    @Default('') String platform,
    @Default('') String url,
    @Default('') String linkType,
    @Default('') String sourceEventKey,
    @Default('') String candidateId,
    required bool primary,
  }) = _ExternalEventLink;

  factory ExternalEventLink.fromJson(Map<String, dynamic> json) =>
      _$ExternalEventLinkFromJson(json);
}

String platformDisplayLabel(String? platform) {
  return switch (platform) {
    'bookMyShow' => 'BookMyShow',
    'district' => 'District',
    'luma' => 'Luma',
    'partiful' => 'Partiful',
    'sortMyScene' => 'Sort My Scene',
    _ => 'Source',
  };
}

DateTime _requiredTimestamp(Object? value, String field) {
  return dateTimeFromFirestoreValue(value, field: field);
}

DateTime? _nullableTimestamp(Object? value) {
  return nullableDateTimeFromFirestoreValue(value);
}

Map<String, dynamic> _map(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry('$key', value));
  }
  return const {};
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) return const [];
  return [
    for (final item in value)
      if (item is Map<String, dynamic>)
        item
      else if (item is Map)
        item.map((key, value) => MapEntry('$key', value)),
  ];
}

String? _string(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _requiredString(Object? value, String field) {
  final string = _string(value);
  if (string == null) {
    throw FormatException('$field must be a non-empty string.');
  }
  return string;
}

double _requiredNumber(
  Object? value,
  String field, {
  required double minimum,
  required double maximum,
}) {
  if (value is! num) {
    throw FormatException('$field must be a number.');
  }
  final number = value.toDouble();
  if (!number.isFinite || number < minimum || number > maximum) {
    throw FormatException('$field is outside its valid range.');
  }
  return number;
}

int? _integer(Object? value) {
  if (value is num) return value.toInt();
  return null;
}

T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
