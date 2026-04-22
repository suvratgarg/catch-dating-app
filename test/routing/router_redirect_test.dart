import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

AppUser _completeUser() => AppUser(
      uid: 'user-1',
      name: 'Runner',
      dateOfBirth: DateTime(1995, 6, 15),
      gender: Gender.man,
      sexualOrientation: SexualOrientation.straight,
      phoneNumber: '+910000000000',
      profileComplete: true,
      interestedInGenders: const [Gender.woman],
    );

AppUser _incompleteUser() => AppUser(
      uid: 'user-1',
      name: 'New Runner',
      dateOfBirth: DateTime(1995, 6, 15),
      gender: Gender.man,
      sexualOrientation: SexualOrientation.straight,
      phoneNumber: '+910000000000',
      profileComplete: false,
      interestedInGenders: const [],
    );

/// Mirrors the production redirect logic from [goRouterProvider].
/// [uid] and [appUser] simulate the resolved Riverpod provider values.
String? _appRedirect({
  required String? uid,
  required AppUser? appUser,
  required String location,
}) {
  final onOnboarding = location == Routes.onboardingScreen.path;
  final onAuth = location == Routes.authScreen.path;

  if (uid == null) {
    if (onAuth || onOnboarding) return null;
    return Routes.authScreen.path;
  }

  if (appUser == null) {
    if (onOnboarding) return null;
    return Routes.onboardingScreen.path;
  }

  if (!appUser.profileComplete) {
    if (onOnboarding) return null;
    return Routes.onboardingScreen.path;
  }

  if (onAuth || onOnboarding) return Routes.dashboardScreen.path;
  return null;
}

/// Builds a [GoRouter] starting at [initialLocation] with stub screens and
/// the production redirect logic applied via [_appRedirect].
GoRouter _testRouter({
  required String initialLocation,
  required String? uid,
  required AppUser? appUser,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: Routes.authScreen.path,
        builder: (_, _) => const Scaffold(body: Text('auth')),
      ),
      GoRoute(
        path: Routes.onboardingScreen.path,
        builder: (_, _) => const Scaffold(body: Text('onboarding')),
      ),
      GoRoute(
        path: Routes.dashboardScreen.path,
        builder: (_, _) => const Scaffold(body: Text('dashboard')),
      ),
    ],
    redirect: (context, state) => _appRedirect(
      uid: uid,
      appUser: appUser,
      location: state.matchedLocation,
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Router redirects', () {
    testWidgets(
      '#32 unauthenticated user → redirected to /auth',
      (tester) async {
        final router = _testRouter(
          initialLocation: Routes.dashboardScreen.path,
          uid: null,
          appUser: null,
        );
        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(find.text('auth'), findsOneWidget);
        expect(find.text('dashboard'), findsNothing);
      },
    );

    testWidgets(
      '#33 authenticated with no profile doc → redirected to /onboarding',
      (tester) async {
        final router = _testRouter(
          initialLocation: Routes.dashboardScreen.path,
          uid: 'user-1',
          appUser: null,
        );
        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(find.text('onboarding'), findsOneWidget);
        expect(find.text('dashboard'), findsNothing);
      },
    );

    testWidgets(
      '#34 authenticated with profileComplete=false → redirected to /onboarding',
      (tester) async {
        final router = _testRouter(
          initialLocation: Routes.dashboardScreen.path,
          uid: 'user-1',
          appUser: _incompleteUser(),
        );
        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(find.text('onboarding'), findsOneWidget);
        expect(find.text('dashboard'), findsNothing);
      },
    );

    testWidgets(
      '#35 fully set-up user visiting /auth → redirected to /',
      (tester) async {
        final router = _testRouter(
          initialLocation: Routes.authScreen.path,
          uid: 'user-1',
          appUser: _completeUser(),
        );
        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(find.text('dashboard'), findsOneWidget);
        expect(find.text('auth'), findsNothing);
      },
    );

    testWidgets(
      '#36 fully set-up user visiting / stays on dashboard (no redirect)',
      (tester) async {
        final router = _testRouter(
          initialLocation: Routes.dashboardScreen.path,
          uid: 'user-1',
          appUser: _completeUser(),
        );
        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(find.text('dashboard'), findsOneWidget);
      },
    );

    testWidgets(
      '#37 unauthenticated user on /auth stays on /auth (no redirect loop)',
      (tester) async {
        final router = _testRouter(
          initialLocation: Routes.authScreen.path,
          uid: null,
          appUser: null,
        );
        await tester.pumpWidget(
          MaterialApp.router(theme: AppTheme.light, routerConfig: router),
        );
        await tester.pumpAndSettle();

        expect(find.text('auth'), findsOneWidget);
      },
    );
  });
}
