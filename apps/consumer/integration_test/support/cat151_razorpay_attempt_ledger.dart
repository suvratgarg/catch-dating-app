import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const cat151SecondAttemptConfirmation = 'AUTHORIZE ATTEMPT 2';

abstract interface class Cat151StringStore {
  Future<String?> getString(String key);

  Future<void> setString(String key, String value);
}

final class Cat151SharedPreferencesStore implements Cat151StringStore {
  Cat151SharedPreferencesStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);
}

enum Cat151AttemptStatus { reserved, admitted, refunded }

final class Cat151Attempt {
  const Cat151Attempt({
    required this.number,
    required this.status,
    required this.reservedAtMillis,
    this.paymentId,
    this.orderId,
  });

  final int number;
  final Cat151AttemptStatus status;
  final int reservedAtMillis;
  final String? paymentId;
  final String? orderId;

  Cat151Attempt copyWith({
    Cat151AttemptStatus? status,
    String? paymentId,
    String? orderId,
  }) => Cat151Attempt(
    number: number,
    status: status ?? this.status,
    reservedAtMillis: reservedAtMillis,
    paymentId: paymentId ?? this.paymentId,
    orderId: orderId ?? this.orderId,
  );

  Map<String, Object?> toJson() => {
    'number': number,
    'status': status.name,
    'reservedAtMillis': reservedAtMillis,
    'paymentId': paymentId,
    'orderId': orderId,
  };
}

final class Cat151AttemptLedgerState {
  const Cat151AttemptLedgerState({
    required this.projectId,
    required this.uid,
    required this.eventId,
    required this.seedPrefix,
    required this.secondAttemptAuthorized,
    required this.attempts,
  });

  final String projectId;
  final String uid;
  final String eventId;
  final String seedPrefix;
  final bool secondAttemptAuthorized;
  final List<Cat151Attempt> attempts;

  bool get isTerminal => attempts.any(
    (attempt) =>
        attempt.status == Cat151AttemptStatus.admitted ||
        attempt.status == Cat151AttemptStatus.refunded,
  );

  bool get canReserveFirst => attempts.isEmpty;
  bool get canAuthorizeSecond =>
      attempts.length == 1 &&
      attempts.single.status == Cat151AttemptStatus.reserved &&
      !secondAttemptAuthorized;
  bool get canReserveSecond =>
      attempts.length == 1 &&
      attempts.single.status == Cat151AttemptStatus.reserved &&
      secondAttemptAuthorized;

  Map<String, Object?> toJson() => {
    'version': 1,
    'projectId': projectId,
    'uid': uid,
    'eventId': eventId,
    'seedPrefix': seedPrefix,
    'secondAttemptAuthorized': secondAttemptAuthorized,
    'attempts': attempts.map((attempt) => attempt.toJson()).toList(),
  };
}

final class Cat151AttemptLedgerException implements Exception {
  const Cat151AttemptLedgerException(this.message);

  final String message;

  @override
  String toString() => 'Cat151AttemptLedgerException: $message';
}

/// A project-wide, fail-closed device ledger for the supervised native test.
///
/// Reservation is persisted before checkout begins. A reserved attempt remains
/// consumed after cancellation, timeout, process death, or an unreadable
/// provider result. The ledger has no reset API.
final class Cat151AttemptLedger {
  Cat151AttemptLedger({Cat151StringStore? store, int Function()? nowMillis})
    : _store = store ?? Cat151SharedPreferencesStore(),
      _nowMillis = nowMillis ?? (() => DateTime.now().millisecondsSinceEpoch);

  final Cat151StringStore _store;
  final int Function() _nowMillis;

  String _key(String projectId) {
    final normalized = _requiredText(projectId, 'projectId');
    return 'cat151_razorpay_acceptance_v1_${base64Url.encode(utf8.encode(normalized))}';
  }

