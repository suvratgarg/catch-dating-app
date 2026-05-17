import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_form_keys.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../onboarding/onboarding_test_helpers.dart';

Future<void> pumpAuthScreen(
  WidgetTester tester, {
  required ProviderContainer container,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        home: const AuthScreen(),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('AuthScreen', () {
    testWidgets('starts on phone entry view', (tester) async {
      final repository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      await pumpAuthScreen(tester, container: container);

      expect(find.text("What's your number?"), findsOneWidget);
      expect(find.text('Send code'), findsOneWidget);
    });

    testWidgets('defaults the country picker to India', (tester) async {
      final repository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      await pumpAuthScreen(tester, container: container);

      expect(find.text('+91'), findsOneWidget);
    });

    testWidgets('country picker opens with dark theme styles', (tester) async {
      final repository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      await pumpAuthScreen(
        tester,
        container: container,
        themeMode: ThemeMode.dark,
      );

      await tester.tap(find.text('+91'));
      await tester.pumpAndSettle();

      expect(find.text('Select Country'), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('switch between phone and OTP views', (tester) async {
      final repository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      await pumpAuthScreen(tester, container: container);

      expect(find.text("What's your number?"), findsOneWidget);

      container.read(authControllerProvider.notifier).goToStep(AuthStep.otp);
      await tester.pump();

      expect(find.text('Enter the code'), findsOneWidget);
    });

    testWidgets('change number returns to phone step', (tester) async {
      final repository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      container.read(authControllerProvider.notifier).goToStep(AuthStep.otp);
      await pumpAuthScreen(tester, container: container);

      await tester.tap(find.byKey(AuthFormKeys.changeNumber));
      await tester.pump();

      expect(container.read(authControllerProvider).step, AuthStep.phone);
    });

    testWidgets('phone form sends OTP through the controller', (tester) async {
      final repository = FakeAuthRepository()
        ..onVerifyPhoneNumber =
            ({
              required verificationCompleted,
              required verificationFailed,
              required codeSent,
              required codeAutoRetrievalTimeout,
            }) {
              codeSent('verification-id', 11);
            };
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      await pumpAuthScreen(tester, container: container);

      await tester.enterText(
        find.descendant(
          of: find.byKey(AuthFormKeys.phoneField),
          matching: find.byType(EditableText),
        ),
        '9999999999',
      );
      await tester.tap(find.byKey(AuthFormKeys.sendCode));
      await tester.pump();
      await tester.pump();

      expect(repository.verifiedPhoneNumber, '+919999999999');
      expect(container.read(authControllerProvider).step, AuthStep.otp);
      expect(find.text('Enter the code'), findsOneWidget);
    });

    testWidgets('OTP entry verifies with the stored verification id', (
      tester,
    ) async {
      final repository = FakeAuthRepository()
        ..onVerifyPhoneNumber =
            ({
              required verificationCompleted,
              required verificationFailed,
              required codeSent,
              required codeAutoRetrievalTimeout,
            }) {
              codeSent('verification-id', 11);
            };
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      await container
          .read(authControllerProvider.notifier)
          .sendOtp('9999999999', '+91');

      await pumpAuthScreen(tester, container: container);

      await tester.enterText(find.byKey(AuthFormKeys.otpField), '123456');
      await tester.pump();
      await tester.pump();

      expect(repository.otpVerificationId, 'verification-id');
      expect(repository.otpSmsCode, '123456');
    });
  });
}
