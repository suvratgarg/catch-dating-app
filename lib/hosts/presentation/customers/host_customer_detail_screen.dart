import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
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
  });

  final String organizerId;
  final String contactId;

  @override
  ConsumerState<HostCustomerDetailScreen> createState() =>
      _HostCustomerDetailScreenState();
}

class _HostCustomerDetailScreenState
    extends ConsumerState<HostCustomerDetailScreen> {
  bool _openingConversation = false;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(
      hostAudienceContactDetailProvider(widget.organizerId, widget.contactId),
    );
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title:
            detail.asData?.value.displayName ??
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
              context: AppErrorContext.club,
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
              HostCustomerIdentityCard(customer: customer),
              gapH12,
              CatchButton(
                label: context.l10n.hostCustomersManage,
                variant: CatchButtonVariant.secondary,
                onPressed: () => _manageCustomer(customer),
              ),
              gapH16,
              HostCustomerConversationCard(
                customer: customer,
                loading: _openingConversation,
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
              gapH16,
              HostCustomerAttendanceCard(customer: customer),
              gapH16,
              HostCustomerRevenueCard(revenue: customer.revenue),
              gapH16,
              HostCustomerAttendanceHistory(customer: customer),
              const CatchScrollTerminalPadding(),
            ],
          ),
        ),
      ),
    );
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
