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
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/payments/data/payment_history_repository.dart';
import 'package:catch_dating_app/payments/domain/payment.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_keys.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_state.dart';
import 'package:catch_dating_app/payments/presentation/payment_history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);

    return Scaffold(
      appBar: CatchTopBar(
        title: context.l10n.paymentsPaymentHistoryScreenTitlePaymentHistory,
      ),
      body: CatchAsyncValueView<String?>(
        value: uidAsync,
        loadingBuilder: (_) => const PaymentHistorySkeleton(),
        errorContext: AppErrorContext.payments,
        onRetry: () => ref.invalidate(uidProvider),
        builder: (context, uid) {
          if (uid == null) {
            return CatchScreenBody(
              scrollable: false,
              child: Center(
                child: CatchEmptyState(
                  icon: CatchIcons.lockOutlineRounded,
                  title: context
                      .l10n
                      .paymentsPaymentHistoryScreenTitleSignInRequired,
                  message: context
                      .l10n
                      .paymentsPaymentHistoryScreenMessageSignInAgainTo,
                ),
              ),
            );
          }
          return PaymentHistoryListController(userId: uid);
        },
      ),
    );
  }
}

class PaymentHistoryListController extends ConsumerWidget {
  const PaymentHistoryListController({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentHistoryAsync = ref.watch(
      paymentHistoryViewModelProvider(userId),
    );

    return CatchAsyncValueView<PaymentHistoryViewModel>(
      value: paymentHistoryAsync,
      loadingBuilder: (_) => const PaymentHistorySkeleton(),
      errorContext: AppErrorContext.payments,
      onRetry: () => ref.invalidate(watchPaymentsForUserProvider(userId)),
      builder: (context, paymentHistory) =>
          PaymentHistoryList(paymentHistory: paymentHistory),
    );
  }
}

class PaymentHistoryList extends StatelessWidget {
  const PaymentHistoryList({super.key, required this.paymentHistory});

  final PaymentHistoryViewModel paymentHistory;

  @override
  Widget build(BuildContext context) {
    if (paymentHistory.isEmpty) {
      return CatchScreenBody(
        scrollable: false,
        child: Center(
          child: CatchEmptyState(
            icon: CatchIcons.receiptLongOutlined,
            title: context.l10n.paymentsPaymentHistoryScreenTitleNoPaymentsYet,
            message: context
                .l10n
                .paymentsPaymentHistoryScreenMessageEventBookingsAndRefunds,
          ),
        ),
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
          child: const CatchDivider.fieldRow(indent: 0),
        ),
      ),
      itemBuilder: (context, index) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: PaymentHistoryTile(row: paymentHistory.rows[index]),
        ),
      ),
    );
  }
}

class PaymentHistorySkeleton extends StatelessWidget {
  const PaymentHistorySkeleton({super.key});

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
          child: const CatchDivider.fieldRow(indent: 0),
        ),
      ),
      itemBuilder: (context, _) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.maxContentWidth,
          ),
          child: const PaymentHistoryTileSkeleton(),
        ),
      ),
    );
  }
}

