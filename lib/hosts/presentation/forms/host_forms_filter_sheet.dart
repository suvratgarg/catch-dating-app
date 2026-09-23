part of 'host_forms_screen.dart';

Future<void> _showHostFormsFilters(
  BuildContext context, {
  required HostFormPurpose? purpose,
  required HostFormLifecycleStatus? status,
  required ValueChanged<HostFormPurpose?> onPurposeChanged,
  required ValueChanged<HostFormLifecycleStatus?> onStatusChanged,
}) async {
  var selectedPurpose = purpose;
  var selectedStatus = status;
  await showCatchBottomSheet<void>(
    context: context,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, updateSheet) => CatchSheet(
        title: context.l10n.hostCustomersFilters,
        mode: CatchSheetMode.scrollable,
        footer: CatchButton(
          label: context.l10n.coreCatchFieldLabelDone,
          onPressed: () => Navigator.of(sheetContext).pop(),
        ),
        child: CatchSection.fieldRows(
          children: [
            CatchField.nav(
              copy: catchFieldCopy(context.l10n),
              title: context.l10n.hostFormPurposeLabel,
              valueText: selectedPurpose == null
                  ? context.l10n.hostAudienceAllPurposes
                  : hostFormPurposeLabel(context, selectedPurpose!),
              onTap: () async {
                final value = await showCatchSelectionSheet<String>(
                  context: context,
                  title: context.l10n.hostAudienceFormPurposeFilter,
                  value: selectedPurpose?.name ?? 'all',
                  items: [
                    CatchSelectionMenuItem(
                      value: 'all',
                      label: context.l10n.hostAudienceAllPurposes,
                    ),
                    for (final item in HostFormPurpose.values)
                      CatchSelectionMenuItem(
                        value: item.name,
                        label: hostFormPurposeLabel(context, item),
                      ),
                  ],
                );
                if (value == null || !context.mounted) return;
                updateSheet(
                  () => selectedPurpose = value == 'all'
                      ? null
                      : HostFormPurpose.values.byName(value),
                );
                onPurposeChanged(selectedPurpose);
              },
            ),
            CatchField.nav(
              copy: catchFieldCopy(context.l10n),
              title: context.l10n.hostAudienceFormStatusFilter,
              valueText: selectedStatus == null
                  ? context.l10n.hostAudienceAllStatuses
                  : hostFormStatusLabel(context, selectedStatus!),
              onTap: () async {
                final value = await showCatchSelectionSheet<String>(
                  context: context,
                  title: context.l10n.hostAudienceFormStatusFilter,
                  value: selectedStatus?.name ?? 'all',
                  items: [
                    CatchSelectionMenuItem(
                      value: 'all',
                      label: context.l10n.hostAudienceAllStatuses,
                    ),
                    for (final item in HostFormLifecycleStatus.values)
                      CatchSelectionMenuItem(
                        value: item.name,
                        label: hostFormStatusLabel(context, item),
                      ),
                  ],
                );
                if (value == null || !context.mounted) return;
                updateSheet(
                  () => selectedStatus = value == 'all'
                      ? null
                      : HostFormLifecycleStatus.values.byName(value),
                );
                onStatusChanged(selectedStatus);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
