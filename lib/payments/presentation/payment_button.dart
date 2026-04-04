import 'package:catch_dating_app/payments/presentation/payment_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentButton extends ConsumerWidget {
  const PaymentButton({
    super.key,
    required this.activityId,
    required this.amountInPaise,
    required this.description,
    required this.userName,
    required this.userEmail,
    required this.userContact,
    this.label = 'Book Activity Slot',
    this.onSuccess,
  });

  final String activityId;
  final int amountInPaise;
  final String description;
  final String userName;
  final String userEmail;
  final String userContact;
  final String label;
  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payMutation = ref.watch(PaymentController.payMutation);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    ref.listen(PaymentController.payMutation, (previous, current) {
      if (previous?.isPending == true && current.isSuccess) {
        onSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed!')),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (payMutation.hasError) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (payMutation as MutationError).error.toString(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        FilledButton(
          onPressed: payMutation.isPending
              ? null
              : () => PaymentController.payMutation.run(ref, (transaction) async {
                    await transaction
                        .get(paymentControllerProvider.notifier)
                        .pay(
                          activityId: activityId,
                          amountInPaise: amountInPaise,
                          description: description,
                          userName: userName,
                          userEmail: userEmail,
                          userContact: userContact,
                        );
                  }),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label),
              if (payMutation.isPending) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
