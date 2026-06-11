import 'dart:typed_data';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_event_controller.g.dart';

class PickedEventPhoto {
  const PickedEventPhoto({required this.image, required this.bytes});

  final XFile image;
  final Uint8List bytes;
}

/// **Pattern A: Action controller + static Mutations**
///
/// Validates input and delegates event creation to [EventRepository].
/// [submitMutation] carries the created [Event] on success so the UI can
/// navigate to the event detail screen.
@riverpod
class CreateEventController extends _$CreateEventController {
  static final submitMutation = Mutation<Event>();

  @override
  void build() {}

  Future<PickedEventPhoto?> pickEventPhoto({int imageQuality = 82}) async {
    final image = await ref
        .read(imageUploadRepositoryProvider)
        .pickImage(
          purpose: ImageUploadPurpose.eventPhoto,
          imageQuality: imageQuality,
        );
    if (image == null) {
      return null;
    }

    return PickedEventPhoto(image: image, bytes: await image.readAsBytes());
  }

  Future<List<PickedEventPhoto>> pickEventPhotos({
    int imageQuality = 82,
    int limit = 6,
  }) async {
    final images = await ref
        .read(imageUploadRepositoryProvider)
        .pickImages(
          purpose: ImageUploadPurpose.eventPhoto,
          imageQuality: imageQuality,
          limit: limit,
        );
    return [
      for (final image in images)
        PickedEventPhoto(image: image, bytes: await image.readAsBytes()),
    ];
  }

  Future<Event> submit({
    required String clubId,
    required DateTime startTime,
    required DateTime endTime,
    required EventMeetingLocation meetingLocation,
    required EventFormatSnapshot eventFormat,
    required double distanceKm,
    required PaceLevel pace,
    required String description,
    required String currency,
    required EventConstraints constraints,
    required EventPolicyBundle eventPolicy,
    String? inviteCode,
    XFile? photoImage,
    List<XFile> photoImages = const [],
    EventSuccessDefaults eventSuccessDefaults = const EventSuccessDefaults(),
  }) async {
    final normalizedClubId = _requireNonBlank(
      clubId,
      fieldName: 'clubId',
      message: 'Club id is required.',
    );
    final normalizedMeetingLocation = _requireMeetingLocation(meetingLocation);
    final normalizedDescription = description.trim();

    if (!endTime.isAfter(startTime)) {
      throw ArgumentError.value(
        endTime,
        'endTime',
        'Event end time must be after the start time.',
      );
    }
    if (eventFormat.isDistanceBased && distanceKm <= 0) {
      throw ArgumentError.value(
        distanceKm,
        'distanceKm',
        'Distance must be greater than zero.',
      );
    }
    if (!eventFormat.isDistanceBased && distanceKm < 0) {
      throw ArgumentError.value(
        distanceKm,
        'distanceKm',
        'Distance cannot be negative.',
      );
    }
    if (eventPolicy.capacityLimit < 1) {
      throw ArgumentError.value(
        eventPolicy.capacityLimit,
        'eventPolicy.capacityLimit',
        'Capacity limit must be at least 1.',
      );
    }
    if (eventPolicy.basePriceInPaise < 0) {
      throw ArgumentError.value(
        eventPolicy.basePriceInPaise,
        'eventPolicy.basePriceInPaise',
        'Price cannot be negative.',
      );
    }
    final normalizedInviteCode = _trimToNull(inviteCode);
    if (eventPolicy.usesInviteOnly &&
        (normalizedInviteCode == null || normalizedInviteCode.length < 4)) {
      throw ArgumentError.value(
        inviteCode,
        'inviteCode',
        'Invite-only events need a code of at least 4 characters.',
      );
    }
    final eventRepo = ref.read(eventRepositoryProvider);
    final eventId = eventRepo.generateId();
    final event = Event(
      id: eventId,
      clubId: normalizedClubId,
      startTime: startTime,
      endTime: endTime,
      meetingPoint: normalizedMeetingLocation.name,
      meetingLocation: normalizedMeetingLocation,
      startingPointLat: normalizedMeetingLocation.latitude,
      startingPointLng: normalizedMeetingLocation.longitude,
      locationDetails: normalizedMeetingLocation.notes,
      eventFormat: eventFormat,
      distanceKm: distanceKm,
      pace: pace,
      capacityLimit: eventPolicy.capacityLimit,
      description: normalizedDescription,
      priceInPaise: eventPolicy.basePriceInPaise,
      currency: currency,
      constraints: constraints,
      eventPolicy: eventPolicy,
    );
    await eventRepo.createEvent(
      event: event,
      inviteCode: normalizedInviteCode,
      eventSuccessDefaults: eventSuccessDefaults.enabled
          ? eventSuccessDefaults.normalizedForFormat(
              event.eventFormat,
              targetAttendeeCount: event.capacityLimit,
            )
          : null,
    );
    final selectedPhotoImages = photoImages.isNotEmpty
        ? photoImages
        : [?photoImage];
    if (selectedPhotoImages.isEmpty) return event;

    requireSignedInUid(ref, action: 'upload event photos');
    final uploadedPhotos = <UploadedPhoto>[];
    for (final indexedImage in selectedPhotoImages.indexed) {
      final upload = await ref
          .read(imageUploadRepositoryProvider)
          .uploadEventPhotoWithMetadata(
            eventId: eventId,
            position: indexedImage.$1,
            image: indexedImage.$2,
          );
      uploadedPhotos.add(
        UploadedPhoto.fromUpload(
          url: upload.url,
          storagePath: upload.storagePath,
          position: indexedImage.$1,
        ),
      );
    }
    final updatedEvent = event.copyWith(
      photoUrl: uploadedPhotos.first.url,
      eventPhotos: uploadedPhotos,
    );
    await eventRepo.updateEventDetails(event: updatedEvent);
    return updatedEvent;
  }
}

EventMeetingLocation _requireMeetingLocation(EventMeetingLocation location) {
  final normalized = location.normalized();
  _requireNonBlank(
    normalized.name,
    fieldName: 'meetingLocation.name',
    message: 'Meeting location is required.',
  );
  _requireStartingPoint(
    latitude: normalized.latitude,
    longitude: normalized.longitude,
  );
  return normalized;
}

void _requireStartingPoint({
  required double latitude,
  required double longitude,
}) {
  if (latitude < -90 || latitude > 90) {
    throw ArgumentError.value(
      latitude,
      'startingPointLat',
      'Invalid latitude.',
    );
  }
  if (longitude < -180 || longitude > 180) {
    throw ArgumentError.value(
      longitude,
      'startingPointLng',
      'Invalid longitude.',
    );
  }
}

String _requireNonBlank(
  String value, {
  required String fieldName,
  required String message,
}) {
  final normalized = value.trim();
  if (normalized.isEmpty) {
    throw ArgumentError.value(value, fieldName, message);
  }
  return normalized;
}

String? _trimToNull(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}
