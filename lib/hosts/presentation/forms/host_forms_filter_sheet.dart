part of 'host_forms_screen.dart';

Future<void> _showHostFormsFilters(
  BuildContext context, {
  required Set<HostFormPurpose> purposes,
  required Set<HostFormLifecycleStatus> statuses,
  required ValueChanged<Set<HostFormPurpose>> onPurposesChanged,
  required ValueChanged<Set<HostFormLifecycleStatus>> onStatusesChanged,
}) async {
  var selectedPurposes = Set<HostFormPurpose>.of(purposes);
  var selectedStatuses = Set<HostFormLifecycleStatus>.of(statuses);
  await showCatchBottomSheet<void>(
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, updateSheet) => CatchSheet.filter(
        title: context.l10n.hostCustomersFilters,
        trailing: CatchButton(
          label: context.l10n.hostFiltersResetAll,
          variant: CatchButtonVariant.ghost,
          size: CatchButtonSize.sm,
          onPressed: selectedPurposes.isEmpty && selectedStatuses.isEmpty
              ? null
              : () {
                  updateSheet(() {
                    selectedPurposes = {};
                    selectedStatuses = {};
                  });
                  onPurposesChanged(const {});
                  onStatusesChanged(const {});
                },
        ),
        closeLabel: context.l10n.hostSheetClose,
        onClose: () => Navigator.of(sheetContext).pop(),
        child: CatchSectionList(
          emptyStateOmitted: true,
          mainAxisSize: MainAxisSize.min,
          children: [
            CatchSection.choiceGroup(
              first: true,
              title: context.l10n.hostFormPurposeLabel,
              child: CatchChoiceInput<HostFormPurpose>(
                values: HostFormPurpose.values,
                itemLabelBuilder: (value) =>
                    hostFormPurposeLabel(context, value),
                selected: selectedPurposes,
                mode: CatchChipMode.multiple,
                allowEmptySelection: true,
                onChanged: (values) {
                  updateSheet(() => selectedPurposes = Set.of(values));
                  onPurposesChanged(Set.unmodifiable(values));
                },
              ),
            ),
            CatchSection.choiceGroup(
              first: true,
              title: context.l10n.hostAudienceFormStatusFilter,
              child: CatchChoiceInput<HostFormLifecycleStatus>(
                values: HostFormLifecycleStatus.values,
                itemLabelBuilder: (value) =>
                    hostFormStatusLabel(context, value),
                selected: selectedStatuses,
                mode: CatchChipMode.multiple,
                allowEmptySelection: true,
                onChanged: (values) {
                  updateSheet(() => selectedStatuses = Set.of(values));
                  onStatusesChanged(Set.unmodifiable(values));
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
