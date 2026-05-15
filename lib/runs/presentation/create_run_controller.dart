import 'dart:typed_data';

import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_run_controller.g.dart';

class PickedRunPhoto {
  const PickedRunPhoto({required this.image, required this.bytes});

  final XFile image;
  final Uint8List bytes;
}

/// **Pattern A: Action controller + static Mutations**
///
/// Validates input and delegates run creation to [RunRepository].
/// [submitMutation] carries the created [Run] on success so the UI can
/// navigate to the run detail screen.
@riverpod
class CreateRunController extends _$CreateRunController {
  static final submitMutation = Mutation<Run>();

  @override
  void build() {}

  Future<PickedRunPhoto?> pickRunPhoto({int imageQuality = 82}) async {
    final image = await ref
        .read(imageUploadRepositoryProvider)
        .pickImage(
          purpose: ImageUploadPurpose.runPhoto,
          imageQuality: imageQuality,
        );
    if (image == null) {
      return null;
    }

    return PickedRunPhoto(image: image, bytes: await image.readAsBytes());
  }

  Future<Run> submit({
    required String runClubId,
    required DateTime startTime,
    required DateTime endTime,
    required String meetingPoint,
    double? startingPointLat,
    double? startingPointLng,
    String? locationDetails,
    required double distanceKm,
    required PaceLevel pace,
    required int capacityLimit,
    required String description,
    required int priceInPaise,
    required RunConstraints constraints,
    XFile? photoImage,
  }) async {
    final normalizedRunClubId = _requireNonBlank(
      runClubId,
      fieldName: 'runClubId',
      message: 'Run club id is required.',
    );
    final normalizedMeetingPoint = _requireNonBlank(
      meetingPoint,
      fieldName: 'meetingPoint',
      message: 'Meeting point is required.',
    );
    final normalizedDescription = description.trim();
    final normalizedLocationDetails = _trimToNull(locationDetails);

    if (!endTime.isAfter(startTime)) {
      throw ArgumentError.value(
        endTime,
        'endTime',
        'Run end time must be after the start time.',
      );
    }
    if (distanceKm <= 0) {
      throw ArgumentError.value(
        distanceKm,
        'distanceKm',
        'Distance must be greater than zero.',
      );
    }
    if (capacityLimit < 1) {
      throw ArgumentError.value(
        capacityLimit,
        'capacityLimit',
        'Capacity limit must be at least 1.',
      );
    }
    if (priceInPaise < 0) {
      throw ArgumentError.value(
        priceInPaise,
        'priceInPaise',
        'Price cannot be negative.',
      );
    }
    final normalizedStartingPoint = _requireStartingPoint(
      latitude: startingPointLat,
      longitude: startingPointLng,
    );

    final runRepo = ref.read(runRepositoryProvider);
    final runId = runRepo.generateId();
    String? photoUrl;
    if (photoImage != null) {
      photoUrl = await ref
          .read(imageUploadRepositoryProvider)
          .uploadRunPhoto(
            runClubId: normalizedRunClubId,
            runId: runId,
            image: photoImage,
          );
    }

    final run = Run(
      id: runId,
      runClubId: normalizedRunClubId,
      startTime: startTime,
      endTime: endTime,
      meetingPoint: normalizedMeetingPoint,
      startingPointLat: normalizedStartingPoint.latitude,
      startingPointLng: normalizedStartingPoint.longitude,
      locationDetails: normalizedLocationDetails,
      photoUrl: photoUrl,
      distanceKm: distanceKm,
      pace: pace,
      capacityLimit: capacityLimit,
      description: normalizedDescription,
      priceInPaise: priceInPaise,
      constraints: constraints,
    );
    await runRepo.createRun(run: run);
    return run;
  }
}

({double latitude, double longitude}) _requireStartingPoint({
  required double? latitude,
  required double? longitude,
}) {
  if (latitude == null || longitude == null) {
    throw ArgumentError(
      'A pinned starting point is required for run check-in and directions.',
    );
  }
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
  return (latitude: latitude, longitude: longitude);
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
