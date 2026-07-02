import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardEventFocusController {
  const DashboardEventFocusController({required this.ref});

  final WidgetRef ref;

  static final Mutation<void> selfCheckInMutation =
      EventBookingController.selfCheckInMutation;

  Future<void> selfCheckIn(MutationTransaction tx, Event event) {
    return tx
        .get(eventBookingControllerProvider.notifier)
        .selfCheckIn(eventId: event.id);
  }

  void resetSelfCheckInError() {
    selfCheckInMutation.reset(ref);
  }
}
