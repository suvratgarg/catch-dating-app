part of 'host_forms_screen.dart';

typedef _DirectoryReadScope = ({
  String uid,
  int accountGeneration,
  HostFormListRequest request,
});

// The family identity includes the actor and account generation. A new account
// or form query waits for its own fresh directory read before cached rows show.
final _scopedFormsDirectoryProvider =
    FutureProvider.autoDispose.family<HostFormsDirectoryState, _DirectoryReadScope>(
  (ref, scope) {
    final directoryProvider = hostFormsDirectoryControllerProvider(scope.request);
    final fresh = ref.refresh(directoryProvider.future);
    // A strong subscription keeps the auto-dispose source alive while the
    // scoped read awaits it, without making this gate rebuild on updates.
    ref.listen(directoryProvider, (_, _) {});
    return fresh;
  },
);

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
