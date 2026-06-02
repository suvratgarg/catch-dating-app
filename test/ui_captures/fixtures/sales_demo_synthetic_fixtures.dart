import 'dart:convert';
import 'dart:io';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

import '../../clubs/clubs_test_helpers.dart' as club_test;
import '../../events/events_test_helpers.dart' as event_test;

final salesDemoSyntheticFixtures = SalesDemoSyntheticFixtures.load();

final _ageReferenceDate = DateTime(2026, 5, 31);

const salesDemoNycRosterPersonaIds = <String>[
  'nyc_maya_shah_001',
  'nyc_jordan_ellis_002',
  'nyc_sofia_martinez_003',
  'nyc_ethan_brooks_004',
  'nyc_aisha_williams_005',
  'nyc_daniel_kim_006',
  'nyc_priya_desai_007',
  'nyc_marcus_chen_008',
  'nyc_chloe_bennett_009',
  'nyc_noah_patel_010',
  'nyc_olivia_nguyen_011',
  'nyc_caleb_johnson_012',
  'nyc_emma_rodriguez_013',
  'nyc_liam_oconnor_014',
  'nyc_nia_okafor_015',
  'nyc_arjun_mehta_016',
  'nyc_grace_liu_017',
  'nyc_miles_anderson_018',
  'nyc_hannah_cohen_019',
  'nyc_andre_baptiste_020',
  'nyc_isabella_romano_021',
  'nyc_samir_khan_022',
  'nyc_taylor_reed_023',
  'nyc_victor_alvarez_024',
];

class SalesDemoSyntheticFixtures {
  const SalesDemoSyntheticFixtures._(this._personas);

  factory SalesDemoSyntheticFixtures.load({
    String path =
        'tool/demo/demo_seed/personas/us_nyc_sales_profile_projection.planned.json',
  }) {
    final decoded = jsonDecode(File(path).readAsStringSync());
    final root = _stringMap(decoded, context: path);
    if (_optionalStringFrom(root, 'kind') !=
        'sales-demo-persona-profile-projection') {
      throw StateError(
        'Expected sales demo persona profile projection in $path.',
      );
    }
    final remotePhotosAvailable = _list(
      root['assetStatuses'],
    ).whereType<String>().contains('uploaded');
    final personas = <String, _SalesDemoPersona>{};
    for (final persona in _list(root['personas'])) {
      final mapped = _SalesDemoPersona(
        _stringMap(persona, context: path),
        remotePhotosAvailable: remotePhotosAvailable,
      );
      personas[mapped.id] = mapped;
    }
    return SalesDemoSyntheticFixtures._(personas);
  }

  final Map<String, _SalesDemoPersona> _personas;

  List<String> get personaIds => List.unmodifiable(_personas.keys);

  PublicProfile publicProfile(String personaId) {
    final persona = _personas[personaId];
    if (persona == null) {
      throw ArgumentError.value(
        personaId,
        'personaId',
        'Unknown sales demo persona id.',
      );
    }
    return persona.toPublicProfile();
  }

  List<PublicProfile> publicProfiles(Iterable<String> personaIds) => [
    for (final personaId in personaIds) publicProfile(personaId),
  ];

  List<PublicProfile> rosterProfiles({
    int? count,
    Iterable<String> skipPersonaIds = const <String>[],
  }) {
    final limit = count ?? salesDemoNycRosterPersonaIds.length;
    final skip = skipPersonaIds.toSet();
    return [
      for (final personaId in salesDemoNycRosterPersonaIds)
        if (!skip.contains(personaId)) publicProfile(personaId),
    ].take(limit).toList(growable: false);
  }

  Club captureClub({
    required String id,
    required String name,
    required String description,
    required String area,
    String location = 'mumbai',
    String hostUserId = 'sales-demo-host',
    String hostName = 'Host',
    List<String> tags = const <String>['social'],
    int memberCount = 72,
    double rating = 4.8,
    int reviewCount = 24,
    DateTime? nextEventAt,
    String? nextEventLabel,
  }) {
    return club_test.buildClub(
      id: id,
      name: name,
      description: description,
      location: location,
      area: area,
      hostUserId: hostUserId,
      hostName: hostName,
      tags: tags,
      memberCount: memberCount,
      rating: rating,
      reviewCount: reviewCount,
      nextEventAt: nextEventAt,
      nextEventLabel: nextEventLabel,
    );
  }

