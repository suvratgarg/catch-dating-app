part of 'host_forms_screen.dart';

extension _HostFormsAccountBinding on _HostFormsScreenState {
  void _bindAccount(String? accountId) {
    if (!_accountBound) {
      _accountBound = true;
      _boundAccountId = accountId;
      return;
    }
    if (_boundAccountId == accountId) return;
    _boundAccountId = accountId;
    _accountGeneration++;
    _searchDebounce?.cancel();
    _query = null;
    _responseQuery = null;
    _responseFormId = null;
    _responseContactId = null;
    _statuses = const {};
    _purposes = const {};
    _importRevision++;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _boundAccountId == accountId) _syncRoute();
    });
  }

  bool _directoryRequestCurrent(HostFormListRequest request) =>
      mounted &&
      _boundAccountId == request.accountUid &&
      _accountGeneration == request.accountGeneration &&
      ref.read(firebaseAuthProvider).currentUser?.uid == request.accountUid;

  Future<void> _handleRowAction(
    _HostFormRowAction action,
    HostFormSummary form,
    HostFormListRequest request,
  ) async {
    if (!_directoryRequestCurrent(request)) return;
    if (action == _HostFormRowAction.analytics) {
      await context.pushNamed(
        Routes.hostFormAnalyticsScreen.name,
        pathParameters: {'formId': form.formId},
        queryParameters: {'organizerId': form.organizerId},
      );
      return;
    }
    if (action == _HostFormRowAction.automations) {
      await context.pushNamed(
        Routes.hostFormAutomationsScreen.name,
        pathParameters: {'formId': form.formId},
        queryParameters: {'organizerId': form.organizerId},
      );
      return;
    }
    try {
      switch (action) {
        case _HostFormRowAction.analytics:
        case _HostFormRowAction.automations:
          break;
        case _HostFormRowAction.duplicate:
          final duplicate = await ref
              .read(hostFormsControllerProvider)
              .duplicate(source: form, requestId: _requestId('duplicate'));
          if (!_directoryRequestCurrent(request)) return;
          ref.invalidate(hostFormsDirectoryControllerProvider(request));
          if (!context.mounted) return;
          await context.pushNamed(
            Routes.hostFormBuilderScreen.name,
            pathParameters: {'formId': duplicate.form.formId},
            queryParameters: {'organizerId': form.organizerId},
          );
          return;
        case _HostFormRowAction.pause:
        case _HostFormRowAction.resume:
        case _HostFormRowAction.archive:
          final lifecycleAction = switch (action) {
            _HostFormRowAction.pause => HostFormLifecycleAction.pause,
            _HostFormRowAction.resume => HostFormLifecycleAction.resume,
            _ => HostFormLifecycleAction.archive,
          };
          if (lifecycleAction == HostFormLifecycleAction.archive) {
            final confirmed = await showCatchConfirmDialog(
              copy: catchDialogCopy(context.l10n),
              context: context,
              title: context.l10n.hostFormsArchiveConfirmTitle,
              message: context.l10n.hostFormsArchiveConfirmBody,
              confirmLabel: context.l10n.hostFormsArchive,
              danger: true,
            );
            if (confirmed != true || !_directoryRequestCurrent(request)) {
              return;
            }
          }
          await ref
              .read(hostFormsControllerProvider)
              .setLifecycle(form: form, action: lifecycleAction);
          if (!_directoryRequestCurrent(request)) return;
          ref.invalidate(hostFormsDirectoryControllerProvider(request));
          return;
        case _HostFormRowAction.delete:
          final confirmed = await showCatchConfirmDialog(
            copy: catchDialogCopy(context.l10n),
            context: context,
            title: context.l10n.hostFormsDeleteConfirmTitle,
            message: context.l10n.hostFormsDeleteConfirmBody,
            confirmLabel: context.l10n.hostFormsDeleteDraft,
            danger: true,
          );
          if (confirmed != true || !_directoryRequestCurrent(request)) return;
          await ref.read(hostFormsControllerProvider).deleteDraft(form);
          if (!_directoryRequestCurrent(request)) return;
          ref.invalidate(hostFormsDirectoryControllerProvider(request));
          return;
      }
    } on Object catch (error) {
      if (!_directoryRequestCurrent(request)) return;
      if (!context.mounted) return;
      showCatchErrorSnackBar(context, error);
    }
  }

}
