import 'dart:async';

import 'package:catch_dating_app/core/persistence/memory_command_journal_storage.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/data/host_forms_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_export.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_response_query.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_query_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_response_export_action.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_response_export_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_response_query_editor_section.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_response_query_workspace_section.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _request = HostResponseQueryRequest(
  organizerId: 'org', formId: 'form', versionId: 'form_v2',
  predicate: HostResponseCondition(questionId: 'city',
    operator: HostResponseOperator.choiceAny, values: ['Delhi']),
);

void main() {
  test('applied query, hashes and null cursor bind a complete export', () async {
    final source = _Query();
    final query = HostResponseQueryController(source);
    addTearDown(query.dispose);
    await query.apply(_request);
    final gateway = _Gateway();
    final opened = <Uri>[];
    final controller = _controller(query, gateway,
      openDownload: (uri) async { opened.add(uri); return true; });
    addTearDown(controller.dispose);
    await controller.recover();
    await controller.start(HostFormExportFormat.csv);

    expect(gateway.calls, hasLength(2));
    expect(gateway.calls.map((command) => command.requestId).toSet(),
      hasLength(1));
    final command = gateway.calls.first;
    expect(command.responseQuery['cursor'], isNull);
    expect(command.responseQuery['predicate'], _request.predicate!.toJson());
    expect(command.expectedQueryHash, 'query-hash');
    expect(command.expectedResultHash, 'result-hash');
    expect(command.versionId, 'form_v2');
    expect(opened.single.toString(), 'https://catch.example/export.csv');
    expect(controller.view.status, HostResponseExportStatus.ready);
  });

  test('late receipt after query drift is never opened or attached', () async {
    final source = _Query();
    final query = HostResponseQueryController(source);
    addTearDown(query.dispose);
    await query.apply(_request);
    final gateway = _Gateway()..deferred = Completer<HostFormExportReceipt>();
    final opened = <Uri>[];
    final controller = _controller(query, gateway,
      openDownload: (uri) async { opened.add(uri); return true; });
    addTearDown(controller.dispose);
    await controller.recover();
    final running = controller.start(HostFormExportFormat.csv);
    await Future<void>.delayed(Duration.zero);
    source.resultHash = 'changed-result';
    await query.apply(_request);
    gateway.deferred!.complete(_receipt(HostFormExportStatus.completed));
    await running;
    expect(opened, isEmpty);
    expect(controller.view.status, HostResponseExportStatus.stale);
    expect(gateway.calls.single.requestId, isNotEmpty);
  });

  test('a query changed while checking the journal is not exported', () async {
    final source = _Query();
    final query = HostResponseQueryController(source);
    addTearDown(query.dispose);
    await query.apply(_request);
    final gateway = _Gateway()
      ..pendingDeferred = Completer<HostResponseExportCommand?>();
    final controller = _controller(query, gateway,
      openDownload: (_) async => true);
    addTearDown(controller.dispose);
    final running = controller.start(HostFormExportFormat.csv);
    source.resultHash = 'new-result';
    await query.apply(_request);
    gateway.pendingDeferred!.complete(null);
    await running;
    expect(gateway.calls, isEmpty);
    expect(controller.view.status, HostResponseExportStatus.idle);
  });

  test('typed stale receipt requires a fresh applied result', () async {
    final source = _Query();
    final query = HostResponseQueryController(source);
    addTearDown(query.dispose);
    await query.apply(_request);
    final gateway = _Gateway()
      ..statuses = [HostFormExportStatus.failed]
      ..errorCode = 'response-query-stale';
    final controller = _controller(query, gateway,
      openDownload: (_) async => true);
    addTearDown(controller.dispose);
    await controller.start(HostFormExportFormat.csv);
    expect(controller.view.status, HostResponseExportStatus.stale);
    source.resultHash = 'new-result';
    await query.apply(_request);
    expect(controller.view.status, HostResponseExportStatus.idle);
  });

  test('a stale pending export settles its original command without opening',
      () async {
    final source = _Query()..resultHash = 'new-result';
    final query = HostResponseQueryController(source);
    addTearDown(query.dispose);
    await query.apply(_request);
    final gateway = _Gateway()
      ..saved = _command(expectedResultHash: 'old-result');
    final opened = <Uri>[];
    final controller = _controller(query, gateway,
      openDownload: (uri) async { opened.add(uri); return true; });
    addTearDown(controller.dispose);
    await controller.recover();
    expect(controller.view.status, HostResponseExportStatus.stale);
    await controller.retryPending();
    expect(gateway.calls, hasLength(2));
    expect(gateway.calls.every((entry) =>
        entry.requestId == 'saved_request'), isTrue);
    expect(opened, isEmpty);
    expect(controller.view.status, HostResponseExportStatus.idle);
    expect(await gateway.pending(accountId: 'manager', organizerId: 'org',
      formId: 'form'), isNull);
  });

  test('account change before completion or reopen never opens the URL',
      () async {
    final query = HostResponseQueryController(_Query());
    addTearDown(query.dispose);
    await query.apply(_request);
    final gateway = _Gateway()..statuses = [HostFormExportStatus.completed];
    var activeUid = 'manager';
    final opened = <Uri>[];
    final controller = _controller(query, gateway,
      currentAccountId: () => activeUid,
      openDownload: (uri) async { opened.add(uri); return true; });
    addTearDown(controller.dispose);
    await controller.start(HostFormExportFormat.csv);
    expect(opened, hasLength(1));
    activeUid = 'other-manager';
    await controller.openReady();
    expect(opened, hasLength(1));

    final late = _Gateway()..deferred = Completer<HostFormExportReceipt>();
    activeUid = 'manager';
    final second = _controller(query, late,
      currentAccountId: () => activeUid,
      openDownload: (uri) async { opened.add(uri); return true; });
    addTearDown(second.dispose);
    final running = second.start(HostFormExportFormat.xlsx);
    await Future<void>.delayed(Duration.zero);
    activeUid = 'other-manager';
    late.deferred!.complete(_receipt(HostFormExportStatus.completed));
    await running;
    expect(opened, hasLength(1));
  });

  test('durable ambiguous request replays the same ID after recreation', () async {
    final storage = MemoryCommandJournalStorage();
    final repository = _Repository();
    JournalHostResponseExportGateway gateway() =>
      JournalHostResponseExportGateway(repository: repository,
        storage: () async => storage, currentAccountId: () => 'manager');
    final command = HostResponseExportCommand(
      accountId: 'manager', organizerId: 'org', formId: 'form',
      versionId: 'form_v2', requestId: 'export_request_123',
      format: HostFormExportFormat.csv, statuses: const ['submitted'],
      responseQuery: _request.toJson(), expectedQueryHash: 'query-hash',
      expectedResultHash: 'result-hash', createdAtMillis: 1000);
    repository.failFirst = true;
    await expectLater(gateway().execute(command), throwsA(isA<TimeoutException>()));
    final recovered = await gateway().pending(accountId: 'manager',
      organizerId: 'org', formId: 'form');
    expect(recovered?.requestId, command.requestId);
    await gateway().execute(recovered!);
    expect(repository.requestIds, [command.requestId, command.requestId]);
    expect(await gateway().pending(accountId: 'manager',
      organizerId: 'org', formId: 'form'), isNull);
  });

  testWidgets('inline export action uses the reviewed query and opens once',
      (tester) async {
    final query = HostResponseQueryController(_Query());
    addTearDown(query.dispose);
    await query.apply(_request);
    final gateway = _Gateway()..statuses = [HostFormExportStatus.completed];
    final opened = <Uri>[];
    await tester.pumpWidget(ProviderScope(child: MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: HostResponseExportAction(
        accountId: 'manager', organizerId: 'org', formId: 'form',
        queryController: query, gateway: gateway,
        currentAccountId: () => 'manager',
        openDownload: (uri) async { opened.add(uri); return true; },
      )),
    )));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export CSV'));
    await tester.pumpAndSettle();
    expect(gateway.calls.single.responseQuery['predicate'],
      _request.predicate!.toJson());
    expect(opened, hasLength(1));
    expect(find.text('Export ready'), findsOneWidget);
  });

  testWidgets('offer create action can select without a bulk review callback',
      (tester) async {
    final query = HostResponseQueryController(_Query(withRow: true));
    addTearDown(query.dispose);
    var created = false;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(
        child: HostResponseQueryWorkspaceSection(
          controller: query, request: _request, copy: _workspaceCopy,
          onOpenResponse: (_) {},
          onCreateEventForSelection: () async { created = true; },
        ),
      )),
    ));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Select'));
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(query.selectionIntent?.ids, ['response-1']);
    await tester.ensureVisible(find.text('Create event'));
    await tester.tap(find.text('Create event'));
    await tester.pumpAndSettle();
    expect(created, isTrue);
  });
}

