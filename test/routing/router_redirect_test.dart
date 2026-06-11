import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/profile_readiness_fixtures.dart';

const _testUid = 'user-1';

UserProfile _socialReadyUser() => buildSocialReadyUser(uid: _testUid);

UserProfile _identityIncompleteUser() => UserProfile(
  uid: _testUid,
  name: 'New Runner',
  dateOfBirth: DateTime(1995, 6, 15),
  gender: Gender.man,
  phoneNumber: '+910000000000',
  profileComplete: false,
);

UserProfile _bookingReadyUser() =>
    buildBookingReadyIncompleteUser(uid: _testUid);

String? _redirect({
  required AsyncValue<String?> uidAsync,
  required AsyncValue<UserProfile?> userProfileAsync,
  required String location,
  bool hasPendingAuthVerification = false,
  String? matchedLocation,
}) {
  final uri = Uri.parse(location);
  return appRedirect(
    uidAsync: uidAsync,
    userProfileAsync: userProfileAsync,
    hasPendingAuthVerification: hasPendingAuthVerification,
    matchedLocation: matchedLocation ?? uri.path,
    uri: uri,
  );
}

void main() {
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  group('route role boundary', () {
    test('host management routes are not available to consumer role', () {
      final hostRoutes = Routes.values.where(
        (route) => route.path.startsWith('/host'),
      );

      expect(hostRoutes, isNotEmpty);
      for (final route in hostRoutes) {
        expect(
          routeAvailableForAppRole(route, AppRole.consumer),
          isFalse,
          reason: '${route.name} should stay host-app only.',
        );
        expect(routeAvailableForAppRole(route, AppRole.host), isTrue);
      }
    });

    test('consumer in-app event deep links stay on consumer event routes', () {
      expect(
        AppDeepLinks.inAppEventPath(
          clubId: 'club-1',
          eventId: 'event-1',
          appRole: AppRole.consumer,
        ),
        '/clubs/club-1/events/event-1',
      );
      expect(
        AppDeepLinks.inAppEventPath(
          clubId: 'club-1',
          eventId: 'event-1',
          appRole: AppRole.host,
        ),
        '/host/clubs/club-1/events/event-1',
      );
    });
  });

  group('appRedirect', () {
    test(
      'unauthenticated users are sent to the start screen with the pending route',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(null),
            userProfileAsync: const AsyncData(null),
            location: '/chats/match-1',
            matchedLocation: Routes.chatScreen.path,
          ),
          '/start?from=%2Fchats%2Fmatch-1',
        );
      },
    );

    test('unauthenticated users can stay on the start screen', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/start',
          matchedLocation: Routes.startScreen.path,
        ),
        null,
      );
    });

    test('unauthenticated users can browse the clubs list', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/clubs',
          matchedLocation: Routes.clubsListScreen.path,
        ),
        null,
      );
    });

    test('unauthenticated users can open the dev event policy lab', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/dev/event-policy-lab',
          matchedLocation: Routes.eventPolicyLabScreen.path,
        ),
        null,
      );
    });

    test('unauthenticated users can open the dev event success lab', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/dev/event-success-lab',
          matchedLocation: Routes.eventSuccessLabScreen.path,
        ),
        null,
      );
    });

    test(
      'legacy unauthenticated onboarding links move to start and preserve from',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(null),
            userProfileAsync: const AsyncData(null),
            location: '/onboarding?from=%2Fclubs%2Fclub-1',
            matchedLocation: Routes.onboardingScreen.path,
          ),
          '/start?from=%2Fclubs%2Fclub-1',
        );
      },
    );

    test(
      'authenticated users without a profile doc are sent to onboarding',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(_testUid),
            userProfileAsync: const AsyncData(null),
            location: '/clubs',
            matchedLocation: Routes.clubsListScreen.path,
          ),
          '/onboarding?from=%2Fclubs',
        );
      },
    );

    test('club detail deep links are accessible to unauthenticated users', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/clubs/club-1',
          matchedLocation: Routes.clubDetailScreen.path,
        ),
        null,
      );
    });

    test('event detail deep links are accessible to unauthenticated users', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/clubs/club-1/events/event-1',
          matchedLocation: Routes.eventDetailScreen.path,
        ),
        null,
      );
    });

    test(
      'identity-incomplete profiles stay in onboarding and preserve the pending route',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(_testUid),
            userProfileAsync: AsyncData(_identityIncompleteUser()),
            location: '/auth?from=%2Fchats%2Fmatch-1',
            matchedLocation: Routes.authScreen.path,
          ),
          '/onboarding?from=%2Fchats%2Fmatch-1',
        );
      },
    );

    test(
      'booking-ready users can access event routes without a social-ready profile',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(_testUid),
            userProfileAsync: AsyncData(_bookingReadyUser()),
            location: '/clubs/club-1/events/event-1',
            matchedLocation: Routes.eventDetailScreen.path,
          ),
          null,
        );
      },
    );

    test('booking-ready users are sent to profile completion for catches', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(_testUid),
          userProfileAsync: AsyncData(_bookingReadyUser()),
          location: '/catches/event-1?tab=recent',
          matchedLocation: Routes.swipeEventScreen.path,
        ),
        '/onboarding?intent=complete-profile&from=%2Fcatches%2Fevent-1%3Ftab%3Drecent',
      );
    });

    test('profile-completion onboarding is allowed until social ready', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(_testUid),
          userProfileAsync: AsyncData(_bookingReadyUser()),
          location:
              '/onboarding?intent=complete-profile&from=%2Fcatches%2Fevent-1',
          matchedLocation: Routes.onboardingScreen.path,
        ),
        null,
      );
    });

    test(
      'run-preference onboarding is allowed until run preferences are ready',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(_testUid),
            userProfileAsync: AsyncData(
              _socialReadyUser().copyWith(
                activityPreferences: const ActivityPreferences(),
              ),
            ),
            location:
                '/onboarding?intent=complete-run-preferences&from=%2Fclubs%2Fclub-1%2Fevents%2Fevent-1',
            matchedLocation: Routes.onboardingScreen.path,
          ),
          null,
        );
      },
    );

    test('run-preference onboarding resumes once run preferences are ready', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(_testUid),
          userProfileAsync: AsyncData(_socialReadyUser()),
          location:
              '/onboarding?intent=complete-run-preferences&from=%2Fclubs%2Fclub-1%2Fevents%2Fevent-1',
          matchedLocation: Routes.onboardingScreen.path,
        ),
        '/clubs/club-1/events/event-1',
      );
    });

    test('loading auth state routes through the loading screen', () {
      expect(
        _redirect(
          uidAsync: const AsyncLoading(),
          userProfileAsync: const AsyncLoading(),
          location: '/catches/event-1?tab=recent',
          matchedLocation: Routes.swipeEventScreen.path,
        ),
        '/loading?from=%2Fcatches%2Fevent-1%3Ftab%3Drecent',
      );
    });

    test(
      'fully set-up users resume the preserved destination from onboarding',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(_testUid),
            userProfileAsync: AsyncData(_socialReadyUser()),
            location: '/onboarding?from=%2Fchats%2Fmatch-1',
            matchedLocation: Routes.onboardingScreen.path,
          ),
          '/chats/match-1',
        );
      },
    );

    test('fully set-up users visiting the auth route land on dashboard', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(_testUid),
          userProfileAsync: AsyncData(_socialReadyUser()),
          location: '/auth',
          matchedLocation: Routes.authScreen.path,
        ),
        '/',
      );
    });

    test(
      'fully set-up users visiting start resume the preserved destination',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(_testUid),
            userProfileAsync: AsyncData(_socialReadyUser()),
            location: '/start?from=%2Fclubs%2Fclub-1',
            matchedLocation: Routes.startScreen.path,
          ),
          '/clubs/club-1',
        );
      },
    );

    test('unauthenticated users can access the auth route', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/auth?from=%2Fchats%2Fmatch-1',
          matchedLocation: Routes.authScreen.path,
        ),
        null,
      );
    });

    test(
      'pending OTP verification returns signed-out users from start to auth',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(null),
            userProfileAsync: const AsyncData(null),
            hasPendingAuthVerification: true,
            location: '/start',
            matchedLocation: Routes.startScreen.path,
          ),
          Routes.authScreen.path,
        );
      },
    );

    test(
      'pending OTP verification returns signed-out users from default route to auth',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(null),
            userProfileAsync: const AsyncData(null),
            hasPendingAuthVerification: true,
            location: '/',
            matchedLocation: Routes.dashboardScreen.path,
          ),
          '/auth?from=%2F',
        );
      },
    );

    test(
      'pending OTP verification does not steal signed-out public club browsing',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(null),
            userProfileAsync: const AsyncData(null),
            hasPendingAuthVerification: true,
            location: '/clubs/club-1',
            matchedLocation: Routes.clubDetailScreen.path,
          ),
          null,
        );
      },
    );

    test('invalid from values are discarded on resume', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(_testUid),
          userProfileAsync: AsyncData(_socialReadyUser()),
          location: '/auth?from=chats/match-1',
          matchedLocation: Routes.authScreen.path,
        ),
        '/',
      );
    });

    test('authority-style from values are discarded on resume', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(_testUid),
          userProfileAsync: AsyncData(_socialReadyUser()),
          location: '/auth?from=%2F%2Fexample.com%2Fclubs',
          matchedLocation: Routes.authScreen.path,
        ),
        '/',
      );
    });

    test('transient pending destinations resume to dashboard', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(_testUid),
          userProfileAsync: AsyncData(_socialReadyUser()),
          location: '/loading?from=%2Fauth',
          matchedLocation: Routes.loadingScreen.path,
        ),
        '/',
      );
    });
  });
}
