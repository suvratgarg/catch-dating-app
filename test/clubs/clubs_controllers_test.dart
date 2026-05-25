import 'dart:typed_data';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/create/create_club_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_host_management_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'clubs_test_helpers.dart';

ClubMembership _membership({
  String clubId = 'club-1',
  String uid = 'runner-1',
  ClubMembershipStatus status = ClubMembershipStatus.active,
}) => ClubMembership(
  id: clubMembershipId(clubId: clubId, uid: uid),
  clubId: clubId,
  uid: uid,
  role: ClubMembershipRole.member,
  status: status,
  joinedAt: DateTime(2026, 1, 1),
);

void main() {
  group('ClubMembershipController', () {
    test('join requires sign-in and forwards the club id', () async {
      final fakeRepository = FakeClubsRepository();
      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-7')),
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
      await container
          .read(clubMembershipControllerProvider.notifier)
          .join('club-7');

      expect(fakeRepository.joinedClubId, 'club-7');
    });

    test('join throws when there is no signed-in user', () async {
      final container = ProviderContainer(
        overrides: [uidProvider.overrideWith((ref) => Stream.value(null))],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      await container.pump();

      expect(
        () => container
            .read(clubMembershipControllerProvider.notifier)
            .join('club-123'),
        throwsA(isA<SignInRequiredException>()),
      );
    });

    test('leave requires sign-in and forwards the club id', () async {
      final fakeRepository = FakeClubsRepository();
      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-9')),
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
      await container
          .read(clubMembershipControllerProvider.notifier)
          .leave('club-9');

      expect(fakeRepository.leftClubId, 'club-9');
    });

    test('setPushNotifications forwards the club id and preference', () async {
      final fakeRepository = FakeClubsRepository();
      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-10')),
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
      await container
          .read(clubMembershipControllerProvider.notifier)
          .setPushNotifications(clubId: 'club-10', enabled: true);

      expect(fakeRepository.notificationsClubId, 'club-10');
      expect(fakeRepository.notificationsEnabled, isTrue);
    });
  });

  group('ClubHostManagementController', () {
    test('forwards owner host-management actions to the repository', () async {
      final fakeRepository = FakeClubsRepository();
      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          uidProvider.overrideWith((ref) => Stream.value('owner-1')),
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

      final controller = container.read(
        clubHostManagementControllerProvider.notifier,
      );
      await controller.addHostByPhone(
        clubId: 'club-1',
        phoneNumber: '98765 43210',
      );
      await controller.removeHost(clubId: 'club-1', uid: 'host-2');
      await controller.transferOwnership(clubId: 'club-1', uid: 'host-2');
      final matchId = await controller.startConversation(
        clubId: 'club-1',
        hostUid: 'host-2',
      );

      expect(fakeRepository.addedHostClubId, 'club-1');
      expect(fakeRepository.addedHostPhoneNumber, '98765 43210');
      expect(fakeRepository.removedHostClubId, 'club-1');
      expect(fakeRepository.removedHostUid, 'host-2');
      expect(fakeRepository.transferredOwnershipClubId, 'club-1');
      expect(fakeRepository.transferredOwnershipUid, 'host-2');
      expect(fakeRepository.startedConversationClubId, 'club-1');
      expect(fakeRepository.startedConversationHostUid, 'host-2');
      expect(matchId, fakeRepository.nextHostConversationMatchId);
    });
  });

  group('ClubDetailViewModel', () {
    test('builds derived state for hosts, members, and upcoming events', () {
      final now = DateTime(2025, 1, 1, 9);
      final futureEvent = buildEvent(
        id: 'future-event',
        startTime: now.add(const Duration(hours: 2)),
      );
      final soonerFutureRun = buildEvent(
        id: 'sooner-future-event',
        startTime: now.add(const Duration(hours: 1)),
      );
      final pastEvent = buildEvent(
        id: 'past-event',
        startTime: now.subtract(const Duration(hours: 2)),
      );
      final result = buildClubDetailViewModel(
        clubAsync: AsyncData(buildClub(hostUserId: 'host-1')),
        eventsAsync: AsyncData([futureEvent, pastEvent, soonerFutureRun]),
        reviewsAsync: AsyncData([buildReview()]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: AsyncData(_membership()),
        now: now,
      );

      final vm = result.requireValue!;
      expect(vm.isHost, isFalse);
      expect(vm.isMember, isTrue);
      expect(vm.upcomingEvents.map((event) => event.id), [
        'sooner-future-event',
        'future-event',
      ]);
      expect(vm.reviews, hasLength(1));
    });

    test('returns loading while a core dependency is still loading', () {
      final result = buildClubDetailViewModel(
        clubAsync: const AsyncLoading(),
        eventsAsync: const AsyncData(<Event>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.isLoading, isTrue);
    });

    test('keeps schedule visible while secondary auth data hydrates', () {
      final now = DateTime(2025, 1, 1, 9);
      final futureEvent = buildEvent(
        id: 'future-event',
        startTime: now.add(const Duration(hours: 1)),
      );

      final result = buildClubDetailViewModel(
        clubAsync: AsyncData(buildClub(hostUserId: 'host-1')),
        eventsAsync: AsyncData([futureEvent]),
        reviewsAsync: const AsyncLoading(),
        userProfileAsync: const AsyncLoading(),
        uidAsync: const AsyncData('host-1'),
        membershipAsync: const AsyncLoading(),
        now: now,
      );

      final vm = result.requireValue!;
      expect(vm.isHost, isTrue);
      expect(vm.upcomingEvents.map((event) => event.id), ['future-event']);
      expect(vm.reviews, isEmpty);
      expect(vm.userProfile, isNull);
      expect(vm.isMember, isFalse);
    });

    test('returns null data when the club stream yields no club', () {
      final result = buildClubDetailViewModel(
        clubAsync: const AsyncData(null),
        eventsAsync: const AsyncData(<Event>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.value, isNull);
    });

    test('surfaces club stream errors', () {
      final result = buildClubDetailViewModel(
        clubAsync: AsyncError(StateError('club failed'), StackTrace.empty),
        eventsAsync: const AsyncData(<Event>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('surfaces event stream errors', () {
      final result = buildClubDetailViewModel(
        clubAsync: AsyncData(buildClub()),
        eventsAsync: AsyncError(StateError('events failed'), StackTrace.empty),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('uses empty reviews when the review stream is unavailable', () {
      final result = buildClubDetailViewModel(
        clubAsync: AsyncData(buildClub()),
        eventsAsync: const AsyncData(<Event>[]),
        reviewsAsync: AsyncError(
          StateError('reviews failed'),
          StackTrace.empty,
        ),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.requireValue!.reviews, isEmpty);
    });

    test('surfaces uid stream errors', () {
      final result = buildClubDetailViewModel(
        clubAsync: AsyncData(buildClub()),
        eventsAsync: const AsyncData(<Event>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncData(buildUser(uid: 'runner-1')),
        uidAsync: AsyncError(StateError('uid failed'), StackTrace.empty),
        membershipAsync: const AsyncData(null),
      );

      expect(result.hasError, isTrue);
      expect(result.error, isA<StateError>());
    });

    test('uses null profile when profile stream is unavailable', () {
      final result = buildClubDetailViewModel(
        clubAsync: AsyncData(buildClub()),
        eventsAsync: const AsyncData(<Event>[]),
        reviewsAsync: const AsyncData(<Review>[]),
        userProfileAsync: AsyncError(
          StateError('app user failed'),
          StackTrace.empty,
        ),
        uidAsync: const AsyncData('runner-1'),
        membershipAsync: const AsyncData(null),
      );

      expect(result.requireValue!.userProfile, isNull);
    });
  });

  group('CreateClubController', () {
    test('picks a cover image and reads preview bytes', () async {
      final image = XFile.fromData(
        Uint8List.fromList(const [1, 2, 3]),
        name: 'club-cover.png',
      );
      final fakeImageUploadRepository = FakeImageUploadRepository(
        pickedImage: image,
      );
      final container = ProviderContainer(
        overrides: [
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
        ],
      );
      addTearDown(container.dispose);

      final picked = await container
          .read(createClubControllerProvider.notifier)
          .pickCoverImage();

      expect(picked?.image, image);
      expect(picked?.bytes, [1, 2, 3]);
    });

    test(
      'creates a club through the repository when there is no cover image',
      () async {
        final fakeRepository = FakeClubsRepository();
        final fakeImageUploadRepository = FakeImageUploadRepository();
        final container = ProviderContainer(
          overrides: [
            clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
            imageUploadRepositoryProvider.overrideWith(
              (ref) => fakeImageUploadRepository,
            ),
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

        await container
            .read(createClubControllerProvider.notifier)
            .submit(
              name: 'Sunset Striders',
              location: buildClub().location,
              area: 'Bandra',
              description: 'Easy social club',
            );

        expect(fakeRepository.lastCreateCall, isNotNull);
        expect(
          fakeRepository.lastCreateCall!.clubId,
          fakeRepository.generatedId,
        );
        expect(fakeRepository.lastCreateCall!.imageUrl, isNull);
        expect(fakeImageUploadRepository.lastUploadClubId, isNull);
      },
    );

    test('creates the club before uploading new club media', () async {
      final fakeRepository = FakeClubsRepository()..generatedId = 'club-42';
      final fakeImageUploadRepository = FakeImageUploadRepository(
        pickedImage: XFile('/tmp/club-cover.jpg'),
      );
      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
          watchUserProfileProvider.overrideWith(
            (ref) => Stream.value(buildUser(uid: 'host-1', name: 'Priya')),
          ),
        ],
      );
      addTearDown(container.dispose);
      final uidSubscription = container.listen(
        uidProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(uidSubscription.close);
      final userProfileSubscription = container.listen(
        watchUserProfileProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(userProfileSubscription.close);
      await container.pump();
      await container.pump();

      await container
          .read(createClubControllerProvider.notifier)
          .submit(
            name: 'Sunset Striders',
            location: buildClub().location,
            area: 'Bandra',
            description: 'Easy social club',
            coverImage: fakeImageUploadRepository.pickedImage,
          );

      expect(fakeImageUploadRepository.lastUploadClubId, 'club-42');
      expect(fakeRepository.lastCreateCall, isNotNull);
      expect(fakeRepository.lastCreateCall!.clubId, 'club-42');
      expect(fakeRepository.lastCreateCall!.imageUrl, isNull);
      expect(fakeRepository.lastUpdatedClubId, 'club-42');
      expect(
        fakeRepository.lastUpdatedFields,
        containsPair('imageUrl', fakeImageUploadRepository.uploadResult),
      );
    });

    test('creates a club without requiring profile state', () async {
      final fakeRepository = FakeClubsRepository();
      final fakeImageUploadRepository = FakeImageUploadRepository();
      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
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

      await container
          .read(createClubControllerProvider.notifier)
          .submit(
            name: 'Sunset Striders',
            location: buildClub().location,
            area: 'Bandra',
            description: 'Easy social club',
          );

      expect(fakeRepository.lastCreateCall, isNotNull);
      expect(fakeRepository.lastCreateCall!.clubId, fakeRepository.generatedId);
    });

    test('updates an existing club without requiring profile state', () async {
      final existingClub = buildClub(
        id: 'club-1',
        name: 'Old Name',
        description: 'Old description',
        area: 'Bandra',
        imageUrl: 'https://example.com/old.jpg',
        instagramHandle: '@oldclub',
        phoneNumber: '+91 99999 99999',
        email: 'old@example.com',
        memberCount: 2,
        rating: 4.5,
        reviewCount: 8,
        nextEventLabel: 'Sat 6:30 AM',
      );
      final fakeRepository = FakeClubsRepository();
      final fakeImageUploadRepository = FakeImageUploadRepository();
      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
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

      await container
          .read(createClubControllerProvider.notifier)
          .submit(
            name: 'New Name',
            location: 'indore',
            area: 'Vijay Nagar',
            description: 'Updated description',
            existingClub: existingClub,
          );

      expect(fakeRepository.lastUpdatedClubId, existingClub.id);
      final fields = fakeRepository.lastUpdatedFields;
      expect(fields, isNotNull);
      expect(fields!['name'], 'New Name');
      expect(fields['location'], 'indore');
      expect(fields['area'], 'Vijay Nagar');
      expect(fields['description'], 'Updated description');
      // When no new cover is uploaded, imageUrl stays as the existing one.
      expect(fields['imageUrl'], existingClub.imageUrl);
      expect(fields['instagramHandle'], isNull);
      expect(fields['phoneNumber'], isNull);
      expect(fields['email'], isNull);
      expect(fakeImageUploadRepository.lastUploadClubId, isNull);
    });

    test('uploads a replacement cover when editing with a new image', () async {
      final existingClub = buildClub(
        id: 'club-1',
        imageUrl: 'https://example.com/old.jpg',
      );
      final fakeRepository = FakeClubsRepository();
      final fakeImageUploadRepository = FakeImageUploadRepository(
        pickedImage: XFile('/tmp/club-cover.jpg'),
        uploadResult: 'https://example.com/new.jpg',
      );
      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
          imageUploadRepositoryProvider.overrideWith(
            (ref) => fakeImageUploadRepository,
          ),
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

      await container
          .read(createClubControllerProvider.notifier)
          .submit(
            name: existingClub.name,
            location: existingClub.location,
            area: existingClub.area,
            description: existingClub.description,
            existingClub: existingClub,
            coverImage: fakeImageUploadRepository.pickedImage,
          );

      expect(fakeImageUploadRepository.lastUploadClubId, 'club-1');
      expect(
        fakeRepository.lastUpdatedFields!['imageUrl'],
        'https://example.com/new.jpg',
      );
    });

    test(
      'lets a co-host update club media without changing owner fields',
      () async {
        final existingClub = buildClub(
          id: 'club-1',
          hostUserId: 'owner-1',
          ownerUserId: 'owner-1',
          hostUserIds: const ['owner-1', 'cohost-1'],
          imageUrl: 'https://example.com/old.jpg',
        );
        final fakeRepository = FakeClubsRepository();
        final fakeImageUploadRepository = FakeImageUploadRepository(
          pickedImage: XFile('/tmp/club-cover.jpg'),
          uploadResult: 'https://example.com/new.jpg',
        );
        final container = ProviderContainer(
          overrides: [
            clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
            imageUploadRepositoryProvider.overrideWith(
              (ref) => fakeImageUploadRepository,
            ),
            uidProvider.overrideWith((ref) => Stream.value('cohost-1')),
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

        await container
            .read(createClubControllerProvider.notifier)
            .submit(
              name: 'Ignored Name',
              location: 'indore',
              area: 'Ignored Area',
              description: 'Ignored description',
              existingClub: existingClub,
              coverImage: fakeImageUploadRepository.pickedImage,
            );

        expect(fakeImageUploadRepository.lastUploadClubId, 'club-1');
        expect(fakeRepository.lastUpdatedClubId, 'club-1');
        expect(fakeRepository.lastUpdatedFields, {
          'imageUrl': 'https://example.com/new.jpg',
        });
      },
    );

    test('rejects editing by a non-host user', () async {
      final container = ProviderContainer(
        overrides: [
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

      expect(
        () => container
            .read(createClubControllerProvider.notifier)
            .submit(
              name: 'New Name',
              location: 'mumbai',
              area: 'Bandra',
              description: 'Updated description',
              existingClub: buildClub(hostUserId: 'host-1'),
            ),
        throwsA(isA<StateError>()),
      );
    });
  });
}