HostResponseExportController _controller(HostResponseQueryController query,
  HostResponseExportGateway gateway, {
  required Future<bool> Function(Uri) openDownload,
  String? Function()? currentAccountId,
}) => HostResponseExportController(
  accountId: 'manager', organizerId: 'org', formId: 'form',
  queryController: query, gateway: gateway, openDownload: openDownload,
  currentAccountId: currentAccountId ?? () => 'manager',
  now: () => DateTime.fromMillisecondsSinceEpoch(2000),
  wait: (_) async {},
);

class _Query implements HostResponseQueryGateway {
  _Query({this.withRow = false});
  final bool withRow;
  String resultHash = 'result-hash';
  @override
  Future<HostResponseQueryPage> query(HostResponseQueryRequest request) async =>
      HostResponseQueryPage(
        form: const HostResponseQueryForm(formId: 'form', title: 'Form',
          versionId: 'form_v2', version: 2),
        items: withRow ? [HostResponseQueryRow(
          responseId: 'response-1', formId: 'form', formTitle: 'Form',
          versionId: 'form_v2', version: 2,
          status: HostFormResponseStatus.submitted,
          identityKind: HostFormResponseIdentityKind.phoneVerified,
          identity: const HostFormResponseIdentity(displayName: 'Maya',
            email: null, phoneE164: '+919999999999',
            origin: HostFormDataOrigin.respondentGranted),
          sourceLinkId: null, submittedAt: DateTime.utc(2026, 9, 24),
          withdrawnAt: null,
        )] : const [], nextCursor: null, total: withRow ? 1 : 0,
        selectedIds: withRow ? const {'response-1'} : const {},
        queryHash: 'query-hash',
        resultHash: resultHash,
        fieldCatalog: const [HostResponseQueryField(
          questionId: 'city', label: 'City', kind: 'singleChoice',
          operators: {HostResponseOperator.choiceAny}, sortable: false,
          options: {'Delhi': 'Delhi'},
        )],
      );
}

