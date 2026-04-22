import 'dart:async';

import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import '../runs/runs_test_helpers.dart';

class FakePhotoAppUserRepository extends Fake implements AppUserRepository {
  FakePhotoAppUserRepository(this.currentUser);

  AppUser currentUser;
  final updatedPhotoUrls = <List<String>>[];

  @override
  Future<AppUser?> fetchAppUser({required String? uid}) async => currentUser;

  @override
  Future<void> updatePhotoUrls({
    required String uid,
    required List<String> photoUrls,
  }) async {
    updatedPhotoUrls.add(List<String>.from(photoUrls));
    currentUser = currentUser.copyWith(photoUrls: List<String>.from(photoUrls));
  }
}

class ControlledImageUploadRepository extends Fake
    implements ImageUploadRepository {
  final uploadCompleters = <Completer<String>>[];
  final uploadedIndices = <int>[];

  @override
  Future<XFile?> pickImage({int imageQuality = 85}) async =>
      XFile('picked-photo.jpg');

  @override
  Future<String> uploadUserPhoto({
    required String uid,
    required int index,
    required XFile image,
  }) {
    uploadedIndices.add(index);
    final completer = Completer<String>();
    uploadCompleters.add(completer);
    return completer.future;
  }
}

void main() {
  test(
    'serializes overlapping photo writes so newer state is preserved',
    () async {
      final appUserRepository = FakePhotoAppUserRepository(
        buildUser(
          uid: 'runner-1',
          photoUrls: const ['https://img.example/old-0.jpg'],
        ),
      );
      final imageUploadRepository = ControlledImageUploadRepository();
      final container = ProviderContainer(
        overrides: [
          appUserRepositoryProvider.overrideWith((ref) => appUserRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => imageUploadRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      await container.pump();

      final controller = container.read(photoUploadControllerProvider.notifier);
      final firstUpload = controller.pickAndUpload(0);
      final secondUpload = controller.pickAndUpload(1);
      await container.pump();

      expect(imageUploadRepository.uploadedIndices, [0, 1]);

      imageUploadRepository.uploadCompleters[1].complete(
        'https://img.example/new-1.jpg',
      );
      await container.pump();
      imageUploadRepository.uploadCompleters[0].complete(
        'https://img.example/new-0.jpg',
      );

      await Future.wait([firstUpload, secondUpload]);

      expect(appUserRepository.updatedPhotoUrls, [
        ['https://img.example/old-0.jpg', 'https://img.example/new-1.jpg'],
        ['https://img.example/new-0.jpg', 'https://img.example/new-1.jpg'],
      ]);
      expect(appUserRepository.currentUser.photoUrls, [
        'https://img.example/new-0.jpg',
        'https://img.example/new-1.jpg',
      ]);
      expect(
        container.read(photoUploadControllerProvider).loadingIndices,
        isEmpty,
      );
    },
  );

  test('completes safely if the provider is disposed mid-upload', () async {
    final appUserRepository = FakePhotoAppUserRepository(
      buildUser(uid: 'runner-1'),
    );
    final imageUploadRepository = ControlledImageUploadRepository();
    final container = ProviderContainer(
      overrides: [
        appUserRepositoryProvider.overrideWith((ref) => appUserRepository),
        imageUploadRepositoryProvider.overrideWith(
          (ref) => imageUploadRepository,
        ),
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
      ],
    );
    final uidSubscription = container.listen(
      uidProvider,
      (_, _) {},
      fireImmediately: true,
    );
    await container.pump();

    final controller = container.read(photoUploadControllerProvider.notifier);
    final upload = controller.pickAndUpload(0);
    await container.pump();
    expect(imageUploadRepository.uploadCompleters, hasLength(1));

    container.dispose();
    uidSubscription.close();
    imageUploadRepository.uploadCompleters.single.complete(
      'https://img.example/disposed.jpg',
    );

    await expectLater(upload, completes);
  });
}
