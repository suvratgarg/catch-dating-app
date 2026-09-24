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

  HostAudienceStateScaffold _loadingFormsRoute() => HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-forms-route-state'),
        slivers: const [CatchStateViewport.sliverLoading()],
      );
}
