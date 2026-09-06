import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool isCatchAsyncBlockingLoading(AsyncValue<Object?> value) =>
    value.isLoading && !value.hasValue;

const catchAsyncInitialLoadTimeoutException = NetworkException(
  'timeout',
  'This is taking longer than expected. Please try again.',
);
