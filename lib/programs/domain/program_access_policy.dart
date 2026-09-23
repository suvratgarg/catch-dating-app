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

/// Dispatch needs one tuple covering both ends of the selected route. Its
/// captured sheet must refresh when any contributing tuple expires.
({bool allowed, DateTime? expiresAt}) programDispatchAccess(
  ProgramWorkAccess access,
  String pickupPointId,
  String? hotelId, {
  required DateTime now,
}) {
  if (access.isManager) return (allowed: true, expiresAt: null);
  final assignments = access
      .activeDutiesAt(now)
      .where(
        (assignment) =>
            (assignment.duty == ProgramStaffDuty.transportDispatcher ||
                assignment.duty == ProgramStaffDuty.programCoordinator) &&
            assignment.coversPickupPoint(pickupPointId) &&
            (assignment.hotelIds.isEmpty ||
                (hotelId != null && assignment.coversHotel(hotelId))),
      );
  if (assignments.isEmpty) return (allowed: false, expiresAt: null);
  var expiry = access.grantExpiresAt!;
  for (final assignment in assignments) {
    if (assignment.expiresAt!.isBefore(expiry)) expiry = assignment.expiresAt!;
  }
  return (allowed: true, expiresAt: expiry);
}
