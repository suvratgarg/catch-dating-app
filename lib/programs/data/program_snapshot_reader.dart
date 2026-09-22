import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/programs/data/program_read_snapshots.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';

typedef ProgramReadView<T> = ({T value, DateTime? snapshotAt});

/// A saved projection is usable only during connectivity failures, within its
/// cache lifetime and the last verified grant, for the same signed-in account.
Future<ProgramReadView<T>> readProgramWithSnapshot<T>({
  required String accountId,
  required String programId,
  required String scope,
  required ProgramReadSnapshotStore store,
  required bool Function() isCurrentAccount,
  required Future<T> Function() live,
  required T Function(Object?) parse,
  bool Function(ProgramWorkAccess)? allowsAccess,
}) async {
  void requireAccount() {
    if (!isCurrentAccount()) {
      throw const SignInRequiredException('view program work');
    }
  }

  requireAccount();
  try {
    final value = await live();
    requireAccount();
    return (value: value, snapshotAt: null);
  } on AppException catch (error) {
    if (error is PermissionException ||
        error is SignInRequiredException ||
        error is DocumentNotFoundException) {
      await store.clearProgram(accountId, programId);
      rethrow;
    }
    if (error is! NetworkException ||
        !{'connection-failed', 'timeout', 'offline'}.contains(error.code)) {
      rethrow;
    }
    requireAccount();
    final work = await store.load(
      accountId,
      programSnapshotScope('work', programId),
    );
    if (work == null) rethrow;
    final access = ProgramWorkAccess.fromCallableData(work.data);
    if (access.programId != programId ||
        (!access.isManager &&
            (access.grantExpiresAt == null ||
                !access.grantExpiresAt!.isAfter(DateTime.now()))) ||
        (allowsAccess != null && !allowsAccess(access))) {
      await store.clearProgram(accountId, programId);
      rethrow;
    }
    final snapshot = await store.load(accountId, scope);
    if (snapshot == null) rethrow;
    final payload = requiredMap(snapshot.data, 'saved program data');
    if (payload['programId'] != programId) rethrow;
    requireAccount();
    return (value: parse(payload), snapshotAt: snapshot.savedAt);
  }
}
