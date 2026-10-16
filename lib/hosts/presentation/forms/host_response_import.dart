part of 'host_forms_screen.dart';

extension _HostResponseImport on _HostFormsScreenState {
  Future<void> _pickApplicationImport(HostFormListRequest request) async {
    if (_importing || !_directoryRequestCurrent(request)) return;
    final operation = Object();
    _importOperation = operation;
    bool current() =>
        identical(_importOperation, operation) &&
        _directoryRequestCurrent(request);
    _setImporting(true);
    try {
      final table = await ref
          .read(hostApplicationsControllerProvider)
          .pickImportFile();
      if (table == null || !current()) return;
      final draft = buildHostApplicationImportDraft(table);
      final confirmed = await showCatchBottomSheet<bool>(
        context: context,
        builder: (context) => CatchSheet.standard(
          title: context.l10n.hostApplicationsImportTitle,
          subtitle: context.l10n.hostApplicationsImportSubtitle,
          footer: CatchButton.sheet(
            role: CatchButtonEmphasis.commit,
            label: context.l10n.hostApplicationsImportAction(
              count: draft.rows.length,
            ),

            onPressed: () => Navigator.of(context).pop(true),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchSection.fieldRows(
                first: true,
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
      if (confirmed != true || !current()) return;
      final imported = await ref
          .read(hostApplicationsControllerProvider)
          .importDraft(
            organizerId: request.organizerId,
            draft: draft,
            consentCopy: context.l10n.hostApplicationsConsentCopy,
            consentVersion: 'host-applications-v1',
            retentionCopy: context.l10n.hostApplicationsRetentionCopy,
          );
      if (!current()) return;
      ref.invalidate(hostApplicationsDirectoryControllerProvider);
      ref.invalidate(hostFormResponsesControllerProvider);
      if (current()) {
        _completeResponseImport();
        showCatchNotice(
          context,
          context.l10n.hostApplicationsImportComplete(
            created: imported.createdCount,
            skipped: imported.skippedCount,
          ),
        );
      }
    } on HostApplicationImportException catch (error) {
      if (current()) {
        showCatchNotice(context, _applicationImportIssue(context, error));
      }
    } on HostRosterImportException catch (error) {
      if (current()) {
        showCatchNotice(context, _rosterImportIssue(context, error.issue));
      }
    } on Object catch (error) {
      if (current()) {
        showCatchNoticeError(
          context,
          error,
          errorContext: AppErrorContext.applications,
        );
      }
    } finally {
      if (mounted && identical(_importOperation, operation)) {
        _importOperation = null;
        _setImporting(false);
      }
    }
  }
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
