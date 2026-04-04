import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_run_controller.g.dart';

@riverpod
class CreateRunController extends _$CreateRunController {
  static final submitMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> submit({
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
    final runRepo = ref.read(runRepositoryProvider);
    await runRepo.createRun(
      run: Run(
        id: runRepo.generateId(),
        runClubId: runClubId,
        startTime: startTime,
        endTime: endTime,
        meetingPoint: meetingPoint,
        startingPointLat: startingPointLat,
        startingPointLng: startingPointLng,
        locationDetails: locationDetails,
        distanceKm: distanceKm,
        pace: pace,
        capacityLimit: capacityLimit,
        description: description,
        priceInPaise: priceInPaise,
        constraints: constraints,
      ),
    );
  }
}
