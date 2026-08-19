part of 'clubs_controllers_test.dart';

void _registerClubMediaReliabilityTests() {
  test('create cleanup removes uploads when media attachment fails', () async {
    final fakeRepository = FakeClubsRepository()
      ..generatedId = 'club-42'
      ..updateError = StateError('attach failed');
    final image = XFile('/tmp/club-a.jpg');
    final uploads = FakeImageUploadRepository();
    final container = ProviderContainer(
      overrides: [
        clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
        imageUploadRepositoryProvider.overrideWith((ref) => uploads),
        uidProvider.overrideWith((ref) => Stream.value('host-1')),
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

    await expectLater(
      container
          .read(createClubControllerProvider.notifier)
          .submit(
            name: 'Sunset Striders',
            location: buildClub().location,
            area: 'Bandra',
            description: 'Easy social club',
            clubPhotoInputs: [NewClubPhotoInput(image)],
          ),
      throwsStateError,
    );

    expect(uploads.deletedStoragePaths, hasLength(1));
    expect(
      uploads.deletedStoragePaths.single,
      startsWith('organizers/club-42/media/'),
    );
  });

  test('partial media retries reuse successful staged uploads', () async {
    final club = buildClub(ownerUserId: 'host-1');
    final fakeRepository = FakeClubsRepository();
    final uploads = FakeImageUploadRepository()
      ..failingClubMediaIds.add('photo-two');
    final firstImage = XFile.fromData(Uint8List(1), name: 'one.jpg');
    final secondImage = XFile.fromData(Uint8List(1), name: 'two.jpg');
    final container = ProviderContainer(
      overrides: [
        clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
        imageUploadRepositoryProvider.overrideWith((ref) => uploads),
        uidProvider.overrideWith((ref) => Stream.value('host-1')),
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

    final firstResult = await container
        .read(hostClubEditControllerProvider)
        .updateClubMedia(
          club: club,
          photoInputs: [
            HostNewClubPhotoInput(id: 'photo-one', image: firstImage),
            HostNewClubPhotoInput(id: 'photo-two', image: secondImage),
          ],
        );

    expect(firstResult.attached, isFalse);
    expect(firstResult.failures.keys, ['photo-two']);
    expect(fakeRepository.lastUpdatedFields, isNull);

    final retryResult = await container
        .read(hostClubEditControllerProvider)
        .updateClubMedia(club: club, photoInputs: firstResult.photoInputs);

    expect(retryResult.attached, isTrue);
    expect(uploads.uploadedClubMediaIds, [
      'photo-one',
      'photo-two',
      'photo-two',
    ]);
    expect(fakeRepository.lastUpdatedFields?['clubPhotos'], hasLength(2));
  });
}
