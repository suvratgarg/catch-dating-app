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
            ],
          ),
          details: CatchSectionList(
            emptyStateOmitted: true,
            children: [
              HostCustomerDetailsSection(
                customer: customer,
                onCall: onCall,
                onEmail: onEmail,
                onEdit: () => _editDetails(context),
              ),
              HostCustomerReachSection(
                includeSources: false,
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
              HostCustomerSubmissionsSection(
                customer: customer,
                onOpen: onOpenFormResponse,
              ),
              HostCustomerApplicationsPanel(
                organizerId: customer.organizerId,
                contactId: customer.contactId,
                onOpenApplication: onOpenApplication,
                onOpenContact: onOpenContact,
              ),
              HostCustomerSourcesSection(
                customer: customer,
                onReviewDuplicates: customer.ambiguousCandidateCount > 0
                    ? onReviewDuplicates
                    : null,
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

  Future<void> _editDetails(BuildContext context) => showCatchBottomSheet<void>(
    context: context,
    builder: (sheetContext) => CatchSheet.standard(
      title: context.l10n.hostCustomersEditDetails,
      child: HostCustomerIdentityCard(
        customer: customer,
        initiallyEditing: true,
        onCancel: () => Navigator.of(sheetContext).pop(),
        onSave: ({required displayName, phoneE164, email}) async {
          await onSaveDetails(
            displayName: displayName,
            phoneE164: phoneE164,
            email: email,
          );
          if (sheetContext.mounted) Navigator.of(sheetContext).pop();
        },
      ),
    ),
  );
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
  Widget build(BuildContext context) => CatchSectionList(
    emptyStateOmitted: true,
    children: [
      CatchSection.content(
        title: context.l10n.hostCustomersDetailAttendance,
        child: HostCustomerAttendanceCard(customer: customer),
      ),
      CatchSection.content(
        title: context.l10n.hostCustomersDetailRevenue,
        child: HostCustomerRevenueCard(
          revenue: customer.revenue,
          onOpen: onOpenRevenue,
        ),
      ),
    ],
  );
}