  Event captureEvent({
    required String id,
    required Club club,
    required DateTime startTime,
    DateTime? endTime,
    required String meetingPoint,
    String? locationDetails,
    double? startingPointLat,
    double? startingPointLng,
    ActivityKind activityKind = ActivityKind.socialRun,
    double distanceKm = 5,
    int bookedCount = 14,
    int checkedInCount = 0,
    int waitlistedCount = 0,
    int capacityLimit = 20,
    int priceInPaise = 0,
    String description = 'A hosted event with a clear social rhythm.',
  }) {
    return event_test.buildEvent(
      id: id,
      clubId: club.id,
      startTime: startTime,
      endTime: endTime,
      meetingPoint: meetingPoint,
      locationDetails: locationDetails,
      startingPointLat: startingPointLat,
      startingPointLng: startingPointLng,
      eventFormat: EventFormatSnapshot.fromActivityKind(activityKind),
      distanceKm: distanceKm,
      bookedCount: bookedCount,
      checkedInCount: checkedInCount,
      waitlistedCount: waitlistedCount,
      capacityLimit: capacityLimit,
      priceInPaise: priceInPaise,
      description: description,
    );
  }

  EventDraft hostSetupDraft({
    required String id,
    required Club club,
    required DateTime savedAt,
    DateTime? eventDate,
  }) {
    final scheduledDate = eventDate ?? DateTime(2026, 6, 7);
    return EventDraft(
      id: id,
      clubId: club.id,
      savedAt: savedAt,
      activityKind: ActivityKind.dinner.name,
      capacity: '16',
      price: '1200',
      description:
          'A hosted long-table dinner with arrivals, prompts, and a warm close.',
      meetingPoint: 'Pali Village Cafe',
      locationDetails: 'Ask for the Catch table near the courtyard.',
      meetingLocationAddress: 'Pali Village, Bandra West',
      meetingLocationPlaceId: 'capture-pali-village-cafe',
      startingPointLat: 19.0648,
      startingPointLng: 72.8292,
      selectedDateMillis: scheduledDate.millisecondsSinceEpoch,
      selectedStartHour: 20,
      selectedStartMinute: 0,
      durationMinutes: 120,
      minAge: '24',
      maxAge: '34',
      admissionPreset: 'balancedSingles',
      dynamicPricingEnabled: true,
      dynamicPricingStep: '200',
      dynamicPricingMax: '1800',
    );
  }

  List<EventParticipation> participationsForProfiles({
    required Event event,
    required Iterable<PublicProfile> profiles,
    int attendedCount = 0,
    int waitlistedCount = 0,
    DateTime? createdAt,
  }) {
    final profileList = profiles.toList(growable: false);
    final firstCreatedAt = createdAt ?? DateTime(2026, 5, 28, 10);
    return [
      for (final indexed in profileList.indexed)
        event_test.buildEventParticipation(
          event: event,
          uid: indexed.$2.uid,
          status: _participationStatusForIndex(
            indexed.$1,
            totalCount: profileList.length,
            attendedCount: attendedCount,
            waitlistedCount: waitlistedCount,
          ),
          createdAt: firstCreatedAt.add(Duration(minutes: indexed.$1 * 7)),
          genderAtSignup: indexed.$2.gender,
        ),
    ];
  }

  List<Review> reviewsForProfiles({
    required Club club,
    required Event event,
    required Iterable<PublicProfile> reviewers,
    DateTime? firstCreatedAt,
  }) {
    final comments = const <String>[
      'Clear route, thoughtful host, and an easy coffee plan after.',
      'The prompts made it simple to meet people without forcing it.',
      'Well-paced, warm, and everyone knew where to be.',
    ];
    final createdAt = firstCreatedAt ?? DateTime(2026, 5, 25);
    return [
      for (final indexed in reviewers.indexed)
        Review(
          id: 'review-${event.id}-${indexed.$1 + 1}',
          clubId: club.id,
          eventId: event.id,
          reviewerUserId: indexed.$2.uid,
          reviewerName: _firstName(indexed.$2.name),
          rating: 5,
          comment: comments[indexed.$1 % comments.length],
          createdAt: createdAt.subtract(Duration(days: indexed.$1 * 3)),
        ),
    ];
  }

  List<Review> reviewsByViewer({
    required Iterable<Event> events,
    required String reviewerUserId,
    required String reviewerName,
    DateTime? firstCreatedAt,
  }) {
    final comments = const <String>[
      'Clear route, thoughtful host, and an easy coffee plan after.',
      'The table prompts made the room feel warm without being forced.',
      'Good pacing, useful updates, and I met people I would actually see again.',
    ];
    final eventList = events.toList(growable: false);
    final createdAt = firstCreatedAt ?? DateTime(2026, 5, 25);
    return [
      for (final indexed in eventList.indexed)
        Review(
          id: 'review-${indexed.$2.id}',
          clubId: indexed.$2.clubId,
          eventId: indexed.$2.id,
          reviewerUserId: reviewerUserId,
          reviewerName: reviewerName,
          rating: 5,
          comment: comments[indexed.$1 % comments.length],
          createdAt: createdAt.subtract(Duration(days: indexed.$1 * 5)),
        ),
    ];
  }
}

