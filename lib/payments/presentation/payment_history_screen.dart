import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/core/widgets/detail_row.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);

    return Scaffold(
      appBar: const CatchTopBar(title: 'Payment history'),
      body: uidAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (e, _) => CatchErrorState.fromError(
          e,
          context: AppErrorContext.payments,
          onRetry: () => ref.invalidate(uidProvider),
        ),
        data: (uid) {
          if (uid == null) {
            return Center(
              child: CatchEmptyState(
                icon: CatchIcons.lockOutlineRounded,
                title: 'Sign in required',
                message: 'Sign in again to view payment history.',
              ),
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
    final paymentsAsync = ref.watch(watchPaymentsForUserProvider(userId));

    return paymentsAsync.when(
      loading: () => const CatchLoadingIndicator(),
      error: (e, _) => CatchErrorState.fromError(
        e,
        context: AppErrorContext.payments,
        onRetry: () => ref.invalidate(watchPaymentsForUserProvider(userId)),
      ),
      data: (payments) {
        if (payments.isEmpty) {
          return Center(
            child: CatchEmptyState(
              icon: CatchIcons.receiptLongOutlined,
              title: 'No payments yet',
              message: 'Event bookings and refunds will appear here.',
            ),
          );
        }
        return ListView.separated(
          padding: CatchInsets.listBody,
          itemCount: payments.length,
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
              child: _PaymentTile(payment: payments[index]),
            ),
          ),
        );
      },
    );
  }
}

class _PaymentTile extends ConsumerWidget {
  const _PaymentTile({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final eventAsync = ref.watch(watchEventProvider(payment.eventId));
    final eventTitle = eventAsync.asData?.value?.title ?? 'Event booking';
    final statusPresentation = _statusPresentation(payment);

    return Semantics(
      button: true,
      label: 'Payment for $eventTitle',
      child: Padding(
        padding: CatchInsets.contentVertical,
        child: InkWell(
          key: PaymentHistoryKeys.paymentTile(payment.id),
          borderRadius: BorderRadius.circular(CatchRadius.md),
          onTap: () => _showDetailSheet(context, ref, eventTitle),
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

  void _showDetailSheet(
    BuildContext context,
    WidgetRef ref,
    String eventTitle,
  ) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final statusPresentation = _statusPresentation(payment);

    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(CatchRadius.lg),
        ),
      ),
      builder: (sheetContext) {
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
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please contact Catch support for assistance with this booking.',
                                style: CatchTextStyles.labelL(
                                  context,
                                  color: CatchTokens.of(context).bg,
                                ),
                              ),
                            ),
                          );
                        },
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
