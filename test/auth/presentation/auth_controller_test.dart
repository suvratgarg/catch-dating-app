import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth_test_helpers.dart';

void main() {
  group('AuthController', () {
    test('build returns the requested initial auth state', () {
      final container = createAuthTestContainer();
      addTearDown(container.dispose);

      expect(
        container.read(authControllerProvider(authState: AuthState.signIn)),
        AuthState.signIn,
      );
      expect(
        container.read(authControllerProvider(authState: AuthState.signUp)),
        AuthState.signUp,
      );
    });

    test('toggleAuthState flips between sign-in and sign-up', () {
      final container = createAuthTestContainer();
      addTearDown(container.dispose);
      final notifier = container.read(
        authControllerProvider(authState: AuthState.signIn).notifier,
      );

      notifier.toggleAuthState();
      expect(
        container.read(authControllerProvider(authState: AuthState.signIn)),
        AuthState.signUp,
      );

      notifier.toggleAuthState();
      expect(
        container.read(authControllerProvider(authState: AuthState.signIn)),
        AuthState.signIn,
      );
    });

    test('submit signs in when state is signIn', () async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);
      final notifier = container.read(
        authControllerProvider(authState: AuthState.signIn).notifier,
      );

      await notifier.submit(email: 'runner@example.com', password: 'secret123');

      expect(repository.signInEmail, 'runner@example.com');
      expect(repository.signInPassword, 'secret123');
      expect(repository.createEmail, isNull);
    });

    test('submit creates an account when state is signUp', () async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);
      final notifier = container.read(
        authControllerProvider(authState: AuthState.signUp).notifier,
      );

      await notifier.submit(email: 'runner@example.com', password: 'secret123');

      expect(repository.createEmail, 'runner@example.com');
      expect(repository.createPassword, 'secret123');
      expect(repository.signInEmail, isNull);
    });

    test('signOut delegates to the repository', () async {
      final repository = FakeAuthRepository();
      final container = createAuthTestContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      addTearDown(repository.dispose);
      final notifier = container.read(
        authControllerProvider(authState: AuthState.signIn).notifier,
      );

      await notifier.signOut();

      expect(repository.signOutCallCount, 1);
    });
  });
}
