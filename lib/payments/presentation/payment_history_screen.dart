import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_row.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_keys.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);

    return Scaffold(
      appBar: const CatchTopBar(title: 'Payment history'),
      body: CatchAsyncValueView<String?>(
        value: uidAsync,
        loadingBuilder: (_) => const _PaymentHistorySkeleton(),
        errorContext: AppErrorContext.payments,
        onRetry: () => ref.invalidate(uidProvider),
        builder: (context, uid) {
          if (uid == null) {
            return _PaymentHistoryEmpty(
              icon: CatchIcons.lockOutlineRounded,
              title: 'Sign in required',
              message: 'Sign in again to view payment history.',
            );
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
    final paymentHistoryAsync = ref.watch(
      paymentHistoryViewModelProvider(userId),
    );

    return CatchAsyncValueView<PaymentHistoryViewModel>(
      value: paymentHistoryAsync,
      loadingBuilder: (_) => const _PaymentHistorySkeleton(),
      errorContext: AppErrorContext.payments,
      onRetry: () => ref.invalidate(watchPaymentsForUserProvider(userId)),
      builder: (context, paymentHistory) {
        if (paymentHistory.isEmpty) {
          return _PaymentHistoryEmpty(
            icon: CatchIcons.receiptLongOutlined,
            title: 'No payments yet',
            message: 'Event bookings and refunds will appear here.',
          );
        }
        return ListView.separated(
          padding: CatchInsets.listBody,
          itemCount: paymentHistory.rows.length,
          separatorBuilder: (context, _) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: Divider(color: CatchTokens.of(context).line, height: 1),
            ),
          ),
          itemBuilder: (context, index) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: CatchLayout.maxContentWidth,
              ),
              child: _PaymentTile(row: paymentHistory.rows[index]),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentHistorySkeleton extends StatelessWidget {
  const _PaymentHistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: CatchInsets.listBody,
      itemCount: 5,
      separatorBuilder: (context, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: Divider(color: CatchTokens.of(context).line, height: 1),
        ),
      ),
      itemBuilder: (context, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: const _PaymentHistoryTileSkeleton(),
        ),
      ),
    );
  }
}

class _PaymentHistoryTileSkeleton extends StatelessWidget {
  const _PaymentHistoryTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.contentVertical,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s1,
          vertical: CatchSpacing.s2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CatchSkeleton.text(width: 190),
                  gapH8,
                  CatchSkeleton.text(width: 126),
                  gapH6,
                  CatchSkeleton.text(width: 150),
                ],
              ),
            ),
            gapW16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CatchSkeleton.text(width: 72),
                gapH8,
                CatchSkeleton.box(
                  width: 76,
                  height: CatchSpacing.s5,
                  radius: CatchRadius.pill,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentHistoryEmpty extends StatelessWidget {
  const _PaymentHistoryEmpty({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return CatchScreenBody(
      scrollable: false,
      child: Center(
        child: CatchEmptyState(icon: icon, title: title, message: message),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.row});

  final PaymentHistoryRow row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final payment = row.payment;
    final eventTitle = row.eventTitle;
    final statusPresentation = paymentStatusPresentation(payment);

    return Semantics(
      button: true,
      label: 'Payment for $eventTitle',
      child: Padding(
        padding: CatchInsets.contentVertical,
        child: InkWell(
          key: PaymentHistoryKeys.paymentTile(payment.id),
          borderRadius: BorderRadius.circular(CatchRadius.md),
          onTap: () => _showDetailSheet(context, eventTitle),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CatchSpacing.s1,
              vertical: CatchSpacing.s2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventTitle,
                        style: CatchTextStyles.sectionTitle(context),
                      ),
                      gapH4,
                      Text(
                        AppTimeFormatters.dateTime(payment.createdAt),
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                      if (statusPresentation.detail case final detail?) ...[
                        gapH4,
                        Text(
                          detail,
                          style: CatchTextStyles.supporting(
                            context,
                            color: t.ink2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      EventFormatters.priceInPaise(
                        payment.amount,
                        currencyCode: payment.currency,
                      ),
                      style: CatchTextStyles.statCompact(context),
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
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, String eventTitle) {
    final t = CatchTokens.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CatchRadius.lg),
        ),
      ),
      builder: (sheetContext) {
        return PaymentReceiptSheet(
          payment: row.payment,
          eventTitle: eventTitle,
          onHelp: () {
            Navigator.of(sheetContext).pop();
            showCatchSnackBar(
              context,
              'Please contact Catch support for assistance with this booking.',
            );
          },
        );
      },
    );
  }
}

class PaymentReceiptSheet extends StatelessWidget {
  const PaymentReceiptSheet({
    super.key,
    required this.payment,
    required this.eventTitle,
    this.onHelp,
  });

  final Payment payment;
  final String eventTitle;
  final VoidCallback? onHelp;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final statusPresentation = paymentStatusPresentation(payment);

    return SafeArea(
      child: SingleChildScrollView(
        child: CatchBottomSheetScaffold(
          title: eventTitle,
          padding: EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s3,
            CatchSpacing.s5,
            CatchSpacing.s5 + bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CatchBadge(
                    label: statusPresentation.label,
                    tone: statusPresentation.tone,
                    size: CatchBadgeSize.md,
                  ),
                  const Spacer(),
                  Text(
                    EventFormatters.priceInPaise(
                      payment.amount,
                      currencyCode: payment.currency,
                    ),
                    style: CatchTextStyles.titleL(context),
                  ),
                ],
              ),
              gapH20,
              Divider(color: t.line, height: 1),
              gapH20,
              CatchDetailRow(label: 'Payment ID', value: payment.paymentId),
              gapH12,
              CatchDetailRow(label: 'Order ID', value: payment.orderId),
              gapH12,
              CatchDetailRow(label: 'Event ID', value: payment.eventId),
              gapH12,
              CatchDetailRow(
                label: 'Date',
                value: AppTimeFormatters.dateTime(payment.createdAt),
              ),
              if (statusPresentation.detail case final detail?) ...[
                gapH12,
                CatchDetailRow(label: 'Status', value: detail),
              ],
              if (payment.signUpFailed) ...[
                gapH20,
                Divider(color: t.line, height: 1),
                gapH16,
                SizedBox(
                  width: double.infinity,
                  child: CatchButton(
                    label: 'Get help with this booking',
                    onPressed: onHelp,
                    icon: Icon(CatchIcons.helpOutlineRounded),
                    variant: CatchButtonVariant.secondary,
                    foregroundColor: t.warning,
                    borderColor: t.warning.withValues(
                      alpha: CatchOpacity.paymentHelpBorder,
                    ),
                    fullWidth: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

({String label, CatchBadgeTone tone, String? detail}) paymentStatusPresentation(
  Payment payment,
) {
  if (payment.signUpFailed) {
    return switch (payment.status) {
      PaymentStatus.refunded => (
        label: 'Refunded',
        tone: CatchBadgeTone.brand,
        detail: 'Booking failed, but your payment was refunded.',
      ),
      PaymentStatus.refundFailed => (
        label: 'Refund pending',
        tone: CatchBadgeTone.danger,
        detail:
            'No spot was reserved and the refund needs attention. '
            'Please contact support.',
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
    PaymentStatus.refundFailed => (
      label: 'Refund pending',
      tone: CatchBadgeTone.danger,
      detail: 'Your refund needs attention. Please contact support.',
    ),
    PaymentStatus.pending => (
      label: 'Pending',
      tone: CatchBadgeTone.warning,
      detail: null,
    ),
  };
}