EventParticipationStatus _participationStatusForIndex(
  int index, {
  required int totalCount,
  required int attendedCount,
  required int waitlistedCount,
}) {
  if (index >= totalCount - waitlistedCount) {
    return EventParticipationStatus.waitlisted;
  }
  if (index < attendedCount) return EventParticipationStatus.attended;
  return EventParticipationStatus.signedUp;
}

String _firstName(String name) => name.trim().split(RegExp(r'\s+')).first;

class _SalesDemoPersona {
  const _SalesDemoPersona(this._json, {required this.remotePhotosAvailable});

  final Map<String, Object?> _json;
  final bool remotePhotosAvailable;

  String get id => _requiredString('id');

  PublicProfile toPublicProfile() {
    return PublicProfile(
      uid: id,
      name: _requiredString('displayName'),
      age: _ageFromBirthDate(_requiredString('dateOfBirth')),
      gender: _genderFromCatalog(_requiredString('gender')),
      profilePrompts: _profilePrompts(),
      profilePhotos: _profilePhotos(),
      city: _optionalString('cityLabel'),
      height: _optionalInt('heightCm'),
      occupation: _optionalString('occupation'),
      company: _optionalString('company'),
    );
  }

  List<ProfilePromptAnswer> _profilePrompts() {
    return normalizeProfilePromptAnswers(
      _list(_json['profilePrompts']).map((item) {
        final prompt = _stringMap(item, context: id);
        final definition = profilePromptDefinition(
          _requiredStringFrom(prompt, 'promptId'),
        );
        return profilePromptAnswerFor(
          definition: definition,
          answer: _requiredStringFrom(prompt, 'answer'),
        );
      }),
    );
  }

  List<ProfilePhoto> _profilePhotos() {
    if (!remotePhotosAvailable) return const <ProfilePhoto>[];
    final photos = <ProfilePhoto>[];
    for (final item in _list(_json['profilePhotos'])) {
      final photo = _stringMap(item, context: id);
      final position = _optionalIntFrom(photo, 'position') ?? photos.length;
      photos.add(
        ProfilePhoto(
          id: _requiredStringFrom(photo, 'id'),
          url: _requiredStringFrom(photo, 'url'),
          thumbnailUrl: _requiredStringFrom(photo, 'thumbnailUrl'),
          storagePath: _requiredStringFrom(photo, 'storagePath'),
          thumbnailStoragePath: _requiredStringFrom(
            photo,
            'thumbnailStoragePath',
          ),
          position: position,
          createdAt: _ageReferenceDate,
          updatedAt: _ageReferenceDate,
          prompt: _photoPrompt(photo, position),
          moderation: const ProfilePhotoModeration(status: 'approved'),
        ),
      );
    }
    return normalizeProfilePhotos(photos);
  }

  PhotoPromptAnswer? _photoPrompt(Map<String, Object?> photo, int position) {
    final promptId = _optionalStringFrom(photo, 'promptId');
    if (promptId == null) return null;
    return photoPromptAnswerFor(
      photoIndex: position,
      definition: photoPromptDefinition(promptId),
    );
  }

  String _requiredString(String key) => _requiredStringFrom(_json, key);

  String? _optionalString(String key) => _optionalStringFrom(_json, key);

  int? _optionalInt(String key) => _optionalIntFrom(_json, key);
}

int _ageFromBirthDate(String value) {
  final birthDate = DateTime.parse(value);
  var age = _ageReferenceDate.year - birthDate.year;
  final birthdayThisYear = DateTime(
    _ageReferenceDate.year,
    birthDate.month,
    birthDate.day,
  );
  if (_ageReferenceDate.isBefore(birthdayThisYear)) age -= 1;
  return age;
}

Gender _genderFromCatalog(String value) {
  return Gender.values.firstWhere(
    (gender) => gender.name == value,
    orElse: () => Gender.other,
  );
}

String _requiredStringFrom(Map<String, Object?> json, String key) {
  final value = _optionalStringFrom(json, key);
  if (value == null) {
    throw StateError('Missing required string "$key".');
  }
  return value;
}

String? _optionalStringFrom(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

int? _optionalIntFrom(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is num) return value.round();
  return null;
}

Map<String, Object?> _stringMap(Object? value, {required String context}) {
  if (value is Map) {
    return value.map((key, child) => MapEntry(key.toString(), child));
  }
  throw StateError('Expected object in $context.');
}

List<Object?> _list(Object? value) {
  if (value is List) return value;
  return const <Object?>[];
}
