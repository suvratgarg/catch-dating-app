import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: uidAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (uid) {
          if (uid == null) {
            return const Center(child: Text('Not signed in.'));
          }
          return _PaymentList(userId: uid);
        },
      ),
    );
  }
}

class _PaymentList extends ConsumerWidget {
  const _PaymentList({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsForUserProvider(userId));

    return paymentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (payments) {
        if (payments.isEmpty) {
          return const Center(child: Text('No payments yet.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.p16,
            vertical: Sizes.p12,
          ),
          itemCount: payments.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) =>
              _PaymentTile(payment: payments[index]),
        );
      },
    );
  }
}

class _PaymentTile extends ConsumerWidget {
  const _PaymentTile({required this.payment});

  final Payment payment;

  static final _dateFormat = DateFormat('d MMM yyyy');

  String _formattedAmount(Payment payment) {
    final rupees = payment.amount / 100;
    return rupees == rupees.roundToDouble()
        ? '₹${rupees.round()}'
        : '₹${rupees.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final runAsync = ref.watch(watchRunProvider(payment.runId));
    final runTitle = runAsync.asData?.value?.title ?? 'Run booking';
    final statusPresentation = _statusPresentation(payment);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.p12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(runTitle, style: CatchTextStyles.bodyMd(context)),
                gapH4,
                Text(
                  _dateFormat.format(payment.createdAt),
                  style: CatchTextStyles.caption(context, color: t.ink2),
                ),
                if (statusPresentation.detail case final detail?) ...[
                  gapH4,
                  Text(
                    detail,
                    style: CatchTextStyles.caption(context, color: t.ink2),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formattedAmount(payment),
                style: CatchTextStyles.bodyMd(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              gapH4,
              _StatusChip(
                label: statusPresentation.label,
                color: statusPresentation.color,
              ),
            ],
          ),
        ],
      ),
    );
  }

  ({String label, Color color, String? detail}) _statusPresentation(
    Payment payment,
  ) {
    if (payment.signUpFailed) {
      return switch (payment.status) {
        PaymentStatus.refunded => (
          label: 'Refunded',
          color: Colors.blue.shade700,
          detail: 'Booking failed, but your payment was refunded.',
        ),
        _ => (
          label: 'Booking failed',
          color: Colors.orange.shade700,
          detail: 'No spot was reserved. Refund may still be pending.',
        ),
      };
    }

    return switch (payment.status) {
      PaymentStatus.completed => (
        label: 'Paid',
        color: Colors.green.shade700,
        detail: null,
      ),
      PaymentStatus.refunded => (
        label: 'Refunded',
        color: Colors.blue.shade700,
        detail: null,
      ),
      PaymentStatus.failed => (
        label: 'Failed',
        color: Colors.red.shade700,
        detail: null,
      ),
      PaymentStatus.pending => (
        label: 'Pending',
        color: Colors.orange.shade700,
        detail: null,
      ),
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Sizes.p8,
        vertical: Sizes.p2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Sizes.p4),
      ),
      child: Text(label, style: CatchTextStyles.caption(context, color: color)),
    );
  }
}
