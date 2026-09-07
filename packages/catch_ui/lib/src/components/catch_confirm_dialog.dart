import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/components/catch_dialog_action.dart';
import 'package:catch_ui/src/components/catch_dialog_copy.dart';
import 'package:catch_ui/src/foundations/catch_adaptive_platform.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    barrierColor: CatchTokens.of(
      context,
    ).ink.withValues(alpha: CatchOpacity.confirmDialogScrim),
    builder: (context) =>
        CatchConfirmDialog<T>(title: title, message: message, actions: actions),
  );
}

Future<bool?> showCatchConfirmDialog({
  required BuildContext context,
  required String title,
  required CatchDialogCopy copy,
  String message = '',
  String? confirmLabel,
  String? cancelLabel,
  bool danger = false,
  bool barrierDismissible = true,
}) {
  return showCatchAdaptiveDialog<bool>(
    context: context,
    title: title,
    message: message,
    barrierDismissible: barrierDismissible,
    actions: [
      CatchDialogAction(label: cancelLabel ?? copy.cancelLabel, value: false),
      CatchDialogAction(
        label: confirmLabel ?? copy.confirmLabel,
        value: true,
        isDefault: !danger,
        isDestructive: danger,
      ),
    ],
  );
}

class CatchConfirmDialog<T> extends StatelessWidget {
  const CatchConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
  });

  final String title;
  final String message;
  final List<CatchDialogAction<T>> actions;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final actionButtons = [
      for (final action in actions)
        CatchButton(
          label: action.label,
          variant: action.isDestructive
              ? CatchButtonVariant.danger
              : action.isDefault
              ? CatchButtonVariant.primary
              : CatchButtonVariant.secondary,
          fullWidth: true,
          onPressed: () => Navigator.of(context).pop(action.value),
        ),
    ];
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.all(CatchLayout.confirmDialogInset),
      backgroundColor: Colors.transparent,
      child: CatchSurface(
        elevation: CatchSurfaceElevation.overlay,
        borderWidth: 0,
        padding: CatchInsets.confirmDialogCard,
        width: CatchLayout.confirmDialogMaxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: CatchTextStyles.titleL(context, color: t.ink),
            ),
            if (message.isNotEmpty) ...[
              gapH10,
              Text(
                message,
                textAlign: TextAlign.center,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
            gapH20,
            if (actions.length <= 2)
              Row(
                children: [
                  for (final indexed in actionButtons.indexed) ...[
                    if (indexed.$1 > 0) gapW10,
                    Expanded(child: indexed.$2),
                  ],
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final indexed in actionButtons.indexed) ...[
                    if (indexed.$1 > 0) gapH10,
                    indexed.$2,
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
