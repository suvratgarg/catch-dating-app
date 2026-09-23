import 'package:catch_dating_app/programs/domain/program_models.dart';

bool canReadProgramStation(
  ProgramWorkAccess access,
  String? stationId, {
  required bool dispatch,
  required DateTime now,
  bool forSnapshot = false,
}) {
  final duties = [
    ProgramStaffDuty.transportDispatcher,
    if (!dispatch) ProgramStaffDuty.airportGreeter,
  ];
  // A saved roster/plan may contain rows exposed by any matching tuple.
  // Require a fresh projection after its authority shrinks, even when another
  // tuple still permits opening the same station.
  if (forSnapshot &&
      !access.isManager &&
      access.duties.any(
        (assignment) =>
            (duties.contains(assignment.duty) ||
                assignment.duty == ProgramStaffDuty.programCoordinator) &&
            (stationId == null || assignment.coversPickupPoint(stationId)) &&
            !assignment.isActiveAt(now),
      )) {
    return false;
  }
  for (final duty in duties) {
    if (!access.hasDuty(duty, now: now)) continue;
    final stations = access.stationScope(duty, now: now);
    if (stations == null ||
        (stationId != null && stations.contains(stationId))) {
      return true;
    }
  }
  return false;
}
