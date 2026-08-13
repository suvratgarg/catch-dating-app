part of '../host_operations_screen_test.dart';

Finder _hostEventsScrollable() => find.descendant(
  of: find.byKey(const ValueKey<String>('host-events-scroll-view')),
  matching: find.byType(Scrollable),
);

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
        watchHostPaymentAccountProvider(
          _hostUid,
        ).overrideWithValue(const AsyncData<HostPaymentAccount?>(null)),
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
    expect(find.byType(HostAudiencePane), findsOneWidget);
    expect(find.byType(HostClubEditTab), findsNothing);

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
    expect(find.byType(HostAudiencePane), findsOneWidget);

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
  Future<void> updateClubMedia({
    required Club club,
    List<HostClubMediaInput>? photoInputs,
    HostPickedClubLogo? logo,
    bool removeLogo = false,
  }) async {
    mediaUpdateCalls += 1;
    removeLogoWrites.add(removeLogo);
    if (mediaFailuresRemaining > 0) {
      mediaFailuresRemaining -= 1;
      throw StateError('media update failed');
    }
    if (photoInputs != null) {
      mediaWrites.add(List<HostClubMediaInput>.of(photoInputs));
    }
  }
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
}) {
  final organizerIds = {
    ...owned.map((club) => club.id),
    ...hosted.map((club) => club.id),
  };
  return [
    uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
    watchClubsOwnedByProvider(
      _hostUid,
    ).overrideWithValue(AsyncData<List<Club>>(owned)),
    watchClubsHostedByProvider(
      _hostUid,
    ).overrideWithValue(AsyncData<List<Club>>(hosted)),
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
            sourceCoverage: HostAudienceSourceCoverage.exact,
            projectionVersion: 1,
          ),
        ),
      ),
    for (final organizerId in organizerIds)
      hostMessagingSetupProvider(organizerId).overrideWithValue(
        AsyncData(
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
