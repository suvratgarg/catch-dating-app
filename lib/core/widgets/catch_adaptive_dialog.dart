import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CatchDialogAction<T> {
  const CatchDialogAction({
    required this.label,
    required this.value,
    this.isDefault = false,
    this.isDestructive = false,
  });

  final String label;
  final T value;
  final bool isDefault;
  final bool isDestructive;
}

Future<T?> showCatchAdaptiveDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  required List<CatchDialogAction<T>> actions,
  bool barrierDismissible = true,
}) {
  if (prefersCupertinoControls()) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          for (final action in actions)
            CupertinoDialogAction(
              isDefaultAction: action.isDefault,
              isDestructiveAction: action.isDestructive,
              onPressed: () => Navigator.of(context).pop(action.value),
              child: Text(action.label),
            ),
        ],
      ),
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        for (final action in actions)
          CatchTextButton(
            label: action.label,
            tone: action.isDestructive
                ? CatchTextButtonTone.danger
                : CatchTextButtonTone.primary,
            onPressed: () => Navigator.of(context).pop(action.value),
          ),
      ],
    ),
  );
}
