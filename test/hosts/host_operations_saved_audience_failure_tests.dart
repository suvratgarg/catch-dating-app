part of 'host_operations_screen_test.dart';

void _registerHostOperationsSavedAudienceFailureTests() {
  testWidgets('saved audience preview failure retains the saved identity', (
    tester,
  ) async {
    const organizerId = 'organizer-1';
    final functions = _SavedAudienceEditorTestFunctions();

    await _pumpHostScreen(
      tester,
      const HostSavedAudienceEditorScreen(organizerId: organizerId),
      overrides: [
        hostCrmRepositoryProvider.overrideWithValue(
          HostCrmRepository(functions),
        ),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            [],
            _customerDirectoryState(),
          ),
        ),
      ],
    );

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-saved-audience-name')),
        matching: find.byType(TextField),
      ),
      'Friday regulars',
    );
    await tester.tap(find.byKey(const ValueKey('host-saved-audience-save')));
    await pumpFeatureUi(tester);

    expect(functions.upsertCalls, hasLength(1));
    expect(functions.previewCalls, hasLength(1));
    expect(find.text('Save changes'), findsOneWidget);
    expect(find.text('Friday regulars'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('host-saved-audience-save')));
    await pumpFeatureUi(tester);

    expect(functions.upsertCalls, hasLength(2));
    expect(functions.upsertCalls.last['audienceId'], 'audience-created');
    expect(functions.upsertCalls.last['expectedRevision'], 1);
  });

  testWidgets('saved audience create retry reuses its request identity', (
    tester,
  ) async {
    const organizerId = 'organizer-1';
    final functions = _SavedAudienceEditorTestFunctions(failFirstUpsert: true);

    await _pumpHostScreen(
      tester,
      const HostSavedAudienceEditorScreen(organizerId: organizerId),
      overrides: [
        hostCrmRepositoryProvider.overrideWithValue(
          HostCrmRepository(functions),
        ),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _FixedHostCustomersDirectoryController(
            [],
            _customerDirectoryState(),
          ),
        ),
      ],
    );

    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('host-saved-audience-name')),
        matching: find.byType(TextField),
      ),
      'Friday regulars',
    );
    await tester.tap(find.byKey(const ValueKey('host-saved-audience-save')));
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(const ValueKey('host-saved-audience-save')));
    await pumpFeatureUi(tester);

    expect(functions.upsertCalls, hasLength(2));
    expect(
      functions.upsertCalls.last['requestId'],
      functions.upsertCalls.first['requestId'],
    );
  });
}

class _SavedAudienceEditorTestFunctions extends Fake
    implements FirebaseFunctions {
  _SavedAudienceEditorTestFunctions({this.failFirstUpsert = false});

  final bool failFirstUpsert;
  final List<Map<Object?, Object?>> upsertCalls = [];
  final List<Map<Object?, Object?>> previewCalls = [];

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) =>
      _SavedAudienceEditorTestCallable(name: name, owner: this);
}

class _SavedAudienceEditorTestCallable extends Fake implements HttpsCallable {
  _SavedAudienceEditorTestCallable({required this.name, required this.owner});

  final String name;
  final _SavedAudienceEditorTestFunctions owner;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    final payload = parameters as Map<Object?, Object?>;
    switch (name) {
      case 'listOrganizerSavedAudiences':
        return _SavedAudienceEditorCallableResult<T>(
          {
                'organizerId': 'organizer-1',
                'audiences': [],
                'nextCursor': null,
                'filterOptions': {
                  'forms': [],
                  'questions': [],
                  'events': [],
                  'tags': [],
                },
              }
              as T,
        );
      case 'upsertOrganizerSavedAudience':
        owner.upsertCalls.add(payload);
        if (owner.failFirstUpsert && owner.upsertCalls.length == 1) {
          throw StateError('upsert response unavailable');
        }
        return _SavedAudienceEditorCallableResult<T>(
          _savedAudienceEditorResponse() as T,
        );
      case 'previewOrganizerSavedAudience':
        owner.previewCalls.add(payload);
        throw StateError('preview unavailable');
      default:
        throw UnsupportedError('Unexpected callable: $name');
    }
  }
}

class _SavedAudienceEditorCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  _SavedAudienceEditorCallableResult(this.value);

  final T value;

  @override
  T get data => value;
}

Map<String, Object?> _savedAudienceEditorResponse() => {
  'organizerId': 'organizer-1',
  'audienceId': 'audience-created',
  'scope': 'organizerCrm',
  'name': 'Friday regulars',
  'status': 'active',
  'definition': {
    'join': 'all',
    'predicates': [
      {'kind': 'computedSegment', 'segmentId': 'regular'},
    ],
  },
  'definitionHash':
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
  'definitionVersion': 1,
  'revision': 1,
  'lastPreviewMatchCount': null,
  'lastPreviewReachSummary': null,
  'lastPreviewAtMillis': null,
  'createdAtMillis': 1788067200000,
  'updatedAtMillis': 1788067200000,
};
