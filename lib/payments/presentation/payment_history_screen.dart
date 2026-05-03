import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
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
      appBar: const CatchTopBar(title: 'Payment history'),
      body: uidAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(firestoreErrorMessage(e))),
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

  static final _dateFormat = DateFormat('d MMM yyyy · HH:mm');

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

    return GestureDetector(
      onTap: () => _showDetailSheet(context, ref, runTitle),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.p12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(runTitle, style: CatchTextStyles.bodyM(context)),
                  gapH4,
                  Text(
                    _dateFormat.format(payment.createdAt),
                    style: CatchTextStyles.bodyS(context, color: t.ink2),
                  ),
                  if (statusPresentation.detail case final detail?) ...[
                    gapH4,
                    Text(
                      detail,
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
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
                  style: CatchTextStyles.bodyM(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                gapH4,
                CatchBadge(
                  label: statusPresentation.label,
                  tone: statusPresentation.tone,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(
    BuildContext context,
    WidgetRef ref,
    String runTitle,
  ) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final statusPresentation = _statusPresentation(payment);

    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(CatchRadius.lg)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              Sizes.p20,
              Sizes.p20,
              Sizes.p20,
              Sizes.p20 + bottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Grabber
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: t.line2,
                    borderRadius: BorderRadius.circular(CatchRadius.pill),
                  ),
                ),
              ),
              gapH16,
              // Header
              Text(runTitle, style: CatchTextStyles.titleL(context)),
              gapH8,
              Row(
                children: [
                  CatchBadge(
                    label: statusPresentation.label,
                    tone: statusPresentation.tone,
                    size: CatchBadgeSize.md,
                  ),
                  const Spacer(),
                  Text(
                    _formattedAmount(payment),
                    style: CatchTextStyles.displayS(context),
                  ),
                ],
              ),
              gapH20,
              Divider(color: t.line, height: 1),
              gapH20,
              // Detail rows
              _DetailRow(label: 'Payment ID', value: payment.paymentId),
              gapH12,
              _DetailRow(label: 'Order ID', value: payment.orderId),
              gapH12,
              _DetailRow(label: 'Run ID', value: payment.runId),
              gapH12,
              _DetailRow(
                label: 'Date',
                value: _dateFormat.format(payment.createdAt),
              ),
              if (statusPresentation.detail case final detail?) ...[
                gapH12,
                _DetailRow(label: 'Status', value: detail),
              ],
              if (payment.signUpFailed) ...[
                gapH20,
                Divider(color: t.line, height: 1),
                gapH16,
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please contact Catch support for assistance with this booking.',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.help_outline_rounded, size: 18),
                    label: const Text('Get help with this booking'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.warning,
                      side: BorderSide(color: t.warning.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(CatchRadius.pill),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
            ),
          ),
        );
      },
    );
  }

  ({String label, CatchBadgeTone tone, String? detail}) _statusPresentation(
    Payment payment,
  ) {
    if (payment.signUpFailed) {
      return switch (payment.status) {
        PaymentStatus.refunded => (
          label: 'Refunded',
          tone: CatchBadgeTone.brand,
          detail: 'Booking failed, but your payment was refunded.',
        ),
        _ => (
          label: 'Booking failed',
          tone: CatchBadgeTone.warning,
          detail: 'No spot was reserved. Refund may still be pending.',
        ),
      };
    }

    return switch (payment.status) {
      PaymentStatus.completed => (
        label: 'Paid',
        tone: CatchBadgeTone.success,
        detail: null,
      ),
      PaymentStatus.refunded => (
        label: 'Refunded',
        tone: CatchBadgeTone.brand,
        detail: null,
      ),
      PaymentStatus.failed => (
        label: 'Failed',
        tone: CatchBadgeTone.danger,
        detail: null,
      ),
      PaymentStatus.pending => (
        label: 'Pending',
        tone: CatchBadgeTone.warning,
        detail: null,
      ),
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: CatchTextStyles.bodyS(context, color: t.ink3),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: CatchTextStyles.bodyS(context, color: t.ink).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
