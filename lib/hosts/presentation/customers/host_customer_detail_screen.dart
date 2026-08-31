import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeletonized.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_contact_merge_review.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_memory.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_timeline.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_whatsapp_thread_sheet.dart';
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
    this.embedded = false,
  });

  final String organizerId;
  final String contactId;
  final String? initialDisplayName;
  final bool embedded;

  @override
  ConsumerState<HostCustomerDetailScreen> createState() =>
      _HostCustomerDetailScreenState();
}

class _HostCustomerDetailScreenState
    extends ConsumerState<HostCustomerDetailScreen> {
  bool _openingConversation = false;
  bool _updatingCustomer = false;

  @override
  Widget build(BuildContext context) {
    final currentUid = catchAsyncStateFromAsyncValue(
      ref.watch(uidProvider),
    ).value;
    final detail = ref.watch(
      hostAudienceContactDetailProvider(widget.organizerId, widget.contactId),
    );
    final detailState = catchAsyncStateFromAsyncValue(detail);
    final communicationPlan = detailState.value == null
        ? null
        : ref.watch(
            hostCommunicationPlanProvider(widget.organizerId, widget.contactId),
          );
    final communicationPlanState = communicationPlan == null
        ? null
        : catchAsyncStateFromAsyncValue(communicationPlan);
    final initialDisplayName = widget.initialDisplayName?.trim();
    final displayName =
        detailState.value?.displayName ??
        (initialDisplayName?.isNotEmpty ?? false ? initialDisplayName : null) ??
        context.l10n.hostNavigationCustomers;
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchScreenTopBar(
        context: context,
        title: displayName,
        leadingType: widget.embedded
            ? CatchTopBarLeading.none
            : CatchTopBarLeading.back,
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
          loadingBuilder: (_) => CatchSkeletonized(
            child: HostCustomerDetailBody(
              customer: _hostCustomerSkeletonDetail(
                organizerId: widget.organizerId,
                contactId: widget.contactId,
                displayName: displayName,
                manualTagLabel: context.l10n.hostCustomersManualTags,
                noteBody: context.l10n.hostCustomersMemoryHelp,
              ),
              currentUid: currentUid,
              communicationPlan: null,
              communicationPlanLoading: true,
              communicationPlanFailed: false,
              openingConversation: false,
              updatingCustomer: false,
              onSaveDetails: _noopSaveCustomerDetails,
              onEditTags: _noop,
              onAddNote: _noop,
              onEditNote: (_) {},
              onReviewDuplicates: _noop,
              onMessage: _noop,
              onRetryCommunicationPlan: _noop,
              onMessagingEnabledChanged: (_) {},
              onOpenFormResponse: (_) {},
              onOpenEvent: (_) {},
              onOpenCatchThread: (_) {},
              onOpenWhatsappThread: (_) {},
              onRemove: _noop,
              onUndoMerge: (_) {},
            ),
          ),
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
          builder: (context, customer) => HostCustomerDetailBody(
            customer: customer,
            currentUid: currentUid,
            communicationPlan: communicationPlanState?.value,
            communicationPlanLoading: communicationPlanState?.isLoading ?? true,
            communicationPlanFailed: communicationPlanState?.hasError ?? false,
            messageActionInHeader:
                communicationPlanState
                    ?.value
                    ?.singleRecipient
                    .recommendedRouteId !=
                null,
            openingConversation: _openingConversation,
            updatingCustomer: _updatingCustomer,
            onSaveDetails: ({required displayName, phoneE164, email}) =>
                _saveCustomerDetails(
                  customer,
                  displayName: displayName,
                  phoneE164: phoneE164,
                  email: email,
                ),
            onEditTags: () => _editTags(customer),
            onAddNote: () => _editNote(customer),
            onEditNote: (note) => _editNote(customer, note: note),
            onReviewDuplicates: _reviewDuplicates,
            onMessage: () =>
                _messageCustomer(customer, communicationPlanState?.value),
            onRetryCommunicationPlan: _refreshCommunicationPlan,
            onMessagingEnabledChanged: (enabled) =>
                _setMessagingEnabled(customer, enabled),
            onOpenFormResponse: _openFormResponse,
            onOpenEvent: _openEvent,
            onOpenCatchThread: _openCatchThread,
            onOpenWhatsappThread: _openWhatsappThread,
            onRemove: () => _removeCustomer(customer),
            onUndoMerge: _undoMerge,
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

  void _refreshDetail() {
    ref.invalidate(
      hostAudienceContactDetailProvider(widget.organizerId, widget.contactId),
    );
    _refreshCommunicationPlan();
  }

  void _refreshCommunicationPlan() => ref.invalidate(
    hostCommunicationPlanProvider(widget.organizerId, widget.contactId),
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

  Future<void> _saveCustomerDetails(
    HostAudienceContactDetail customer, {
    required String displayName,
    String? phoneE164,
    String? email,
  }) async {
    await ref
        .read(hostCustomersControllerProvider)
        .mutateCustomer(
          organizerId: customer.organizerId,
          contactId: customer.contactId,
          expectedRevision: customer.revision,
          displayNameOverride: displayName == customer.sourceDisplayName
              ? null
              : displayName,
          clearDisplayNameOverride: displayName == customer.sourceDisplayName,
          phoneE164: phoneE164,
          updatePhoneE164: customer.contactDetailsEditable,
          email: email,
          updateEmail: customer.contactDetailsEditable,
        );
    if (!mounted) return;
    ref.invalidate(hostCustomersDirectoryControllerProvider);
    ref.invalidate(hostCrmSummaryProvider(widget.organizerId));
    _refreshDetail();
  }

  Future<void> _setMessagingEnabled(
    HostAudienceContactDetail customer,
    bool enabled,
  ) async {
    if (_updatingCustomer) return;
    setState(() => _updatingCustomer = true);
    try {
      await ref
          .read(hostCustomersControllerProvider)
          .mutateCustomer(
            organizerId: customer.organizerId,
            contactId: customer.contactId,
            expectedRevision: customer.revision,
            whatsappAdminSuppressed: !enabled,
          );
      if (!mounted) return;
      ref.invalidate(hostCustomersDirectoryControllerProvider);
      _refreshDetail();
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _updatingCustomer = false);
    }
  }

  Future<void> _removeCustomer(HostAudienceContactDetail customer) async {
    if (_updatingCustomer) return;
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostsHostAudienceRemoveTitle,
      message: context.l10n.hostsHostAudienceRemoveBody,
      confirmLabel: context.l10n.hostsHostAudienceRemoveConfirm,
      danger: true,
    );
    if (confirmed != true || !mounted) return;
    setState(() => _updatingCustomer = true);
    try {
      await ref
          .read(hostCustomersControllerProvider)
          .mutateCustomer(
            organizerId: customer.organizerId,
            contactId: customer.contactId,
            expectedRevision: customer.revision,
            hidden: true,
          );
      if (!mounted) return;
      ref.invalidate(hostCustomersDirectoryControllerProvider);
      ref.invalidate(hostCrmSummaryProvider(widget.organizerId));
      context.pop();
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _updatingCustomer = false);
    }
  }

  Future<void> _messageCustomer(
    HostAudienceContactDetail customer,
    HostCommunicationPlan? plan,
  ) async {
    final route = plan?.singleRecipient.recommendedRouteId;
    switch (route) {
      case HostCommunicationRouteId.catchChat:
        return _startConversation(customer);
      case HostCommunicationRouteId.personalWhatsappHandoff:
        return _openWhatsapp(customer);
      case null:
      case HostCommunicationRouteId.organizerWhatsappCampaign:
      case HostCommunicationRouteId.catchWhatsapp:
      case HostCommunicationRouteId.catchEventAnnouncement:
      case HostCommunicationRouteId.organizerFollowerUpdate:
        return;
    }
  }

  void _openFormResponse(String responseId) {
    unawaited(
      context.pushNamed(
        Routes.hostFormResponseDetailScreen.name,
        pathParameters: {'responseId': responseId},
        queryParameters: {'organizerId': widget.organizerId},
      ),
    );
  }

  void _openEvent(String eventId) {
    unawaited(
      context.pushNamed(
        Routes.hostAppEventDetailScreen.name,
        pathParameters: {'clubId': widget.organizerId, 'eventId': eventId},
      ),
    );
  }

  void _openCatchThread(String matchId) {
    unawaited(
      context.pushNamed(
        Routes.hostChatScreen.name,
        pathParameters: {'matchId': matchId},
      ),
    );
  }

  void _openWhatsappThread(String threadId) {
    unawaited(
      showCatchBottomSheet<void>(
        context: context,
        builder: (_) => HostWhatsappThreadSheet(
          organizerId: widget.organizerId,
          threadId: threadId,
        ),
      ),
    );
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

  Future<void> _openWhatsapp(HostAudienceContactDetail customer) =>
      showCatchBottomSheet<void>(
        context: context,
        builder: (_) => _HostWhatsappHandoffSheet(customer: customer),
      );
}

class _HostWhatsappHandoffSheet extends ConsumerStatefulWidget {
  const _HostWhatsappHandoffSheet({required this.customer});

  final HostAudienceContactDetail customer;

  @override
  ConsumerState<_HostWhatsappHandoffSheet> createState() =>
      _HostWhatsappHandoffSheetState();
}

class _HostWhatsappHandoffSheetState
    extends ConsumerState<_HostWhatsappHandoffSheet> {
  TextEditingController? _messageController;
  late final String _requestId =
      'handoff_${DateTime.now().microsecondsSinceEpoch}_${widget.customer.contactId}';
  bool _opening = false;

  TextEditingController get _message => _messageController!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messageController ??= TextEditingController(
      text: context.l10n.hostCustomersWhatsappDefaultMessage(
        name: widget.customer.displayName,
      ),
    );
  }

  @override
  void dispose() {
    _messageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = _message.text.trim();
    return CatchBottomSheetScaffold(
      title: context.l10n.hostCustomersWhatsappHandoffTitle,
      subtitle: context.l10n.hostCustomersWhatsappHandoffSubtitle(
        name: widget.customer.displayName,
        phone: widget.customer.phoneE164!,
      ),
      keyboardSafe: true,
      action: CatchButton(
        key: const ValueKey('host-customer-confirm-whatsapp'),
        label: context.l10n.hostCustomersOpenWhatsapp,
        isLoading: _opening,
        onPressed: _opening || message.isEmpty ? null : _open,
        fullWidth: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchNotice(
            notice: CatchNoticeData(
              id: 'host.customer.whatsapp-handoff',
              title: context.l10n.hostCustomersWhatsappAppChannel,
              message: context.l10n.hostCustomersWhatsappHandoffDisclosure,
            ),
          ),
          gapH16,
          CatchFieldLanes.single(
            child: CatchField.input(
              key: const ValueKey('host-customer-whatsapp-message'),
              title: context.l10n.hostCustomersWhatsappMessage,
              controller: _message,
              minLines: 3,
              maxLines: 7,
              maxLength: 1000,
              textCapitalization: TextCapitalization.sentences,
              contractExemption:
                  'Editable handoff copy is persisted only in the bounded '
                  'TTL manual-send task, then passed to the external app.',
              enabled: !_opening,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open() async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final controller = ref.read(hostAudienceControllerProvider);
      final task = await controller.prepareManualSendTask(
        organizerId: widget.customer.organizerId,
        contactId: widget.customer.contactId,
        requestId: _requestId,
        prefillText: _message.text,
      );
      ref.invalidate(hostManualSendTasksProvider(widget.customer.organizerId));
      final opened = await ref
          .read(externalLinkControllerProvider)
          .openWhatsappHandoff(
            phoneE164: task.phoneE164,
            message: task.prefillText,
          );
      if (!opened) {
        if (!mounted) return;
        throw ExternalActionException(
          context.l10n.hostCustomersWhatsappOpenFailed,
        );
      }
      try {
        await controller.recordManualHandoffOpened(task);
      } on Object {
        if (!mounted) return;
        showCatchErrorSnackBar(
          context,
          ExternalActionException(
            context.l10n.hostCustomersWhatsappRecordFailed,
          ),
          errorContext: AppErrorContext.customer,
        );
      }
      ref.invalidate(hostManualSendTasksProvider(widget.customer.organizerId));
      if (mounted) Navigator.of(context).pop();
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.customer,
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }
}

void _noop() {}

Future<void> _noopSaveCustomerDetails({
  required String displayName,
  String? phoneE164,
  String? email,
}) async {}

class HostCustomerDetailBody extends StatelessWidget {
  const HostCustomerDetailBody({
    super.key,
    required this.customer,
    required this.currentUid,
    required this.communicationPlan,
    required this.communicationPlanLoading,
    required this.communicationPlanFailed,
    this.messageActionInHeader = false,
    required this.openingConversation,
    required this.updatingCustomer,
    required this.onSaveDetails,
    required this.onEditTags,
    required this.onAddNote,
    required this.onEditNote,
    required this.onReviewDuplicates,
    required this.onMessage,
    required this.onRetryCommunicationPlan,
    required this.onMessagingEnabledChanged,
    required this.onOpenFormResponse,
    required this.onOpenEvent,
    required this.onOpenCatchThread,
    required this.onOpenWhatsappThread,
    required this.onRemove,
    required this.onUndoMerge,
  });

  final HostAudienceContactDetail customer;
  final String? currentUid;
  final HostCommunicationPlan? communicationPlan;
  final bool communicationPlanLoading;
  final bool communicationPlanFailed;
  final bool messageActionInHeader;
  final bool openingConversation;
  final bool updatingCustomer;
  final HostCustomerDetailsSaveCallback onSaveDetails;
  final VoidCallback onEditTags;
  final VoidCallback onAddNote;
  final ValueChanged<HostCustomerNote> onEditNote;
  final VoidCallback onReviewDuplicates;
  final VoidCallback onMessage;
  final VoidCallback onRetryCommunicationPlan;
  final ValueChanged<bool> onMessagingEnabledChanged;
  final ValueChanged<String> onOpenFormResponse;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenCatchThread;
  final ValueChanged<String> onOpenWhatsappThread;
  final VoidCallback onRemove;
  final ValueChanged<HostActiveContactMerge> onUndoMerge;

  @override
  Widget build(BuildContext context) {
    final headerMessageAction = messageActionInHeader
        ? CatchButton(
            key: const ValueKey('host-customer-message'),
            label: context.l10n.hostCustomersWhatsappMessage,
            icon: Icon(CatchIcons.tabChats, size: CatchIcon.sm),
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
            isLoading: openingConversation,
            onPressed: openingConversation ? null : onMessage,
          )
        : null;
    return ListView(
      padding: CatchInsets.pageBody.copyWith(bottom: 0),
      children: [
        CatchSectionList(
          emptyStateOmitted: true,
          children: [
            HostCustomerIdentityCard(
              customer: customer,
              onSave: onSaveDetails,
              primaryAction: headerMessageAction,
            ),
            HostCustomerDetailOverview(
              customer: customer,
              currentUid: currentUid,
              onEditTags: onEditTags,
              onAddNote: onAddNote,
              onEditNote: onEditNote,
            ),
            HostCustomerReachSection(
              customer: customer,
              communicationPlan: communicationPlan,
              communicationPlanLoading: communicationPlanLoading,
              communicationPlanFailed: communicationPlanFailed,
              messageLoading: openingConversation,
              onMessage: onMessage,
              onRetryCommunicationPlan: onRetryCommunicationPlan,
              messageActionInHeader: messageActionInHeader,
              onMessagingEnabledChanged: updatingCustomer
                  ? null
                  : onMessagingEnabledChanged,
              onReviewDuplicates: customer.ambiguousCandidateCount > 0
                  ? onReviewDuplicates
                  : null,
            ),
            HostCustomerRevenueCard(revenue: customer.revenue),
            HostCustomerTimelineSection(
              customer: customer,
              onOpenFormResponse: onOpenFormResponse,
              onOpenEvent: onOpenEvent,
              onOpenCatchThread: onOpenCatchThread,
              onOpenWhatsappThread: onOpenWhatsappThread,
            ),
            if (customer.activeMerges.isNotEmpty)
              HostCustomerActiveMergesSection(
                merges: customer.activeMerges,
                onUndo: onUndoMerge,
              ),
            CatchSection.fieldRows(
              key: const ValueKey('host-customer-controls'),
              title: context.l10n.hostCustomersControls,
              children: [
                CatchField.action(
                  key: const ValueKey('host-customer-remove'),
                  title: context.l10n.hostsHostAudienceRemoveAction,
                  body: context.l10n.hostsHostAudienceRemoveBody,
                  icon: CatchIcons.deleteOutline,
                  tone: CatchFieldTone.danger,
                  onTap: updatingCustomer ? null : onRemove,
                ),
              ],
            ),
          ],
        ),
        const CatchScrollTerminalPadding(),
      ],
    );
  }
}

class HostCustomerDetailOverview extends StatelessWidget {
  const HostCustomerDetailOverview({
    super.key,
    required this.customer,
    required this.currentUid,
    required this.onEditTags,
    required this.onAddNote,
    required this.onEditNote,
  });

  final HostAudienceContactDetail customer;
  final String? currentUid;
  final VoidCallback onEditTags;
  final VoidCallback onAddNote;
  final ValueChanged<HostCustomerNote> onEditNote;

  @override
  Widget build(BuildContext context) => ComponentResponsiveBuilder(
    breakpoint: ComponentBreakpoints.sectionPageTwoColumnBreakpoint,
    compact: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HostCustomerMemorySection(
          customer: customer,
          currentUid: currentUid,
          onEditTags: onEditTags,
          onAddNote: onAddNote,
          onEditNote: onEditNote,
        ),
        gapH24,
        KeyedSubtree(
          key: const ValueKey('host-customer-activity'),
          child: HostCustomerAttendanceCard(customer: customer),
        ),
      ],
    ),
    expanded: (context) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: HostCustomerMemorySection(
            customer: customer,
            currentUid: currentUid,
            onEditTags: onEditTags,
            onAddNote: onAddNote,
            onEditNote: onEditNote,
          ),
        ),
        gapW24,
        Expanded(
          flex: 2,
          child: KeyedSubtree(
            key: const ValueKey('host-customer-activity'),
            child: HostCustomerAttendanceCard(customer: customer),
          ),
        ),
      ],
    ),
  );
}

