import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

CatchAsyncState<T> catchAsyncStateFromAsyncValue<T>(AsyncValue<T> value) {
  if (value.hasError) return CatchAsyncState<T>.error(value.error!);
  if (value.hasValue) return CatchAsyncState<T>.data(value.value as T);
  return CatchAsyncState<T>.loading();
}
