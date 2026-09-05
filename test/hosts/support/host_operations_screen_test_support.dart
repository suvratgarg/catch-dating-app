part of '../host_operations_screen_test.dart';

Finder _hostEventsScrollable() => find
    .descendant(
      of: find.byType(HostEventsTimelinePage),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    )
    .hitTestable();

void registerHostEventEntryTests() {
  testWidgets('Host Today delegates creation and opens event manage', (
    tester,
  ) async {
    final club = buildClub(id: 'club-host', ownerUserId: _hostUid);
    final event = buildEvent(
      id: 'event-host',
      clubId: club.id,
      startTime: DateTime(2026, 6, 15, 17),
    );

    await _pumpHostScreen(
      tester,
      HostTodayScreen(now: DateTime(2026, 6, 15, 12)),
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

    expect(find.text('Today'), findsOneWidget);
    expect(find.byTooltip('Create organizer'), findsNothing);
    expect(find.byTooltip('Switch organizer'), findsNothing);
    expect(find.text('Create event'), findsNothing);
    final header = tester.widget<CatchScreenHeaderTitle>(
      find.byType(CatchScreenHeaderTitle),
    );
    expect(header.eyebrow, 'Monday, June 15, 2026');
    expect(header.subtitle, isNull);
    expect(header.actions, isEmpty);
    expect(
      find.byKey(const ValueKey<String>('host-today-create-event')),
      findsNothing,
    );
    expect(find.text('Use guest list'), findsNothing);

    expect(
      tester
          .widget<HostTodayEventSpotlight>(find.byType(HostTodayEventSpotlight))
          .event,
      event,
    );
    await tester.tap(find.text('Continue setup'));
    await pumpFeatureUi(tester);

    expect(find.text('Manage ${event.id}'), findsOneWidget);
    expect(find.text('Section setup'), findsOneWidget);
  });

  testWidgets('Host Today owns the dedicated dress rehearsal entry point', (
    tester,
  ) async {
    final club = buildClub(id: 'rehearsal-club', ownerUserId: _hostUid);

    await _pumpHostScreen(
      tester,
      HostTodayScreen(now: DateTime(2026, 6, 15, 12)),
      overrides: [
        ..._hostClubOverrides(owned: [club]),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(const AsyncData<List<Event>>([])),
      ],
    );

    final rehearsalAction = find.byKey(
      const ValueKey<String>('host-today-start-dress-rehearsal'),
    );
    expect(rehearsalAction, findsOneWidget);
    await tester.tap(rehearsalAction);
    await pumpFeatureUi(tester);
    expect(
      find.text('Rehearse rehearsal-club event=null source=custom'),
      findsOneWidget,
    );
  });

  testWidgets('Host Today opens the rehearsal starting-point sheet', (
    tester,
  ) async {
    final club = buildClub(id: 'choice-club', ownerUserId: _hostUid);
    final event = buildEvent(
      id: 'choice-event',
      clubId: club.id,
      bookedCount: 24,
      startTime: DateTime(2026, 6, 15, 17),
    ).copyWith(name: 'Wednesday Trivia Night');

    await _pumpHostScreen(
      tester,
      HostTodayScreen(now: DateTime(2026, 6, 15, 12)),
      overrides: [
        ..._hostClubOverrides(
          owned: [club],
          timelineEventsByOrganizer: {
            club.id: [event],
          },
        ),
      ],
    );

    expect(
      find.byKey(const ValueKey<String>('host-today-start-dress-rehearsal')),
      findsNothing,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('host-today-rehearse-event')),
    );
    await pumpFeatureUi(tester);

    expect(find.byType(EventRehearsalStartSheet), findsOneWidget);
    expect(find.text('Start dress rehearsal'), findsOneWidget);
    expect(find.text('Choose a starting point'), findsOneWidget);
    expect(find.text('Rehearse Wednesday Trivia Night'), findsOneWidget);
    expect(find.text('Create a custom rehearsal'), findsOneWidget);

    await tester.tap(find.text('Rehearse Wednesday Trivia Night'));
    await pumpFeatureUi(tester);
    expect(
      find.text('Rehearse choice-club event=choice-event source=null'),
      findsOneWidget,
    );
  });

  testWidgets('Host Events resumes a loaded draft without a second lookup', (
    tester,
  ) async {
    final club = buildClub(id: 'draft-club', ownerUserId: _hostUid);
    final draft = EventDraft(
      id: 'draft-one',
      clubId: club.id,
      savedAt: DateTime(2026, 6, 15, 10),
      customActivityLabel: 'Quiz night',
    );

    await _pumpHostScreen(
      tester,
      HostEventsScreen(now: DateTime(2026, 6, 15, 12)),
      overrides: [
        ..._hostClubOverrides(
          owned: [club],
          draftsByOrganizer: {
            club.id: [draft],
          },
        ),
        watchEventsForClubProvider(
          club.id,
        ).overrideWithValue(const AsyncData<List<Event>>([])),
      ],
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('host-events-create-event')),
    );
    await pumpFeatureUi(tester);
    expect(find.text('Continue draft'), findsOneWidget);
    expect(find.text('Quiz night'), findsOneWidget);
    final eventEntrySheet = find.byKey(
      const ValueKey<String>('host-event-entry-sheet'),
    );
    expect(
      find.descendant(of: eventEntrySheet, matching: find.byType(CatchSection)),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: eventEntrySheet,
        matching: find.byType(CatchSectionFocusSurface),
      ),
      findsOneWidget,
    );
    expect(find.text('CONTINUE'), findsOneWidget);
    expect(find.text('START NEW'), findsOneWidget);

    await tester.tap(find.text('Continue draft'));
    await pumpFeatureUi(tester);
    expect(find.text('Draft draft-one'), findsOneWidget);
  });
}

