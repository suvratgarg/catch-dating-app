import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'auth_test_helpers.dart';

void main() {
  group('AuthRepository', () {
    test('currentUser exposes the FirebaseAuth current user', () {
      final user = TestUser(uid: 'user-1', email: 'runner@example.com');
      final auth = TestFirebaseAuth(currentUser: user);
      addTearDown(auth.dispose);

      final repository = AuthRepository(auth);

      expect(repository.currentUser, same(user));
    });

    test(
      'createUserWithEmailAndPassword trims the email before delegating',
      () async {
        final auth = TestFirebaseAuth();
        addTearDown(auth.dispose);
        final repository = AuthRepository(auth);

        await repository.createUserWithEmailAndPassword(
          email: '  runner@example.com  ',
          password: 'secret123',
        );

        expect(auth.createdEmail, 'runner@example.com');
        expect(auth.createdPassword, 'secret123');
      },
    );

    test(
      'signInWithEmailAndPassword trims the email before delegating',
      () async {
        final auth = TestFirebaseAuth();
        addTearDown(auth.dispose);
        final repository = AuthRepository(auth);

        await repository.signInWithEmailAndPassword(
          email: '  runner@example.com  ',
          password: 'secret123',
        );

        expect(auth.signedInEmail, 'runner@example.com');
        expect(auth.signedInPassword, 'secret123');
      },
    );

    test('verifyPhoneNumber forwards callbacks to FirebaseAuth', () async {
      final auth = TestFirebaseAuth()
        ..onVerifyPhoneNumber =
            ({
              required verificationCompleted,
              required verificationFailed,
              required codeSent,
              required codeAutoRetrievalTimeout,
            }) {
              codeSent('verification-id', 7);
              verificationFailed(
                FirebaseAuthException(code: 'invalid-phone-number'),
              );
              verificationCompleted(
                PhoneAuthProvider.credential(
                  verificationId: 'verification-id',
                  smsCode: '123456',
                ),
              );
              codeAutoRetrievalTimeout('verification-id');
            };
      addTearDown(auth.dispose);
      final repository = AuthRepository(auth);

      var sentVerificationId = '';
      int? sentResendToken;
      FirebaseAuthException? failure;
      PhoneAuthCredential? completedCredential;

      await repository.verifyPhoneNumber(
        phoneNumber: '+919999999999',
        codeSent: (verificationId, resendToken) {
          sentVerificationId = verificationId;
          sentResendToken = resendToken;
        },
        verificationFailed: (error) => failure = error,
        verificationCompleted: (credential) => completedCredential = credential,
      );

      expect(auth.verifiedPhoneNumber, '+919999999999');
      expect(sentVerificationId, 'verification-id');
      expect(sentResendToken, 7);
      expect(failure?.code, 'invalid-phone-number');
      expect(completedCredential, isA<PhoneAuthCredential>());
    });

    test(
      'signInWithOtp creates a phone credential and signs in with it',
      () async {
        final auth = TestFirebaseAuth();
        addTearDown(auth.dispose);
        final repository = AuthRepository(auth);

        await repository.signInWithOtp(
          verificationId: 'verification-id',
          smsCode: '123456',
        );

        expect(auth.signedInCredential, isA<PhoneAuthCredential>());
      },
    );

    test('signInWithCredential delegates to FirebaseAuth', () async {
      final auth = TestFirebaseAuth();
      addTearDown(auth.dispose);
      final repository = AuthRepository(auth);
      final credential = EmailAuthProvider.credential(
        email: 'runner@example.com',
        password: 'secret123',
      );

      await repository.signInWithCredential(credential);

      expect(auth.signedInCredential, same(credential));
    });

    test('signOut delegates to FirebaseAuth', () async {
      final auth = TestFirebaseAuth();
      addTearDown(auth.dispose);
      final repository = AuthRepository(auth);

      await repository.signOut();

      expect(auth.signOutCallCount, 1);
    });
  });

  group('auth providers', () {
    test('authRepositoryProvider uses firebaseAuthProvider', () {
      final auth = TestFirebaseAuth(currentUser: TestUser(uid: 'user-1'));
      final container = createAuthTestContainer(
        overrides: [firebaseAuthProvider.overrideWithValue(auth)],
      );
      addTearDown(auth.dispose);
      addTearDown(container.dispose);

      final repository = container.read(authRepositoryProvider);

      expect(repository.currentUser?.uid, 'user-1');
    });

    test('authStateChangesProvider forwards Firebase auth changes', () async {
      final auth = TestFirebaseAuth();
      final container = createAuthTestContainer(
        overrides: [firebaseAuthProvider.overrideWithValue(auth)],
      );
      addTearDown(auth.dispose);
      addTearDown(container.dispose);

      final events = <String?>[];
      final subscription = container.listen<AsyncValue<User?>>(
        authStateChangesProvider,
        (_, next) => events.add(next.asData?.value?.uid),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      auth.emitAuthState(TestUser(uid: 'user-42'));
      await Future<void>.delayed(Duration.zero);

      expect(events, contains('user-42'));
    });

    test('uidProvider maps users into uid values', () async {
      final auth = TestFirebaseAuth();
      final container = createAuthTestContainer(
        overrides: [firebaseAuthProvider.overrideWithValue(auth)],
      );
      addTearDown(auth.dispose);
      addTearDown(container.dispose);

      final values = <String?>[];
      final subscription = container.listen<AsyncValue<String?>>(
        uidProvider,
        (_, next) => values.add(next.asData?.value),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      auth.emitAuthState(TestUser(uid: 'user-7'));
      await Future<void>.delayed(Duration.zero);
      auth.emitAuthState(null);
      await Future<void>.delayed(Duration.zero);

      expect(values, containsAllInOrder(['user-7', null]));
    });
  });
}
