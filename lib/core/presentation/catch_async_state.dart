enum CatchAsyncStatus { data, loading, error }

class CatchAsyncState<T> {
  const CatchAsyncState.data(this.value)
    : status = CatchAsyncStatus.data,
      error = null,
      stackTrace = null;

  const CatchAsyncState.loading()
    : status = CatchAsyncStatus.loading,
      value = null,
      error = null,
      stackTrace = null;

  const CatchAsyncState.error(this.error, [this.stackTrace])
    : status = CatchAsyncStatus.error,
      value = null;

  final CatchAsyncStatus status;
  final T? value;
  final Object? error;
  final StackTrace? stackTrace;

  bool get hasData => status == CatchAsyncStatus.data;
  bool get isLoading => status == CatchAsyncStatus.loading;
  bool get hasError => status == CatchAsyncStatus.error;
}