void registerHostWorkspacePagingTest() {
  testWidgets('Host club workspace uses native horizontal tab paging', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final ownedClub = buildClub(
      id: 'paged-club',
      name: 'Paged Club',
      ownerUserId: _hostUid,
    );

    await _pumpHostScreen(
      tester,
      const HostClubsScreen(),
      overrides: [
        ..._hostClubOverrides(owned: [ownedClub]),
        watchEventsForClubProvider(
          ownedClub.id,
        ).overrideWithValue(const AsyncData<List<Event>>([])),
        clubDetailViewModelProvider(ownedClub.id).overrideWithValue(
          AsyncData<ClubDetailViewModel?>(_previewViewModel(ownedClub)),
        ),
        watchHostPaymentAccountsProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<List<HostPaymentAccount>>([])),
        hostAnalyticsRepositoryProvider.overrideWithValue(
          const _EmptyHostAnalyticsRepository(),
        ),
      ],
    );

    final pager = find.byType(TabBarView);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );
    expect(find.byType(HostClubEditTab), findsOneWidget);
    expect(find.byType(HostClubInsightsPane), findsNothing);

    await tester.drag(pager, const Offset(-320, 0));
    await pumpFeatureUi(tester);
    expect(find.byType(HostClubInsightsPane), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsOneWidget,
    );
    expect(find.byType(HostClubEditTab), findsNothing);

    await tester.drag(pager, const Offset(-320, 0));
    await pumpFeatureUi(tester);
    expect(
      find.byKey(const ValueKey('club-detail-hero-module')),
      findsOneWidget,
    );
    expect(find.text('Open public preview'), findsNothing);

    await tester.drag(pager, const Offset(320, 0));
    await pumpFeatureUi(tester);
    expect(find.byType(HostClubInsightsPane), findsOneWidget);

    await tester.drag(pager, const Offset(320, 0));
    await pumpFeatureUi(tester);
    expect(find.byType(HostClubEditTab), findsOneWidget);
    expect(
      find.byKey(const ValueKey('host-club-insights-summary')),
      findsNothing,
    );
  });
}

class _RecordingHostClubEditActions implements HostClubEditActions {
  _RecordingHostClubEditActions({
    this.pickedPhotos = const [],
    this.mediaFailuresRemaining = 0,
  });

  final List<HostPickedClubPhoto> pickedPhotos;
  final List<UpdateClubPatch> profileWrites = [];
  final List<List<HostClubMediaInput>> mediaWrites = [];
  int mediaFailuresRemaining;
  int mediaUpdateCalls = 0;
  final List<bool> removeLogoWrites = [];

  @override
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {
    profileWrites.add(patch);
  }

  @override
  Future<List<HostPickedClubPhoto>> pickClubPhotos({int? limit}) async =>
      limit == null
      ? pickedPhotos
      : pickedPhotos.take(limit).toList(growable: false);

  @override
  Future<HostPickedClubLogo?> pickClubLogo() async => null;

