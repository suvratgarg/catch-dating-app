import 'package:catch_dating_app/hosts/audience/phone_import/presentation/phone_import_controller.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/presentation/phone_import_submission_controller.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';

/// One route-owned, disposable review. Confirmed retry data has its separate
/// account/program lifetime in the canonical command database.
class PhoneImportRouteSession {
  const PhoneImportRouteSession({
    required this.accountId,
    required this.access,
    required this.plannerName,
    required this.review,
    required this.submission,
  });
  final String accountId;
  final ProgramWorkAccess access;
  final String plannerName;
  final PhoneImportController review;
  final PhoneImportSubmissionController submission;

  void dispose() {
    submission.dispose();
    review.dispose();
  }
}
