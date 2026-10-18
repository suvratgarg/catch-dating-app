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
    this.selectedView = HostCustomerDetailView.overview,
    this.onOpenMemory,
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

  HostCustomerDetailBody.loading({
    super.key,
    required String organizerId,
    required String contactId,
    required String displayName,
    required String manualTagLabel,
    required String noteBody,
    required this.currentUid,
    required this.selectedView,
    required this.onOpenMemory,
  }) : customer = hostCustomerSkeletonDetail(
         organizerId: organizerId,
         contactId: contactId,
         displayName: displayName,
         manualTagLabel: manualTagLabel,
         noteBody: noteBody,
       ),
       communicationPlan = null,
       communicationPlanLoading = true,
       communicationPlanFailed = false,
       messageActionInHeader = false,
       openingConversation = false,
       updatingCustomer = false,
       onSaveDetails = _noopSaveCustomerDetails,
       onEditTags = _noop,
       onAddNote = _noop,
       onEditNote = ((_) {}),
       onReviewDuplicates = _noop,
       onMessage = _noop,
       onRetryCommunicationPlan = _noop,
       onMessagingEnabledChanged = ((_) {}),
       onOpenFormResponse = ((_) {}),
       onCall = null,
       onEmail = null,
       onOpenApplication = ((_) {}),
       onOpenContact = ((_) {}),
       onOpenRevenue = _noop,
       onOpenEvent = ((_) {}),
       onOpenCatchThread = ((_) {}),
       onOpenWhatsappThread = ((_) {}),
       onUndoMerge = ((_) {});

  final HostAudienceContactDetail customer;
  final String? currentUid;
  final HostCommunicationPlan? communicationPlan;
  final bool communicationPlanLoading;
  final bool communicationPlanFailed;
  final bool messageActionInHeader;
  final HostCustomerDetailView selectedView;
  final VoidCallback? onOpenMemory;
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
    return switch (selectedView) {
      HostCustomerDetailView.overview => CatchSectionList(
        emptyStateOmitted: true,
        children: [
          HostCustomerOverviewSectionList(
            customer: customer,
            onOpenRevenue: onOpenRevenue,
          ),
          HostCustomerMemoryPreview(
            customer: customer,
            onOpenMemory: onOpenMemory ?? () {},
          ),
          HostCustomerRecentEvents(
            customer: customer,
            onOpenEvent: onOpenEvent,
          ),
        ],
      ),
      HostCustomerDetailView.details => CatchSectionList(
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
          HostCustomerApplicationsSection(
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
      HostCustomerDetailView.memory => CatchSectionList(
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
      HostCustomerDetailView.history => HostCustomerHistorySection(
        customer: customer,
        onOpenFormResponse: onOpenFormResponse,
        onOpenEvent: onOpenEvent,
        onOpenCatchThread: onOpenCatchThread,
        onOpenWhatsappThread: onOpenWhatsappThread,
        onUndoMerge: onUndoMerge,
      ),
    };
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

class HostCustomerOverviewSectionList extends StatelessWidget {
  const HostCustomerOverviewSectionList({
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

void _noop() {}

Future<void> _noopSaveCustomerDetails({
  required String displayName,
  String? phoneE164,
  String? email,
}) async {}
