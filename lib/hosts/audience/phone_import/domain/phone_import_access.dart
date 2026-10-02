import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';

/// An affordance derived from a fresh canonical work-access response. The
/// import callable must still recheck the current grant before every write.
bool canImportWeddingPhoneContacts(ProgramWorkAccess access, DateTime now) {
  // Keep production entry and direct routes closed until the backend rollout
  // and native import compatibility proof in release_operations.md are accepted.
  if (AppConfig.environment.isProduction) return false;
  if (access.kind != ProgramKind.wedding ||
      access.status == ProgramStatus.archived) {
    return false;
  }
  if (access.isManager) return true;
  final grantDeadline = access.grantExpiresAt;
  if (grantDeadline == null || !grantDeadline.isAfter(now)) return false;
  return access
      .activeDutiesAt(now)
      .any(
        (assignment) =>
            (assignment.duty == ProgramStaffDuty.guestRelations ||
                assignment.duty == ProgramStaffDuty.programCoordinator) &&
            assignment.pickupPointIds.isEmpty &&
            assignment.hotelIds.isEmpty &&
            assignment.functionIds.isEmpty &&
            !assignment.expiresAt!.isAfter(grantDeadline),
      );
}
