import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'payment_history_view_model.g.dart';

@riverpod
AsyncValue<PaymentHistoryViewModel> paymentHistoryViewModel(
  Ref ref,
  String userId,
) {
  final paymentsAsync = ref.watch(watchPaymentsForUserProvider(userId));

  return switch (paymentsAsync) {
    AsyncData(:final value) => AsyncData(
      buildPaymentHistoryViewModel(
        payments: value,
        events: _resolvedEventsForPayments(ref, value),
      ),
    ),
    AsyncError(:final error, :final stackTrace) => AsyncError(
      error,
      stackTrace,
    ),
    _ => const AsyncLoading(),
  };
}

List<Event> _resolvedEventsForPayments(Ref ref, List<Payment> payments) {
  final eventIds = {for (final payment in payments) payment.eventId};
  if (eventIds.isEmpty) return const [];

  final eventsAsync = ref.watch(
    watchEventsByIdsProvider(EventsByIdQuery(eventIds)),
  );
  return eventsAsync.asData?.value ?? const [];
}
