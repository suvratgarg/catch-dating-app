part of 'host_operations_screen_test.dart';

void _registerHostOperationsAnalyticsTeamTests() {
  testWidgets('Host club workspace keeps shared chrome across every tab', (
    tester,
  ) async {
    final ownedClub = buildClub(
      id: 'owned-club',
      name: 'Saket Run Club',
      description: 'Morning runs, plenty of sunshine and energy.',
      area: 'Saket',
      location: 'in-mp-indore',
      ownerUserId: _hostUid,
    );
    final secondClub = buildClub(
      id: 'second-club',
      name: 'Second Club',
      ownerUserId: _hostUid,
    );
    final previewEvent = buildEvent(
      clubId: ownedClub.id,
      startTime: DateTime(2030, 7, 20, 7),
    );

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub, secondClub]),
        watchEventsForClubProvider(
          ownedClub.id,
        ).overrideWithValue(AsyncData<List<Event>>([previewEvent])),
        clubDetailViewModelProvider(ownedClub.id).overrideWithValue(
          AsyncData<ClubDetailViewModel?>(
            _previewViewModel(ownedClub, events: [previewEvent]),
          ),
        ),
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
        hostAnalyticsRepositoryProvider.overrideWithValue(
          const _EmptyHostAnalyticsRepository(),
        ),
      ],
    );

    final tabRail = find.byKey(const ValueKey('host-club-tab-rail'));

    Finder tab(String label) =>
        find.descendant(of: tabRail, matching: find.text(label));

    void expectSharedChrome({
      bool switcherVisible = true,
      bool constrainToContentWidth = true,
    }) {
      expect(find.byType(CatchTabbedScreenScaffold), findsOneWidget);
      expect(find.byType(NestedScrollView), findsOneWidget);
      expect(find.byType(SliverOverlapAbsorber), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
      expect(tabRail, findsOneWidget);
      expect(tab('Organizer'), findsNothing);
      expect(tab('Edit'), findsOneWidget);
      expect(tab('Audience'), findsNothing);
      expect(tab('Insights'), findsOneWidget);
      expect(tab('Preview'), findsOneWidget);
      expect(
        find.byTooltip('Switch organizer'),
        switcherVisible ? findsOneWidget : findsNothing,
      );
      final workspaceSemantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Organizer workspace tabs',
        ),
      );
      expect(
        workspaceSemantics.properties.hint,
        'Drag left or right to switch between Edit, Insights, and Preview.',
      );
      final currentPage = tester.widget<CatchTabbedPageScrollView>(
        find.byType(CatchTabbedPageScrollView),
      );
      expect(currentPage.includeTerminalPadding, isTrue);
      expect(currentPage.constrainToContentWidth, constrainToContentWidth);
    }

    expectSharedChrome();
    final editBodyPadding = tester
        .widgetList<Padding>(
          find.ancestor(
            of: find.byType(HostClubEditTab),
            matching: find.byType(Padding),
          ),
        )
        .where(
          (padding) =>
              padding.padding == CatchInsets.pageBody.copyWith(bottom: 0),
        );
    expect(editBodyPadding, hasLength(1));
    final loadedHeader = tester.widget<CatchScreenHeaderTitle>(
      find.byWidgetPredicate(
        (widget) =>
            widget is CatchScreenHeaderTitle &&
            widget.title == 'Saket Run Club',
      ),
    );
    expect(loadedHeader.eyebrow, isNull);
    expect(loadedHeader.subtitle, isNull);
    expect(loadedHeader.leading, isNull);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );

    final editWorkspaceScrollable = find
        .descendant(
          of: find.byKey(
            const PageStorageKey<String>('host-club-owned-club-edit-scroll'),
          ),
          matching: find.byType(Scrollable),
        )
        .first;
    await Scrollable.ensureVisible(
      tester.element(
        find.byKey(const ValueKey('host-club-settings-host-team')),
      ),
      alignment: 0.5,
    );
    await pumpFeatureUi(tester);

    expectSharedChrome(switcherVisible: false);
    expect(find.text('IDENTITY'), findsOneWidget);
    expect(find.text('SAKET · INDORE'), findsNothing);
    final editScroll = tester
        .state<ScrollableState>(editWorkspaceScrollable)
        .position;
    expect(editScroll.pixels, greaterThan(0));

    await tester.tap(tab('Insights'));
    await pumpFeatureUi(tester);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsOneWidget,
    );

    expectSharedChrome(switcherVisible: false);
    expect(find.byType(HostClubInsightsPane), findsOneWidget);
    final insightsBodyPadding = tester
        .widgetList<SliverPadding>(
          find.ancestor(
            of: find.byType(HostClubInsightsPane),
            matching: find.byType(SliverPadding),
          ),
        )
        .where(
          (padding) =>
              padding.padding == CatchInsets.pageBody.copyWith(bottom: 0),
        );
    expect(insightsBodyPadding, hasLength(1));
    expect(find.byType(HostAnalyticsTrendPanel), findsOneWidget);
    expect(find.text('SAKET · INDORE'), findsNothing);
    expect(find.byTooltip('Back to Organizer'), findsNothing);
    final rangeOptions = find.byType(
      CatchOptionGroup<HostClubInsightsRangePreset>,
    );
    expect(
      tester
          .widget<CatchOptionGroup<HostClubInsightsRangePreset>>(rangeOptions)
          .selected,
      HostClubInsightsRangePreset.thirtyDays,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('90 days')),
      alignment: 0.5,
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.text('90 days'));
    await pumpFeatureUi(tester);
    expect(
      tester
          .widget<CatchOptionGroup<HostClubInsightsRangePreset>>(rangeOptions)
          .selected,
      HostClubInsightsRangePreset.ninetyDays,
    );

    await tester.tap(tab('Preview'));
    await pumpFeatureUi(tester);

    expectSharedChrome(switcherVisible: false, constrainToContentWidth: false);
    expect(
      find.byKey(const ValueKey('club-detail-hero-module')),
      findsOneWidget,
    );
    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.text('Open public preview'), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
    expect(find.byTooltip('Share club'), findsNothing);
    expect(find.text('HOSTED'), findsNothing);
    expect(find.byType(SliverIgnorePointer), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('SCHEDULE'),
      320,
      scrollable: find
          .descendant(
            of: find.byKey(
              const PageStorageKey<String>(
                'host-club-owned-club-preview-scroll',
              ),
            ),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await pumpFeatureUi(tester);
    expect(find.text('SCHEDULE'), findsOneWidget);
    final eventCard = tester.widget<EventDateRailCard>(
      find.byType(EventDateRailCard),
    );
    expect(eventCard.statusLabel, isNull);
    expect(eventCard.onTap, isNull);

    await tester.tap(tab('Insights'));
    await pumpFeatureUi(tester);
    expect(
      tester
          .widget<CatchOptionGroup<HostClubInsightsRangePreset>>(rangeOptions)
          .selected,
      HostClubInsightsRangePreset.ninetyDays,
    );

    await tester.tap(tab('Edit'));
    await pumpFeatureUi(tester);

    expectSharedChrome(switcherVisible: false);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );
  });

  registerHostWorkspacePagingTest();

  testWidgets(
    'Host edit content is centered, capped, and reveals stable keys',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(900, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final ownedClub = buildClub(
        id: 'wide-club',
        name: 'Wide Club',
        ownerUserId: _hostUid,
      );

      await _pumpHostScreen(
        tester,
        const HostClubsScreen(
          initialExpandedEditField: HostClubEditFieldKeys.description,
        ),
        overrides: [
          ..._hostClubOverrides(owned: [ownedClub]),
          watchHostPaymentAccountProvider(
            _hostUid,
          ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
        ],
      );

      final editTab = find.byType(HostClubEditTab);
      expect(editTab, findsOneWidget);
      expect(
        tester.getSize(editTab).width,
        closeTo(CatchLayout.maxContentWidth, 0.1),
      );
      expect(tester.getCenter(editTab).dx, closeTo(450, 0.1));
      expect(find.text('0 photos'), findsOneWidget);

      final descriptionEditor = find.byKey(
        const ValueKey('catch-form-text-description'),
      );
      expect(descriptionEditor, findsOneWidget);
      final descriptionField = tester.widget<CatchField>(
        find.descendant(
          of: descriptionEditor,
          matching: find.byType(CatchField),
        ),
      );
      expect(descriptionField.open, isTrue);
    },
  );

  testWidgets('Host club photo picks commit immediately', (tester) async {
    final photoBytes = _testPngBytes();
    final actions = _RecordingHostClubEditActions(
      pickedPhotos: [
        HostPickedClubPhoto(
          image: XFile.fromData(photoBytes, name: 'picked.jpg'),
          bytes: photoBytes,
        ),
      ],
    );
    final club = buildClub(id: 'media-pick', ownerUserId: _hostUid);

    await _pumpHostClubEditTab(tester, club: club, actions: actions);
    final add = find.byKey(OrderedPhotoPickerKeys.addAction('Add photos'));
    await Scrollable.ensureVisible(tester.element(add));
    await tester.tap(add);
    await pumpFeatureUi(tester);

    expect(actions.mediaWrites, hasLength(1));
    expect(actions.mediaWrites.single, hasLength(1));
    expect(actions.mediaWrites.single.single, isA<HostNewClubPhotoInput>());
  });

  testWidgets('Host club photo upload failures stay visible and retry', (
    tester,
  ) async {
    final photoBytes = _testPngBytes();
    final actions = _RecordingHostClubEditActions(
      pickedPhotos: [
        HostPickedClubPhoto(
          image: XFile.fromData(photoBytes, name: 'retry.jpg'),
          bytes: photoBytes,
        ),
      ],
      mediaFailuresRemaining: 1,
    );
    final club = buildClub(id: 'media-retry', ownerUserId: _hostUid);

    await _pumpHostClubEditTab(tester, club: club, actions: actions);
    final add = find.byKey(OrderedPhotoPickerKeys.addAction('Add photos'));
    await Scrollable.ensureVisible(tester.element(add));
    await tester.tap(add);
    await pumpFeatureUi(tester);

    expect(actions.mediaUpdateCalls, 1);
    expect(find.textContaining('Upload failed'), findsWidgets);

    await tester.tap(find.byKey(OrderedPhotoPickerKeys.coverRetryAction));
    await pumpFeatureUi(tester);

    expect(actions.mediaUpdateCalls, 2);
    expect(actions.mediaWrites, hasLength(1));
    expect(actions.mediaWrites.single.single, isA<HostNewClubPhotoInput>());
  });

  testWidgets('Organizer owners can edit the organizer type', (tester) async {
    final actions = _RecordingHostClubEditActions();
    final club = buildClub(id: 'typed-organizer', ownerUserId: _hostUid);

    await _pumpHostClubEditTab(tester, club: club, actions: actions);
    final organizerTypeEditor = find.byKey(
      const ValueKey('catch-form-single-choice-organizerType'),
    );
    await Scrollable.ensureVisible(tester.element(organizerTypeEditor));
    await tester.tap(organizerTypeEditor);
    await pumpFeatureUi(tester);

    final communityChoice = find.widgetWithText(
      CatchFieldChoiceChip,
      'Community',
    );
    expect(communityChoice, findsOneWidget);
    await tester.tap(communityChoice);
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(const ValueKey('catch-field-done')));
    await pumpFeatureUi(tester);

    expect(actions.profileWrites, hasLength(1));
    expect(
      actions.profileWrites.single.toFieldsJson()['organizerType'],
      OrganizerType.community.name,
    );
  });

  testWidgets('Club settings rows push every spoke with the selected club id', (
    tester,
  ) async {
    final club = buildClub(id: 'spoke-club', ownerUserId: _hostUid);
    final destinations = <(Routes, String)>[];
    await _pumpHostScreen(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: HostClubEditTab(
            club: club,
            currentUid: _hostUid,
            isOwner: true,
            onOpenSettingsRoute: (route, clubId) =>
                destinations.add((route, clubId)),
          ),
        ),
      ),
      overrides: _hostClubOverrides(owned: [club]),
    );

    for (final entry in {
      'host-club-settings-event-defaults': Routes.hostClubEventDefaultsScreen,
      'host-club-settings-live-guide': Routes.hostClubLiveGuideScreen,
      'host-club-settings-payments': Routes.hostClubPaymentsScreen,
      'host-club-settings-host-team': Routes.hostClubTeamScreen,
    }.entries) {
      final field = find.byKey(ValueKey(entry.key));
      await Scrollable.ensureVisible(tester.element(field));
      tester.widget<CatchField>(field).onTap!();
    }

    expect(destinations, [
      (Routes.hostClubEventDefaultsScreen, club.id),
      (Routes.hostClubLiveGuideScreen, club.id),
      (Routes.hostClubPaymentsScreen, club.id),
      (Routes.hostClubTeamScreen, club.id),
    ]);
  });

  testWidgets('Club settings spokes are read-only for co-hosts', (
    tester,
  ) async {
    final club = buildClub(
      id: 'cohost-spoke-club',
      hostUserId: 'owner-2',
      hostUserIds: const [_hostUid],
    );
    final overrides = _hostClubOverrides(hosted: [club]);

    await _pumpHostScreen(
      tester,
      HostClubEventDefaultsScreen(clubId: club.id),
      overrides: overrides,
    );
    final topBar = tester.widget<CatchTopBar>(find.byType(CatchTopBar));
    expect(topBar.title, 'Event defaults');
    expect(topBar.subtitle, club.name);
    expect(topBar.leadingType, CatchTopBarLeading.back);
    expect(topBar.divider, isFalse);
    expect(find.byType(CatchRouteScaffold), findsOneWidget);
    expect(find.byType(CatchFieldToggle), findsNothing);
    expect(find.byType(CatchFieldActionBar), findsNothing);
    expect(find.text('Default activity'), findsOneWidget);

    await _pumpHostScreen(
      tester,
      HostClubLiveGuideScreen(clubId: club.id),
      overrides: overrides,
    );
    expect(find.byType(CatchFieldToggle), findsNothing);
    expect(find.byType(CatchFieldActionBar), findsNothing);

    await _pumpHostScreen(
      tester,
      HostClubTeamScreen(clubId: club.id),
      overrides: overrides,
    );
    expect(find.text('Add host'), findsNothing);

    await _pumpHostScreen(
      tester,
      HostClubPaymentsScreen(clubId: club.id),
      overrides: overrides,
    );
    expect(find.text('Owner'), findsOneWidget);
    expect(find.byType(HostPaymentAccountControllerCard), findsNothing);
  });

  testWidgets('Host club photo removal commits immediately', (tester) async {
    final actions = _RecordingHostClubEditActions();
    final club = buildClub(
      id: 'media-remove',
      ownerUserId: _hostUid,
      clubPhotos: [_uploadedClubPhoto('one', position: 0)],
    );

    await _pumpHostClubEditTab(tester, club: club, actions: actions);
    final manage = find.byKey(OrderedPhotoPickerKeys.manageAction);
    await Scrollable.ensureVisible(tester.element(manage));
    await tester.tap(manage);
    await pumpFeatureUi(tester);

    await tester.tap(find.byKey(OrderedPhotoPickerKeys.setCoverAction(0)));
    await pumpFeatureUi(tester);
    await tester.tap(find.text('Remove photo'));
    await pumpFeatureUi(tester);

    expect(actions.mediaWrites, hasLength(1));
    expect(actions.mediaWrites.single, isEmpty);
  });

  testWidgets('Host club photo reorder debounces one immediate commit', (
    tester,
  ) async {
    final actions = _RecordingHostClubEditActions();
    final club = buildClub(
      id: 'media-reorder',
      ownerUserId: _hostUid,
      clubPhotos: [
        _uploadedClubPhoto('one', position: 0),
        _uploadedClubPhoto('two', position: 1),
      ],
    );

    await _pumpHostClubEditTab(tester, club: club, actions: actions);
    tester
        .widget<CreateClubPhotosPicker>(find.byType(CreateClubPhotosPicker))
        .onReorderPhoto!(0, 1);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 399));
    expect(actions.mediaWrites, isEmpty);
    await pumpFeatureUiFor(tester, const Duration(milliseconds: 1));
    await pumpFeatureUi(tester);

    expect(actions.mediaWrites, hasLength(1));
    final reordered = actions.mediaWrites.single
        .whereType<HostExistingClubPhotoInput>()
        .map((input) => input.photo.id)
        .toList();
    expect(reordered, ['two', 'one']);
  });

  testWidgets('Host club tabs preserve independent vertical scroll offsets', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ownedClub = buildClub(
      id: 'offset-club',
      name: 'Offset Club',
      ownerUserId: _hostUid,
      hostProfiles: const [
        ClubHostProfile(
          uid: _hostUid,
          displayName: 'Owner Host',
          role: ClubHostRole.owner,
        ),
        ClubHostProfile(uid: 'cohost-1', displayName: 'Co Host One'),
        ClubHostProfile(uid: 'cohost-2', displayName: 'Co Host Two'),
        ClubHostProfile(uid: 'cohost-3', displayName: 'Co Host Three'),
      ],
    );

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub]),
        watchEventsForClubProvider(
          ownedClub.id,
        ).overrideWithValue(const AsyncData<List<Event>>([])),
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
        hostAnalyticsRepositoryProvider.overrideWithValue(
          _EmptyHostAnalyticsRepository(
            topEvents: List.generate(
              12,
              (index) => _hostAnalyticsEventRow(eventId: 'offset-$index'),
            ),
          ),
        ),
      ],
    );

    final rail = find.byKey(const ValueKey('host-club-tab-rail'));
    final editKey = const PageStorageKey<String>(
      'host-club-offset-club-edit-scroll',
    );
    final insightsKey = const PageStorageKey<String>(
      'host-club-offset-club-insights-scroll',
    );

    ScrollPosition positionFor(PageStorageKey<String> key) => tester
        .state<ScrollableState>(
          find
              .descendant(
                of: find.byKey(key),
                matching: find.byType(Scrollable),
              )
              .first,
        )
        .position;

    await tester.drag(find.byKey(editKey), const Offset(0, -1200));
    await pumpFeatureUi(tester);
    final editOffset = positionFor(editKey).pixels;
    expect(editOffset, greaterThan(0));

    await tester.tap(
      find.descendant(of: rail, matching: find.text('Insights')),
    );
    await pumpFeatureUi(tester);
    expect(positionFor(insightsKey).pixels, 0);
    expect(find.byType(HostClubInsightsPane), findsOneWidget);

    final insightsPosition = positionFor(insightsKey);
    expect(insightsPosition.maxScrollExtent, greaterThan(0));
    insightsPosition.jumpTo(insightsPosition.maxScrollExtent / 2);
    await pumpFeatureUi(tester);
    final insightsOffset = insightsPosition.pixels;
    expect(insightsOffset, greaterThan(0));

    await tester.tap(find.descendant(of: rail, matching: find.text('Edit')));
    await pumpFeatureUi(tester);
    expect(positionFor(editKey).pixels, closeTo(editOffset, 1));

    await tester.tap(
      find.descendant(of: rail, matching: find.text('Insights')),
    );
    await pumpFeatureUi(tester);
    expect(positionFor(insightsKey).pixels, closeTo(insightsOffset, 1));
  });

  testWidgets('Host analytics trend renders every backend bucket', (
    tester,
  ) async {
    final points = List.generate(
      30,
      (index) => HostAnalyticsTrendPoint(
        periodStart: DateTime(2026, 6, index + 1),
        periodEnd: DateTime(2026, 6, index + 2),
        metrics: {'demand': index + 2, 'bookings': index + 1},
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: HostAnalyticsTrendPanel(
            points: points,
            granularity: HostAnalyticsGranularity.week,
          ),
        ),
      ),
    );

    expect(find.byType(HostAnalyticsDualBar), findsNWidgets(30));
    expect(find.byType(CatchSection), findsOneWidget);
  });

  testWidgets('Host analytics loading uses canonical section rhythm', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(child: HostAnalyticsReportSkeleton()),
        ),
      ),
    );

    final stack = tester.widget<CatchSectionStack>(
      find.byType(CatchSectionStack),
    );
    expect(stack.gap, 0);
    expect(find.byType(CatchSection), findsNWidgets(4));
  });
}
