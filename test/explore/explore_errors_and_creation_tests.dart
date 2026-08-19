part of 'explore_widgets_test.dart';

void _registerExploreErrorsAndCreationTests() {
  testWidgets('ExploreMapScreen keeps browsing after location is unavailable', (
    tester,
  ) async {
    final club = buildClub(
      id: 'club-map-location-denied',
      name: 'Location Optional Club',
    );
    final event = event_test.buildEvent(
      id: 'event-map-location-denied',
      clubId: club.id,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cityListProvider.overrideWith((ref) async => _testCities),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          exploreFeedViewModelProvider.overrideWithValue(
            AsyncData(
              ExploreFeedViewModel(
                items: [
                  ExploreEventItem(
                    event: event,
                    club: club,
                    status: EventTileStatus.open,
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ExploreMapScreen(enableNetworkTiles: false),
        ),
      ),
    );
    await _pumpClubUi(tester);

    await tester.tap(find.text('Use my location'));
    await tester.pump();

    expect(
      find.text('Location is unavailable. You can still browse the map.'),
      findsOneWidget,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ExploreMapScreen)),
    );
    expect(
      container.read(exploreFiltersProvider).distanceFilter,
      ExploreDistanceFilter.any,
    );
    expect(find.byType(CatchDistanceRing), findsNothing);
    expect(find.byType(EventPinsMapPlaceholder), findsOneWidget);
    expect(find.bySemanticsLabel('Select Carter Road'), findsOneWidget);
  });

  testWidgets('ExploreMapScreen selects pin before navigating from card', (
    tester,
  ) async {
    final club = buildClub(id: 'club-map-nav', name: 'Race Course Road Club');
    final event = event_test.buildEvent(
      id: 'event-map-nav',
      clubId: club.id,
      meetingPoint: 'Race Course Road main gate',
      startTime: DateTime.now().add(const Duration(days: 1)),
    );
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const ExploreMapScreen(enableNetworkTiles: false),
        ),
        GoRoute(
          path: '/events/:clubId/:eventId',
          name: Routes.eventDetailScreen.name,
          builder: (_, state) {
            final extra = state.extra as EventDetailRouteExtra?;
            return Text(
              [
                'Event ${state.pathParameters['eventId']}',
                extra?.transition.name,
                extra?.heroTag,
              ].whereType<Object>().join(' · '),
              textDirection: TextDirection.ltr,
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cityListProvider.overrideWith((ref) async => _testCities),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          exploreFeedViewModelProvider.overrideWithValue(
            AsyncData(
              ExploreFeedViewModel(
                items: [
                  ExploreEventItem(
                    event: event,
                    club: club,
                    status: EventTileStatus.open,
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await _pumpClubUi(tester);

    expect(find.byType(EventDateRailCard), findsNothing);
    expect(find.textContaining('Event event-map-nav'), findsNothing);

    await tester.tap(
      find.bySemanticsLabel('Select Race Course Road main gate'),
    );
    await tester.pump(CatchMotion.fast);

    expect(find.byType(EventDateRailCard), findsOneWidget);
    expect(find.text('Social run'), findsOneWidget);
    expect(find.textContaining('Event event-map-nav'), findsNothing);

    await tester.tap(find.text('Social run'));
    await _pumpClubUi(tester);

    expect(
      find.text(
        'Event event-map-nav · mapSelectedCard · event-ticket-map-event-map-nav',
      ),
      findsOneWidget,
    );
  });

  testWidgets('ExploreMapScreen opens selected external event source', (
    tester,
  ) async {
    final externalEvent = _buildExternalExploreEvent(
      id: 'external-map-outbound',
      title: 'Bandra mixer night',
    );
    Uri? openedUri;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cityListProvider.overrideWith((ref) async => _testCities),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          appAnalyticsProvider.overrideWithValue(
            AppAnalytics(shouldCollect: false),
          ),
          externalUrlLauncherProvider.overrideWithValue((
            Uri uri, {
            LaunchMode mode = LaunchMode.platformDefault,
          }) async {
            openedUri = uri;
            return true;
          }),
          exploreFeedViewModelProvider.overrideWithValue(
            AsyncData(
              ExploreFeedViewModel(
                items: const [],
                externalItems: [ExploreExternalEventItem(event: externalEvent)],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ExploreMapScreen(enableNetworkTiles: false),
        ),
      ),
    );
    await _pumpClubUi(tester);

    await tester.tap(find.bySemanticsLabel('Select Bandra Amphitheatre'));
    await tester.pump(CatchMotion.fast);

    expect(find.text('Bandra mixer night'), findsOneWidget);
    final outboundAction = find.widgetWithText(CatchButton, 'Open');
    expect(outboundAction, findsOneWidget);

    await tester.tap(outboundAction);
    await tester.pump();

    expect(
      openedUri,
      Uri.parse('https://district.example/events/external-event-only'),
    );
  });

  testWidgets('ExploreMapScreen background tap dismisses selected card', (
    tester,
  ) async {
    final club = buildClub(id: 'club-map-clear', name: 'Map Clear Club');
    final event = event_test.buildEvent(
      id: 'event-map-clear',
      clubId: club.id,
      meetingPoint: 'Clearable Pin Point',
      startTime: DateTime.now().add(const Duration(days: 1)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cityListProvider.overrideWith((ref) async => _testCities),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          exploreFeedViewModelProvider.overrideWithValue(
            AsyncData(
              ExploreFeedViewModel(
                items: [
                  ExploreEventItem(
                    event: event,
                    club: club,
                    status: EventTileStatus.open,
                  ),
                ],
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ExploreMapScreen(enableNetworkTiles: false),
        ),
      ),
    );
    await _pumpClubUi(tester);

    await tester.tap(find.bySemanticsLabel('Select Clearable Pin Point'));
    await tester.pump(CatchMotion.fast);
    expect(find.byType(EventDateRailCard), findsOneWidget);

    await tester.tapAt(const Offset(24, 220));
    await _pumpClubUi(tester);

    expect(find.byType(EventDateRailCard), findsNothing);
  });

  testWidgets(
    'ExploreMapScreen clears selected card when feed refresh drops event',
    (tester) async {
      var showSelectedEvent = true;
      final club = buildClub(id: 'club-map-refresh', name: 'Map Refresh Club');
      final event = event_test.buildEvent(
        id: 'event-map-refresh',
        clubId: club.id,
        meetingPoint: 'Refresh Pin Point',
        startTime: DateTime.now().add(const Duration(days: 1)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            exploreFeedViewModelProvider.overrideWith((ref) {
              return AsyncData(
                ExploreFeedViewModel(
                  items: showSelectedEvent
                      ? [
                          ExploreEventItem(
                            event: event,
                            club: club,
                            status: EventTileStatus.open,
                          ),
                        ]
                      : const <ExploreEventItem>[],
                ),
              );
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ExploreMapScreen(enableNetworkTiles: false),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.tap(find.bySemanticsLabel('Select Refresh Pin Point'));
      await tester.pump(CatchMotion.fast);
      expect(find.byType(EventDateRailCard), findsOneWidget);

      final ProviderContainer container = ProviderScope.containerOf(
        tester.element(find.byType(ExploreMapScreen)),
      );
      showSelectedEvent = false;
      container.invalidate(exploreFeedViewModelProvider);
      await tester.pump();
      await _pumpClubUi(tester);

      expect(find.byType(EventDateRailCard), findsNothing);
    },
  );

  testWidgets(
    'ExploreMapScreen clears selected card when selected event loses its pin',
    (tester) async {
      var showExactPin = true;
      final club = buildClub(id: 'club-map-pin-loss', name: 'Map Pin Club');
      final pinnedEvent = event_test.buildEvent(
        id: 'event-map-pin-loss',
        clubId: club.id,
        meetingPoint: 'Pin Loss Point',
        startTime: DateTime.now().add(const Duration(days: 1)),
      );
      final unpinnedEvent = pinnedEvent.copyWith(
        meetingLocation: null,
        startingPointLat: null,
        startingPointLng: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cityListProvider.overrideWith((ref) async => _testCities),
            deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
            exploreFeedViewModelProvider.overrideWith((ref) {
              return AsyncData(
                ExploreFeedViewModel(
                  items: [
                    ExploreEventItem(
                      event: showExactPin ? pinnedEvent : unpinnedEvent,
                      club: club,
                      status: EventTileStatus.open,
                    ),
                  ],
                ),
              );
            }),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const ExploreMapScreen(enableNetworkTiles: false),
          ),
        ),
      );
      await _pumpClubUi(tester);

      await tester.tap(find.bySemanticsLabel('Select Pin Loss Point'));
      await tester.pump(CatchMotion.fast);
      expect(find.byType(EventDateRailCard), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ExploreMapScreen)),
      );
      showExactPin = false;
      container.invalidate(exploreFeedViewModelProvider);
      await tester.pump();
      await _pumpClubUi(tester);

      expect(find.bySemanticsLabel('Select Pin Loss Point'), findsNothing);
      expect(find.byType(EventDateRailCard), findsNothing);
    },
  );

  testWidgets('ExploreScreen shows Explore-specific error copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cityListProvider.overrideWith((ref) async => _testCities),
          deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
          watchClubsByLocationProvider(
            'mumbai',
          ).overrideWith((ref) => Stream.value(const [])),
          exploreClubsViewModelProvider.overrideWithValue(
            const AsyncError(
              BackendOperationException(
                code: 'failed-precondition',
                message:
                    'This list is still getting set up. Please try again in a moment.',
                debugMessage:
                    'Firestore query requires a composite required index.',
                context: BackendErrorContext(
                  service: BackendService.firestore,
                  action: 'watch clubs by location',
                  resource: 'clubs',
                ),
                retryable: true,
              ),
              StackTrace.empty,
            ),
          ),
          _emptyExploreFeedOverride,
        ],
        child: MaterialApp(theme: AppTheme.light, home: const ExploreScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Explore unavailable'), findsOneWidget);
    expect(
      find.text(
        'Explore is still getting set up. Please try again in a moment.',
      ),
      findsOneWidget,
    );
    expect(find.text('Reload Explore'), findsOneWidget);
    expect(find.text('Club unavailable'), findsNothing);
    expect(find.text('Reload club'), findsNothing);
  });

  testWidgets('ExploreScreen listens for join mutation errors', (tester) async {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [
        cityListProvider.overrideWith((ref) async => _testCities),
        deviceLocationProvider.overrideWith(_NoDeviceLocation.new),
        watchClubsByLocationProvider(
          'mumbai',
        ).overrideWith((ref) => Stream.value([buildClub(id: 'club-err')])),
        exploreClubsViewModelProvider.overrideWithValue(
          AsyncData(
            ExploreViewModel(
              joinedClubs: const [],
              allClubs: [buildClub(id: 'club-err')],
            ),
          ),
        ),
        uidProvider.overrideWith((ref) => Stream.value(null)),
        _emptyExploreFeedOverride,
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: AppTheme.light, home: const ExploreScreen()),
      ),
    );
    await tester.pump();

    try {
      await ClubMembershipController.joinMutation.run(container, (tx) async {
        throw StateError('join failed');
      });
    } catch (_) {}
    await _pumpClubUi(tester);

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'ClubDetailScreen uses initialClub while live data is still loading',
    (tester) async {
      final club = buildClub(name: 'Initial Club');
      final controller = StreamController<Club?>.broadcast();
      addTearDown(controller.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            watchClubProvider(club.id).overrideWith((ref) => controller.stream),
            watchEventsForClubProvider(
              club.id,
            ).overrideWith((ref) => Stream.value(const <Event>[])),
            watchReviewsForClubProvider(
              club.id,
            ).overrideWith((ref) => Stream.value(const <Review>[])),
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
            watchUserProfileProvider.overrideWith(
              (ref) => Stream.value(buildUser(uid: 'runner-1')),
            ),
            watchClubMembershipProvider(
              club.id,
              'runner-1',
            ).overrideWith((ref) => Stream.value(null)),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ClubDetailScreen(clubId: club.id, initialClub: club),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Initial Club'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );

  testWidgets('ClubDetailScreen shows detail-provider errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
          clubDetailViewModelProvider('club-err').overrideWithValue(
            AsyncError(StateError('detail failed'), StackTrace.empty),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ClubDetailScreen(clubId: 'club-err'),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('ClubDetailScreen shows a not-found state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
          clubDetailViewModelProvider(
            'club-missing',
          ).overrideWithValue(const AsyncData(null)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ClubDetailScreen(clubId: 'club-missing'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Organizer not found'), findsOneWidget);
    expect(find.text('This organizer is no longer available.'), findsOneWidget);
  });

  testWidgets('ClubDetailScreen listens for join mutation errors', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        watchUserProfileProvider.overrideWith(
          (ref) => Stream.value(buildUser(uid: 'runner-1')),
        ),
        watchClubMembershipProvider(
          'club-1',
          'runner-1',
        ).overrideWith((ref) => Stream.value(null)),
        clubDetailViewModelProvider('club-1').overrideWithValue(
          AsyncData(
            ClubDetailViewModel(
              club: buildClub(),
              isHost: false,
              isMember: false,
              upcomingEvents: const [],
              reviews: const [],
              userProfile: buildUser(uid: 'runner-1'),
              uid: 'runner-1',
              isAuthenticated: true,
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ClubDetailScreen(clubId: 'club-1'),
        ),
      ),
    );
    await tester.pump();

    try {
      await ClubMembershipController.joinMutation.run(container, (tx) async {
        throw StateError('join failed');
      });
    } catch (_) {}
    await tester.pump();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    ClubMembershipController.joinMutation.reset(container);
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    container.dispose();
    await _pumpClubUi(tester);
  });

  testWidgets('ClubDetailScreen listens for leave mutation errors', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        watchUserProfileProvider.overrideWith(
          (ref) => Stream.value(buildUser(uid: 'runner-1')),
        ),
        watchClubMembershipProvider(
          'club-1',
          'runner-1',
        ).overrideWith((ref) => Stream.value(null)),
        clubDetailViewModelProvider('club-1').overrideWithValue(
          AsyncData(
            ClubDetailViewModel(
              club: buildClub(),
              isHost: false,
              isMember: true,
              upcomingEvents: const [],
              reviews: const [],
              userProfile: buildUser(uid: 'runner-1'),
              uid: 'runner-1',
              isAuthenticated: true,
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ClubDetailScreen(clubId: 'club-1'),
        ),
      ),
    );
    await tester.pump();

    try {
      await ClubMembershipController.leaveMutation.run(container, (tx) async {
        throw StateError('leave failed');
      });
    } catch (_) {}
    await tester.pump();

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    ClubMembershipController.leaveMutation.reset(container);
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    container.dispose();
    await _pumpClubUi(tester);
  });

  testWidgets('CreateClubScreen picks and previews club photos', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    const transparentPixel =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==';
    final fakeImageUploadRepository = FakeImageUploadRepository(
      pickedImages: [
        XFile.fromData(
          base64Decode(transparentPixel),
          name: 'club-photo-test.png',
          mimeType: 'image/png',
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CreateClubScreen(restoreSavedDraft: false),
        ),
      ),
    );
    await _pumpClubUi(tester);

    // Cover picker sits below the fold in the create form — scroll it into
    // view before tapping (standard for a long scrollable form).
    await tester.ensureVisible(find.text('Add organizer photos'));
    await _pumpClubUi(tester);
    await tester.tap(find.text('Add organizer photos'));
    await _pumpClubUi(tester);

    expect(find.bySemanticsLabel('Photo 1'), findsOneWidget);
  });

  testWidgets('CreateClubScreen shows mutation errors inline', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [uidProvider.overrideWith((ref) => Stream.value(null))],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CreateClubScreen(restoreSavedDraft: false),
        ),
      ),
    );
    await tester.pump();

    try {
      await CreateClubController.submitMutation.run(container, (tx) async {
        throw StateError('create failed');
      });
    } catch (_) {}
    await _pumpClubUi(tester);

    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'CreateClubScreen freezes route and draft controls while submit is pending',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final pendingSubmit = Completer<void>();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: const CreateClubScreen(restoreSavedDraft: false),
          ),
        ),
      );
      await tester.pump();

      final request = CreateClubController.submitMutation.run(
        container,
        (_) => pendingSubmit.future,
      );
      await tester.pump();

      expect(
        tester
            .widget<CatchStepHeader>(find.byType(CatchStepHeader))
            .leadingType,
        CatchTopBarLeading.close,
      );
      expect(
        tester
            .widget<CatchField>(
              find.byWidgetPredicate(
                (widget) =>
                    widget is CatchField && widget.title == 'Organizer name',
              ),
            )
            .enabled,
        isFalse,
      );
      expect(find.text('Save draft'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is PopScope<dynamic> && !widget.canPop,
        ),
        findsWidgets,
      );

      pendingSubmit.complete();
      await request;
      await tester.pump();
    },
  );

  testWidgets('CreateClubScreen reviews and pops after a successful submit', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final fakeRepository = FakeClubsRepository();
    final fakeImageUploadRepository = FakeImageUploadRepository(
      pickedImage: XFile('/tmp/club-cover.jpg'),
    );
    final container = ProviderContainer(
      overrides: [
        clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
        imageUploadRepositoryProvider.overrideWith(
          (ref) => fakeImageUploadRepository,
        ),
        uidProvider.overrideWith((ref) => Stream.value('host-1')),
        watchUserProfileProvider.overrideWith(
          (ref) => Stream.value(buildUser(uid: 'host-1', name: 'Priya')),
        ),
      ],
    );
    addTearDown(container.dispose);
    final uidSubscription = container.listen(
      uidProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(uidSubscription.close);
    final userProfileSubscription = container.listen(
      watchUserProfileProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(userProfileSubscription.close);
    await container.pump();
    await container.pump();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const CreateClubScreen(restoreSavedDraft: false),
                    ),
                  ),
                  child: const Text('Open create screen'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open create screen'));
    await _pumpClubUi(tester);

    await tester.tap(find.text('Next'));
    await _pumpClubUi(tester);

    expect(find.text('Organizer details'), findsOneWidget);
    expect(find.text('Please enter an organizer name'), findsNothing);

    await tester.tap(find.text('Previous'));
    await _pumpClubUi(tester);
    expect(find.text('Organizer basics'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: _field('Organizer name'),
        matching: find.byType(EditableText),
      ),
      'Sunset Striders',
    );
    await tester.enterText(
      find.descendant(
        of: _field('Area / neighbourhood'),
        matching: find.byType(EditableText),
      ),
      'Bandra',
    );

    tester.testTextInput.hide();
    await tester.pump();
    final cityField = _field('City');
    await tester.ensureVisible(cityField);
    await tester.tap(cityField);
    await _pumpClubUi(tester);
    await tester.tap(_fieldChoice('Mumbai'));
    await _pumpClubUi(tester);

    await tester.tap(find.text('Next'));
    await _pumpClubUi(tester);

    await tester.tap(find.text('Next'));
    await _pumpClubUi(tester);

    expect(find.text('DEFAULT EVENT POLICY'), findsOneWidget);

    await tester.tap(find.text('Previous'));
    await _pumpClubUi(tester);

    await tester.enterText(
      find.descendant(
        of: _field('Description'),
        matching: find.byType(EditableText),
      ),
      'Easy social club',
    );
    tester.testTextInput.hide();
    await tester.pump();

    await tester.tap(find.text('Next'));
    await _pumpClubUi(tester);

    expect(find.text('DEFAULT EVENT POLICY'), findsOneWidget);
    expect(_field('Cohort caps'), findsOneWidget);
    await tester.tap(_field('Admission format'));
    await _pumpClubUi(tester);
    expect(_fieldOptionCard('OPEN', selected: true), findsOneWidget);

    await tester.tap(find.text('Next'));
    await _pumpClubUi(tester);

    expect(find.text('Live event guide'), findsOneWidget);
    expect(_field('Live event guide'), findsOneWidget);

    await tester.tap(find.text('Review organizer'));
    await _pumpClubUi(tester);

    expect(find.text('COMPLETE'), findsNWidgets(2));
    expect(find.text('OPTIONAL'), findsNWidgets(2));

    await tester.tap(find.text('Create organizer'));
    await _pumpClubUi(tester);

    expect(find.text('Open create screen'), findsOneWidget);
    expect(fakeRepository.lastCreateCall, isNotNull);
    expect(fakeRepository.lastCreateCall!.name, 'Sunset Striders');
  });
}
