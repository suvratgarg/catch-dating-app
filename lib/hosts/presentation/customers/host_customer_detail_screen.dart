import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_contact_merge_review.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_memory.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostCustomerDetailScreen extends ConsumerStatefulWidget {
  const HostCustomerDetailScreen({
    super.key,
    required this.organizerId,
    required this.contactId,
    this.initialDisplayName,
  });

  final String organizerId;
  final String contactId;
  final String? initialDisplayName;

  @override
  ConsumerState<HostCustomerDetailScreen> createState() =>
      _HostCustomerDetailScreenState();
}

class _HostCustomerDetailScreenState
    extends ConsumerState<HostCustomerDetailScreen> {
  bool _openingConversation = false;

  @override
  Widget build(BuildContext context) {
    final currentUid = ref.watch(uidProvider).asData?.value;
    final detail = ref.watch(
      hostAudienceContactDetailProvider(widget.organizerId, widget.contactId),
    );
    final initialDisplayName = widget.initialDisplayName?.trim();
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title:
            detail.asData?.value.displayName ??
            (initialDisplayName?.isNotEmpty ?? false
                ? initialDisplayName
                : null) ??
            context.l10n.hostNavigationCustomers,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CatchAsyncValueView<HostAudienceContactDetail>(
          value: detail,
          onRetry: () => ref.invalidate(
            hostAudienceContactDetailProvider(
              widget.organizerId,
              widget.contactId,
            ),
          ),
          initialLoadTimeout: null,
          loadingBuilder: (_) =>
              const CatchPageBody(child: CatchSkeletonRows(count: 6)),
          errorBuilder: (_, error, _) => CatchPageBody(
            child: CatchErrorState.fromError(
              error,
              context: AppErrorContext.customer,
              onRetry: () => ref.invalidate(
                hostAudienceContactDetailProvider(
                  widget.organizerId,
                  widget.contactId,
                ),
              ),
            ),
          ),
          builder: (context, customer) => ListView(
            padding: CatchInsets.pageBody.copyWith(bottom: 0),
            children: [
              HostCustomerIdentityCard(
                customer: customer,
                onManage: () => _manageCustomer(customer),
              ),
              gapH16,
              HostCustomerMemorySection(
                customer: customer,
                currentUid: currentUid,
                onEditTags: () => _editTags(customer),
                onAddNote: () => _editNote(customer),
                onEditNote: (note) => _editNote(customer, note: note),
              ),
              gapH24,
              Text(
                context.l10n.hostCustomersActivity,
                key: const ValueKey('host-customer-activity'),
                style: CatchTextStyles.sectionTitle(context),
              ),
              gapH12,
              HostCustomerAttendanceCard(customer: customer),
              gapH16,
              HostCustomerRevenueCard(revenue: customer.revenue),
              gapH16,
              HostCustomerAttendanceHistory(customer: customer),
              gapH16,
              HostCustomerSendHistory(customer: customer),
              if (customer.activeMerges.isNotEmpty) ...[
                gapH16,
                HostCustomerActiveMergesSection(
                  merges: customer.activeMerges,
                  onUndo: _undoMerge,
                ),
              ],
              gapH24,
              CatchSection.divided(
                key: const ValueKey('host-customer-controls'),
                title: context.l10n.hostCustomersControls,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HostCustomerConversationCard(
                      customer: customer,
                      loading: _openingConversation,
                      onReview: customer.ambiguousCandidateCount > 0
                          ? _reviewDuplicates
                          : null,
                      onOpen:
                          customerConversationAvailability(
                                linkedAccount: customer.linkedAccount,
                                identityVerified:
                                    customer.identityState ==
                                    HostAudienceIdentityState.verified,
                                ambiguousCandidateCount:
                                    customer.ambiguousCandidateCount,
                              ) ==
                              HostCustomerConversationAvailability.ready
                          ? () => _startConversation(customer)
                          : null,
                    ),
                  ],
                ),
              ),
              const CatchScrollTerminalPadding(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editTags(HostAudienceContactDetail customer) async {
    final updated = await showCatchBottomSheet<bool>(
      context: context,
      builder: (context) => HostCustomerTagsSheet(customer: customer),
    );
    if (!mounted || updated != true) return;
    ref.invalidate(hostCustomersDirectoryControllerProvider);
    _refreshDetail();
  }

  Future<void> _editNote(
    HostAudienceContactDetail customer, {
    HostCustomerNote? note,
  }) async {
    final updated = await showCatchBottomSheet<bool>(
      context: context,
      builder: (context) =>
          HostCustomerNoteSheet(customer: customer, note: note),
    );
    if (!mounted || updated != true) return;
    _refreshDetail();
  }

  void _refreshDetail() => ref.invalidate(
    hostAudienceContactDetailProvider(widget.organizerId, widget.contactId),
  );

  Future<void> _reviewDuplicates() async {
    final changed = await showCatchBottomSheet<bool>(
      context: context,
      builder: (_) =>
          HostContactMergeReviewSheet(organizerId: widget.organizerId),
    );
    if (!mounted || changed != true) return;
    ref.invalidate(hostCustomersDirectoryControllerProvider);
    ref.invalidate(hostCrmSummaryProvider(widget.organizerId));
    _refreshDetail();
  }

  Future<void> _undoMerge(HostActiveContactMerge merge) async {
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostCustomersUndoMergeTitle,
      message: context.l10n.hostCustomersUndoMergeBody,
      confirmLabel: context.l10n.hostCustomersUndoMerge,
      danger: true,
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(hostCustomersControllerProvider)
          .unmergeCustomers(
            organizerId: widget.organizerId,
            mergeReceiptId: merge.mergeReceiptId,
          );
      if (!mounted) return;
      ref.invalidate(hostCustomersDirectoryControllerProvider);
      ref.invalidate(hostCrmSummaryProvider(widget.organizerId));
      _refreshDetail();
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    }
  }

  Future<void> _manageCustomer(HostAudienceContactDetail customer) async {
    final result = await showCatchBottomSheet<HostCustomerManageResult>(
      context: context,
      builder: (context) => HostCustomerManageSheet(customer: customer),
    );
    if (!mounted || result == null) return;
    ref.invalidate(hostCustomersDirectoryControllerProvider);
    ref.invalidate(hostCrmSummaryProvider(widget.organizerId));
    ref.invalidate(
      hostAudienceContactDetailProvider(widget.organizerId, widget.contactId),
    );
    if (result == HostCustomerManageResult.hidden) context.pop();
  }

  Future<void> _startConversation(HostAudienceContactDetail customer) async {
    if (_openingConversation) return;
    setState(() => _openingConversation = true);
    try {
      final matchId = await ref
          .read(hostCustomersControllerProvider)
          .startConversation(
            organizerId: widget.organizerId,
            contactId: widget.contactId,
          );
      if (mounted) {
        unawaited(
          context.pushNamed(
            Routes.hostChatScreen.name,
            pathParameters: {'matchId': matchId},
          ),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.chat,
        );
      }
    } finally {
      if (mounted) setState(() => _openingConversation = false);
    }
  }
}

class HostCustomerActiveMergesSection extends StatelessWidget {
  const HostCustomerActiveMergesSection({
    super.key,
    required this.merges,
    required this.onUndo,
  });

  final List<HostActiveContactMerge> merges;
  final ValueChanged<HostActiveContactMerge> onUndo;

  @override
  Widget build(BuildContext context) => CatchSection.divided(
    key: const ValueKey('host-customer-active-merges'),
    title: context.l10n.hostCustomersMergedHistory,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, merge) in merges.indexed) ...[
          Text(
            context.l10n.hostCustomersMergedHistoryRow(
              name: merge.sourceDisplayName,
              count: merge.movedFactCount,
            ),
            style: CatchTextStyles.proseM(context),
          ),
          gapH8,
          CatchButton(
            label: context.l10n.hostCustomersUndoMerge,
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
            onPressed: () => onUndo(merge),
          ),
          if (index < merges.length - 1) gapH16,
        ],
      ],
    ),
  );
}
