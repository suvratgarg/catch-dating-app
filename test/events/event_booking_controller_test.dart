import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'events_test_helpers.dart';

Future<void> primeUidProvider(ProviderContainer container) async {
  final uidSubscription = container.listen(
    uidProvider,
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(uidSubscription.close);
  await container.pump();
}

void main() {
  group('EventBookingController.book', () {
    test('books a free event through the payment repository', () async {
      final fakePaymentRepository = FakePaymentRepository();
      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      final controller = container.read(
        eventBookingControllerProvider.notifier,
      );
      await controller.book(
        event: buildEvent(),
        user: buildUser(),
        inviteCode: 'CATCH-DELHI',
      );

      expect(fakePaymentRepository.bookFreeEventCalled, isTrue);
      expect(fakePaymentRepository.bookedFreeEventId, 'event-1');
      expect(fakePaymentRepository.bookedFreeEventInviteCode, 'CATCH-DELHI');
      expect(fakePaymentRepository.processPaymentCalled, isFalse);
    });

    test('books a paid event with the full payment payload', () async {
      final fakePaymentRepository = FakePaymentRepository(supportsPaid: true);
      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-7')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      final event = buildEvent(
        id: 'paid-event',
        startTime: DateTime(2025, 1, 2, 6),
        endTime: DateTime(2025, 1, 2, 7),
        priceInPaise: 50000,
      );
      final user = buildUser(
        uid: 'runner-7',
        name: 'Priya',
        email: 'priya@example.com',
        phoneNumber: '+919876543210',
      );

      final controller = container.read(
        eventBookingControllerProvider.notifier,
      );
      await controller.book(event: event, user: user);

      expect(fakePaymentRepository.processPaymentCalled, isTrue);
      expect(fakePaymentRepository.lastProcessPaymentCall, isNotNull);
      expect(
        fakePaymentRepository.lastProcessPaymentCall!.eventId,
        'paid-event',
      );
      expect(
        fakePaymentRepository.lastProcessPaymentCall!.description,
        'Thursday Morning Event · Thu, 2 Jan',
      );
      expect(fakePaymentRepository.lastProcessPaymentCall!.userName, 'Priya');
      expect(
        fakePaymentRepository.lastProcessPaymentCall!.userEmail,
        'priya@example.com',
      );
      expect(
        fakePaymentRepository.lastProcessPaymentCall!.userContact,
        '+919876543210',
      );
      expect(fakePaymentRepository.lastProcessPaymentCall!.inviteCode, isNull);
      expect(fakePaymentRepository.bookFreeEventCalled, isFalse);
    });

    test('passes invite codes through paid bookings', () async {
      final fakePaymentRepository = FakePaymentRepository(supportsPaid: true);
      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-7')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await container
          .read(eventBookingControllerProvider.notifier)
          .book(
            event: buildEvent(id: 'paid-event', priceInPaise: 50000),
            user: buildUser(uid: 'runner-7'),
            inviteCode: 'CATCH-DELHI',
          );

      expect(
        fakePaymentRepository.lastProcessPaymentCall!.inviteCode,
        'CATCH-DELHI',
      );
    });

    test('throws when paid bookings are unsupported on the platform', () async {
      final fakePaymentRepository = FakePaymentRepository(supportsPaid: false);
      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      final controller = container.read(
        eventBookingControllerProvider.notifier,
      );

      await expectLater(
        controller.book(
          event: buildEvent(priceInPaise: 50000),
          user: buildUser(),
        ),
        throwsA(isA<PaidBookingUnsupportedException>()),
      );
      expect(fakePaymentRepository.processPaymentCalled, isFalse);
    });

    test('throws before booking when the user is not signed in', () async {
      final fakePaymentRepository = FakePaymentRepository();
      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          uidProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await expectLater(
        container
            .read(eventBookingControllerProvider.notifier)
            .book(event: buildEvent(), user: buildUser()),
        throwsA(isA<SignInRequiredException>()),
      );
      expect(fakePaymentRepository.bookFreeEventCalled, isFalse);
      expect(fakePaymentRepository.processPaymentCalled, isFalse);
    });
  });

  group('EventBookingController mutations', () {
    test('cancelBooking delegates to the event repository', () async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await container
          .read(eventBookingControllerProvider.notifier)
          .cancelBooking(event: buildEvent(id: 'event-9'));

      expect(fakeEventRepository.cancelledEventId, 'event-9');
    });

    test('cancelHostedEvent delegates to the event repository', () async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await container
          .read(eventBookingControllerProvider.notifier)
          .cancelHostedEvent(
            event: buildEvent(id: 'event-10'),
            reason: 'Weather warning',
          );

      expect(fakeEventRepository.hostCancelledEventId, 'event-10');
      expect(fakeEventRepository.hostCancelReason, 'Weather warning');
    });

    test('deleteHostedEvent delegates to the event repository', () async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await container
          .read(eventBookingControllerProvider.notifier)
          .deleteHostedEvent(event: buildEvent(id: 'event-11'));

      expect(fakeEventRepository.deletedEventId, 'event-11');
    });

    test('deleteHostedEvent throws when the user is not signed in', () async {
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
          uidProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await expectLater(
        container
            .read(eventBookingControllerProvider.notifier)
            .deleteHostedEvent(event: buildEvent()),
        throwsA(isA<SignInRequiredException>()),
      );
    });

    test(
      'joinWaitlist delegates to the server-side waitlist function',
      () async {
        final fakeEventRepository = FakeEventRepository();
        final container = ProviderContainer(
          overrides: [
            eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          ],
        );
        addTearDown(container.dispose);
        await primeUidProvider(container);

        await container
            .read(eventBookingControllerProvider.notifier)
            .joinWaitlist(
              event: buildEvent(id: 'event-42'),
              inviteCode: 'CATCH-DELHI',
            );

        expect(fakeEventRepository.joinedWaitlistEventId, 'event-42');
        expect(fakeEventRepository.joinedWaitlistInviteCode, 'CATCH-DELHI');
      },
    );

    test('leaveWaitlist uses the signed-in uid from auth', () async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-42')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await container
          .read(eventBookingControllerProvider.notifier)
          .leaveWaitlist(event: buildEvent(id: 'event-42'));

      expect(fakeEventRepository.leftWaitlistEventId, 'event-42');
    });

    test('approveJoinRequest delegates to the event repository', () async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await container
          .read(eventBookingControllerProvider.notifier)
          .approveJoinRequest(eventId: 'event-42', userId: 'runner-9');

      expect(fakeEventRepository.decidedJoinRequestEventId, 'event-42');
      expect(fakeEventRepository.decidedJoinRequestUserId, 'runner-9');
      expect(fakeEventRepository.decidedJoinRequestDecision, 'approve');
    });

    test('declineJoinRequest delegates to the event repository', () async {
      final fakeEventRepository = FakeEventRepository();
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          uidProvider.overrideWith((ref) => Stream.value('host-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await container
          .read(eventBookingControllerProvider.notifier)
          .declineJoinRequest(eventId: 'event-42', userId: 'runner-9');

      expect(fakeEventRepository.decidedJoinRequestEventId, 'event-42');
      expect(fakeEventRepository.decidedJoinRequestUserId, 'runner-9');
      expect(fakeEventRepository.decidedJoinRequestDecision, 'decline');
    });

    test('joinWaitlist surfaces repository errors', () async {
      final fakeEventRepository = FakeEventRepository()
        ..joinWaitlistError = StateError('not signed in');
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => fakeEventRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await expectLater(
        container
            .read(eventBookingControllerProvider.notifier)
            .joinWaitlist(event: buildEvent()),
        throwsA(isA<StateError>()),
      );
    });

    test('leaveWaitlist throws when the user is not signed in', () async {
      final container = ProviderContainer(
        overrides: [
          eventRepositoryProvider.overrideWith((ref) => FakeEventRepository()),
          uidProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await expectLater(
        container
            .read(eventBookingControllerProvider.notifier)
            .leaveWaitlist(event: buildEvent()),
        throwsA(isA<SignInRequiredException>()),
      );
    });
  });
}
