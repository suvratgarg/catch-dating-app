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
  final VoidCallback? onCall;
  final VoidCallback? onEmail;
  final ValueChanged<String> onOpenApplication;
  final ValueChanged<Uri> onOpenContact;
  final VoidCallback onOpenRevenue;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenCatchThread;
  final ValueChanged<String> onOpenWhatsappThread;
  final VoidCallback onRemove;
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
          history: CatchSectionList(
            emptyStateOmitted: true,
            children: [
              HostCustomerHistoryFilters(
                builder: (filter) => HostCustomerTimelineSection(
                  customer: customer,
                  filter: filter,
                  onOpenFormResponse: onOpenFormResponse,
                  onOpenEvent: onOpenEvent,
                  onOpenCatchThread: onOpenCatchThread,
                  onOpenWhatsappThread: onOpenWhatsappThread,
                ),
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
  Widget build(BuildContext context) => ComponentResponsiveBuilder(
    breakpoint: ComponentBreakpoints.sectionPageTwoColumnBreakpoint,
    compact: (context) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HostCustomerAttendanceCard(customer: customer),
        gapH24,
        HostCustomerRevenueCard(
          revenue: customer.revenue,
          onOpen: onOpenRevenue,
        ),
      ],
    ),
    expanded: (context) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: HostCustomerAttendanceCard(customer: customer)),
        gapW24,
        Expanded(
          child: HostCustomerRevenueCard(
            revenue: customer.revenue,
            onOpen: onOpenRevenue,
          ),
        ),
      ],
    ),
  );
}
