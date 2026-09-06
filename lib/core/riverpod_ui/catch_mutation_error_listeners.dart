import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
