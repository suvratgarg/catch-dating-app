import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CatchAsyncRenderBranch { data, loading, error }

CatchAsyncState<T> catchAsyncStateFromAsyncValue<T>(AsyncValue<T> value) {
  if (value.hasValue) {
    final data = value.value as T;
    if (value.hasError) {
      return CatchAsyncState<T>.staleData(
        data,
        value.error!,
        value.stackTrace,
        value.isLoading,
      );
    }
    if (value.isLoading) return CatchAsyncState<T>.refreshing(data);
    return CatchAsyncState<T>.data(data);
  }
  if (value.isLoading && value.hasError) {
    return CatchAsyncState<T>.retrying(value.error!, value.stackTrace);
  }
  if (value.isLoading) return const CatchAsyncState.loading();
  if (value.hasError) {
    return CatchAsyncState<T>.error(value.error!, value.stackTrace);
  }
  return CatchAsyncState<T>.loading();
}

/// Resolves one visible branch without discarding Riverpod's overlapping
/// loading, data, error, refresh, reload, and automatic-retry signals.
CatchAsyncRenderBranch catchAsyncRenderBranchFromAsyncValue<T>(
  AsyncValue<T> value, {
  bool skipLoadingOnReload = false,
  bool skipLoadingOnRefresh = true,
  bool skipError = false,
}) {
  if (value.retrying && !value.hasValue) {
    return CatchAsyncRenderBranch.loading;
  }

  if (value.isLoading) {
    // Loading without credible data is always loading. In particular, an
    // automatic or user-triggered retry must not replay its previous error as
    // though the retry had already terminated.
    if (!value.hasValue) return CatchAsyncRenderBranch.loading;

    final skipLoading = value.isRefreshing
        ? skipLoadingOnRefresh
        : value.isReloading
        ? skipLoadingOnReload
        : false;
    return skipLoading
        ? CatchAsyncRenderBranch.data
        : CatchAsyncRenderBranch.loading;
  }

  if (value.hasError && (!value.hasValue || !skipError)) {
    return CatchAsyncRenderBranch.error;
  }
  if (value.hasValue) return CatchAsyncRenderBranch.data;

  // AsyncValue guarantees at least one state. Keeping this defensive fallback
  // as loading fails safe if a future Riverpod version introduces another
  // transition shape.
  return CatchAsyncRenderBranch.loading;
}
