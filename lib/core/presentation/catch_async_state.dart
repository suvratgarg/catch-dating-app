enum CatchAsyncStatus { data, loading, error }

class CatchAsyncState<T> {
  const CatchAsyncState.data(this.value)
    : status = CatchAsyncStatus.data,
      error = null;

  const CatchAsyncState.loading()
    : status = CatchAsyncStatus.loading,
      value = null,
      error = null;

  const CatchAsyncState.error(this.error)
    : status = CatchAsyncStatus.error,
      value = null;

  final CatchAsyncStatus status;
  final T? value;
  final Object? error;
}
