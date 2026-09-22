import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:catch_dating_app/programs/domain/travel_leg_revision.dart';

export 'travel_leg_revision.dart';

void validateDispatchRevisionFences(
  List<String> legIds,
  List<DispatchLegRevision> fences,
) {
  if (legIds.isEmpty ||
      legIds.toSet().length != legIds.length ||
      fences.length != legIds.length ||
      fences.map((fence) => fence.legId).toSet().length != legIds.length ||
      fences.any(
        (fence) => fence.revision < 1 || !legIds.contains(fence.legId),
      )) {
    throw const ValidationException(
      'Reload the manifest before dispatching. Every passenger needs a '
      'current revision.',
      code: 'dispatch-manifest-needs-review',
    );
  }
}

/// Captures the actual roster shown to the dispatcher, including a saved view.
/// The server revalidates every revision when this immutable command replays.
List<DispatchLegRevision> captureDispatchLegRevisions(
  ProgramArrivalsRoster roster,
  List<String> legIds,
) {
  final rows = {for (final row in roster.rows) row.legId: row};
  final fences = <DispatchLegRevision>[];
  for (final legId in legIds) {
    final row = rows[legId];
    if (row == null || row.readiness != TravelLegReadiness.ready) {
      throw const ValidationException(
        'Every passenger must be marked ready before the vehicle departs. '
        'Refresh the arrivals roster after the waiting guests reach the curb.',
        code: 'dispatch-passengers-not-ready',
      );
    }
    fences.add(DispatchLegRevision(legId: legId, revision: row.revision));
  }
  validateDispatchRevisionFences(legIds, fences);
  return fences;
}
