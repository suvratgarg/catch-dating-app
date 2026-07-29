import 'dart:convert';
import 'dart:typed_data';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_tabbed_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/ordered_photo_picker.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_defaults.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_date_rail_card.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/data/host_profile_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/create/widgets/create_club_photos_picker.dart';
import 'package:catch_dating_app/hosts/presentation/club_management/host_club_edit_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_home_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_team_workspace_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_team_workspace_view_model.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_card.dart';
import 'package:catch_dating_app/hosts/presentation/payments/host_payment_account_controller_card.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/l10n/generated/app_localizations_en.dart';
import 'package:catch_dating_app/payments/data/host_payment_account_repository.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../clubs/clubs_test_helpers.dart';
import '../test_pump_helpers.dart';

part 'host_operations_state_events_tests.dart';
part 'host_operations_club_workspace_tests.dart';
part 'host_operations_analytics_team_tests.dart';
part 'host_operations_team_failures_tests.dart';

const _hostUid = 'host-1';
final _l10n = AppLocalizationsEn();

void main() {
  setUp(() {
    AppConfig.configureEntrypointRole(AppRole.host);
  });

  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  _registerHostOperationsStateEventsTests();
  _registerHostOperationsClubWorkspaceTests();
  _registerHostOperationsAnalyticsTeamTests();
  _registerHostOperationsTeamFailuresTests();
}

Future<void> _editHostTeamProfileField(
  WidgetTester tester, {
  required String title,
  required String value,
}) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == title,
  );
  await tester.ensureVisible(field);
  await tester.tap(field);
  await pumpFeatureUi(tester);
  final input = find.descendant(of: field, matching: find.byType(TextField));
  expect(input, findsOneWidget);
  await tester.enterText(input, value);
  await tester.tap(find.byKey(const ValueKey('catch-field-done')));
  await pumpFeatureUi(tester);
}

Club _hostTeamClub() => buildClub(
  id: 'owned-club',
  name: 'Saket Run Club',
  ownerUserId: _hostUid,
  hostProfiles: const [
    ClubHostProfile(
      uid: _hostUid,
      displayName: 'Catch Host',
      role: ClubHostRole.owner,
    ),
  ],
);

Club _hostTeamClubWithoutProfile() => buildClub(
  id: 'owned-club',
  name: 'Saket Run Club',
  hostUserId: 'other-host',
  ownerUserId: 'other-host',
  hostProfiles: const [],
);

List _hostClubOverrides({
  List<Club> owned = const [],
  List<Club> hosted = const [],
}) {
  return [
    uidProvider.overrideWith((ref) => Stream.value(_hostUid)),
    watchClubsOwnedByProvider(
      _hostUid,
    ).overrideWithValue(AsyncData<List<Club>>(owned)),
    watchClubsHostedByProvider(
      _hostUid,
    ).overrideWithValue(AsyncData<List<Club>>(hosted)),
  ];
}

ClubDetailViewModel _previewViewModel(
  Club club, {
  List<Event> events = const [],
}) {
  return ClubDetailViewModel(
    club: club,
    isHost: true,
    isMember: true,
    upcomingEvents: events,
    reviews: const [],
    userProfile: buildUser(uid: _hostUid),
    uid: _hostUid,
    isAuthenticated: true,
  );
}

Future<void> _pumpHostScreen(
  WidgetTester tester,
  Widget child, {
  List overrides = const [],
  bool settle = true,
}) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => child),
      GoRoute(
        path: Routes.hostOrganizerScreen.path,
        name: Routes.hostOrganizerScreen.name,
        builder: (_, _) => const Text('Organizer route'),
      ),
      GoRoute(
        path: Routes.hostCreateClubScreen.path,
        name: Routes.hostCreateClubScreen.name,
        builder: (_, _) => const Text('Create club route'),
      ),
      GoRoute(
        path: Routes.hostCreateEventScreen.path,
        name: Routes.hostCreateEventScreen.name,
        builder: (_, state) => switch (state.extra) {
          final HostCreateEventRouteArguments arguments
              when arguments.initialPrefill != null =>
            Text('Repeat ${arguments.initialPrefill!.sourceEventId}'),
          _ => Text('Create ${state.pathParameters['clubId']}'),
        },
      ),
      GoRoute(
        path: Routes.hostClubTeamScreen.path,
        name: Routes.hostClubTeamScreen.name,
        builder: (_, state) => HostClubTeamScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostClubDetailScreen.path,
        name: Routes.hostClubDetailScreen.name,
        builder: (_, state) => Text('Club ${state.pathParameters['clubId']}'),
      ),
      GoRoute(
        path: Routes.hostEditClubScreen.path,
        name: Routes.hostEditClubScreen.name,
        builder: (_, state) => Text('Edit ${state.pathParameters['clubId']}'),
      ),
      GoRoute(
        path: Routes.hostClubEventDefaultsScreen.path,
        name: Routes.hostClubEventDefaultsScreen.name,
        builder: (_, state) => HostClubEventDefaultsScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostClubLiveGuideScreen.path,
        name: Routes.hostClubLiveGuideScreen.name,
        builder: (_, state) => HostClubLiveGuideScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostClubPaymentsScreen.path,
        name: Routes.hostClubPaymentsScreen.name,
        builder: (_, state) => HostClubPaymentsScreen(
          clubId: state.uri.queryParameters['clubId'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.hostAppEventManageScreen.path,
        name: Routes.hostAppEventManageScreen.name,
        builder: (_, state) => Column(
          children: [
            Text('Manage ${state.pathParameters['eventId']}'),
            Text('Section ${state.uri.queryParameters['section'] ?? 'setup'}'),
          ],
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  if (settle) {
    await pumpFeatureUi(tester);
  } else {
    await tester.pump();
    await tester.pump();
  }
}

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

class _RecordingHostClubEditActions implements HostClubEditActions {
  _RecordingHostClubEditActions({this.pickedPhotos = const []});

  final List<HostPickedClubPhoto> pickedPhotos;
  final List<UpdateClubPatch> profileWrites = [];
  final List<List<HostClubMediaInput>> mediaWrites = [];

  @override
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {
    profileWrites.add(patch);
  }

  @override
  Future<List<HostPickedClubPhoto>> pickClubPhotos({
    required int limit,
  }) async => pickedPhotos.take(limit).toList(growable: false);

  @override
  Future<HostPickedClubLogo?> pickClubLogo() async => null;

  @override
  Future<void> updateClubMedia({
    required Club club,
    List<HostClubMediaInput>? photoInputs,
    HostPickedClubLogo? logo,
  }) async {
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
