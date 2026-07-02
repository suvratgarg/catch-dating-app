import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';

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
