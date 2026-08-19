part of 'host_create_event_screen_test.dart';

void _registerCreateEventWizardFlowTests() {
  testWidgets('allows sections to be completed out of order', (tester) async {
    await _pumpCreateEventFlow(tester);
    await _openCreateEventFlow(tester);
    await _tapPrimaryButton(tester, 'Next');
    await _pumpTestAnimation(tester);
    expect(find.text('Meeting location'), findsWidgets);
    expect(find.text('Required'), findsNothing);
    expect(find.text('Select a pace'), findsNothing);
    expect(find.text('Previous'), findsOneWidget);
  });

  testWidgets(
    'uses dockless actions and separates media content from its rule',
    (tester) async {
      await _pumpCreateEventFlow(tester);
      await _openCreateEventFlow(tester);

      expect(find.byType(CatchBottomActionOverlay), findsOneWidget);
      expect(
        find.byKey(const ValueKey('catch_bottom_action_overlay.actions')),
        findsOneWidget,
      );

      final organizerFinder = find.byKey(
        const ValueKey('create_event.inherited_organizer_logo'),
      );
      final mediaSection = find.ancestor(
        of: organizerFinder,
        matching: find.byType(CatchSection),
      );
      final ruleRect = tester.getRect(
        find.descendant(of: mediaSection, matching: find.byType(CatchDivider)),
      );
      final organizerRect = tester.getRect(organizerFinder);
      expect(
        organizerRect.top - ruleRect.bottom,
        closeTo(CatchSpacing.s3, 0.001),
      );
    },
  );

  testWidgets(
    'external guest-list creation preserves the mapped source and removes Catch payment policy',
    (tester) async {
      const rosterPlan = HostRosterImportPlan(
        fileName: 'luma-guests.csv',
        fileFingerprint: 'sha256:guest-list',
        format: EventAttendeeImportFormat.csv,
        rows: [
          EventAttendeeImportRow(
            rowId: '2',
            displayName: 'Asha Shah',
            email: 'asha@example.com',
            status: EventAttendeeStatus.registered,
          ),
          EventAttendeeImportRow(
            rowId: '3',
            displayName: 'Ravi Rao',
            email: 'ravi@example.com',
            status: EventAttendeeStatus.registered,
          ),
        ],
        readyCount: 2,
        needsReviewCount: 1,
        excludedCount: 1,
        adapterId: HostRosterAdapterId.lumaV1,
      );
      await _pumpCreateEventFlow(tester, initialRosterImportPlan: rosterPlan);
      await _openCreateEventFlow(tester);

      expect(find.text('Guest list'), findsOneWidget);
      expect(
        find.text('luma-guests.csv · 2 ready · 1 need review · 1 excluded'),
        findsOneWidget,
      );
      expect(find.text('Luma'), findsWidgets);

      for (var step = 0; step < 3; step += 1) {
        await _tapPrimaryButton(tester, 'Next');
        await _pumpTestAnimation(tester);
      }

      expect(find.text('Event policy'), findsOneWidget);
      expect(find.text('Event price'), findsNothing);
      expect(find.text('Cancellation policy'), findsNothing);
      final capacity = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(CreateEventFormKeys.capacity),
          matching: find.byType(EditableText),
        ),
      );
      expect(capacity.controller.text, '2');
    },
  );

  testWidgets('stays open when save draft and exit fails', (tester) async {
    await _pumpCreateEventFlow(
      tester,
      overrides: [
        eventDraftRepositoryProvider.overrideWithValue(
          _FailingEventDraftRepository(),
        ),
      ],
    );
    await _openCreateEventFlow(tester);
    await _fillBasicsStep(tester);

    await tester.tap(find.byTooltip('Close'));
    await _pumpTestAnimation(tester);
    expect(find.text('Keep editing'), findsOneWidget);
    expect(find.text('Discard & exit'), findsOneWidget);
    expect(find.text('Save draft & exit'), findsOneWidget);

    await tester.tap(_dialogAction('Save draft & exit'));
    await _pumpTestAnimation(tester);

    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.text('Open'), findsNothing);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });
}

class _FailingEventDraftRepository extends EventDraftRepository {
  _FailingEventDraftRepository() : super(ErrorLogger());

  @override
  Future<void> saveDraft({
    required String userId,
    required EventDraft draft,
  }) async {
    throw StateError('save draft failed');
  }
}

class _FakePlacesRepository implements PlacesRepository {
  const _FakePlacesRepository({
    required this.suggestions,
    required this.placeDetails,
  });

  final List<PlaceAutocompleteSuggestion> suggestions;
  final PlaceDetails placeDetails;

  @override
  Future<List<PlaceAutocompleteSuggestion>> autocomplete({
    required String input,
    required String sessionToken,
    LocationCoordinate? bias,
    String? countryIsoCode,
  }) async {
    return suggestions;
  }

  @override
  Future<PlaceDetails> details({
    required String placeId,
    required String sessionToken,
  }) async {
    return placeDetails;
  }
}
