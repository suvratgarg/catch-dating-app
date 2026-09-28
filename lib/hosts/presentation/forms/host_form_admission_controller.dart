import 'dart:convert';
import 'dart:math';

import 'package:catch_dating_app/hosts/data/forms/host_form_admission_gateway.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_admission.dart';
import 'package:flutter/foundation.dart';

/// One account and response/event scope. Every write uses a durable command.
class HostFormAdmissionController extends ChangeNotifier {
  HostFormAdmissionController({
    required this.accountId,
    required this.scope,
    required this.gateway,
    required this.outbox,
    required this.currentAccountId,
  });
  final String accountId;
  final HostFormAdmissionScope scope;
  final HostFormAdmissionGateway gateway;
  final JournalHostFormAdmissionOutbox outbox;
  final String? Function() currentAccountId;
  HostFormAdmissionPreview? preview;
  PendingFormAdmission? pending;
  HostFormAdmissionReceipt? receipt;
  Object? error;
  bool busy = false;
  bool _disposed = false;
  int _generation = 0;

  bool _current(int generation) =>
      !_disposed &&
      generation == _generation &&
      currentAccountId() == accountId;

  Future<void> review() => _run((generation) async {
    final saved = await outbox.pending(accountId, scope);
    if (!_current(generation)) return;
    pending = saved;
    if (saved != null) return;
    final result = await gateway.preview(scope);
    if (_current(generation)) preview = result;
  });

  Future<void> confirm() => _run((generation) async {
    final saved = pending;
    final command = saved?.command ?? preview?.command('admission_${base64UrlEncode(List.generate(18, (_) => Random.secure().nextInt(256)))}');
    if (command == null || saved?.needsReview == true) {
      throw StateError('Review admission before confirming.');
    }
    final result = await outbox.submit(accountId, command);
    if (!_current(generation)) return;
    receipt = result;
    pending = null;
    preview = null;
  });

  Future<void> reviewAgain() => _run((generation) async {
    await outbox.reviewAgain(accountId, scope);
    if (!_current(generation)) return;
    pending = null;
    final result = await gateway.preview(scope);
    if (_current(generation)) preview = result;
  });

  Future<void> _run(Future<void> Function(int generation) action) async {
    if (busy || _disposed || currentAccountId() != accountId) return;
    final generation = ++_generation;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action(generation);
    } on Object catch (failure) {
      if (_current(generation)) {
        preview = null;
        error = failure;
        try {
          final saved = await outbox.pending(accountId, scope);
          if (_current(generation)) pending = saved;
        } on Object catch (recoveryFailure) {
          if (_current(generation)) error = recoveryFailure;
        }
      }
    } finally {
      if (_current(generation)) {
        busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
