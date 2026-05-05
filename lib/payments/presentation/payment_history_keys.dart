import 'package:flutter/widgets.dart';

abstract final class PaymentHistoryKeys {
  static ValueKey<String> paymentTile(String paymentId) =>
      ValueKey('payment-history-tile-$paymentId');
}
