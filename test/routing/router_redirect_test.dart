import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

UserProfile _completeUser() => UserProfile(
  uid: 'user-1',
  name: 'Runner',
  dateOfBirth: DateTime(1995, 6, 15),
  gender: Gender.man,
  sexualOrientation: SexualOrientation.straight,
  phoneNumber: '+910000000000',
  profileComplete: true,
  interestedInGenders: const [Gender.woman],
);

UserProfile _incompleteUser() => UserProfile(
  uid: 'user-1',
  name: 'New Runner',
  dateOfBirth: DateTime(1995, 6, 15),
  gender: Gender.man,
  sexualOrientation: SexualOrientation.straight,
  phoneNumber: '+910000000000',
  profileComplete: false,
  interestedInGenders: const [],
);

String? _redirect({
  required AsyncValue<String?> uidAsync,
  required AsyncValue<UserProfile?> userProfileAsync,
  required String location,
  String? matchedLocation,
}) {
  final uri = Uri.parse(location);
  return appRedirect(
    uidAsync: uidAsync,
    userProfileAsync: userProfileAsync,
    matchedLocation: matchedLocation ?? uri.path,
    uri: uri,
  );
}

void main() {
  group('appRedirect', () {
    test(
      'unauthenticated users are sent to onboarding and keep their destination',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData(null),
            userProfileAsync: const AsyncData(null),
            location: '/chats/match-1',
            matchedLocation: Routes.chatScreen.path,
          ),
          '/onboarding?from=%2Fchats%2Fmatch-1',
        );
      },
    );

    test(
      'authenticated users without a profile doc are sent to onboarding',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData('user-1'),
            userProfileAsync: const AsyncData(null),
            location: '/clubs',
            matchedLocation: Routes.runClubsListScreen.path,
          ),
          '/onboarding?from=%2Fclubs',
        );
      },
    );

    test('run club detail deep links are preserved through onboarding', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/clubs/run-clubs/club-1',
          matchedLocation: Routes.runClubDetailScreen.path,
        ),
        '/onboarding?from=%2Fclubs%2Frun-clubs%2Fclub-1',
      );
    });

    test('run detail deep links are preserved through onboarding', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/clubs/run-clubs/club-1/runs/run-1',
          matchedLocation: Routes.runDetailScreen.path,
        ),
        '/onboarding?from=%2Fclubs%2Frun-clubs%2Fclub-1%2Fruns%2Frun-1',
      );
    });

    test(
      'incomplete profiles stay in onboarding and preserve the pending route',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData('user-1'),
            userProfileAsync: AsyncData(_incompleteUser()),
            location: '/auth?from=%2Fchats%2Fmatch-1',
            matchedLocation: Routes.legacyAuthRedirect.path,
          ),
          '/onboarding?from=%2Fchats%2Fmatch-1',
        );
      },
    );

    test('loading auth state routes through the loading screen', () {
      expect(
        _redirect(
          uidAsync: const AsyncLoading(),
          userProfileAsync: const AsyncLoading(),
          location: '/catches/run-1?tab=recent',
          matchedLocation: Routes.swipeRunScreen.path,
        ),
        '/loading?from=%2Fcatches%2Frun-1%3Ftab%3Drecent',
      );
    });

    test(
      'fully set-up users resume the preserved destination from onboarding',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData('user-1'),
            userProfileAsync: AsyncData(_completeUser()),
            location: '/onboarding?from=%2Fchats%2Fmatch-1',
            matchedLocation: Routes.onboardingScreen.path,
          ),
          '/chats/match-1',
        );
      },
    );

    test(
      'fully set-up users visiting the legacy auth route land on dashboard',
      () {
        expect(
          _redirect(
            uidAsync: const AsyncData('user-1'),
            userProfileAsync: AsyncData(_completeUser()),
            location: '/auth',
            matchedLocation: Routes.legacyAuthRedirect.path,
          ),
          '/',
        );
      },
    );

    test('legacy auth links send signed-out users to phone onboarding', () {
      expect(
        _redirect(
          uidAsync: const AsyncData(null),
          userProfileAsync: const AsyncData(null),
          location: '/auth?from=%2Fchats%2Fmatch-1',
          matchedLocation: Routes.legacyAuthRedirect.path,
        ),
        '/onboarding?from=%2Fchats%2Fmatch-1',
      );
    });

    test('invalid from values are discarded on resume', () {
      expect(
        _redirect(
          uidAsync: const AsyncData('user-1'),
          userProfileAsync: AsyncData(_completeUser()),
          location: '/auth?from=chats/match-1',
          matchedLocation: Routes.legacyAuthRedirect.path,
        ),
        '/',
      );
    });

    test('transient pending destinations resume to dashboard', () {
      expect(
        _redirect(
          uidAsync: const AsyncData('user-1'),
          userProfileAsync: AsyncData(_completeUser()),
          location: '/loading?from=%2Fauth',
          matchedLocation: Routes.loadingScreen.path,
        ),
        '/',
      );
    });
  });
}
