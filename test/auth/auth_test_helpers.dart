import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

typedef VerifyPhoneNumberHandler =
    FutureOr<void> Function({
      required PhoneVerificationCompleted verificationCompleted,
      required PhoneVerificationFailed verificationFailed,
      required PhoneCodeSent codeSent,
      required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
    });

class TestUser extends Fake implements User {
  TestUser({required this.uid, this.phoneNumber});

  @override
  final String uid;

  @override
  final String? phoneNumber;
}

class RecordingMockFirebaseAuth extends MockFirebaseAuth {
  RecordingMockFirebaseAuth({super.signedIn, super.mockUser});

  String? verifiedPhoneNumber;
  AuthCredential? signedInCredential;
  int signOutCallCount = 0;

  @override
  Future<UserCredential> signInWithCredential(AuthCredential? credential) {
    signedInCredential = credential;
    return super.signInWithCredential(credential);
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
    Object? multiFactorSession,
  }) async {
    verifiedPhoneNumber = phoneNumber;
    await super.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      autoRetrievedSmsCodeForTesting: autoRetrievedSmsCodeForTesting,
      timeout: timeout,
      forceResendingToken: forceResendingToken,
    );
  }

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
    await super.signOut();
  }

  void dispose() {
    if (!stateChangedStreamController.isClosed) {
      stateChangedStreamController.close();
    }
    if (!userChangedStreamController.isClosed) {
      userChangedStreamController.close();
    }
    if (!idTokenChangedStreamController.isClosed) {
      idTokenChangedStreamController.close();
    }
    if (!authForFakeFirestoreStreamController.isClosed) {
      authForFakeFirestoreStreamController.close();
    }
  }
}

class FakeAuthRepository extends Fake implements AuthRepository {
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  User? currentUserValue;
  String? otpVerificationId;
  String? otpSmsCode;
  AuthCredential? credential;
  int signOutCallCount = 0;
  Object? signOutError;
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
  return ProviderContainer(overrides: overrides.cast());
}
