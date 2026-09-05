part of 'host_customer_detail_screen.dart';

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
    required this.onCall,
    required this.onEmail,
    required this.onOpenApplication,
    required this.onOpenContact,
    required this.onOpenRevenue,
    required this.onOpenEvent,
    required this.onOpenCatchThread,
    required this.onOpenWhatsappThread,
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
  final VoidCallback? onCall;
  final VoidCallback? onEmail;
  final ValueChanged<String> onOpenApplication;
  final ValueChanged<Uri> onOpenContact;
  final VoidCallback onOpenRevenue;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenCatchThread;
  final ValueChanged<String> onOpenWhatsappThread;
  final ValueChanged<HostActiveContactMerge> onUndoMerge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HostCustomerIdentityCard(
          customer: customer,
          onSave: onSaveDetails,
          showName: false,
          showContacts: false,
        ),
        gapH12,
        HostCustomerDetailTabs(
          overviewBuilder: (openMemory) => CatchSectionList(
            emptyStateOmitted: true,
            children: [
              HostCustomerDetailOverview(
                customer: customer,
                onOpenRevenue: onOpenRevenue,
              ),
              HostCustomerMemoryPreview(
                customer: customer,
                onOpenMemory: openMemory,
              ),
              HostCustomerRecentEvents(
                customer: customer,
                onOpenEvent: onOpenEvent,
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
            ],
          ),
          details: CatchSectionList(
            emptyStateOmitted: true,
            children: [
              HostCustomerDetailsSection(
                customer: customer,
                onCall: onCall,
                onEmail: onEmail,
                onOpenFormResponse: onOpenFormResponse,
              ),
              HostCustomerApplicationsPanel(
                organizerId: customer.organizerId,
                contactId: customer.contactId,
                onOpenApplication: onOpenApplication,
                onOpenContact: onOpenContact,
              ),
            ],
          ),
          memory: CatchSectionList(
            emptyStateOmitted: true,
            children: [
              HostCustomerMemorySection(
                customer: customer,
                currentUid: currentUid,
                onEditTags: onEditTags,
                onAddNote: onAddNote,
                onEditNote: onEditNote,
              ),
            ],
          ),
          history: HostCustomerHistoryPanel(
            customer: customer,
            onOpenFormResponse: onOpenFormResponse,
            onOpenEvent: onOpenEvent,
            onOpenCatchThread: onOpenCatchThread,
            onOpenWhatsappThread: onOpenWhatsappThread,
            onUndoMerge: onUndoMerge,
          ),
        ),
      ],
    );
  }
}

class HostCustomerDetailOverview extends StatelessWidget {
  const HostCustomerDetailOverview({
    super.key,
    required this.customer,
    required this.onOpenRevenue,
  });

  final HostAudienceContactDetail customer;
  final VoidCallback onOpenRevenue;

  @override
  Widget build(BuildContext context) {
    final largeText =
        MediaQuery.textScalerOf(context).scale(1) >=
        CatchRecordTokens.largeTextBreakpoint;
    final metrics = <Widget>[
      CatchStatColumn(
        value: '${customer.traits.attendedEventCount}',
        label: context.l10n.hostsHostAudienceAttended,
      ),
      if (customer.revenue.amounts.isEmpty ||
          customer.revenue.coverage == HostCustomerRevenueCoverage.unavailable)
        CatchStatColumn(
          value: '—',
          label: context.l10n.hostCustomersDetailRevenue,
        ),
      if (customer.revenue.coverage != HostCustomerRevenueCoverage.unavailable)
        for (final amount in customer.revenue.amounts)
          CatchStatColumn(
            value: NumberFormat.simpleCurrency(
              name: amount.currency,
            ).format(amount.amountMinor / 100),
            label:
                '${context.l10n.hostCustomersDetailRevenue} · ${amount.currency}',
          ),
    ];
    return CatchSection.divided(
      first: true,
      title: context.l10n.hostAudienceAtAGlance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (largeText)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in metrics.indexed) ...[
                  if (entry.$1 > 0) gapH16,
                  entry.$2,
                ],
              ],
            )
          else
            Wrap(
              spacing: CatchSpacing.s8,
              runSpacing: CatchSpacing.s4,
              children: metrics,
            ),
          if (customer.revenue.coverage ==
              HostCustomerRevenueCoverage.unavailable) ...[
            gapH8,
            Text(
              context.l10n.hostCustomersDetailRevenueUnavailable,
              style: CatchTextStyles.supporting(context),
            ),
          ],
          if (customer.revenue.coverage ==
              HostCustomerRevenueCoverage.partial) ...[
            gapH8,
            Text(
              context.l10n.hostCustomersDetailRevenuePartial,
              style: CatchTextStyles.recordContext(context),
            ),
          ],
          gapH16,
          CatchField.control(
            title: context.l10n.hostCustomersDetailAttendance,
            control: HostCustomerAttendanceCard(customer: customer),
          ),
          CatchButton.command(
            key: const ValueKey('host-customer-revenue-breakdown'),
            label: context.l10n.hostCustomersViewBreakdown,
            onPressed: onOpenRevenue,
          ),
        ],
      ),
    );
  }
}