  @override
  Future<HostClubMediaSaveResult> updateClubMedia({
    required Club club,
    List<HostClubMediaInput>? photoInputs,
    HostPickedClubLogo? logo,
    bool removeLogo = false,
    ValueChanged<HostClubMediaProgress>? onProgress,
  }) async {
    mediaUpdateCalls += 1;
    removeLogoWrites.add(removeLogo);
    if (mediaFailuresRemaining > 0) {
      mediaFailuresRemaining -= 1;
      final error = StateError('media update failed');
      final newInputs =
          photoInputs?.whereType<HostNewClubPhotoInput>().toList() ?? const [];
      final failedId = newInputs.isEmpty ? null : newInputs.first.id;
      return HostClubMediaSaveResult(
        photoInputs: photoInputs,
        logo: logo,
        failures: {?failedId: error},
        attached: false,
      );
    }
    if (photoInputs != null) {
      mediaWrites.add(List<HostClubMediaInput>.of(photoInputs));
    }
    return HostClubMediaSaveResult(
      photoInputs: photoInputs,
      logo: logo,
      failures: const {},
      attached: true,
    );
  }

  @override
  Future<void> discardClubMedia({
    required List<HostClubMediaInput> photoInputs,
    HostPickedClubLogo? logo,
  }) async {}
}

class _FakeHostProfileRepository implements HostProfileRepository {
  _FakeHostProfileRepository({
    this.profile,
    this.throwOnEnsure = false,
    this.throwOnSave = false,
  });

  HostProfile? profile;
  final bool throwOnEnsure;
  final bool throwOnSave;
  String? ensuredUid;
  String? savedUid;
  String? savedDisplayName;
  String? savedRoleTitle;
  String? savedBio;

  @override
  Stream<HostProfile?> watchHostProfile(String uid) => Stream.value(profile);

  @override
  Future<void> ensureHostProfile({
    required String uid,
    required String displayName,
  }) async {
    if (throwOnEnsure) throw StateError('create failed');
    ensuredUid = uid;
  }

  @override
  Future<void> saveHostProfile({
    required String uid,
    required String displayName,
    String? roleTitle,
    String? bio,
  }) async {
    if (throwOnSave) throw StateError('save failed');
    savedUid = uid;
    savedDisplayName = displayName;
    savedRoleTitle = roleTitle;
    savedBio = bio;
  }
}

class _FakeHostAuthRepository extends Fake implements AuthRepository {
  _FakeHostAuthRepository({this.throwOnSignOut = false});

  final bool throwOnSignOut;
  int signOutCallCount = 0;

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
    if (throwOnSignOut) throw StateError('sign out failed');
  }
}

final class _EmptyHostAnalyticsRepository implements HostAnalyticsRepository {
  const _EmptyHostAnalyticsRepository({this.topEvents = const []});

  final List<HostAnalyticsEventRow> topEvents;

  @override
  Future<HostAnalyticsReport> getHostAnalytics(HostAnalyticsQuery query) async {
    return HostAnalyticsReport(
      generatedAt: DateTime(2026, 7, 10),
      summaryCards: const [],
      trend: const [],
      topEvents: topEvents,
      reviewSummary: const HostAnalyticsReviewSummary(
        newReviews: 0,
        publishedReviews: 0,
        verifiedReviews: 0,
        publicReviews: 0,
        ownerResponseCount: 0,
        averageRating: 0,
      ),
      discoverySummary: const HostAnalyticsDiscoverySummary(
        listingViews: 0,
        searchAppearances: 0,
        eventViews: 0,
        organizerSaves: 0,
        eventSaves: 0,
        contactClicks: 0,
        claimClicks: 0,
        outboundClicks: 0,
      ),
      dataQuality: const [],
    );
  }
}

HostAnalyticsEventRow _hostAnalyticsEventRow({required String eventId}) =>
    HostAnalyticsEventRow(
      eventId: eventId,
      clubId: 'exact-club',
      title: 'Top event',
      startTime: DateTime(2026, 7, 8, 19),
      status: 'completed',
      bookedCount: 20,
      checkedInCount: 18,
      waitlistedCount: 2,
      fillRate: 1,
      checkInRate: 0.9,
      grossRevenueMinor: 0,
      currency: 'INR',
      checkoutStartedCount: 0,
      checkoutDropoffCount: 0,
      paymentCompletedCount: 0,
      paymentFailedCount: 0,
      paymentRefundedCount: 0,
      reviewCount: 2,
      averageRating: 4.5,
      demandCount: 24,
      inviteOpenCount: 3,
      mutualMatchCount: 4,
      chatStartedCount: 2,
      repeatAttendeeCount: 5,
    );

