import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

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
  group('RunBookingController.book', () {
    test('books a free run through the payment repository', () async {
      final fakePaymentRepository = FakePaymentRepository();
      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      final controller = container.read(runBookingControllerProvider.notifier);
      await controller.book(run: buildRun(), user: buildUser());

      expect(fakePaymentRepository.bookFreeRunCalled, isTrue);
      expect(fakePaymentRepository.bookedFreeRunId, 'run-1');
      expect(fakePaymentRepository.processPaymentCalled, isFalse);
    });

    test('books a paid run with the full payment payload', () async {
      final fakePaymentRepository = FakePaymentRepository(supportsPaid: true);
      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakePaymentRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-7')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      final run = buildRun(
        id: 'paid-run',
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

      final controller = container.read(runBookingControllerProvider.notifier);
      await controller.book(run: run, user: user);

      expect(fakePaymentRepository.processPaymentCalled, isTrue);
      expect(fakePaymentRepository.lastProcessPaymentCall, isNotNull);
      expect(fakePaymentRepository.lastProcessPaymentCall!.runId, 'paid-run');
      expect(
        fakePaymentRepository.lastProcessPaymentCall!.description,
        'Thursday Morning Run · Thu, 2 Jan',
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
      expect(fakePaymentRepository.bookFreeRunCalled, isFalse);
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

      final controller = container.read(runBookingControllerProvider.notifier);

      await expectLater(
        controller.book(run: buildRun(priceInPaise: 50000), user: buildUser()),
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
            .read(runBookingControllerProvider.notifier)
            .book(run: buildRun(), user: buildUser()),
        throwsA(isA<SignInRequiredException>()),
      );
      expect(fakePaymentRepository.bookFreeRunCalled, isFalse);
      expect(fakePaymentRepository.processPaymentCalled, isFalse);
    });
  });

  group('RunBookingController mutations', () {
    test('cancelBooking delegates to the run repository', () async {
      final fakeRunRepository = FakeRunRepository();
      final container = ProviderContainer(
        overrides: [
          runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await container
          .read(runBookingControllerProvider.notifier)
          .cancelBooking(run: buildRun(id: 'run-9'));

      expect(fakeRunRepository.cancelledRunId, 'run-9');
    });

    test(
      'joinWaitlist delegates to the server-side waitlist function',
      () async {
        final fakeRunRepository = FakeRunRepository();
        final container = ProviderContainer(
          overrides: [
            runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
            uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          ],
        );
        addTearDown(container.dispose);
        await primeUidProvider(container);

        await container
            .read(runBookingControllerProvider.notifier)
            .joinWaitlist(run: buildRun(id: 'run-42'));

        expect(fakeRunRepository.joinedWaitlistRunId, 'run-42');
      },
    );

    test('leaveWaitlist uses the signed-in uid from auth', () async {
      final fakeRunRepository = FakeRunRepository();
      final container = ProviderContainer(
        overrides: [
          runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-42')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await container
          .read(runBookingControllerProvider.notifier)
          .leaveWaitlist(run: buildRun(id: 'run-42'));

      expect(fakeRunRepository.leftWaitlistRunId, 'run-42');
      expect(fakeRunRepository.leftWaitlistUserId, 'runner-42');
    });

    test('joinWaitlist surfaces repository errors', () async {
      final fakeRunRepository = FakeRunRepository()
        ..joinWaitlistError = StateError('not signed in');
      final container = ProviderContainer(
        overrides: [
          runRepositoryProvider.overrideWith((ref) => fakeRunRepository),
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await expectLater(
        container
            .read(runBookingControllerProvider.notifier)
            .joinWaitlist(run: buildRun()),
        throwsA(isA<StateError>()),
      );
    });

    test('leaveWaitlist throws when the user is not signed in', () async {
      final container = ProviderContainer(
        overrides: [
          runRepositoryProvider.overrideWith((ref) => FakeRunRepository()),
          uidProvider.overrideWith((ref) => Stream.value(null)),
        ],
      );
      addTearDown(container.dispose);
      await primeUidProvider(container);

      await expectLater(
        container
            .read(runBookingControllerProvider.notifier)
            .leaveWaitlist(run: buildRun()),
        throwsA(isA<SignInRequiredException>()),
      );
    });
  });
}
