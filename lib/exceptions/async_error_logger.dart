import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueUI on AsyncValue<void> {
  /// Show a [SnackBar] with the error message when this [AsyncValue] has an
  /// error. Safe to call from `ref.listen` callbacks.
  ///
  /// Usage:
  /// ```dart
  /// ref.listen(someControllerProvider, (_, state) {
  ///   state.showSnackbarOnError(context);
  /// });
  /// ```
  void showSnackbarOnError(BuildContext context) {
    if (!isLoading && hasError) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
