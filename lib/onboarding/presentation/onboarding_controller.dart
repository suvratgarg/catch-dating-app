import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.freezed.dart';
part 'onboarding_controller.g.dart';

// Steps: 0=welcome, 1=phone, 2=otp, 3=nameDob, 4=genderInterest, 5=photos, 6=runningPrefs
@freezed
abstract class OnboardingData with _$OnboardingData {
  const factory OnboardingData({
    @Default(0) int step,
    @Default('') String phoneNumber,
    String? verificationId,
    @Default('') String firstName,
    @Default('') String lastName,
    DateTime? dateOfBirth,
    Gender? gender,
    SexualOrientation? sexualOrientation,
    @Default([]) List<Gender> interestedInGenders,
  }) = _OnboardingData;
}

@Riverpod(keepAlive: true)
class OnboardingController extends _$OnboardingController {
  static final sendOtpMutation = Mutation<void>();
  static final verifyOtpMutation = Mutation<void>();
  static final saveProfileMutation = Mutation<void>();
  static final completeMutation = Mutation<void>();

  @override
  OnboardingData build() => const OnboardingData();

  /// Call once from OnboardingScreen.initState to jump to the correct starting step.
  void initStep() {
    final uid = ref.read(uidProvider).asData?.value;
    final appUser = ref.read(appUserStreamProvider).asData?.value;

    if (uid == null) {
      state = state.copyWith(step: 0);
    } else if (appUser == null) {
      // Authenticated (email or phone) but no profile doc yet
      final phoneFromAuth = ref.read(authRepositoryProvider).currentUser?.phoneNumber ?? '';
      state = state.copyWith(
        step: 3,
        phoneNumber: phoneFromAuth.replaceFirst('+91', ''),
      );
    } else if (!appUser.profileComplete) {
      state = state.copyWith(step: 5);
    }
  }

  void goToStep(int step) => state = state.copyWith(step: step);

  // ── Phone OTP ─────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(phoneNumber: phoneNumber);
    await ref.read(authRepositoryProvider).verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      codeSent: (verificationId, _) {
        state = state.copyWith(verificationId: verificationId, step: 2);
      },
      verificationFailed: (e) => throw e,
      verificationCompleted: (credential) async {
        await ref.read(authRepositoryProvider).signInWithCredential(
          credential,
        );
        state = state.copyWith(step: 3);
      },
    );
  }

  Future<void> verifyOtp(String code) async {
    await ref.read(authRepositoryProvider).signInWithOtp(
      verificationId: state.verificationId!,
      smsCode: code,
    );
    state = state.copyWith(step: 3);
  }

  // ── Profile creation ──────────────────────────────────────────────────────

  void setNameDob({
    required String firstName,
    required String lastName,
    required DateTime dateOfBirth,
    required String phoneNumber,
  }) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      phoneNumber: phoneNumber,
    );
  }

  void setGenderInterest({
    required Gender gender,
    required SexualOrientation sexualOrientation,
    required List<Gender> interestedInGenders,
  }) {
    state = state.copyWith(
      gender: gender,
      sexualOrientation: sexualOrientation,
      interestedInGenders: interestedInGenders,
    );
  }

  Future<void> saveProfile() async {
    final uid = ref.read(uidProvider).asData?.value ?? '';
    final email = ref.read(authRepositoryProvider).currentUser?.email ?? '';
    final rawPhone = state.phoneNumber;
    final phone = rawPhone.startsWith('+') ? rawPhone : '+91$rawPhone';

    await ref.read(appUserRepositoryProvider).setAppUser(
      appUser: AppUser(
        uid: uid,
        email: email,
        name: '${state.firstName} ${state.lastName}'.trim(),
        dateOfBirth: state.dateOfBirth!,
        gender: state.gender!,
        sexualOrientation: state.sexualOrientation!,
        phoneNumber: phone,
        interestedInGenders: state.interestedInGenders,
        profileComplete: false,
      ),
    );
    state = state.copyWith(step: 5);
  }

  Future<void> complete({
    required int paceMinSecsPerKm,
    required int paceMaxSecsPerKm,
    required List<PreferredDistance> preferredDistances,
    required List<RunReason> runningReasons,
  }) async {
    final appUser = ref.read(appUserStreamProvider).asData?.value;
    if (appUser == null) {
      throw StateError('User profile not loaded. Please try again.');
    }
    await ref.read(appUserRepositoryProvider).setAppUser(
      appUser: appUser.copyWith(
        paceMinSecsPerKm: paceMinSecsPerKm,
        paceMaxSecsPerKm: paceMaxSecsPerKm,
        preferredDistances: preferredDistances,
        runningReasons: runningReasons,
        profileComplete: true,
      ),
    );
  }
}
