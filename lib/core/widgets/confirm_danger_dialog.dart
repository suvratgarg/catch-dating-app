import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmDangerDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        CatchButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
          variant: CatchButtonVariant.ghost,
          size: CatchButtonSize.sm,
        ),
        CatchButton(
          label: confirmLabel,
          onPressed: () => Navigator.of(context).pop(true),
          variant: CatchButtonVariant.danger,
          size: CatchButtonSize.sm,
        ),
      ],
    ),
  );
}
