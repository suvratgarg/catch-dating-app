import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Generic widget that handles the three states of an [AsyncValue]:
/// loading, error, and data.
///
/// Usage:
/// ```dart
/// AsyncValueWidget<List<RunClub>>(
///   value: ref.watch(watchRunClubsProvider),
///   data: (clubs) => ListView(...),
/// )
/// ```
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.errorContext = AppErrorContext.generic,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;

  /// Optional custom loading widget. Defaults to [CatchLoadingIndicator].
  final Widget Function()? loading;

  /// Optional custom error widget. Defaults to [ErrorMessageWidget].
  final Widget Function(Object error, StackTrace? stackTrace)? error;
  final AppErrorContext errorContext;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: loading ?? (() => const CatchLoadingIndicator()),
      error:
          error ??
          ((e, _) => CatchErrorState.fromError(
            e,
            context: errorContext,
            onRetry: onRetry,
          )),
    );
  }
}

/// Sliver equivalent of [AsyncValueWidget].
class AsyncValueSliverWidget<T> extends StatelessWidget {
  const AsyncValueSliverWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.errorContext = AppErrorContext.generic,
    this.onRetry,
    this.fillErrorRemaining = true,
  });

  final AsyncValue<T> value;
  final Widget Function(T) data;
  final Widget Function()? loading;
  final Widget Function(Object error, StackTrace? stackTrace)? error;
  final AppErrorContext errorContext;
  final VoidCallback? onRetry;
  final bool fillErrorRemaining;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => SliverToBoxAdapter(
        child: loading?.call() ?? const CatchLoadingIndicator(),
      ),
      error: (e, st) {
        final custom = error?.call(e, st);
        if (custom != null) return SliverToBoxAdapter(child: custom);
        return CatchSliverErrorState.fromError(
          e,
          context: errorContext,
          onRetry: onRetry,
          fillRemaining: fillErrorRemaining,
        );
      },
    );
  }
}

/// Simple error display widget used by [AsyncValueWidget].
@Deprecated('Use CatchErrorState instead.')
class ErrorMessageWidget extends StatelessWidget {
  const ErrorMessageWidget(this.errorMessage, {super.key});

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        errorMessage,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
