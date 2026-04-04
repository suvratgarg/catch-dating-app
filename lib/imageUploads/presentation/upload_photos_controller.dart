import 'package:catch_dating_app/appUser/data/app_user_repository.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'upload_photos_controller.g.dart';

@riverpod
class UploadPhotosController extends _$UploadPhotosController {
  static final completeMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> complete() async {
    final uid = ref.read(uidProvider).asData?.value ?? '';
    await ref.read(appUserRepositoryProvider).setProfileComplete(uid: uid);
  }
}
