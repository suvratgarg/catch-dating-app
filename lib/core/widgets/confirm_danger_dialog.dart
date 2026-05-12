import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmDangerDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return showCatchAdaptiveDialog<bool>(
    context: context,
    title: title,
    message: message,
    actions: [
      const CatchDialogAction(label: 'Cancel', value: false),
      CatchDialogAction(label: confirmLabel, value: true, isDestructive: true),
    ],
  );
}
