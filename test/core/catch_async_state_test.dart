// ignore_for_file: invalid_use_of_internal_member

import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('retry loading outranks the previous error', () {
    final failure = StateError('failed');
    // Riverpod exposes combined refresh states to consumers but keeps this
    // constructor helper package-internal.
    final refreshingError = const AsyncLoading<int>().copyWithPrevious(
      AsyncError<int>(failure, StackTrace.empty),
    );

    final state = catchAsyncStateFromAsyncValue(refreshingError);

    expect(refreshingError.isLoading, isTrue);
    expect(state.status, CatchAsyncStatus.loading);
    expect(state.phase, CatchAsyncPhase.retrying);
    expect(
      catchAsyncRenderBranchFromAsyncValue(refreshingError),
      CatchAsyncRenderBranch.loading,
    );
  });

  test('credible refresh data outranks the loading flag', () {
    // Riverpod exposes combined refresh states to consumers but keeps this
    // constructor helper package-internal.
    final refreshingData = const AsyncLoading<int>().copyWithPrevious(
      const AsyncData<int>(7),
    );

    final state = catchAsyncStateFromAsyncValue(refreshingData);

    expect(refreshingData.isLoading, isTrue);
    expect(state.status, CatchAsyncStatus.data);
    expect(state.phase, CatchAsyncPhase.refreshing);
    expect(state.value, 7);
  });

  test('automatic retry is loading until a later attempt resolves', () {
    final failure = StateError('failed');
    final retryingError = AsyncError<int>(
      failure,
      StackTrace.empty,
      retrying: true,
    );
    final retrying = const AsyncLoading<int>().copyWithPrevious(retryingError);

    final state = catchAsyncStateFromAsyncValue(retrying);

    expect(retrying.retrying, isTrue);
    expect(state.status, CatchAsyncStatus.loading);
    expect(state.phase, CatchAsyncPhase.retrying);
    expect(state.error, same(failure));
    expect(
      catchAsyncRenderBranchFromAsyncValue(retrying),
      CatchAsyncRenderBranch.loading,
    );
    expect(
      catchAsyncStateFromAsyncValue(const AsyncData<int>(7)).phase,
      CatchAsyncPhase.data,
    );
  });

  test('terminal error is distinct from a retrying error', () {
    final failure = StateError('failed');
    final terminal = AsyncError<int>(failure, StackTrace.empty);

    final state = catchAsyncStateFromAsyncValue(terminal);

    expect(state.status, CatchAsyncStatus.error);
    expect(state.phase, CatchAsyncPhase.terminalError);
    expect(state.isTerminalError, isTrue);
    expect(
      catchAsyncRenderBranchFromAsyncValue(terminal),
      CatchAsyncRenderBranch.error,
    );
  });

  test('retry with credible data never replays its previous error', () {
    final failure = StateError('failed');
    final stale = AsyncError<int>(
      failure,
      StackTrace.empty,
    ).copyWithPrevious(const AsyncData<int>(7));
    final retryingWithData = const AsyncLoading<int>().copyWithPrevious(stale);

    final state = catchAsyncStateFromAsyncValue(retryingWithData);

    expect(retryingWithData.isLoading, isTrue);
    expect(retryingWithData.hasValue, isTrue);
    expect(retryingWithData.hasError, isTrue);
    expect(state.phase, CatchAsyncPhase.staleDataWithError);
    expect(state.retrying, isTrue);
    expect(
      catchAsyncRenderBranchFromAsyncValue(retryingWithData),
      CatchAsyncRenderBranch.data,
    );
    expect(
      catchAsyncRenderBranchFromAsyncValue(
        retryingWithData,
        skipLoadingOnRefresh: false,
      ),
      CatchAsyncRenderBranch.loading,
    );
  });

  test('stale data preserves its value and refresh error metadata', () {
    final failure = StateError('failed');
    final stale = AsyncError<int>(
      failure,
      StackTrace.empty,
    ).copyWithPrevious(const AsyncData<int>(7));

    final state = catchAsyncStateFromAsyncValue(stale);

    expect(state.status, CatchAsyncStatus.data);
    expect(state.phase, CatchAsyncPhase.staleDataWithError);
    expect(state.value, 7);
    expect(state.error, same(failure));
    expect(
      catchAsyncRenderBranchFromAsyncValue(stale),
      CatchAsyncRenderBranch.error,
    );
    expect(
      catchAsyncRenderBranchFromAsyncValue(stale, skipError: true),
      CatchAsyncRenderBranch.data,
    );
  });
}
