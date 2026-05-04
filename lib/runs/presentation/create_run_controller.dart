import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_run_controller.g.dart';

/// **Pattern B: Stateless controller + static Mutations**
///
/// Validates input and delegates run creation to [RunRepository].
/// [submitMutation] carries the created [Run] on success so the UI can
/// navigate to the run detail screen.
@riverpod
class CreateRunController extends _$CreateRunController {
  static final submitMutation = Mutation<Run>();

  @override
  void build() {}

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
    if ((startingPointLat == null) != (startingPointLng == null)) {
      throw ArgumentError(
        'Starting point latitude and longitude must both be provided or both be omitted.',
      );
    }

    final runRepo = ref.read(runRepositoryProvider);
    final run = Run(
      id: runRepo.generateId(),
      runClubId: normalizedRunClubId,
      startTime: startTime,
      endTime: endTime,
      meetingPoint: normalizedMeetingPoint,
      startingPointLat: startingPointLat,
      startingPointLng: startingPointLng,
      locationDetails: normalizedLocationDetails,
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