class _Gateway implements HostResponseExportGateway {
  final calls = <HostResponseExportCommand>[];
  HostResponseExportCommand? saved;
  Completer<HostResponseExportCommand?>? pendingDeferred;
  Completer<HostFormExportReceipt>? deferred;
  String? errorCode;
  List<HostFormExportStatus> statuses = [HostFormExportStatus.pending,
    HostFormExportStatus.completed];

  @override
  Future<HostResponseExportCommand?> pending({required String accountId,
    required String organizerId, required String formId}) async =>
      pendingDeferred == null ? saved : await pendingDeferred!.future;

  @override
  Future<HostFormExportReceipt> execute(HostResponseExportCommand command) async {
    calls.add(command);
    if (deferred case final completion?) return completion.future;
    final status = statuses[(calls.length - 1).clamp(0, statuses.length - 1)];
    if (status == HostFormExportStatus.completed ||
        status == HostFormExportStatus.failed) saved = null;
    return _receipt(status, errorCode: errorCode);
  }
}

HostResponseExportCommand _command({required String expectedResultHash}) =>
    HostResponseExportCommand(
      accountId: 'manager', organizerId: 'org', formId: 'form',
      versionId: 'form_v2', requestId: 'saved_request',
      format: HostFormExportFormat.csv, statuses: const ['submitted'],
      responseQuery: _request.toJson(), expectedQueryHash: 'query-hash',
      expectedResultHash: expectedResultHash, createdAtMillis: 1000);

final _workspaceCopy = HostResponseQueryWorkspaceCopy(
  filter: 'Filter', sort: 'Sort', newest: 'Newest', oldest: 'Oldest',
  refresh: 'Refresh', loadMore: 'Load more', loading: 'Loading',
  empty: 'Empty', stale: 'Stale', budgetExceeded: 'Limit reached',
  permissionLost: 'Permission lost', failed: 'Failed',
  selected: _selectedCount, clearSelection: 'Clear',
  reviewSelection: 'Review', withdrawn: 'Withdrawn',
  select: 'Select', deselect: 'Deselect',
  editor: HostResponseQueryEditorCopy(
    title: 'Filters', matchAll: 'All', matchAny: 'Any',
    field: 'Field', condition: 'Condition', value: 'Value',
    minimum: 'Minimum', maximum: 'Maximum', yes: 'Yes', no: 'No',
    addCondition: 'Add condition', addGroup: 'Add group',
    remove: 'Remove', apply: 'Apply', reset: 'Reset',
    invalidCondition: 'Invalid', operatorLabels: {},
  ),
);

String _selectedCount(int count) => '$count selected';

HostFormExportReceipt _receipt(HostFormExportStatus status,
    {String? errorCode}) =>
    HostFormExportReceipt(exportId: 'formexport_fixture', status: status,
      format: HostFormExportFormat.csv, rowCount: 0,
      downloadUrl: status == HostFormExportStatus.completed
        ? 'https://catch.example/export.csv' : null,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(1000000),
      errorMessage: null, errorCode: errorCode);

class _Repository extends Fake implements HostFormsRepository {
  bool failFirst = false;
  final requestIds = <String>[];

  @override
  Future<HostFormExportReceipt> requestExport({
    required String organizerId, required String formId,
    required String requestId, required HostFormExportFormat format,
    Set<HostFormResponseStatus> statuses = const {}, String? versionId,
    DateTime? from, DateTime? to, Map<String, Object?>? responseQuery,
    String? expectedQueryHash, String? expectedResultHash,
  }) async {
    requestIds.add(requestId);
    if (failFirst) { failFirst = false; throw TimeoutException('uncertain'); }
    final digest = sha256.convert(('$organizerId\u001f$formId\u001f$requestId').codeUnits)
        .toString().substring(0, 32);
    return HostFormExportReceipt(exportId: 'formexport_$digest',
      status: HostFormExportStatus.completed, format: format, rowCount: 0,
      downloadUrl: 'https://catch.example/export.csv',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(1000000),
      errorMessage: null);
  }
}
