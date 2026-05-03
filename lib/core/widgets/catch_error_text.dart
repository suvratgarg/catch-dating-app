import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:flutter/material.dart';

class CatchErrorText extends StatelessWidget {
  const CatchErrorText(this.error, {super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(firestoreErrorMessage(error)));
  }
}
