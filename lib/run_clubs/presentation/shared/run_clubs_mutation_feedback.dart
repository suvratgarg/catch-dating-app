import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Watches [mutation] and shows a [SnackBar] with the error message when the
/// mutation transitions from pending to error.
///
/// Use this to wrap a screen or section where a mutation error should surface
/// as a transient snackbar (e.g. join/leave club, book/cancel run).
///
/// For inline errors that should persist until the user takes action, use
/// [ErrorBanner] instead.
///
/// Usage:
/// ```dart
/// MutationErrorSnackbarListener(
///   mutation: RunClubMembershipController.joinMutation,
///   child: MyScreen(),
/// ),
/// ```
class MutationErrorSnackbarListener extends ConsumerWidget {
  const MutationErrorSnackbarListener({
    super.key,
    required this.mutation,
    required this.child,
  });

  final Mutation<dynamic> mutation;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(mutation, (previous, current) {
      if (previous?.isPending == true && current.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mutationErrorMessage(current))),
        );
      }
    });
    return child;
  }
}
