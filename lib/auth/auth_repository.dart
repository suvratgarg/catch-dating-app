import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  const AuthRepository(this._auth);

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String _normalizeEmail(String email) => email.trim();

  // ── Email auth ────────────────────────────────────────────────────────────

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: _normalizeEmail(email),
      password: password,
    );
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: _normalizeEmail(email),
      password: password,
    );
  }

  // ── Phone OTP auth ────────────────────────────────────────────────────────

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException e) verificationFailed,
    required void Function(PhoneAuthCredential credential)
    verificationCompleted,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await signInWithCredential(credential);
  }

  Future<void> signInWithCredential(AuthCredential credential) async {
    await _auth.signInWithCredential(credential);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(firebaseAuthProvider));

@Riverpod(keepAlive: true)
Stream<User?> authStateChanges(Ref ref) =>
    ref.watch(authRepositoryProvider).authStateChanges();

@Riverpod(keepAlive: true)
Stream<String?> uid(Ref ref) =>
    ref.watch(authRepositoryProvider).authStateChanges().map((u) => u?.uid);
