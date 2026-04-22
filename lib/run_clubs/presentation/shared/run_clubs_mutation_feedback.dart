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
      final error = current as MutationError;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.error.toString())));
    }
  });
}
