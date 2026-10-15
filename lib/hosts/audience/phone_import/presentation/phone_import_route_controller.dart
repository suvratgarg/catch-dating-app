import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/persistence/command_journal_provider.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/data/phone_contact_picker.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/data/phone_import_adapter.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/data/phone_import_retry_store.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/domain/phone_contact_reference.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/domain/phone_import_access.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/domain/phone_import_draft.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/presentation/phone_import_controller.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/presentation/phone_import_route_state.dart';
import 'package:catch_dating_app/hosts/audience/phone_import/presentation/phone_import_submission_controller.dart';
import 'package:catch_dating_app/hosts/data/host_release_config.dart';
import 'package:catch_dating_app/hosts/work/data/host_work_repository.dart';
import 'package:catch_dating_app/hosts/work/domain/host_work_assignment.dart';
import 'package:catch_dating_app/programs/data/program_setup_repository.dart';
import 'package:catch_dating_app/programs/data/program_work_repository.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phone_import_route_controller.g.dart';

/// Canonical entry composition and fresh access checks. Route widgets own
/// subscriptions, navigation and Flutter lifetime mechanics, not repositories.
@riverpod
class PhoneImportRouteController extends _$PhoneImportRouteController {
  @override
  void build() {}

  bool get _releaseEnabled =>
      ref.read(hostReleaseFlagProvider(hostWeddingPhoneImportFlagKey));

  String? readAccountId() =>
      ref.mounted ? ref.read(authRepositoryProvider).currentUser?.uid : null;

  void _assertCurrent(String account, bool Function() isCurrent) {
    if (!ref.mounted || !isCurrent() || readAccountId() != account) {
      throw const PermissionException(
        'The wedding or signed-in account changed.',
      );
    }
    if (!_releaseEnabled) {
      throw const PermissionException('Phone import is not available.');
    }
  }

  Future<ProgramWorkAccess> refreshAccess({
    required String programId,
    required String? accountId,
    String? organizerId,
    required bool Function() isCurrent,
  }) async {
    if (!_releaseEnabled) {
      throw const PermissionException('Phone import is not available.');
    }
    if (accountId == null) {
      throw const SignInRequiredException('import wedding guests');
    }
    _assertCurrent(accountId, isCurrent);
    final access = await ref
        .read(programWorkRepositoryProvider)
        .getWorkAccess(programId, snapshotAccountId: accountId);
    _assertCurrent(accountId, isCurrent);
    if (access.programId != programId ||
        (organizerId != null && organizerId != access.organizerId) ||
        !_releaseEnabled ||
        !canImportWeddingPhoneContacts(access, DateTime.now())) {
      throw const PermissionException(
        'Current wedding-wide guest access is required.',
      );
    }
    return access;
  }

  Future<PhoneImportRouteSession> open({
    required String programId,
    required bool Function() isCurrent,
  }) async {
    final account = readAccountId();
    if (account == null) {
      throw const SignInRequiredException('import wedding guests');
    }
    final access = await refreshAccess(
      programId: programId,
      accountId: account,
      isCurrent: isCurrent,
    );
    final String plannerName;
    if (access.isManager) {
      // The assignment catalog contains staff grants. Managers resolve only
      // display metadata here; canonical work access remains the authority.
      final organizer = await ref
          .read(clubsRepositoryProvider)
          .fetchClub(access.organizerId);
      _assertCurrent(account, isCurrent);
      if (organizer == null ||
          organizer.id != access.organizerId ||
          organizer.name.trim().isEmpty) {
        throw const PermissionException(
          'The current wedding and planner could not be confirmed.',
        );
      }
      plannerName = organizer.name;
    } else {
      final assignments = await ref
          .read(hostWorkRepositoryProvider)
          .listAssignments();
      _assertCurrent(account, isCurrent);
      HostWorkAssignment? assignment;
      for (final row in assignments.assignments) {
        if (row.kind == HostWorkScopeKind.program &&
            row.scopeId == programId &&
            row.organizerId == access.organizerId &&
            row.organizerName.trim().isNotEmpty) {
          assignment = row;
          break;
        }
      }
      if (assignment == null) {
        throw const PermissionException(
          'The current wedding and planner could not be confirmed.',
        );
      }
      plannerName = assignment.organizerName;
    }
    final review = PhoneImportController(
      picker: const NativePhoneContactPicker(),
      contactReferenceId: (localId) => phoneContactReferenceId(
        accountId: account,
        programId: programId,
        localContactId: localId,
      ),
    );
    final submission = PhoneImportSubmissionController(
      review: review,
      adapter: PhoneImportAdapter(
        isEnabled: () => ref.mounted && _releaseEnabled,
        workRepository: ref.read(programWorkRepositoryProvider),
        setupRepository: ref.read(programSetupRepositoryProvider),
        currentAccountId: readAccountId,
        currentProgramId: () => ref.mounted && isCurrent() ? programId : null,
      ),
      retryStore: PhoneImportRetryStore(
        storage: ref.read(commandJournalStorageProvider),
        currentAccountId: readAccountId,
      ),
      accountId: account,
      programId: programId,
      organizerId: access.organizerId,
      familySideLabels: const {
        PhoneImportFamilySide.partnerOne: 'Partner one family',
        PhoneImportFamilySide.partnerTwo: 'Partner two family',
        PhoneImportFamilySide.both: 'Both families',
      },
    );
    try {
      await submission.initialize();
      final currentAccess = await refreshAccess(
        programId: programId,
        accountId: account,
        organizerId: access.organizerId,
        isCurrent: isCurrent,
      );
      if (currentAccess.isManager != access.isManager) {
        throw const PermissionException(
          'Current wedding-wide guest access must be reviewed again.',
        );
      }
      return PhoneImportRouteSession(
        accountId: account,
        access: currentAccess,
        plannerName: plannerName,
        review: review,
        submission: submission,
      );
    } catch (_) {
      submission.dispose();
      review.dispose();
      rethrow;
    }
  }
}
