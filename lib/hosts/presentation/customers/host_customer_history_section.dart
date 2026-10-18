part of 'host_customer_detail_screen.dart';

/// Mounted only by the History tab, so operational joins cannot block Overview.
class HostCustomerHistorySection extends ConsumerWidget {
  const HostCustomerHistorySection({
    super.key,
    required this.customer,
    required this.onOpenFormResponse,
    required this.onOpenEvent,
    required this.onOpenCatchThread,
    required this.onOpenWhatsappThread,
    required this.onUndoMerge,
  });

  final HostAudienceContactDetail customer;
  final ValueChanged<String> onOpenFormResponse;
  final ValueChanged<String> onOpenEvent;
  final ValueChanged<String> onOpenCatchThread;
  final ValueChanged<String> onOpenWhatsappThread;
  final ValueChanged<HostActiveContactMerge> onUndoMerge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = hostAudienceContactHistoryProvider(
      customer.organizerId,
      customer.contactId,
    );
    final history = customer.historyLoaded
        ? AsyncData(customer)
        : ref.watch(provider);
    return CatchAsyncBoundary<HostAudienceContactDetail>(
      value: history,
      errorContext: AppErrorContext.customer,
      onRetry: () => ref.invalidate(provider),
      builder: (context, loaded) => CatchSectionList(
        emptyStateOmitted: true,
        children: [
          HostCustomerHistoryFilterSection(
            builder: (filter) => HostCustomerTimelineSection(
              customer: loaded,
              filter: filter,
              onOpenFormResponse: onOpenFormResponse,
              onOpenEvent: onOpenEvent,
              onOpenCatchThread: onOpenCatchThread,
              onOpenWhatsappThread: onOpenWhatsappThread,
            ),
          ),
          if (loaded.activeMerges.isNotEmpty)
            HostCustomerActiveMergesSection(
              merges: loaded.activeMerges,
              onUndo: onUndoMerge,
            ),
        ],
      ),
    );
  }
}