HostAudienceContactDetail _hostCustomerSkeletonDetail({
  required String organizerId,
  required String contactId,
  required String displayName,
  required String manualTagLabel,
  required String noteBody,
}) {
  final now = DateTime(2026, 8, 17);
  return HostAudienceContactDetail(
    organizerId: organizerId,
    contactId: contactId,
    displayName: displayName,
    sourceDisplayName: displayName,
    displayNameOverride: null,
    phoneE164: '+919876543210',
    email: 'customer@example.com',
    linkedAccount: false,
    identityState: HostAudienceIdentityState.unlinked,
    identityConfidence: 'unverified',
    contactDetailsEditable: true,
    ambiguousCandidateCount: 0,
    whatsappAdminSuppressed: false,
    whatsappPermission: HostCustomerWhatsappPermission(
      status: HostAudiencePermissionStatus.optedIn,
      evidenceStatus: HostCustomerPermissionEvidenceStatus.complete,
      receiptId: 'loading-receipt',
      source: 'hostFormResponse',
      sourceFormId: 'loading-form',
      sourceFormTitle: 'Community sign-up',
      decisionAt: now,
      identityStrength: 'phoneVerified',
    ),
    origins: [
      HostCustomerOrigin(
        originId: 'loading-origin',
        sourceKind: HostCustomerOriginSourceKind.hostForm,
        sourceEntityKind: 'hostFormResponse',
        formId: 'loading-form',
        formTitle: 'Community sign-up',
        eventId: null,
        eventTitle: null,
        observedAt: now,
      ),
    ],
    originsTruncated: false,
    traits: const HostCustomerTraits(
      expectedEventCount: 3,
      attendedEventCount: 2,
      cancelledEventCount: 0,
      noShowCount: 0,
      importedEventCount: 0,
      attendanceRate: 0.67,
      segments: {HostAudienceSegment.repeatAttendee},
      whatsappStatus: HostAudiencePermissionStatus.optedIn,
      sourceCoverage: HostAudienceSourceCoverage.exact,
    ),
    revenue: const HostCustomerRevenue(
      coverage: HostCustomerRevenueCoverage.exact,
      amounts: [
        HostCustomerRevenueAmount(
          currency: 'INR',
          amountMinor: 250000,
          paidOrderCount: 2,
        ),
      ],
    ),
    events: [
      HostAudienceEventFact(
        eventId: 'loading-event',
        displayName: 'Weekend community event',
        source: 'attendance',
        status: 'attended',
        checkedIn: true,
        eventStartAt: now,
      ),
    ],
    eventsTruncated: false,
    manualTags: [HostManualTag(tagId: 'loading-tag', label: manualTagLabel)],
    notes: [
      HostCustomerNote(
        noteId: 'loading-note',
        body: noteBody,
        authorUid: 'loading-author',
        createdAt: now,
        updatedAt: now,
        revision: 1,
      ),
    ],
    sends: [
      HostCustomerSend(
        campaignId: 'loading-send',
        name: 'Upcoming event invitation',
        messageClass: 'organizerPromotion',
        deliveryStatus: HostCustomerSendDeliveryStatus.delivered,
        createdAt: now,
        sentAt: now,
        updatedAt: now,
      ),
    ],
    timeline: [
      HostCustomerFormTimelineEntry(
        timelineId: 'loading-timeline-form',
        occurredAt: now,
        responseId: 'loading-response',
        formId: 'loading-form',
        formTitle: 'Community sign-up',
        action: HostCustomerFormTimelineAction.submitted,
        answeredQuestionCount: 4,
      ),
    ],
    timelineTruncated: false,
    timelineCoverage: const HostCustomerTimelineCoverage(
      forms: HostCustomerTimelineCoverageValue.exact,
      events: HostCustomerTimelineCoverageValue.exact,
      sends: HostCustomerTimelineCoverageValue.exact,
      replies: HostCustomerTimelineCoverageValue.partial,
    ),
    revision: 1,
  );
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
  Widget build(BuildContext context) => CatchSection.plain(
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
