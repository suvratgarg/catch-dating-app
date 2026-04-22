import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

String requireSignedInUid(Ref ref, {required String action}) {
  final uid = ref.read(uidProvider).asData?.value;
  if (uid == null || uid.isEmpty) {
    throw StateError('You need to be signed in to $action.');
  }
  return uid;
}
