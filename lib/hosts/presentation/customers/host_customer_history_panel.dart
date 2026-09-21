part of 'host_customer_detail_screen.dart';

/// Mounted only by the History tab, so operational joins cannot block Overview.
class HostCustomerHistoryPanel extends ConsumerWidget {
  const HostCustomerHistoryPanel({
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
          HostCustomerHistoryFilters(
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

class _HostCustomerSubmissionsPanel extends ConsumerWidget {
  const _HostCustomerSubmissionsPanel({
    required this.customer,
    required this.onOpen,
  });
  final HostAudienceContactDetail customer;
  final ValueChanged<String> onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = hostAudienceContactHistoryProvider(
      customer.organizerId,
      customer.contactId,
    );
    return CatchAsyncBoundary<HostAudienceContactDetail>(
      value: customer.historyLoaded ? AsyncData(customer) : ref.watch(provider),
      errorContext: AppErrorContext.customer,
      onRetry: () => ref.invalidate(provider),
      loadingBuilder: (_) => CatchSection.loadingRows(
        title: context.l10n.hostCustomersSubmittedInformation,
        layouts: [
          CatchRecordLayout.placeholder(
            icon: CatchIcons.tabForms,
            hasMetadata: true,
          ),
        ],
      ),
      builder: (context, loaded) {
        final forms = <String, HostCustomerFormTimelineEntry>{};
        for (final entry
            in loaded.timeline.whereType<HostCustomerFormTimelineEntry>()) {
          final prior = forms[entry.responseId];
          if (prior == null || entry.occurredAt.isAfter(prior.occurredAt)) {
            forms[entry.responseId] = entry;
          }
        }
        final entries = forms.values.toList()
          ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
        final exact =
            loaded.timelineCoverage.forms ==
                HostCustomerTimelineCoverageValue.exact &&
            !loaded.timelineTruncated;
        if (entries.isEmpty) {
          return CatchSection.content(
            key: const ValueKey('host-customer-submitted-information'),
            title: context.l10n.hostCustomersSubmittedInformation,
            child: Text(
              exact
                  ? context.l10n.hostCustomersNoSubmittedInformation
                  : context.l10n.hostCustomersSubmissionsUnavailable,
              style: CatchTextStyles.supporting(context),
            ),
          );
        }
        return CatchSection.rows(
          key: const ValueKey('host-customer-submitted-information'),
          title: context.l10n.hostCustomersSubmittedInformation,
          children: [
            if (entries.isEmpty)
              CatchField.read(
                copy: catchFieldCopy(context.l10n),
                body: exact
                    ? context.l10n.hostCustomersNoSubmittedInformation
                    : context.l10n.hostCustomersSubmissionsUnavailable,
                bodyMaxLines: 6,
              ),
            for (final entry in entries)
              CatchField.navigate(
                key: ValueKey('host-customer-submission-${entry.responseId}'),
                onActivate: () => onOpen(entry.responseId),
                content: CatchRecordLayout(
                  icon: CatchIcons.tabForms,
                  title:
                      entry.formTitle ??
                      context.l10n.hostCustomersTimelineFormFallback,
                  metadata:
                      entry.action == HostCustomerFormTimelineAction.withdrawn
                      ? context.l10n.hostCustomersTimelineFormWithdrawn(
                          date: AppTimeFormatters.shortDate(entry.occurredAt),
                        )
                      : '${context.l10n.hostCustomersViewAnswers(count: entry.answeredQuestionCount)} · ${AppTimeFormatters.shortDate(entry.occurredAt)}',
                ),
              ),
            if (!exact && entries.isNotEmpty)
              CatchField.read(
                copy: catchFieldCopy(context.l10n),
                body: context.l10n.hostCustomersTimelinePartialBody,
                bodyMaxLines: 6,
              ),
          ],
        );
      },
    );
  }
}
