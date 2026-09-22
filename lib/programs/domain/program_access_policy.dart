import 'package:catch_dating_app/programs/domain/program_models.dart';

bool canReadProgramStation(
  ProgramWorkAccess access,
  String? stationId, {
  required bool dispatch,
}) {
  final duties = [
    ProgramStaffDuty.transportDispatcher,
    if (!dispatch) ProgramStaffDuty.airportGreeter,
  ];
  for (final duty in duties) {
    if (!access.hasDuty(duty)) continue;
    final stations = access.stationScope(duty);
    if (stations == null ||
        (stationId != null && stations.contains(stationId))) {
      return true;
    }
  }
  return false;
}