  Future<Cat151AttemptLedgerState> bindScope({
    required String projectId,
    required String uid,
    required String eventId,
    required String seedPrefix,
  }) async {
    final normalizedProject = _requiredText(projectId, 'projectId');
    final normalizedUid = _requiredText(uid, 'uid');
    final normalizedEvent = _requiredText(eventId, 'eventId');
    final normalizedSeed = _requiredText(seedPrefix, 'seedPrefix');
    final current = await load(normalizedProject);
    if (current == null) {
      final created = Cat151AttemptLedgerState(
        projectId: normalizedProject,
        uid: normalizedUid,
        eventId: normalizedEvent,
        seedPrefix: normalizedSeed,
        secondAttemptAuthorized: false,
        attempts: const [],
      );
      await _save(created);
      return created;
    }
    if (current.uid != normalizedUid ||
        current.eventId != normalizedEvent ||
        current.seedPrefix != normalizedSeed) {
      throw const Cat151AttemptLedgerException(
        'This Firebase project is already bound to a different CAT-151 scope.',
      );
    }
    return current;
  }

  Future<Cat151AttemptLedgerState?> load(String projectId) async {
    final raw = await _store.getString(_key(projectId));
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      return _decode(decoded, expectedProjectId: projectId.trim());
    } on Cat151AttemptLedgerException {
      rethrow;
    } catch (_) {
      throw const Cat151AttemptLedgerException(
        'The durable attempt ledger is malformed; checkout is locked.',
      );
    }
  }

  Future<Cat151AttemptLedgerState> reserveNext(
    Cat151AttemptLedgerState expected,
  ) async {
    final current = await _requireUnchanged(expected);
    if (current.isTerminal || current.attempts.length >= 2) {
      throw const Cat151AttemptLedgerException(
        'The bounded checkout budget is exhausted.',
      );
    }
    if (current.attempts.length == 1 && !current.secondAttemptAuthorized) {
      throw const Cat151AttemptLedgerException(
        'Attempt 2 requires explicit durable authorization.',
      );
    }
    final next = Cat151Attempt(
      number: current.attempts.length + 1,
      status: Cat151AttemptStatus.reserved,
      reservedAtMillis: _nowMillis(),
    );
    final updated = _copy(current, attempts: [...current.attempts, next]);
    await _save(updated);
    return updated;
  }

  Future<Cat151AttemptLedgerState> authorizeSecondAttempt(
    Cat151AttemptLedgerState expected, {
    required String confirmation,
  }) async {
    final current = await _requireUnchanged(expected);
    if (!current.canAuthorizeSecond ||
        confirmation.trim() != cat151SecondAttemptConfirmation) {
      throw const Cat151AttemptLedgerException(
        'Attempt 2 authorization was not explicit or is not available.',
      );
    }
    final updated = _copy(current, secondAttemptAuthorized: true);
    await _save(updated);
    return updated;
  }

  Future<Cat151AttemptLedgerState> markAdmitted(
    Cat151AttemptLedgerState expected, {
    required int attemptNumber,
    required String paymentId,
    required String orderId,
  }) => _mark(
    expected,
    attemptNumber: attemptNumber,
    status: Cat151AttemptStatus.admitted,
    paymentId: _requiredText(paymentId, 'paymentId'),
    orderId: _requiredText(orderId, 'orderId'),
  );

  Future<Cat151AttemptLedgerState> markRefunded(
    Cat151AttemptLedgerState expected, {
    required int attemptNumber,
    required String paymentId,
    required String orderId,
  }) => _mark(
    expected,
    attemptNumber: attemptNumber,
    status: Cat151AttemptStatus.refunded,
    paymentId: _requiredText(paymentId, 'paymentId'),
    orderId: _requiredText(orderId, 'orderId'),
  );

  Future<Cat151AttemptLedgerState> _mark(
    Cat151AttemptLedgerState expected, {
    required int attemptNumber,
    required Cat151AttemptStatus status,
    required String paymentId,
    required String orderId,
  }) async {
    final current = await _requireUnchanged(expected);
    final index = current.attempts.indexWhere(
      (attempt) => attempt.number == attemptNumber,
    );
    if (index < 0) {
      throw const Cat151AttemptLedgerException(
        'The requested attempt transition is invalid.',
      );
    }
    final old = current.attempts[index];
    final validTransition = switch ((old.status, status)) {
      (Cat151AttemptStatus.reserved, Cat151AttemptStatus.admitted) => true,
      (Cat151AttemptStatus.admitted, Cat151AttemptStatus.admitted) ||
      (
        Cat151AttemptStatus.refunded,
        Cat151AttemptStatus.refunded,
      ) => old.paymentId == paymentId && old.orderId == orderId,
      (Cat151AttemptStatus.admitted, Cat151AttemptStatus.refunded) =>
        old.paymentId == paymentId && old.orderId == orderId,
      _ => false,
    };
    if (!validTransition) {
      throw const Cat151AttemptLedgerException(
        'The requested attempt transition is invalid.',
      );
    }
    final attempts = [...current.attempts];
    attempts[index] = attempts[index].copyWith(
      status: status,
      paymentId: paymentId,
      orderId: orderId,
    );
    final updated = _copy(current, attempts: attempts);
    await _save(updated);
    return updated;
  }

  Future<Cat151AttemptLedgerState> _requireUnchanged(
    Cat151AttemptLedgerState expected,
  ) async {
    final current = await load(expected.projectId);
    if (current == null ||
        jsonEncode(current.toJson()) != jsonEncode(expected.toJson())) {
      throw const Cat151AttemptLedgerException(
        'The durable attempt ledger changed; reload before continuing.',
      );
    }
    return current;
  }

  Future<void> _save(Cat151AttemptLedgerState state) =>
      _store.setString(_key(state.projectId), jsonEncode(state.toJson()));

  static Cat151AttemptLedgerState _copy(
    Cat151AttemptLedgerState state, {
    bool? secondAttemptAuthorized,
    List<Cat151Attempt>? attempts,
  }) => Cat151AttemptLedgerState(
    projectId: state.projectId,
    uid: state.uid,
    eventId: state.eventId,
    seedPrefix: state.seedPrefix,
    secondAttemptAuthorized:
        secondAttemptAuthorized ?? state.secondAttemptAuthorized,
    attempts: List.unmodifiable(attempts ?? state.attempts),
  );

  static Cat151AttemptLedgerState _decode(
    Map<String, dynamic> json, {
    required String expectedProjectId,
  }) {
    if (json.length != 7 ||
        json['version'] != 1 ||
        json['projectId'] != expectedProjectId ||
        json['projectId'] is! String ||
        json['uid'] is! String ||
        json['eventId'] is! String ||
        json['seedPrefix'] is! String ||
        json['secondAttemptAuthorized'] is! bool ||
        json['attempts'] is! List) {
      throw const FormatException();
    }
    final attempts = <Cat151Attempt>[];
    for (final value in json['attempts'] as List) {
      if (value is! Map<String, dynamic> ||
          value.length != 5 ||
          value['number'] is! int ||
          value['reservedAtMillis'] is! int ||
          value['status'] is! String ||
          value['paymentId'] is! String? ||
          value['orderId'] is! String?) {
        throw const FormatException();
      }
      attempts.add(
        Cat151Attempt(
          number: value['number'] as int,
          status: Cat151AttemptStatus.values.byName(value['status'] as String),
          reservedAtMillis: value['reservedAtMillis'] as int,
          paymentId: value['paymentId'] as String?,
          orderId: value['orderId'] as String?,
        ),
      );
    }
    if (attempts.length > 2 ||
        attempts.indexed.any((entry) => entry.$2.number != entry.$1 + 1) ||
        attempts.any(
          (attempt) =>
              attempt.reservedAtMillis <= 0 ||
              (attempt.status == Cat151AttemptStatus.reserved &&
                  (attempt.paymentId != null || attempt.orderId != null)) ||
              (attempt.status != Cat151AttemptStatus.reserved &&
                  (attempt.paymentId == null || attempt.orderId == null)),
        ) ||
        attempts.isEmpty && json['secondAttemptAuthorized'] == true ||
        attempts.length > 1 && json['secondAttemptAuthorized'] != true) {
      throw const FormatException();
    }
    for (final attempt in attempts) {
      if (attempt.paymentId case final String paymentId) {
        _requiredText(paymentId, 'paymentId');
      }
      if (attempt.orderId case final String orderId) {
        _requiredText(orderId, 'orderId');
      }
    }
    return Cat151AttemptLedgerState(
      projectId: _requiredText(json['projectId'] as String, 'projectId'),
      uid: _requiredText(json['uid'] as String, 'uid'),
      eventId: _requiredText(json['eventId'] as String, 'eventId'),
      seedPrefix: _requiredText(json['seedPrefix'] as String, 'seedPrefix'),
      secondAttemptAuthorized: json['secondAttemptAuthorized'] as bool,
      attempts: List.unmodifiable(attempts),
    );
  }

  static String _requiredText(String value, String field) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized.length > 180) {
      throw Cat151AttemptLedgerException('Invalid $field.');
    }
    return normalized;
  }
}
