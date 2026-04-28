import 'dart:async';

import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_error_message.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_validators.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../auth_test_helpers.dart';

void main() {
  group('auth support helpers', () {
    test('email validator accepts trimmed valid emails', () {
      expect(AuthFormValidators.email('  runner@example.com  '), isNull);
    });

    test('email validator rejects empty and malformed emails', () {
      expect(AuthFormValidators.email(''), 'Please enter your email');
      expect(
        AuthFormValidators.email('runnerexample.com'),
        'Please enter a valid email address',
      );
      expect(
        AuthFormValidators.email('runner@ example.com'),
        'Please enter a valid email address',
      );
    });

    test('password validator enforces a minimum for sign-up only', () {
      expect(
        AuthFormValidators.password('', isSignUp: true),
        'Please enter your password',
      );
      expect(
        AuthFormValidators.password('12345', isSignUp: true),
        'Password must be at least 6 characters',
      );
      expect(AuthFormValidators.password('12345', isSignUp: false), isNull);
    });

    test(
      'authErrorMessage maps Firebase errors and strips generic exceptions',
      () {
        expect(
          authErrorMessage(FirebaseAuthException(code: 'email-already-in-use')),
          'An account already exists for that email.',
        );
        expect(
          authErrorMessage(FirebaseAuthException(code: 'wrong-password')),
          'Incorrect email or password.',
        );
        expect(
          authErrorMessage(FirebaseAuthException(code: 'user-not-found')),
          'Incorrect email or password.',
        );
        expect(
          authErrorMessage(FirebaseAuthException(code: 'invalid-email')),
          'Please enter a valid email address.',
        );
        expect(
          authErrorMessage(
            FirebaseAuthException(code: 'network-request-failed'),
          ),
          'Check your internet connection and try again.',
        );
        expect(
          authErrorMessage(
            FirebaseAuthException(code: 'operation-not-allowed'),
          ),
          'This sign-in method is not enabled.',
        );
        expect(
          authErrorMessage(FirebaseAuthException(code: 'too-many-requests')),
          'Too many attempts. Please wait a bit and try again.',
        );
        expect(
          authErrorMessage(FirebaseAuthException(code: 'user-disabled')),
          'This account has been disabled.',
        );
        expect(
          authErrorMessage(FirebaseAuthException(code: 'weak-password')),
          'Password must be at least 6 characters.',
        );
        expect(
          authErrorMessage(
            FirebaseAuthException(
              code: 'unexpected',
              message: 'Backend said no',
            ),
          ),
          'Backend said no',
        );
        expect(
          authErrorMessage(Exception('Readable message')),
          'Readable message',
        );
        expect(
          authErrorMessage(StateError('Unexpected')),
          'Unexpected',
        );
      },
    );
  });

  group('AuthScreen', () {
    testWidgets('renders the sign-in state and toggles to sign-up', (
      tester,
    ) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);

      await tester.tap(find.text('Create account with email'));
      await tester.pumpAndSettle();

      expect(find.text('Create your account'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Create account'),
        findsOneWidget,
      );
      expect(find.text('Sign in instead'), findsOneWidget);
    });

    testWidgets('validates the sign-in form before submitting', (tester) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
      expect(repository.signInEmail, isNull);
    });

    testWidgets('sign-in submits through the controller and repository', (
      tester,
    ) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'runner@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();

      expect(repository.signInEmail, 'runner@example.com');
      expect(repository.signInPassword, 'secret');
    });

    testWidgets('sign-up validates minimum password length', (tester) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);
      await tester.tap(find.text('Create account with email'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'runner@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '12345',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
      expect(repository.createEmail, isNull);
    });

    testWidgets('sign-up submits once the form is valid', (tester) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);
      await tester.tap(find.text('Create account with email'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'runner@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();

      expect(repository.createEmail, 'runner@example.com');
      expect(repository.createPassword, 'secret123');
    });

    testWidgets('shows a readable auth error and clears it on mode toggle', (
      tester,
    ) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);

      await expectLater(
        AuthController.submitMutation.run(container, (transaction) async {
          throw FirebaseAuthException(code: 'wrong-password');
        }),
        throwsA(isA<FirebaseAuthException>()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsOneWidget);

      await tester.tap(find.text('Create account with email'));
      await tester.pumpAndSettle();

      expect(find.text('Incorrect email or password.'), findsNothing);
    });

    testWidgets('shows a loading spinner while a submission is pending', (
      tester,
    ) async {
      final repository = FakeAuthRepository()
        ..signInCompleter = Completer<void>();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'runner@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      repository.signInCompleter!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('password visibility can be toggled', (tester) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);

      EditableText passwordField() =>
          tester.widget<EditableText>(find.byType(EditableText).last);

      expect(passwordField().obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pumpAndSettle();

      expect(passwordField().obscureText, isFalse);
    });

    testWidgets(
      'email next action, tap outside, and password done action wire correctly',
      (tester) async {
        final repository = FakeAuthRepository();
        final container = createAuthTestContainer(
          overrides: [authRepositoryProvider.overrideWithValue(repository)],
        );
        addTearDown(container.dispose);
        addTearDown(repository.dispose);

        await pumpAuthScreen(tester, container: container);

        final emailField = find.widgetWithText(TextFormField, 'Email');
        final passwordField = find.widgetWithText(TextFormField, 'Password');

        await tester.enterText(emailField, 'runner@example.com');
        await tester.enterText(passwordField, 'secret');

        await tester.tap(emailField);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText).first)
              .focusNode
              .hasFocus,
          isTrue,
        );

        tester
            .widget<TextField>(find.byType(TextField).first)
            .onTapOutside
            ?.call(const PointerDownEvent());
        await tester.pump();

        expect(
          tester
              .widget<EditableText>(find.byType(EditableText).first)
              .focusNode
              .hasFocus,
          isFalse,
        );

        await tester.tap(emailField);
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.next);
        await tester.pump();

        await tester.tap(passwordField);
        await tester.pumpAndSettle();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        expect(repository.signInEmail, 'runner@example.com');
        expect(repository.signInPassword, 'secret');
      },
    );

    testWidgets('Continue with phone navigates to onboarding', (tester) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Continue with phone'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Onboarding screen'), findsOneWidget);
    });

    testWidgets('Continue with phone preserves the pending destination', (
      tester,
    ) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      final router = GoRouter(
        initialLocation: '/auth?from=%2Fchats%2Fmatch-1',
        routes: [
          GoRoute(
            path: Routes.authScreen.path,
            builder: (_, _) => const AuthScreen(authState: AuthState.signIn),
          ),
          GoRoute(
            path: Routes.onboardingScreen.path,
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

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Continue with phone'),
      );
      await tester.pumpAndSettle();

      expect(find.text('/onboarding?from=%2Fchats%2Fmatch-1'), findsOneWidget);
    });

    testWidgets('the or divider is rendered between auth methods', (
      tester,
    ) async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);

      await pumpAuthScreen(tester, container: container);

      expect(find.text('or'), findsOneWidget);
      expect(find.byType(Divider), findsNWidgets(2));
    });
  });
}