List _hostClubOverrides({
  List<Club> owned = const [],
  List<Club> hosted = const [],
  Map<String, List<EventDraft>> draftsByOrganizer = const {},
  Map<String, List<Event>> timelineEventsByOrganizer = const {},
  Map<String, HostMessagingSetup> messagingSetupByOrganizer = const {},
}) {
  final organizerIds = {
    ...owned.map((club) => club.id),
    ...hosted.map((club) => club.id),
  };
  return [
    eventRepositoryProvider.overrideWithValue(
      _FixedHostEventRepository(timelineEventsByOrganizer),
    ),
    hostTodayFeedControllerProvider.overrideWith2(
      (_) => _FixedHostTodayFeedController(timelineEventsByOrganizer),
    ),
    hostEventsTimelineControllerProvider.overrideWith2(
      (_) => _FixedHostEventsTimelineController(timelineEventsByOrganizer),
    ),
    uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
    watchClubsOwnedByProvider(
      _hostUid,
    ).overrideWithValue(AsyncData<List<Club>>(owned)),
    watchClubsHostedByProvider(
      _hostUid,
    ).overrideWithValue(AsyncData<List<Club>>(hosted)),
    for (final organizerId in organizerIds)
      clubEventDraftsProvider(clubId: organizerId).overrideWithValue(
        AsyncData<List<EventDraft>>(
          draftsByOrganizer[organizerId] ?? const <EventDraft>[],
        ),
      ),
    for (final organizerId in organizerIds)
      hostCrmSummaryProvider(
        organizerId,
      ).overrideWithValue(AsyncData(_emptyCrmSummary(organizerId))),
    for (final organizerId in organizerIds)
      hostAudienceProvider(
        organizerId,
        const HostAudienceQuery(),
      ).overrideWithValue(
        AsyncData(
          HostAudiencePage(
            organizerId: organizerId,
            contacts: const [],
            nextCursor: null,
            matchCount: 0,
            matchCountCoverage: HostAudienceMatchCountCoverage.exact,
            sourceCoverage: HostAudienceSourceCoverage.exact,
            projectionVersion: 1,
          ),
        ),
      ),
    for (final organizerId in organizerIds)
      hostMessagingSetupProvider(organizerId).overrideWithValue(
        AsyncData(
          messagingSetupByOrganizer[organizerId] ??
              HostMessagingSetup(
                organizerId: organizerId,
                providerConfigured: false,
                embeddedSignup: const HostWhatsappEmbeddedSignupConfig(
                  appId: null,
                  configId: null,
                  graphVersion: null,
                ),
                connection: null,
                templates: const [],
              ),
        ),
      ),
  ];
}

class _FixedHostEventRepository extends Fake implements EventRepository {
  _FixedHostEventRepository(this.eventsByOrganizer);

  final Map<String, List<Event>> eventsByOrganizer;

  @override
  Future<CursorPage<Event, DocumentSnapshot<Event>>> fetchActiveEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) async {
    final events = eventsByOrganizer[organizerId] ?? const <Event>[];
    return CursorPage(
      items: events
          .where((event) => event.endTime.isAfter(sessionBoundary))
          .take(limit)
          .toList(growable: false),
      hasMore: false,
    );
  }

  @override
  Future<CursorPage<Event, DocumentSnapshot<Event>>> fetchPastEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) async {
    final events = eventsByOrganizer[organizerId] ?? const <Event>[];
    return CursorPage(
      items: events
          .where((event) => !event.endTime.isAfter(sessionBoundary))
          .take(limit)
          .toList(growable: false),
      hasMore: false,
    );
  }
}

class _FixedHostTodayFeedController extends HostTodayFeedController {
  _FixedHostTodayFeedController(this.eventsByOrganizer);

  final Map<String, List<Event>> eventsByOrganizer;

  @override
  Future<HostTodayFeedData> build(HostTodayFeedRequest request) async {
    final events = eventsByOrganizer[request.organizerId] ?? const <Event>[];
    final activeEvents = events
        .where((event) => event.endTime.isAfter(request.sessionBoundary))
        .toList(growable: false);
    return HostTodayFeedData(
      activeEvents: activeEvents,
      pastEvents: events
          .where((event) => !event.endTime.isAfter(request.sessionBoundary))
          .toList(growable: false),
      attentionItems: _fixedAttentionItems(
        activeEvents,
        request.sessionBoundary,
      ),
      localAttendanceMerged: true,
    );
  }
}

