import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmDangerDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return showCatchConfirmDialog(
    context: context,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
    danger: true,
  );
}