class PaymentHistoryTileSkeleton extends StatelessWidget {
  const PaymentHistoryTileSkeleton({super.key});

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
                  CatchSkeleton.text(width: CatchLayout.skeletonTextLongWidth),
                  gapH8,
                  CatchSkeleton.text(
                    width: CatchLayout.skeletonTextSecondaryWidth,
                  ),
                  gapH6,
                  CatchSkeleton.text(width: CatchLayout.skeletonTextWideWidth),
                ],
              ),
            ),
            gapW16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CatchSkeleton.text(width: CatchLayout.skeletonTextStatusWidth),
                gapH8,
                CatchSkeleton.box(
                  width: CatchLayout.skeletonTextActionWidth,
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

class PaymentHistoryTile extends StatelessWidget {
  const PaymentHistoryTile({super.key, required this.row});

  final PaymentHistoryRow row;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final payment = row.payment;
    final eventTitle = row.eventTitle;
    final statusPresentation = paymentStatusPresentation(payment, context.l10n);

    return Semantics(
      button: true,
      label: context.l10n.paymentsPaymentHistoryScreenLabelPaymentForEventtitle(
        eventTitle: eventTitle,
      ),
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

    showCatchBottomSheet(
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
    final statusPresentation = paymentStatusPresentation(payment, context.l10n);

    return SafeArea(
      child: SingleChildScrollView(
        child: CatchBottomSheetScaffold(
          title: eventTitle,
          padding: CatchInsets.pageBody.copyWith(
            top: CatchSpacing.s3,
            bottom: CatchSpacing.s5 + bottomPadding,
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
              const CatchDivider.section(),
              gapH20,
              CatchField.read(
                title: context.l10n.paymentsPaymentHistoryScreenTitlePaymentId,
                body: payment.paymentId,
              ),
              gapH12,
              CatchField.read(
                title: context.l10n.paymentsPaymentHistoryScreenTitleOrderId,
                body: payment.orderId,
              ),
              gapH12,
              CatchField.read(
                title: context.l10n.paymentsPaymentHistoryScreenTitleEventId,
                body: payment.eventId,
              ),
              gapH12,
              CatchField.read(
                title: context.l10n.paymentsPaymentHistoryScreenTitleDate,
                body: AppTimeFormatters.dateTime(payment.createdAt),
              ),
              if (statusPresentation.detail case final detail?) ...[
                gapH12,
                CatchField.read(
                  title: context.l10n.paymentsPaymentHistoryScreenTitleStatus,
                  body: detail,
                ),
              ],
              if (payment.signUpFailed) ...[
                gapH20,
                const CatchDivider.section(),
                gapH16,
                SizedBox(
                  width: double.infinity,
                  child: CatchButton(
                    label: context
                        .l10n
                        .paymentsPaymentHistoryScreenLabelGetHelpWithThis,
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
  AppLocalizations l10n,
) {
  if (payment.signUpFailed) {
    return switch (payment.status) {
      PaymentStatus.refunded => (
        label: l10n.paymentsPaymentHistoryScreenLabelRefunded,
        tone: CatchBadgeTone.brand,
        detail: l10n.paymentsPaymentHistoryScreenDetailBookingFailedButYour,
      ),
      PaymentStatus.refundFailed => (
        label: l10n.paymentsPaymentHistoryScreenLabelRefundPending,
        tone: CatchBadgeTone.danger,
        detail: l10n.paymentsPaymentHistoryScreenDetailNoSpotWasReserved,
      ),
      _ => (
        label: l10n.paymentsPaymentHistoryScreenLabelBookingFailed,
        tone: CatchBadgeTone.warning,
        detail: l10n.paymentsPaymentHistoryScreenDetailNoSpotWasReservedd0a580,
      ),
    };
  }

  return switch (payment.status) {
    PaymentStatus.completed => (
      label: l10n.paymentsPaymentHistoryScreenLabelPaid,
      tone: CatchBadgeTone.success,
      detail: null,
    ),
    PaymentStatus.refunded => (
      label: l10n.paymentsPaymentHistoryScreenLabelRefunded,
      tone: CatchBadgeTone.brand,
      detail: null,
    ),
    PaymentStatus.failed => (
      label: l10n.paymentsPaymentHistoryScreenLabelFailed,
      tone: CatchBadgeTone.danger,
      detail: null,
    ),
    PaymentStatus.refundFailed => (
      label: l10n.paymentsPaymentHistoryScreenLabelRefundPending,
      tone: CatchBadgeTone.danger,
      detail: l10n.paymentsPaymentHistoryScreenDetailYourRefundNeedsAttention,
    ),
    PaymentStatus.pending => (
      label: l10n.paymentsPaymentHistoryScreenLabelPending,
      tone: CatchBadgeTone.warning,
      detail: null,
    ),
  };
}
