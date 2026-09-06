import 'package:flutter/material.dart';

typedef CatchAsyncValueDataBuilder<T> =
    Widget Function(BuildContext context, T value);
typedef CatchAsyncValueLoadingBuilder = Widget Function(BuildContext context);
typedef CatchAsyncValueErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace stackTrace);
typedef CatchAsyncValueErrorBuilderWithRetry =
    Widget Function(
      BuildContext context,
      Object error,
      StackTrace stackTrace,
      VoidCallback? onRetry,
    );
