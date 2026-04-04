import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

enum AuthState { signIn, signUp }

@riverpod
class AuthController extends _$AuthController {
  static final submitMutation = Mutation<void>();

  @override
  AuthState build({required AuthState authState}) {
    return authState;
  }

  Future<void> toggleAuthState() async {
    state = state == AuthState.signIn ? AuthState.signUp : AuthState.signIn;
  }

  Future<void> submit({required String email, required String password}) async {
    if (state == AuthState.signIn) {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email: email, password: password);
    } else {
      await ref
          .read(authRepositoryProvider)
          .createUserWithEmailAndPassword(email: email, password: password);
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}
