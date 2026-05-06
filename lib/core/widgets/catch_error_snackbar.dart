import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:flutter/material.dart';

void showCatchErrorSnackBar(
  BuildContext context,
  Object error, {
  AppErrorContext errorContext = AppErrorContext.generic,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(appErrorMessage(error, context: errorContext))),
  );
}
