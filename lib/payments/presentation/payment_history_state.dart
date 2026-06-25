import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const paymentHistoryFallbackEventTitle = 'Event booking';

class PaymentHistoryViewModel {
  const PaymentHistoryViewModel({required this.rows});

  final List<PaymentHistoryRow> rows;

  bool get isEmpty => rows.isEmpty;
}

class PaymentHistoryRow {
  const PaymentHistoryRow({required this.payment, required this.eventTitle});

  final Payment payment;
  final String eventTitle;
}

final paymentHistoryViewModelProvider = Provider.autoDispose
    .family<AsyncValue<PaymentHistoryViewModel>, String>((ref, userId) {
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
    });

PaymentHistoryViewModel buildPaymentHistoryViewModel({
  required List<Payment> payments,
  required List<Event> events,
}) {
  final eventsById = {for (final event in events) event.id: event};
  return PaymentHistoryViewModel(
    rows: [
      for (final payment in payments)
        PaymentHistoryRow(
          payment: payment,
          eventTitle:
              eventsById[payment.eventId]?.title ??
              paymentHistoryFallbackEventTitle,
        ),
    ],
  );
}

List<Event> _resolvedEventsForPayments(Ref ref, List<Payment> payments) {
  final eventIds = {for (final payment in payments) payment.eventId};
  if (eventIds.isEmpty) return const [];

  final eventsAsync = ref.watch(
    watchEventsByIdsProvider(EventsByIdQuery(eventIds)),
  );
  return eventsAsync.asData?.value ?? const [];
}
