import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

String runBookingErrorMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }
  if (error is FirebaseException) {
    return firestoreErrorMessage(error);
  }
  if (error is FirebaseFunctionsException) {
    if (error.code == 'unauthenticated') {
      return const SignInRequiredException('book a run').message;
    }

    final message = error.message;
    if (message != null && message.trim().isNotEmpty) {
      return message.trim();
    }
  }
  if (error is StateError && error.message.isNotEmpty) {
    return error.message;
  }
  return 'Unable to update this booking right now.';
}
