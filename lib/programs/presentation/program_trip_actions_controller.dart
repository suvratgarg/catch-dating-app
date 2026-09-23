import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'program_trip_actions_controller.g.dart';

/// Trip-lifecycle mutations for the hotel desk and ledger surfaces.
/// Widgets go through this controller rather than reaching into
/// repository providers directly.
@riverpod
class ProgramTripActions extends _$ProgramTripActions {
  @override
  void build() {}

  Future<ProgramMutationResult> markArrived({
    required String programId,
    required String tripId,
    required int expectedRevision,
    required String clientOperationId,
  }) => ref
      .read(programWorkRepositoryProvider)
      .markTripArrived(
        programId: programId,
        tripId: tripId,
        expectedRevision: expectedRevision,
        clientOperationId: clientOperationId,
      );

  Future<ProgramMutationResult> voidTrip({
    required String programId,
    required String tripId,
    required int expectedRevision,
    required String reason,
    required String clientOperationId,
  }) => ref
      .read(programWorkRepositoryProvider)
      .voidTrip(
        programId: programId,
        tripId: tripId,
        expectedRevision: expectedRevision,
        reason: reason,
        clientOperationId: clientOperationId,
      );
}
