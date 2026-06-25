import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Watches [mutation] and shows a [SnackBar] with the error message when the
/// mutation transitions from pending to error.
///
/// Use this to wrap a screen or section where a mutation error should surface
/// as a transient snackbar.
///
/// For inline errors that should persist until the user takes action, use
/// [CatchErrorBanner] instead.
class CatchMutationErrorListener extends ConsumerWidget {
  const CatchMutationErrorListener({
    super.key,
    required this.mutation,
    required this.child,
    this.errorContext = AppErrorContext.generic,
  });

  final Mutation<dynamic> mutation;
  final Widget child;
  final AppErrorContext errorContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(mutation, (previous, current) {
      if (previous?.isPending == true && current.hasError) {
        // hasError is only ever true for MutationError, so the cast is total;
        // the old `: current` fallback dead-passed a MutationState as the error.
        showCatchErrorSnackBar(
          context,
          (current as MutationError).error,
          errorContext: errorContext,
        );
      }
    });
    return child;
  }
}

/// Watches several mutations and surfaces pending-to-error transitions as one
/// transient snackbar boundary.
class CatchMutationErrorListeners extends ConsumerWidget {
  const CatchMutationErrorListeners({
    super.key,
    required this.mutations,
    required this.child,
    this.errorContext = AppErrorContext.generic,
  });

  final List<Mutation<dynamic>> mutations;
  final Widget child;
  final AppErrorContext errorContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    for (final mutation in mutations) {
      ref.listen(mutation, (previous, current) {
        if (previous?.isPending == true && current.hasError) {
          showCatchErrorSnackBar(
            context,
            (current as MutationError).error,
            errorContext: errorContext,
          );
        }
      });
    }
    return child;
  }
}
