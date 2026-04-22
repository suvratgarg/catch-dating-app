import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/presentation/run_booking_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fake payment repository ────────────────────────────────────────────────

class _FakePaymentRepository implements PaymentRepository {
  bool bookFreeRunCalled = false;
  String? lastFreeRunId;
  bool processPaymentCalled = false;
  final bool _supportsPaid;

  _FakePaymentRepository({bool supportsPaid = true})
      : _supportsPaid = supportsPaid;

  @override
  bool get supportsPaidBookings => _supportsPaid;

  @override
  Future<void> bookFreeRun({required String runId}) async {
    bookFreeRunCalled = true;
    lastFreeRunId = runId;
  }

  @override
  Future<void> processPayment({
    required String activityId,
    required int amountInPaise,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
  }) async {
    processPaymentCalled = true;
  }

  @override
  void dispose() {}
}

// ── Helpers ────────────────────────────────────────────────────────────────

Run buildRun({
  bool free = true,
  String id = 'run-1',
}) {
  final start = DateTime.now().add(const Duration(hours: 2));
  return Run(
    id: id,
    runClubId: 'club-1',
    startTime: start,
    endTime: start.add(const Duration(hours: 1)),
    meetingPoint: 'Start',
    distanceKm: 5,
    pace: PaceLevel.easy,
    capacityLimit: 20,
    description: '',
    priceInPaise: free ? 0 : 50000,
    constraints: const RunConstraints(),
  );
}

AppUser buildUser() => AppUser(
      uid: 'user-1',
      name: 'Runner',
      dateOfBirth: DateTime(1995, 6, 15),
      gender: Gender.man,
      sexualOrientation: SexualOrientation.straight,
      phoneNumber: '+910000000000',
      profileComplete: true,
      email: 'runner@example.com',
      interestedInGenders: const [Gender.woman],
    );

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('RunBookingController.book()', () {
    test('#29 free run calls bookFreeRun on the payment repository', () async {
      final fakeRepo = _FakePaymentRepository();

      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(runBookingControllerProvider.notifier);
      await controller.book(run: buildRun(free: true), user: buildUser());

      expect(fakeRepo.bookFreeRunCalled, isTrue);
      expect(fakeRepo.lastFreeRunId, 'run-1');
      expect(fakeRepo.processPaymentCalled, isFalse);
    });

    test('#30 paid run calls processPayment when supportsPaidBookings is true', () async {
      final fakeRepo = _FakePaymentRepository(supportsPaid: true);

      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(runBookingControllerProvider.notifier);
      await controller.book(run: buildRun(free: false), user: buildUser());

      expect(fakeRepo.processPaymentCalled, isTrue);
      expect(fakeRepo.bookFreeRunCalled, isFalse);
    });

    test('#31 paid run throws UnsupportedError when supportsPaidBookings is false', () async {
      final fakeRepo = _FakePaymentRepository(supportsPaid: false);

      final container = ProviderContainer(
        overrides: [
          paymentRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final controller =
          container.read(runBookingControllerProvider.notifier);

      expect(
        () => controller.book(run: buildRun(free: false), user: buildUser()),
        throwsA(isA<UnsupportedError>()),
      );
      expect(fakeRepo.processPaymentCalled, isFalse);
    });
  });
}
