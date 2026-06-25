import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExternalEvent {
  const ExternalEvent({
    required this.id,
    required this.canonicalHostId,
    required this.compatibilityClubId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.meetingPoint,
    required this.activityKind,
    required this.interactionModel,
    required this.status,
    required this.publicationStatus,
    required this.citySlug,
    required this.externalLinks,
    this.timezone,
    this.locationDetails,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.priceDisplayText,
    this.parsedPriceInPaise,
    this.currency = defaultCurrencyCode,
    this.sourcePlatform,
  });

  factory ExternalEvent.fromJson(Map<String, dynamic> json) {
    final meetingLocation = _map(json['meetingLocation']);
    final activity = _map(json['activity']);
    final price = _map(json['price']);
    final booking = _map(json['booking']);
    final discovery = _map(json['discovery']);
    final externalSource = _map(json['externalSource']);

    return ExternalEvent(
      id: _string(json['eventId']) ?? '',
      canonicalHostId: _string(json['canonicalHostId']) ?? '',
      compatibilityClubId: _string(json['compatibilityClubId']) ?? '',
      title: _string(json['title']) ?? '',
      description: _string(json['description']) ?? '',
      startTime: _requiredTimestamp(json['startTime'], 'startTime'),
      endTime: _nullableTimestamp(json['endTime']),
      timezone: _string(json['timezone']),
      meetingPoint:
          _string(meetingLocation['name']) ??
          _string(json['meetingPoint']) ??
          '',
      locationDetails:
          _string(meetingLocation['notes']) ?? _string(json['locationDetails']),
      photoUrl: _string(json['photoUrl']),
      latitude: _number(meetingLocation['latitude']),
      longitude: _number(meetingLocation['longitude']),
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

  final String id;
  final String canonicalHostId;
  final String compatibilityClubId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final String? timezone;
  final String meetingPoint;
  final String? locationDetails;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final ActivityKind activityKind;
  final EventInteractionModel interactionModel;
  final String? priceDisplayText;
  final int? parsedPriceInPaise;
  final String currency;
  final String status;
  final String publicationStatus;
  final String? citySlug;
  final List<ExternalEventLink> externalLinks;
  final String? sourcePlatform;

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

class ExternalEventLink {
  const ExternalEventLink({
    required this.platform,
    required this.url,
    required this.linkType,
    required this.sourceEventKey,
    required this.candidateId,
    required this.primary,
  });

  factory ExternalEventLink.fromJson(Map<String, dynamic> json) {
    return ExternalEventLink(
      platform: _string(json['platform']) ?? '',
      url: _string(json['url']) ?? '',
      linkType: _string(json['linkType']) ?? '',
      sourceEventKey: _string(json['sourceEventKey']) ?? '',
      candidateId: _string(json['candidateId']) ?? '',
      primary: json['primary'] == true,
    );
  }

  final String platform;
  final String url;
  final String linkType;
  final String sourceEventKey;
  final String candidateId;
  final bool primary;
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
  final parsed = _nullableTimestamp(value);
  if (parsed == null) {
    throw FormatException('Missing timestamp field "$field".');
  }
  return parsed;
}

DateTime? _nullableTimestamp(Object? value) {
  return switch (value) {
    null => null,
    Timestamp() => value.toDate(),
    DateTime() => value,
    _ => null,
  };
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

double? _number(Object? value) {
  if (value is num) return value.toDouble();
  return null;
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