List<HostAttentionItem> _fixedAttentionItems(
  Iterable<Event> events,
  DateTime now,
) => [
  for (final event in events)
    if (event.waitlistCount > 0 &&
        !event.effectiveEventPolicy.admissionPolicy.manualApprovalRequired)
      HostAttentionItem(
        id: 'attention-${event.id}',
        kind: HostAttentionKind.eventWaitlistReview,
        scope: HostAttentionScope.event,
        sourceOwner: HostAttentionSourceOwner.events,
        sourceId: event.id,
        sourceRevision: 'fixture-${event.waitlistCount}',
        eventId: event.id,
        status: HostAttentionStatus.open,
        consequence: HostAttentionConsequence.risksGuestExperience,
        blocking: false,
        urgency: event.startTime.difference(now) <= const Duration(hours: 24)
            ? HostAttentionUrgency.immediate
            : event.startTime.difference(now) <= const Duration(hours: 72)
            ? HostAttentionUrgency.soon
            : HostAttentionUrgency.upcoming,
        destination: HostAttentionDestination(
          route: HostAttentionDestinationRoute.hostEventManage,
          section: 'guests',
          eventId: event.id,
        ),
        context: HostAttentionContext(
          eventName: event.title,
          count: event.waitlistCount,
        ),
        dedupeKey: 'eventWaitlistReview:${event.id}',
        policyVersion: 1,
        resolutionVersion: 1,
        assignedHostUid: null,
        openedAt: now,
        dueAt: event.startTime.subtract(const Duration(hours: 24)),
        expiresAt: event.endTime,
      ),
];

class _FixedHostEventsTimelineController extends HostEventsTimelineController {
  _FixedHostEventsTimelineController(this.eventsByOrganizer);

  final Map<String, List<Event>> eventsByOrganizer;

  @override
  Future<HostEventsTimelineData> build(
    HostEventsTimelineRequest request,
  ) async {
    final events = eventsByOrganizer[request.organizerId] ?? const <Event>[];
    return HostEventsTimelineData(
      activeEvents: events
          .where((event) => event.endTime.isAfter(request.sessionBoundary))
          .toList(growable: false),
      pastEvents: events
          .where((event) => !event.endTime.isAfter(request.sessionBoundary))
          .toList(growable: false),
      activeCursor: null,
      pastCursor: null,
      hasMoreActive: false,
      hasMorePast: false,
    );
  }
}

HostCrmSummary _emptyCrmSummary(String organizerId) => HostCrmSummary(
  organizerId: organizerId,
  contactCount: 0,
  pastAttendeeCount: 0,
  repeatAttendeeCount: 0,
  linkedAccountCount: 0,
  importedContactCount: 0,
  whatsappOptInCount: 0,
  smsOptInCount: 0,
  truncated: false,
  inAppReadiness: HostCrmChannelReadiness.currentEventOnly,
  whatsappReadiness: HostCrmChannelReadiness.providerSetupRequired,
  smsReadiness: HostCrmChannelReadiness.providerAndDltSetupRequired,
);

Club _hostTeamClubWithoutProfile() => buildClub(
  id: 'owned-club',
  name: 'Saket Run Club',
  hostUserId: 'other-host',
  ownerUserId: 'other-host',
  hostProfiles: const [],
);

Future<void> _pumpHostClubEditTab(
  WidgetTester tester, {
  required Club club,
  required HostClubEditActions actions,
}) {
  return _pumpHostScreen(
    tester,
    Scaffold(
      body: SingleChildScrollView(
        child: HostClubEditTab(club: club, currentUid: _hostUid, isOwner: true),
      ),
    ),
    overrides: [hostClubEditControllerProvider.overrideWithValue(actions)],
  );
}

UploadedPhoto _uploadedClubPhoto(String id, {required int position}) {
  final timestamp = DateTime(2026);
  return UploadedPhoto(
    id: id,
    url: 'https://example.test/$id.jpg',
    storagePath: 'clubs/test/$id.jpg',
    position: position,
    createdAt: timestamp,
    updatedAt: timestamp,
  );
}

Uint8List _testPngBytes() => base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUl'
  'EQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==',
);

class _EmptyHostCustomersDirectoryController
    extends HostCustomersDirectoryController {
  _EmptyHostCustomersDirectoryController(this.requests);

  final List<HostCustomersDirectoryRequest> requests;

  @override
  Future<HostCustomersDirectoryState> build(
    HostCustomersDirectoryRequest request,
  ) async {
    requests.add(request);
    return const HostCustomersDirectoryState(
      contacts: [],
      nextCursor: null,
      matchCount: 0,
      matchCountCoverage: HostCustomerMatchCountCoverage.exact,
      sourceCoverage: HostCustomerDirectoryCoverage.exact,
      projectionVersion: 1,
    );
  }
}
