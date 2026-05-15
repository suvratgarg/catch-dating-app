import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/image_uploads/presentation/photo_upload_controller.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import '../runs/runs_test_helpers.dart';

class FakePhotoUserProfileRepository extends Fake
    implements UserProfileRepository {
  FakePhotoUserProfileRepository(this.currentUser);

  UserProfile currentUser;
  final updatedPhotoUrls = <List<String>>[];
  final updatedProfilePhotos = <List<ProfilePhoto>>[];

  @override
  Future<UserProfile?> fetchUserProfile({required String? uid}) async =>
      currentUser;

  @override
  Future<void> updateProfilePhotos({
    required String uid,
    required List<ProfilePhoto> profilePhotos,
    required List<String> photoUrls,
  }) async {
    updatedProfilePhotos.add(List<ProfilePhoto>.from(profilePhotos));
    updatedPhotoUrls.add(List<String>.from(photoUrls));
    currentUser = currentUser.copyWith(
      profilePhotos: List<ProfilePhoto>.from(profilePhotos),
      photoUrls: List<String>.from(photoUrls),
    );
  }
}

class ControlledImageUploadRepository extends Fake
    implements ImageUploadRepository {
  final uploadCompleters = <Completer<UploadedImage>>[];
  final uploadedIndices = <int>[];

  @override
  Future<XFile?> pickImage({
    ImageUploadPurpose purpose = ImageUploadPurpose.profilePhoto,
    int? imageQuality,
  }) async => XFile('picked-photo.jpg');

  @override
  Future<UploadedImage> uploadUserProfilePhoto({
    required String uid,
    required int index,
    required XFile image,
  }) {
    uploadedIndices.add(index);
    final completer = Completer<UploadedImage>();
    uploadCompleters.add(completer);
    return completer.future;
  }
}

class SlowPickingImageUploadRepository extends Fake
    implements ImageUploadRepository {
  final pickCompleter = Completer<XFile?>();
  int pickImageCallCount = 0;

  @override
  Future<XFile?> pickImage({
    ImageUploadPurpose purpose = ImageUploadPurpose.profilePhoto,
    int? imageQuality,
  }) {
    pickImageCallCount += 1;
    return pickCompleter.future;
  }
}

void main() {
  test('image upload policies keep picked media bounded by surface', () {
    expect(ImageUploadRepository.profilePhotoPolicy.maxWidth, 1600);
    expect(ImageUploadRepository.profilePhotoPolicy.quality, 85);
    expect(ImageUploadRepository.chatImagePolicy.maxWidth, 1440);
    expect(ImageUploadRepository.chatImagePolicy.quality, 78);
    expect(ImageUploadRepository.runClubCoverPolicy.maxHeight, 1200);
    expect(ImageUploadRepository.runPhotoPolicy.maxWidth, 1800);
    expect(
      ImageUploadRepository.policyForPurpose(
        ImageUploadPurpose.runPhoto,
      ).quality,
      82,
    );
  });

  test(
    'rejects out-of-range photo slots before starting upload work',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await expectLater(
        container.read(photoUploadControllerProvider.notifier).pickAndUpload(6),
        throwsRangeError,
      );
    },
  );

  test(
    'serializes overlapping photo writes so newer state is preserved',
    () async {
      final userProfileRepository = FakePhotoUserProfileRepository(
        buildUser(
          uid: 'runner-1',
          photoUrls: const ['https://img.example/old-0.jpg'],
        ),
      );
      final imageUploadRepository = ControlledImageUploadRepository();
      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWith(
            (ref) => userProfileRepository,
          ),
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
      final uploadSubscription = container.listen(
        photoUploadControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uploadSubscription.close);
      await container.pump();

      final controller = container.read(photoUploadControllerProvider.notifier);
      final firstUpload = controller.pickAndUpload(0);
      await container.pump();
      final secondUpload = controller.pickAndUpload(1);
      await container.pump();

      expect(imageUploadRepository.uploadedIndices, [0, 1]);

      imageUploadRepository.uploadCompleters[1].complete(
        const UploadedImage(
          url: 'https://img.example/new-1.jpg',
          storagePath: 'users/runner-1/photos/1_test.jpg',
        ),
      );
      await container.pump();
      imageUploadRepository.uploadCompleters[0].complete(
        const UploadedImage(
          url: 'https://img.example/new-0.jpg',
          storagePath: 'users/runner-1/photos/0_test.jpg',
        ),
      );

      await Future.wait([firstUpload, secondUpload]);

      expect(userProfileRepository.updatedPhotoUrls, [
        ['https://img.example/old-0.jpg', 'https://img.example/new-1.jpg'],
        ['https://img.example/new-0.jpg', 'https://img.example/new-1.jpg'],
      ]);
      expect(userProfileRepository.currentUser.photoUrls, [
        'https://img.example/new-0.jpg',
        'https://img.example/new-1.jpg',
      ]);
      expect(
        container.read(photoUploadControllerProvider).loadingIndices,
        isEmpty,
      );
    },
  );

  test('ignores a second picker request while the first is open', () async {
    final userProfileRepository = FakePhotoUserProfileRepository(
      buildUser(uid: 'runner-1'),
    );
    final imageUploadRepository = SlowPickingImageUploadRepository();
    final container = ProviderContainer(
      overrides: [
        userProfileRepositoryProvider.overrideWith(
          (ref) => userProfileRepository,
        ),
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
    final uploadSubscription = container.listen(
      photoUploadControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(uploadSubscription.close);
    await container.pump();

    final controller = container.read(photoUploadControllerProvider.notifier);
    final firstPick = controller.pickAndUpload(0);
    await container.pump();
    final ignoredPick = controller.pickAndUpload(1);
    await container.pump();

    expect(imageUploadRepository.pickImageCallCount, 1);
    expect(container.read(photoUploadControllerProvider).loadingIndices, {0});

    imageUploadRepository.pickCompleter.complete(null);

    await Future.wait([firstPick, ignoredPick]);

    expect(
      container.read(photoUploadControllerProvider).loadingIndices,
      isEmpty,
    );
    expect(userProfileRepository.updatedPhotoUrls, isEmpty);
  });

  test('completes safely if the provider is disposed mid-upload', () async {
    final userProfileRepository = FakePhotoUserProfileRepository(
      buildUser(uid: 'runner-1'),
    );
    final imageUploadRepository = ControlledImageUploadRepository();
    final container = ProviderContainer(
      overrides: [
        userProfileRepositoryProvider.overrideWith(
          (ref) => userProfileRepository,
        ),
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
    final uploadSubscription = container.listen(
      photoUploadControllerProvider,
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
    uploadSubscription.close();
    imageUploadRepository.uploadCompleters.single.complete(
      const UploadedImage(
        url: 'https://img.example/disposed.jpg',
        storagePath: 'users/runner-1/photos/0_test.jpg',
      ),
    );

    await expectLater(upload, completes);
  });
}
