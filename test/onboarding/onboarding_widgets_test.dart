import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/name_dob_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/otp_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/phone_page.dart';
import 'package:catch_dating_app/onboarding/presentation/pages/welcome_page.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_test_helpers.dart';

Future<void> _pumpPage(
  WidgetTester tester, {
  required ProviderContainer container,
  required Widget child,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('WelcomePage', () {
    testWidgets('Get started advances onboarding to the phone step', (
      tester,
    ) async {
      final container = createAuthTestContainer();
      addTearDown(container.dispose);

      await _pumpPage(tester, container: container, child: const WelcomePage());

      await tester.tap(find.widgetWithText(FilledButton, 'Get started'));
      await tester.pumpAndSettle();

      expect(container.read(onboardingControllerProvider).step, 1);
    });

    testWidgets('Sign in routes to the auth screen', (tester) async {
      final container = createAuthTestContainer();
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: Routes.onboardingScreen.path,
        routes: [
          GoRoute(
            path: Routes.onboardingScreen.path,
            builder: (_, _) => const Scaffold(body: WelcomePage()),
          ),
          GoRoute(
            path: Routes.authScreen.path,
            builder: (_, _) => const Scaffold(body: Text('Auth screen')),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Auth screen'), findsOneWidget);
    });

    testWidgets('Sign in preserves the pending destination', (tester) async {
      final container = createAuthTestContainer();
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: '/onboarding?from=%2Fchats%2Fmatch-1',
        routes: [
          GoRoute(
            path: Routes.onboardingScreen.path,
            builder: (_, _) => const Scaffold(body: WelcomePage()),
          ),
          GoRoute(
            path: Routes.authScreen.path,
            builder: (_, state) => Scaffold(body: Text(state.uri.toString())),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.light,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Already have an account? Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('/auth?from=%2Fchats%2Fmatch-1'), findsOneWidget);
    });
  });

  group('PhonePage', () {
    testWidgets('shows a friendly auth error message', (tester) async {
      final container = createAuthTestContainer();
      addTearDown(container.dispose);

      await expectLater(
        OnboardingController.sendOtpMutation.run(container, (
          transaction,
        ) async {
          throw FirebaseAuthException(code: 'invalid-phone-number');
        }),
        throwsA(isA<FirebaseAuthException>()),
      );

      await _pumpPage(tester, container: container, child: const PhonePage());

      expect(find.text('Please enter a valid phone number.'), findsOneWidget);
    });
  });

  group('OtpPage', () {
    testWidgets('Change number returns to the phone step', (tester) async {
      final container = createAuthTestContainer();
      addTearDown(container.dispose);

      await _pumpPage(tester, container: container, child: const OtpPage());

      await tester.tap(find.text('Change number'));
      await tester.pumpAndSettle();

      expect(container.read(onboardingControllerProvider).step, 1);
    });
  });

  group('NameDobPage', () {
    testWidgets('manual phone entry requires 10 digits', (tester) async {
      final container = createAuthTestContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository()..currentUserValue = TestUser(uid: 'user-1'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await _pumpPage(tester, container: container, child: const NameDobPage());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'First name'),
        'Asha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last name'),
        'Runner',
      );
      await tester.tap(find.widgetWithText(TextFormField, 'Date of birth'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile number'),
        '12345',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid 10-digit number'), findsOneWidget);
      expect(container.read(onboardingControllerProvider).step, 0);
    });

    testWidgets('valid manual phone entry advances to the next step', (
      tester,
    ) async {
      final repository = FakeAuthRepository()
        ..currentUserValue = TestUser(uid: 'user-1');
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      await _pumpPage(tester, container: container, child: const NameDobPage());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'First name'),
        'Asha',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last name'),
        'Runner',
      );
      await tester.tap(find.widgetWithText(TextFormField, 'Date of birth'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Mobile number'),
        '9876543210',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(container.read(onboardingControllerProvider).step, 4);
      expect(
        container.read(onboardingControllerProvider).phoneNumber,
        '9876543210',
      );
    });
  });
}
