import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/event_success/data/event_assistance_late_join_setting_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_group_progress.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_setting.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_setting_result.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_late_join_setting_editor.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_late_join_setting_provider.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'event_assistance_late_join_setting_fixtures.dart';

void main() {
  late _Repository repository;
  late StreamController<String?> auth;
  late ProviderContainer container;
  final provider = eventAssistanceLateJoinSettingProvider(settingScope());
  setUp(() {
    repository = _Repository();
    auth = StreamController<String?>.broadcast();
    container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => auth.stream),
        eventAssistanceLateJoinSettingRepositoryProvider.overrideWith(
          (ref) => repository,
        ),
      ],
    );
    container.listen(provider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await auth.close();
  });
  Future<void> signIn(String? uid) async {
    final expected = repository.reads.length + 1;
    auth.add(uid);
    await container.pump();
    if (uid != null) await repository.waitForReads(expected);
    await container.pump();
  }

  Future<void> complete(int index) async {
    final read = repository.reads[index];
    read.result.complete(settingView(groupId: read.scope.groupId));
    await container.pump();
  }

  Future<LateJoinSettingSession> session() async {
    await signIn('host-1');
    await complete(0);
    return container.read(provider).requireValue;
  }

  LateJoinSettingResult confirmation(int index) {
    final change = repository.writes[index].change;
    return LateJoinSettingResult.fromCallableData(
      settingResponse(
        outcome: 'applied',
        operationRevision: 1,
        revision: 1,
        own: settingRecord(preference: change.preference.toJson()),
        status: change.preference is LateJoinDisabled
            ? 'disabled'
            : 'configured',
        origin: 'event',
        effective: change.preference is LateJoinConfigured
            ? (change.preference as LateJoinConfigured).template.toJson()
            : null,
      ),
      expectedScope: change.snapshot.scope,
      expectedChange: change,
    );
  }

  test(
    'loading, sign-out and authentication failures remove private state',
    () async {
      expect(container.read(provider).isLoading, isTrue);
      expect(repository.reads, isEmpty);
      await session();
      await signIn(null);
      expect(container.read(provider).hasValue, isFalse);
      expect(container.read(provider).error, isA<SignInRequiredException>());
      container.read(provider.notifier).reload();
      await container.pump();
      expect(repository.reads, hasLength(1));
      auth.addError(StateError('auth unavailable'));
      await container.pump();
      expect(container.read(provider).hasValue, isFalse);
    },
  );

  test(
    'delayed old-account reads and same-UID re-entry cannot restore a prior review',
    () async {
      await signIn('host-1');
      await signIn('host-2');
      await complete(0);
      expect(container.read(provider).hasValue, isFalse);
      await complete(1);
      final old = container.read(provider).requireValue;
      await signIn(null);
      await signIn('host-2');
      expect(container.read(provider).hasValue, isFalse);
      await complete(2);
      expect(
        identical(old.account, container.read(provider).requireValue.account),
        isFalse,
      );
    },
  );

  test(
    'event and group reads are isolated and explicit refresh fences older completion',
    () async {
      await signIn('host-1');
      container.listen(
        eventAssistanceLateJoinSettingProvider(
          settingScope(groupId: 'pace:slow'),
        ),
        (_, _) {},
      );
      await container.pump();
      await repository.waitForReads(2);
      expect(repository.reads, hasLength(2));
      container.read(provider.notifier).reload();
      await container.pump();
      await repository.waitForReads(3);
      expect(repository.reads, hasLength(3));
      await complete(2);
      final current = container.read(provider).requireValue;
      await complete(0);
      expect(container.read(provider).requireValue, same(current));
      await complete(1);
    },
  );

  test(
    'suggestions require an explicit choice; duplicate saves share one frozen request',
    () async {
      final review = await session();
      final editor = eventAssistanceLateJoinSettingEditorProvider(review);
      container.listen(editor, (_, _) {});
      final notifier = container.read(editor.notifier);
      expect((container.read(editor) as LateJoinSettingForm).decision, isNull);
      await expectLater(notifier.submit(), throwsA(isA<ValidationException>()));
      expect(repository.writes, isEmpty);
      notifier.select(LateJoinConfigured(review.view.suggested!));
      final first = notifier.submit();
      final duplicate = notifier.submit();
      expect(identical(first, duplicate), isTrue);
      notifier.select(const LateJoinDisabled());
      expect(repository.writes, hasLength(1));
      expect(
        repository.writes.single.change.preference,
        isA<LateJoinConfigured>(),
      );
      final receipt = confirmation(0);
      repository.writes[0].result.complete(receipt);
      expect(await first, same(receipt));
      await container.pump();
      expect(
        (container.read(editor) as LateJoinSettingForm).phase,
        LateJoinSettingEditorPhase.saved,
      );
      expect(await notifier.submit(), same(receipt));
      expect(repository.writes, hasLength(1));
      await repository.waitForReads(2);
      expect(repository.reads, hasLength(2));
      expect(container.read(provider).hasValue, isFalse);
    },
  );

  test(
    'uncertain saves retain the request and reject edits until exact retry',
    () async {
      final review = await session();
      final editor = eventAssistanceLateJoinSettingEditorProvider(review);
      container.listen(editor, (_, _) {});
      final notifier = container.read(editor.notifier);
      notifier.select(const LateJoinDisabled());
      final first = notifier.submit();
      final failed = expectLater(first, throwsA(isA<StateError>()));
      repository.writes[0].result.completeError(StateError('unknown result'));
      await failed;
      expect(
        (container.read(editor) as LateJoinSettingForm).phase,
        LateJoinSettingEditorPhase.retryRequired,
      );
      notifier.select(LateJoinConfigured(lateJoinTemplate()));
      final retry = notifier.submit();
      expect(repository.writes[1].change, same(repository.writes[0].change));
      repository.writes[1].result.complete(confirmation(1));
      await retry;
    },
  );

  test('a conflict requires new review, never a rebased retry', () async {
    final review = await session();
    final editor = eventAssistanceLateJoinSettingEditorProvider(review);
    container.listen(editor, (_, _) {});
    final notifier = container.read(editor.notifier);
    notifier.select(const LateJoinDisabled());
    final pending = notifier.submit();
    final failed = expectLater(
      pending,
      throwsA(isA<BackendOperationException>()),
    );
    repository.writes.single.result.completeError(
      const BackendOperationException(
        code: 'aborted',
        message: 'Changed',
        context: BackendErrorContext(
          service: BackendService.functions,
          action: 'save late arrival settings',
          resource: 'eventAssistanceSettings',
        ),
      ),
    );
    await failed;
    expect(
      (container.read(editor) as LateJoinSettingForm).phase,
      LateJoinSettingEditorPhase.refreshRequired,
    );
    await expectLater(notifier.submit(), throwsA(isA<ValidationException>()));
    expect(repository.writes, hasLength(1));
  });

  test(
    'an account change permanently revokes the editor even when its save completes',
    () async {
      final review = await session();
      final editor = eventAssistanceLateJoinSettingEditorProvider(review);
      container.listen(editor, (_, _) {});
      final notifier = container.read(editor.notifier);
      notifier.select(const LateJoinDisabled());
      final pending = notifier.submit();
      final failed = expectLater(
        pending,
        throwsA(isA<BackendOperationException>()),
      );
      await signIn(null);
      await signIn('host-1');
      expect(container.read(editor), isA<LateJoinSettingFormUnavailable>());
      repository.writes.single.result.complete(confirmation(0));
      await failed;
      await complete(1);
      expect(container.read(editor), isA<LateJoinSettingFormUnavailable>());
      await expectLater(
        notifier.submit(),
        throwsA(isA<BackendOperationException>()),
      );
      expect(repository.writes, hasLength(1));
    },
  );
}

class _Repository extends Fake
    implements EventAssistanceLateJoinSettingRepository {
  Completer<void> _changed = Completer<void>();
  Future<void> waitForReads(int count) async {
    while (reads.length < count) {
      await _changed.future.timeout(const Duration(seconds: 10));
    }
  }

  final reads =
      <
        ({
          EventAssistanceGroupScope scope,
          Completer<LateJoinSettingView> result,
        })
      >[];
  final writes =
      <
        ({
          LateJoinSettingChange change,
          Completer<LateJoinSettingResult> result,
        })
      >[];
  @override
  Future<LateJoinSettingView> fetch(EventAssistanceGroupScope scope) {
    final result = Completer<LateJoinSettingView>();
    reads.add((scope: scope, result: result));
    final previous = _changed;
    _changed = Completer<void>();
    previous.complete();
    return result.future;
  }

  @override
  Future<LateJoinSettingResult> apply(LateJoinSettingChange change) {
    final result = Completer<LateJoinSettingResult>();
    writes.add((change: change, result: result));
    return result.future;
  }
}
