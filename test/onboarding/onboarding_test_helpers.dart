import 'dart:async';

import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:catch_dating_app/theme/app_theme.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

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

class FakeAuthRepository extends Fake implements AuthRepository {
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  User? currentUserValue;
  String? otpVerificationId;
  String? otpSmsCode;
  AuthCredential? credential;
  String? verifiedPhoneNumber;
  int verifyPhoneNumberCallCount = 0;
  VerifyPhoneNumberHandler? onVerifyPhoneNumber;

  @override
  User? get currentUser => currentUserValue;

  @override
  Stream<User?> authStateChanges() => _authStateController.stream;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException e) verificationFailed,
    required void Function(PhoneAuthCredential credential)
    verificationCompleted,
  }) async {
    verifyPhoneNumberCallCount += 1;
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

  Future<void> dispose() async {
    if (_authStateController.isClosed) {
      return;
    }
    await _authStateController.close();
  }
}

class FakeOnboardingUserProfileRepository extends Fake
    implements UserProfileRepository {
  FakeOnboardingUserProfileRepository({this.currentUser});

  UserProfile? currentUser;
  UserProfile? lastSavedUser;
  final updatedPhotoUrls = <List<String>>[];

  @override
  Future<UserProfile?> fetchUserProfile({required String? uid}) async =>
      currentUser;

  @override
  Stream<UserProfile?> watchUserProfile({required String? uid}) =>
      Stream.value(currentUser);

  @override
  Future<void> setUserProfile({required UserProfile userProfile}) async {
    lastSavedUser = userProfile;
    currentUser = userProfile;
  }

  @override
  Future<void> updatePhotoUrls({
    required String uid,
    required List<String> photoUrls,
  }) async {
    updatedPhotoUrls.add(List<String>.from(photoUrls));
    currentUser = (currentUser ?? buildUser(uid: uid)).copyWith(
      photoUrls: List<String>.from(photoUrls),
    );
  }
}

ProviderContainer createOnboardingTestContainer({
  List<Object> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides.cast());
  OnboardingController.sendOtpMutation.reset(container);
  OnboardingController.verifyOtpMutation.reset(container);
  OnboardingController.saveProfileMutation.reset(container);
  OnboardingController.completeMutation.reset(container);
  return container;
}

Future<void> pumpOnboardingPage(
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

Future<void> pumpOnboardingScreen(
  WidgetTester tester, {
  required ProviderContainer container,
  required Widget child,
}) async {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.light, home: child),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> primeOnboardingAsyncProviders(ProviderContainer container) async {
  final uidSubscription = container.listen(
    uidProvider,
    (_, _) {},
    fireImmediately: true,
  );
  final userProfileSubscription = container.listen(
    userProfileStreamProvider,
    (_, _) {},
    fireImmediately: true,
  );
  try {
    await container.pump();
  } finally {
    uidSubscription.close();
    userProfileSubscription.close();
  }
}
