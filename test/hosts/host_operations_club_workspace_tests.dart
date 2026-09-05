part of 'host_operations_screen_test.dart';

void _registerHostOperationsClubWorkspaceTests() {
  testWidgets(
    'Host clubs keeps root primary-rail composition for auth and data errors',
    (tester) async {
      void expectStateChrome() {
        expect(find.byType(CatchRootScreenScaffold), findsOneWidget);
        expect(find.byType(CatchRootScreenPageScrollView), findsOneWidget);
        expect(find.byType(NestedScrollView), findsOneWidget);
        expect(
          find.byKey(const ValueKey('host-club-tab-rail')),
          findsOneWidget,
        );
        expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);
        expect(find.byType(CatchSliverStateViewport), findsOneWidget);
        expect(find.byType(CatchErrorScaffold), findsNothing);
        expect(find.byType(HostLoadingScreen), findsNothing);
        expect(find.byType(CatchRouteScaffold), findsNothing);
        expect(
          tester
              .widget<CatchRootScreenPageScrollView>(
                find.byType(CatchRootScreenPageScrollView),
              )
              .bodyLayout,
          CatchScreenBodyLayout.standard,
        );
      }

      await _pumpHostScreen(
        tester,
        const HostClubsScreen(),
        overrides: [
          uidProvider.overrideWithValue(
            AsyncError<String?>(StateError('auth failed'), StackTrace.current),
          ),
        ],
        resetProviderScope: true,
      );

      expectStateChrome();
      expect(find.text('Organizer'), findsOneWidget);

      await _pumpHostScreen(
        tester,
        const HostClubsScreen(),
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>(null)),
        ],
        resetProviderScope: true,
      );

      expectStateChrome();
      expect(find.text('Sign in required'), findsOneWidget);

      await _pumpHostScreen(
        tester,
        const HostClubsScreen(),
        overrides: [
          uidProvider.overrideWithValue(const AsyncData<String?>(_hostUid)),
          watchClubsHostedByProvider(
            _hostUid,
          ).overrideWithValue(const AsyncData<List<Club>>([])),
          watchClubsOwnedByProvider(_hostUid).overrideWithValue(
            AsyncError<List<Club>>(
              StateError('clubs failed'),
              StackTrace.current,
            ),
          ),
        ],
        resetProviderScope: true,
      );

      expectStateChrome();
      expect(find.text('Organizer'), findsOneWidget);
    },
  );

  testWidgets(
    'Host clubs keeps root primary-rail composition without an organizer',
    (tester) async {
      await _pumpHostScreen(
        tester,
        const HostClubsScreen(),
        overrides: _hostClubOverrides(),
      );

      expect(find.byType(HostClubsScaffold), findsOneWidget);
      expect(find.byType(CatchRootScreenScaffold), findsOneWidget);
      expect(find.byType(CatchRootScreenPageScrollView), findsOneWidget);
      expect(find.byType(CatchSliverEmptyState), findsOneWidget);
      expect(find.byType(CatchSliverStateViewport), findsOneWidget);
      expect(find.byKey(const ValueKey('host-club-tab-rail')), findsOneWidget);
      expect(find.text('Organizer'), findsOneWidget);
      expect(find.text('No hosted organizers yet'), findsOneWidget);
    },
  );

  testWidgets('Host Today keeps root composition for auth and route errors', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      HostTodayScreen(now: DateTime(2026, 6, 15, 12)),
      overrides: [
        uidProvider.overrideWithValue(const AsyncData<String?>(null)),
      ],
    );

    expect(find.byType(CatchRootScreenScaffold), findsOneWidget);
    expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);
    expect(find.byType(CatchSliverStateViewport), findsOneWidget);
    expect(find.byType(CatchErrorScaffold), findsNothing);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Sign in required'), findsOneWidget);

    await _pumpHostScreen(
      tester,
      HostTodayScreen(now: DateTime(2026, 6, 15, 12)),
      overrides: [
        uidProvider.overrideWithValue(
          AsyncError<String?>(StateError('auth failed'), StackTrace.current),
        ),
      ],
    );

    expect(find.byType(CatchRootScreenScaffold), findsOneWidget);
    expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);
    expect(find.byType(CatchSliverStateViewport), findsOneWidget);
    expect(find.byType(CatchErrorScaffold), findsNothing);
    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('Host Today uses real countdown and routes cross-event tasks', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 15, 12);
    final club = buildClub(id: 'today-club', ownerUserId: _hostUid);
    final hero = buildEvent(
      id: 'hero-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 15, 17),
    );
    final later = buildEvent(
      id: 'later-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 16, 20),
      waitlistedCount: 3,
    );

    await _pumpHostScreen(
      tester,
      HostTodayScreen(now: now),
      overrides: [
        ..._hostClubOverrides(
          owned: [club],
          timelineEventsByOrganizer: {
            club.id: [hero, later],
          },
        ),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(AsyncData<List<Event>>([hero, later])),
      ],
    );

    expect(find.text('STARTS IN 5H'), findsOneWidget);
    expect(find.text('Review waitlist'), findsOneWidget);
    expect(
      find.text('3 people are waiting for ${later.title}.'),
      findsOneWidget,
    );
    expect(find.text('Check host setup'), findsNothing);
    expect(
      tester
          .widget<HostTodayEventSpotlight>(find.byType(HostTodayEventSpotlight))
          .event,
      hero,
    );

    await tester.tap(find.text('Review waitlist'));
    await pumpFeatureUi(tester);
    expect(find.text('Manage ${later.id}'), findsOneWidget);
    expect(find.text('Section guests'), findsOneWidget);
  });

  testWidgets('Host Today opens a live spotlight in the run-of-show', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 15, 12);
    final club = buildClub(id: 'live-club', ownerUserId: _hostUid);
    final live = buildEvent(
      id: 'live-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 15, 11),
      endTime: DateTime(2026, 6, 15, 13),
    );

    await _pumpHostScreen(
      tester,
      HostTodayScreen(now: now),
      overrides: [
        ..._hostClubOverrides(
          owned: [club],
          timelineEventsByOrganizer: {
            club.id: [live],
          },
        ),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(AsyncData<List<Event>>([live])),
      ],
    );

    expect(find.text('LIVE NOW'), findsOneWidget);
    expect(find.text('Open run-of-show'), findsOneWidget);
    await tester.tap(find.text('Open run-of-show'));
    await pumpFeatureUi(tester);
    expect(find.text('Manage live-event'), findsOneWidget);
    expect(find.text('Section live'), findsOneWidget);
  });

  testWidgets(
    'Host Today error stays in the root state viewport without a club subtitle',
    (tester) async {
      final club = buildClub(
        id: 'today-error-club',
        name: 'Saket Run Club',
        ownerUserId: _hostUid,
      );

      await _pumpHostScreen(
        tester,
        HostTodayBody(
          organizer: club,
          state: HostTodayState(
            status: HostTodayStatus.error,
            error: StateError('Event not found'),
          ),
          now: DateTime(2026, 6, 15, 12),
          onRetry: () {},
          onOpenEvent: (_) {},
          onOpenAttention: (_) {},
          onViewEvents: () {},
          onStartRehearsal: () {},
        ),
      );

      expect(find.byType(CatchRootScreenScaffold), findsOneWidget);
      expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);
      expect(find.byType(CatchSliverStateViewport), findsOneWidget);
      expect(find.text('Saket Run Club'), findsNothing);
      expect(
        find.ancestor(
          of: find.byType(CatchErrorBody),
          matching: find.byType(Center),
        ),
        findsNothing,
      );
    },
  );

  testWidgets('Host Today spotlight reflows at 200 percent text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(393, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final now = DateTime(2026, 6, 15, 12);
    final club = buildClub(id: 'large-text-club', ownerUserId: _hostUid);
    final event = buildEvent(
      id: 'large-text-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 15, 17),
      waitlistedCount: 23,
    );

    await _pumpHostScreen(
      tester,
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: HostTodayScreen(now: now),
      ),
      overrides: [
        ..._hostClubOverrides(
          owned: [club],
          timelineEventsByOrganizer: {
            club.id: [event],
          },
        ),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(AsyncData<List<Event>>([event])),
      ],
    );

    expect(find.text('STARTS IN 5H'), findsOneWidget);
    expect(find.text('Continue setup'), findsOneWidget);
    final createAction = find.byKey(
      const ValueKey<String>('host-today-create-event'),
    );
    expect(createAction, findsNothing);
    expect(find.byTooltip('Create event'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('host-today-compact-layout')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Host Today uses adjacent command and attention panes when wide',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1200, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final now = DateTime(2026, 6, 15, 12);
      final club = buildClub(id: 'wide-today-club', ownerUserId: _hostUid);
      final hero = buildEvent(
        id: 'wide-hero-event',
        clubId: club.id,
        startTime: DateTime(2026, 6, 15, 17),
      );
      final later = buildEvent(
        id: 'wide-later-event',
        clubId: club.id,
        startTime: DateTime(2026, 6, 16, 20),
        waitlistedCount: 3,
      );

      await _pumpHostScreen(
        tester,
        HostTodayScreen(now: now),
        overrides: [
          ..._hostClubOverrides(
            owned: [club],
            timelineEventsByOrganizer: {
              club.id: [hero, later],
            },
          ),
          watchEventsForClubProvider(
            club.id,
          ).overrideWithValue(AsyncData<List<Event>>([hero, later])),
        ],
      );

      expect(
        find.byKey(const ValueKey<String>('host-today-wide-layout')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('host-today-primary-pane')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('host-today-attention-pane')),
        findsOneWidget,
      );
      expect(find.text('Review waitlist'), findsOneWidget);
      expect(find.text('NEXT 7 DAYS'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  registerHostEventEntryTests();

  testWidgets('Host Events keeps root composition for auth and route errors', (
    tester,
  ) async {
    await _pumpHostScreen(
      tester,
      HostEventsScreen(now: DateTime(2026, 6, 15, 12)),
      overrides: [
        uidProvider.overrideWithValue(const AsyncData<String?>(null)),
      ],
    );

    expect(find.byType(CatchRootScreenScaffold), findsOneWidget);
    expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);
    expect(find.byType(CatchSliverStateViewport), findsOneWidget);
    expect(find.byType(CatchErrorScaffold), findsNothing);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Sign in required'), findsOneWidget);

    await _pumpHostScreen(
      tester,
      HostEventsScreen(now: DateTime(2026, 6, 15, 12)),
      overrides: [
        uidProvider.overrideWithValue(
          AsyncError<String?>(StateError('auth failed'), StackTrace.current),
        ),
      ],
    );

    expect(find.byType(CatchRootScreenScaffold), findsOneWidget);
    expect(find.bySubtype<CatchSliverErrorState>(), findsOneWidget);
    expect(find.byType(CatchSliverStateViewport), findsOneWidget);
    expect(find.byType(CatchErrorScaffold), findsNothing);
    expect(find.text('Events'), findsOneWidget);
  });

  testWidgets('Host events centers its canonical empty-state primitive', (
    tester,
  ) async {
    final club = buildClub(id: 'empty-club', ownerUserId: _hostUid);

    await _pumpHostScreen(
      tester,
      HostEventsScreen(now: DateTime(2026, 6, 15, 12)),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(const AsyncData<List<Event>>([])),
      ],
    );

    expect(find.text('No upcoming events'), findsOneWidget);
    final emptyState = find.byType(CatchEmptyState);
    final content = find.byType(CatchEmptyStateContent);
    expect(find.byType(CatchSliverStateViewport), findsOneWidget);
    expect(
      find.ancestor(of: emptyState, matching: find.byType(Center)),
      findsNothing,
    );
    final fill = tester.widget<SliverFillRemaining>(
      find
          .ancestor(of: emptyState, matching: find.byType(SliverFillRemaining))
          .first,
    );
    expect(fill.hasScrollBody, isTrue);
    expect(
      tester.getCenter(content).dx,
      closeTo(tester.getCenter(emptyState).dx, 0.5),
    );
    expect(
      tester.getCenter(content).dy,
      closeTo(tester.getCenter(emptyState).dy, 0.5),
    );
  });

  testWidgets('Host events past-only history starts at standard body rhythm', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 15, 12);
    final club = buildClub(id: 'history-only-club', ownerUserId: _hostUid);
    final past = buildEvent(
      id: 'history-only-event',
      clubId: club.id,
      startTime: DateTime(2026, 5, 27, 9),
      endTime: DateTime(2026, 5, 27, 10),
    );

    await _pumpHostScreen(
      tester,
      HostEventsScreen(now: now),
      overrides: [
        ..._hostClubOverrides(
          owned: [club],
          timelineEventsByOrganizer: {
            club.id: [past],
          },
        ),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(AsyncData<List<Event>>([past])),
      ],
    );

    expect(find.text('No upcoming events'), findsOneWidget);
    await tester.tap(find.text('Past'));
    await pumpFeatureUi(tester);
    final railRect = tester.getRect(
      find.byKey(const ValueKey('host-events-tabs')),
    );
    final historyRect = tester.getRect(find.text('MAY 2026'));
    expect(
      historyRect.top - railRect.bottom,
      closeTo(CatchInsets.pageBody.top, 0.5),
    );
  });

  testWidgets('Host events unifies lifecycle rows and repeats a past event', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 15, 12);
    final club = buildClub(id: 'club-host', ownerUserId: _hostUid);
    final past = buildEvent(
      id: 'past-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 14, 9),
      endTime: DateTime(2026, 6, 14, 10),
    );
    final olderPast = buildEvent(
      id: 'older-past-event',
      clubId: club.id,
      startTime: DateTime(2026, 5, 27, 9),
      endTime: DateTime(2026, 5, 27, 10),
    );
    final oldestPast = buildEvent(
      id: 'oldest-past-event',
      clubId: club.id,
      startTime: DateTime(2026, 5, 18, 9),
      endTime: DateTime(2026, 5, 18, 10),
    );
    final live = buildEvent(
      id: 'live-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 15, 11),
      endTime: DateTime(2026, 6, 15, 13),
    );
    final upcoming = buildEvent(
      id: 'upcoming-event',
      clubId: club.id,
      startTime: DateTime(2026, 6, 16, 18),
    );

    await _pumpHostScreen(
      tester,
      HostEventsScreen(now: now),
      overrides: [
        ..._hostClubOverrides(
          owned: [club],
          timelineEventsByOrganizer: {
            club.id: [oldestPast, olderPast, past, live, upcoming],
          },
        ),
        watchEventsForClubProvider(club.id).overrideWithValue(
          AsyncData<List<Event>>([oldestPast, olderPast, past, live, upcoming]),
        ),
      ],
    );

    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Live'), findsNothing);
    expect(find.text('Past'), findsOneWidget);
    expect(find.text('SCHEDULE'), findsNothing);
    expect(find.byType(HostTodayEventSpotlight), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('host-event-row-live-event')),
      findsOneWidget,
    );
    expect(find.text('Repeat last event'), findsNothing);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('host-event-row-upcoming-event')),
      300,
      scrollable: _hostEventsScrollable(),
    );
    expect(
      find.byKey(const ValueKey<String>('host-event-row-upcoming-event')),
      findsOneWidget,
    );

    await tester.tap(find.text('Past'));
    await pumpFeatureUi(tester);
    expect(
      find.byKey(const ValueKey<String>('host-event-row-past-event')),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('host-events-month-2026-5')),
      300,
      scrollable: _hostEventsScrollable(),
    );
    expect(
      find.byKey(const ValueKey<String>('host-event-row-older-past-event')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('host-event-row-oldest-past-event')),
      findsOneWidget,
    );

    final juneSection = find.byKey(
      const ValueKey<String>('host-events-month-2026-6'),
    );
    final maySection = find.byKey(
      const ValueKey<String>('host-events-month-2026-5'),
    );
    expect(juneSection, findsOneWidget);
    expect(maySection, findsOneWidget);
    expect(tester.widget<CatchSection>(juneSection).title, 'June 2026');
    expect(tester.widget<CatchSection>(maySection).title, 'May 2026');

    final juneFieldFinder = find.descendant(
      of: juneSection,
      matching: find.byType(CatchRecordRow),
    );
    final mayFieldFinder = find.descendant(
      of: maySection,
      matching: find.byType(CatchRecordRow),
    );
    expect(juneFieldFinder, findsOneWidget);
    expect(mayFieldFinder, findsNWidgets(2));
    final juneField = tester.widget<CatchRecordRow>(juneFieldFinder);
    expect(juneField.title, past.title);
    expect(juneField.facts.last, contains('attended'));
    expect(
      juneField.icon,
      ActivityPalette.resolve(
        tester.element(juneSection),
        past.activityKind,
      ).glyph,
    );
    final mayDividers = tester
        .widgetList<CatchDivider>(
          find.descendant(of: maySection, matching: find.byType(CatchDivider)),
        )
        .toList();
    expect(mayDividers.map((divider) => divider.role), [
      CatchDividerRole.fieldRow,
    ]);
    final tokens = CatchTokens.of(tester.element(maySection));
    expect(
      CatchDivider.colorFor(tokens, mayDividers.last.role),
      tokens.line.withValues(
        alpha: tokens.line.a * CatchOpacity.fieldRowDivider,
      ),
    );
    final mayRowDivider = find.descendant(
      of: maySection,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is CatchDivider && widget.role == CatchDividerRole.fieldRow,
      ),
    );
    expect(
      tester.getTopLeft(mayRowDivider).dx,
      closeTo(tester.getTopLeft(maySection).dx, 0.5),
    );
    expect(
      tester.getTopRight(mayRowDivider).dx,
      closeTo(tester.getTopRight(maySection).dx, 0.5),
    );

    await tester.fling(_hostEventsScrollable(), const Offset(0, 1200), 10000);
    await pumpFeatureUi(tester);
    final createButton = find.byKey(
      const ValueKey<String>('host-events-create-event'),
    );
    await tester.ensureVisible(createButton);
    await pumpFeatureUi(tester);
    await tester.tap(createButton);
    await pumpFeatureUi(tester);
    expect(find.text('Repeat last event'), findsOneWidget);
    expect(
      find.text('Reuse the setup from ${past.title} and choose a new date.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Repeat last event'));
    await pumpFeatureUi(tester);
    expect(find.text('Repeat ${past.id}'), findsOneWidget);
  });

  testWidgets('Host Today follows the shared organizer selection', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      ownerUserId: _hostUid,
    );
    final cohostClub = buildClub(
      id: 'cohost-club',
      name: 'Quizzicals',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );
    final ownedEvent = buildEvent(
      id: 'owned-event',
      clubId: ownedClub.id,
      startTime: DateTime(2026, 6, 15, 17),
    );
    final hostedEvent = buildEvent(
      id: 'hosted-event',
      clubId: cohostClub.id,
      startTime: DateTime(2026, 6, 16, 20),
    );

    await _pumpHostScreen(
      tester,
      HostTodayScreen(now: DateTime(2026, 6, 15, 12)),
      overrides: [
        ..._hostClubOverrides(
          owned: [ownedClub],
          hosted: [cohostClub],
          timelineEventsByOrganizer: {
            ownedClub.id: [ownedEvent],
            cohostClub.id: [hostedEvent],
          },
        ),
        watchEventsForClubProvider(
          ownedClub.id,
        ).overrideWithValue(AsyncData<List<Event>>([ownedEvent])),
        watchEventsForClubProvider(
          cohostClub.id,
        ).overrideWithValue(AsyncData<List<Event>>([hostedEvent])),
      ],
    );

    expect(
      tester.widget<HostTodayBody>(find.byType(HostTodayBody)).organizer,
      ownedClub,
    );
    expect(
      tester
          .widget<HostTodayEventSpotlight>(find.byType(HostTodayEventSpotlight))
          .event,
      ownedEvent,
    );

    expect(find.byTooltip('Switch organizer'), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HostTodayScreen)),
    );
    container
        .read(hostOrganizerSelectionProvider(_hostUid).notifier)
        .select(cohostClub.id);
    await pumpFeatureUi(tester);

    expect(
      tester.widget<HostTodayBody>(find.byType(HostTodayBody)).organizer,
      cohostClub,
    );
    expect(
      tester
          .widget<HostTodayEventSpotlight>(find.byType(HostTodayEventSpotlight))
          .event,
      hostedEvent,
    );
  });

  testWidgets('Host Customers follows the shared organizer selection', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      ownerUserId: _hostUid,
    );
    final cohostClub = buildClub(
      id: 'cohost-club',
      name: 'Quizzicals',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );
    final directoryRequests = <HostCustomersDirectoryRequest>[];
    await _pumpHostScreen(
      tester,
      const HostCustomersScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub], hosted: [cohostClub]),
        hostCustomersDirectoryControllerProvider.overrideWith2(
          (_) => _EmptyHostCustomersDirectoryController(directoryRequests),
        ),
      ],
    );

    expect(directoryRequests.last.organizerId, ownedClub.id);
    expect(find.byTooltip('Switch organizer'), findsNothing);
    expect(find.text('People'), findsOneWidget);
    expect(find.text('Groups'), findsOneWidget);
    expect(find.text('Campaigns'), findsNothing);
    expect(
      tester
          .widget<CatchScreenHeaderTitle>(find.byType(CatchScreenHeaderTitle))
          .eyebrow,
      isNull,
    );
    expect(
      find.descendant(
        of: find.byType(CatchScreenTopBar),
        matching: find.byKey(
          const ValueKey<String>('host-customers-add-customer'),
        ),
      ),
      findsOneWidget,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HostCustomersScreen)),
    );
    container
        .read(hostOrganizerSelectionProvider(_hostUid).notifier)
        .select(cohostClub.id);
    await pumpFeatureUi(tester);

    expect(directoryRequests.last.organizerId, cohostClub.id);
  });

  testWidgets('Host clubs defaults to the consolidated edit workspace', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Sunday sea-face crew',
      description: 'Dawn runs along the Bandra seafront, every Sunday.',
      location: 'in-dl-delhi-ncr',
      ownerUserId: _hostUid,
      tags: const ['social run', 'coffee', 'beginner'],
      memberCount: 128,
      rating: 4.8,
      reviewCount: 42,
      hostProfiles: const [
        ClubHostProfile(
          uid: _hostUid,
          displayName: 'Owner Host',
          role: ClubHostRole.owner,
        ),
        ClubHostProfile(uid: 'co-host', displayName: 'Co Host'),
      ],
    );

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub]),
        watchHostPaymentAccountsProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<List<HostPaymentAccount>>([])),
      ],
    );

    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );
    expect(find.text('How guests see you'), findsNothing);
    expect(find.text('Public page'), findsNothing);
    expect(find.text('Preview'), findsWidgets);
    final editSections = tester
        .widgetList<CatchSection>(
          find.descendant(
            of: find.byType(HostClubEditTab),
            matching: find.byType(CatchSection),
          ),
        )
        .toList();
    expect(editSections, hasLength(5));
    expect(editSections.map((section) => section.title), [
      'Public visibility',
      'Media',
      'Identity',
      'Contact',
      'Organizer settings',
    ]);
    for (final title in [
      'Public visibility',
      'Media',
      'Identity',
      'Contact',
      'Organizer settings',
    ]) {
      expect(
        find.byWidgetPredicate(
          (widget) => widget is CatchSection && widget.title == title,
        ),
        findsOneWidget,
      );
    }
    expect(find.text('CLUB LOGO'), findsNothing);
    expect(find.text('PHOTOS'), findsNothing);
    expect(find.text('Event defaults'), findsOneWidget);
    expect(find.text('Live event guide'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Host team'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('host-organizer-sign-out')),
      findsOneWidget,
    );
    expect(find.byTooltip('Host team'), findsNothing);
    expect(find.text('Trends · last 12 weeks'), findsNothing);
    expect(find.text('See insights'), findsNothing);
    expect(find.byType(HostAnalyticsTrendPanel), findsNothing);
    expect(find.text('Manage'), findsNothing);
    expect(find.text('Team · 2'), findsNothing);
    expect(find.text('Connect payouts to get paid'), findsNothing);
    expect(find.textContaining('DELHI NCR'), findsNothing);
    expect(find.textContaining('IN-DL-DELHI-NCR'), findsNothing);
    expect(
      tester
          .widgetList<CatchBadge>(find.byType(CatchBadge))
          .where((badge) => badge.label.toLowerCase() == 'social run'),
      isEmpty,
    );

    final hostTeamRow = find.byKey(
      const ValueKey('host-club-settings-host-team'),
    );
    await tester.ensureVisible(hostTeamRow);
    await pumpFeatureUi(tester);
    await tester.tap(hostTeamRow);
    await pumpFeatureUi(tester);

    expect(find.byType(HostClubTeamScreen), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('host-organizer-sign-out')),
      findsNothing,
    );
  });
}
