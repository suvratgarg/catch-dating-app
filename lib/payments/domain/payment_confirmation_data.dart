/// Data carried from a successful Razorpay payment to the confirmation screen.
class PaymentConfirmationData {
  const PaymentConfirmationData({
    required this.paymentId,
    required this.orderId,
    required this.amountInPaise,
    required this.runId,
  });

  final String paymentId;
  final String orderId;
  final int amountInPaise;
  final String runId;
}
