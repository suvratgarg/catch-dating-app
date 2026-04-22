import 'dart:async';

import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_screen.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

typedef VerifyPhoneNumberHandler =
    FutureOr<void> Function({
      required PhoneVerificationCompleted verificationCompleted,
      required PhoneVerificationFailed verificationFailed,
      required PhoneCodeSent codeSent,
      required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    });

class TestUser extends Fake implements User {
  TestUser({required this.uid, this.email, this.phoneNumber});

  @override
  final String uid;

  @override
  final String? email;

  @override
  final String? phoneNumber;
}

class TestUserCredential extends Fake implements UserCredential {
  TestUserCredential(this._user);

  final User? _user;

  @override
  User? get user => _user;
}

class TestFirebaseAuth extends Fake implements FirebaseAuth {
  TestFirebaseAuth({User? currentUser}) : _currentUser = currentUser;

  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  User? _currentUser;
  String? createdEmail;
  String? createdPassword;
  String? signedInEmail;
  String? signedInPassword;
  String? verifiedPhoneNumber;
  AuthCredential? signedInCredential;
  int signOutCallCount = 0;
  VerifyPhoneNumberHandler? onVerifyPhoneNumber;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() => _authStateController.stream;

  void emitAuthState(User? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    createdEmail = email;
    createdPassword = password;
    return TestUserCredential(_currentUser);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signedInEmail = email;
    signedInPassword = password;
    return TestUserCredential(_currentUser);
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    signedInCredential = credential;
    return TestUserCredential(_currentUser);
  }

  @override
  Future<void> verifyPhoneNumber({
    String? phoneNumber,
    PhoneMultiFactorInfo? multiFactorInfo,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    String? autoRetrievedSmsCodeForTesting,
    Duration timeout = const Duration(seconds: 30),
    int? forceResendingToken,
    MultiFactorSession? multiFactorSession,
  }) async {
    verifiedPhoneNumber = phoneNumber;
    await onVerifyPhoneNumber?.call(
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
  }

  Future<void> dispose() => _authStateController.close();
}

class FakeAuthRepository extends Fake implements AuthRepository {
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  User? currentUserValue;
  String? createEmail;
  String? createPassword;
  String? signInEmail;
  String? signInPassword;
  String? otpVerificationId;
  String? otpSmsCode;
  AuthCredential? credential;
  int signOutCallCount = 0;
  Object? createError;
  Object? signInError;
  Object? signOutError;
  Completer<void>? createCompleter;
  Completer<void>? signInCompleter;
  Completer<void>? signOutCompleter;
  String? verifiedPhoneNumber;
  VerifyPhoneNumberHandler? onVerifyPhoneNumber;

  @override
  User? get currentUser => currentUserValue;

  @override
  Stream<User?> authStateChanges() => _authStateController.stream;

  void emitAuthState(User? user) {
    currentUserValue = user;
    _authStateController.add(user);
  }

  @override
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    createEmail = email;
    createPassword = password;
    if (createError case final error?) {
      throw error;
    }
    if (createCompleter case final completer?) {
      await completer.future;
    }
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    signInEmail = email;
    signInPassword = password;
    if (signInError case final error?) {
      throw error;
    }
    if (signInCompleter case final completer?) {
      await completer.future;
    }
  }

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException e) verificationFailed,
    required void Function(PhoneAuthCredential credential)
    verificationCompleted,
  }) async {
    verifiedPhoneNumber = phoneNumber;
    await onVerifyPhoneNumber?.call(
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<void> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    otpVerificationId = verificationId;
    otpSmsCode = smsCode;
  }

  @override
  Future<void> signInWithCredential(AuthCredential credential) async {
    this.credential = credential;
  }

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
    if (signOutError case final error?) {
      throw error;
    }
    if (signOutCompleter case final completer?) {
      await completer.future;
    }
  }

  Future<void> dispose() => _authStateController.close();
}

ProviderContainer createAuthTestContainer({List<Object> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides.cast());
  AuthController.submitMutation.reset(container);
  return container;
}

Future<void> pumpAuthScreen(
  WidgetTester tester, {
  required ProviderContainer container,
  AuthState authState = AuthState.signIn,
}) async {
  final router = GoRouter(
    initialLocation: Routes.authScreen.path,
    routes: [
      GoRoute(
        path: Routes.authScreen.path,
        builder: (_, _) => AuthScreen(authState: authState),
      ),
      GoRoute(
        path: Routes.onboardingScreen.path,
        builder: (_, _) => const Scaffold(body: Text('Onboarding screen')),
      ),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}
