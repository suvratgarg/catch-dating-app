import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known refresh errors outrank the loading flag', () {
    final failure = StateError('failed');
    // Riverpod exposes combined refresh states to consumers but keeps this
    // constructor helper package-internal.
    // ignore: invalid_use_of_internal_member
    final refreshingError = const AsyncLoading<int>().copyWithPrevious(
      AsyncError<int>(failure, StackTrace.empty),
    );

    final state = catchAsyncStateFromAsyncValue(refreshingError);

    expect(refreshingError.isLoading, isTrue);
    expect(state.status, CatchAsyncStatus.error);
    expect(state.error, same(failure));
  });

  test('credible refresh data outranks the loading flag', () {
    // Riverpod exposes combined refresh states to consumers but keeps this
    // constructor helper package-internal.
    // ignore: invalid_use_of_internal_member
    final refreshingData = const AsyncLoading<int>().copyWithPrevious(
      const AsyncData<int>(7),
    );

    final state = catchAsyncStateFromAsyncValue(refreshingData);

    expect(refreshingData.isLoading, isTrue);
    expect(state.status, CatchAsyncStatus.data);
    expect(state.value, 7);
  });
}
