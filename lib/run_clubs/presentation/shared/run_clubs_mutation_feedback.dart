import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void listenForMutationErrorSnackbar<T>({
  required BuildContext context,
  required WidgetRef ref,
  required Mutation<T> mutation,
}) {
  ref.listen(mutation, (previous, current) {
    if (previous?.isPending == true && current.hasError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mutationErrorMessage(current))));
    }
  });
}
