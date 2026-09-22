part of 'host_forms_screen.dart';

extension _HostResponseImport on _HostFormsScreenState {
  Future<void> _pickApplicationImport(String organizerId) async {
    if (_importing) return;
    _setImporting(true);
    try {
      final table = await ref
          .read(hostApplicationsControllerProvider)
          .pickImportFile();
      if (table == null || !mounted) return;
      final draft = buildHostApplicationImportDraft(table);
      final confirmed = await showCatchBottomSheet<bool>(
        context: context,
        builder: (context) => _ApplicationImportSheet(draft: draft),
      );
      if (confirmed != true || !mounted) return;
      final imported = await ref
          .read(hostApplicationsControllerProvider)
          .importDraft(
            organizerId: organizerId,
            draft: draft,
            consentCopy: context.l10n.hostApplicationsConsentCopy,
            consentVersion: 'host-applications-v1',
            retentionCopy: context.l10n.hostApplicationsRetentionCopy,
          );
      ref.invalidate(hostApplicationsDirectoryControllerProvider);
      ref.invalidate(hostFormResponsesControllerProvider);
      if (mounted) {
        _completeResponseImport();
        showCatchSnackBar(
          context,
          context.l10n.hostApplicationsImportComplete(
            created: imported.createdCount,
            skipped: imported.skippedCount,
          ),
        );
      }
    } on HostApplicationImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(context, _applicationImportIssue(context, error));
      }
    } on HostRosterImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(context, _rosterImportIssue(context, error.issue));
      }
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.applications,
        );
      }
    } finally {
      if (mounted) _setImporting(false);
    }
  }
}

class _ApplicationImportSheet extends StatelessWidget {
  const _ApplicationImportSheet({required this.draft});
  final HostApplicationImportDraft draft;

  @override
  Widget build(BuildContext context) => CatchSheet(
    title: context.l10n.hostApplicationsImportTitle,
    subtitle: context.l10n.hostApplicationsImportSubtitle,
    footer: CatchButton(
      label: context.l10n.hostApplicationsImportAction(
        count: draft.rows.length,
      ),
      fullWidth: true,
      onPressed: () => Navigator.of(context).pop(true),
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchSection.fieldRows(
            children: [
              for (final question in draft.questions)
                CatchField.read(
                  copy: catchFieldCopy(context.l10n),
                  title: question.label,
                  body: question.canonicalFieldId == null
                      ? context.l10n.hostApplicationsImportOrganizerField
                      : context.l10n.hostApplicationsImportReusableField,
                ),
            ],
          ),
          if (draft.truncatedRowCount > 0) ...[
            gapH12,
            CatchNotice(
              dismissLabel: context.l10n.coreCatchNoticeTooltipDismiss,
              notice: CatchNoticeData(
                id: 'application-import-limit',
                title: context.l10n.hostApplicationsImportLimit(
                  count: draft.truncatedRowCount,
                ),
                tone: CatchNoticeTone.warning,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

String _applicationImportIssue(
  BuildContext context,
  HostApplicationImportException error,
) => switch (error.issue) {
  HostApplicationImportIssue.missingNameColumn =>
    context.l10n.hostApplicationsImportMissingName,
  HostApplicationImportIssue.noRows =>
    context.l10n.hostApplicationsImportNoRows,
};

String _rosterImportIssue(BuildContext context, HostRosterImportIssue issue) =>
    switch (issue) {
      HostRosterImportIssue.unsupportedFile =>
        context.l10n.hostsOperationalRosterIssueUnsupported,
      HostRosterImportIssue.fileTooLarge =>
        context.l10n.hostsOperationalRosterIssueFileTooLarge,
      HostRosterImportIssue.expandedFileTooLarge =>
        context.l10n.hostsOperationalRosterIssueExpandedFileTooLarge,
      HostRosterImportIssue.missingRows =>
        context.l10n.hostsOperationalRosterIssueMissingRows,
      HostRosterImportIssue.tooManyColumns =>
        context.l10n.hostsOperationalRosterIssueTooManyColumns,
      HostRosterImportIssue.malformedCsv =>
        context.l10n.hostsOperationalRosterIssueMalformedCsv,
      HostRosterImportIssue.unreadableXlsx ||
      HostRosterImportIssue.missingWorksheet =>
        context.l10n.hostsOperationalRosterIssueUnreadableXlsx,
    };
