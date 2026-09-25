import 'dart:math';

import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_journal.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_defaults_repository.dart';
import 'package:catch_dating_app/hosts/data/manager_event_setup_preferences.dart';
import 'package:flutter/foundation.dart';

typedef ReadManagerEventSetupDefaults = Future<ManagerEventSetupDefaults>
    Function(String organizerId);
typedef WriteManagerEventSetupDefaults =
    Future<ManagerEventSetupDefaultsUpdateReceipt> Function(
      ManagerEventSetupDefaultsUpdateRequest request,
    );

/// A manager session can have only one unresolved defaults update per club.
/// An error after send never rotates its request ID or changes its body.
class HostManagerEventSetupDefaultsController extends ChangeNotifier {
  HostManagerEventSetupDefaultsController({
    required this.organizerId,
    required this.userId,
    required this.read,
    required this.write,
    this.journal =
        const ManagerEventSetupDefaultsJournal(),
  });

  final String organizerId;
  final String userId;
  final ReadManagerEventSetupDefaults read;
  final WriteManagerEventSetupDefaults write;
  final ManagerEventSetupDefaultsJournal journal;

  ManagerEventSetupDefaults? current;
  ManagerEventSetupDefaultsUpdateRequest? pending;
  Object? error;
  bool loading = false;
  bool saving = false;

  bool get canEdit => current != null && pending == null &&
      !loading && !saving;

  Future<void> load() async {
    loading = true;
    error = null;
    // A failed fresh authority read must not leave the prior snapshot editable.
    current = null;
    notifyListeners();
    try {
      // Restore the frozen command before allowing any fresh edit.
      pending = await journal.load(
        userId: userId, organizerId: organizerId,
      );
      current = await read(organizerId);
      if (current!.organizerId != organizerId) {
        throw const FormatException('Manager defaults identity changed');
      }
    } catch (cause) {
      error = cause;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> save(ManagerEventSetupPreferences next) async {
    if (!canEdit) {
      return;
    }
    late final ManagerEventSetupDefaultsUpdateRequest request;
    try {
      request = ManagerEventSetupDefaultsUpdateRequest.forChange(
        current: current!,
        requestId: _newRequestId(),
        next: next,
      );
    } catch (cause) {
      error = cause;
      notifyListeners();
      return;
    }
    if (request.changes.isEmpty) return;
    if (!request.isValid) {
      error = ArgumentError.value(next, 'next');
      notifyListeners();
      return;
    }
    saving = true;
    error = null;
    notifyListeners();
    try {
      // Persist before invoking the callable, including the exact revision
      // and hash. A lost response can then be replayed after app restart.
      await journal.save(userId: userId, request: request);
      pending = request;
      notifyListeners();
      await _sendPending(request);
    } catch (cause) {
      error = cause;
      notifyListeners();
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> retryPending() async {
    if (saving || pending == null) return;
    saving = true;
    error = null;
    notifyListeners();
    try {
      await _sendPending(pending!);
    } catch (cause) {
      // Permission and precondition errors do not prove the first call did
      // not commit. Keep the identical request for a later replay.
      error = cause;
      notifyListeners();
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<void> _sendPending(
    ManagerEventSetupDefaultsUpdateRequest request,
  ) async {
    final receipt = await write(request);
    if (receipt.current.organizerId != organizerId ||
        receipt.appliedRevision <= request.expectedRevision) {
      throw const FormatException('Invalid manager defaults receipt');
    }
    await journal.clear(userId: userId, request: request);
    current = receipt.current;
    pending = null;
    error = null;
    notifyListeners();
  }
}

String _newRequestId() {
  final random = Random.secure();
  return List<int>.generate(24, (_) => random.nextInt(256))
      .map((value) => value.toRadixString(16).padLeft(2, '0'))
      .join();
}
