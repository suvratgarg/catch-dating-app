import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/onboarding/presentation/onboarding_controller.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_session_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns session-level auth side effects such as sign-out. This keeps widgets
/// from calling [AuthRepository] directly and centralizes cleanup of keepAlive
/// flow controllers that should not survive a completed sign-out.
@riverpod
class AuthSessionController extends _$AuthSessionController {
  static final signOutMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> signOut() async {
    clearLocalFlowState();
    await ref.read(authRepositoryProvider).signOut();
    clearLocalFlowState();
  }

  void clearLocalFlowState() {
    AuthController.sendOtpMutation.reset(ref);
    AuthController.verifyOtpMutation.reset(ref);
    OnboardingController.saveProfileMutation.reset(ref);
    OnboardingController.completeMutation.reset(ref);
    ref.invalidate(authControllerProvider);
    ref.invalidate(onboardingControllerProvider);
  }
}
