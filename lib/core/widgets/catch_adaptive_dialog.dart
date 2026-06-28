import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
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
  String message = '',
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool danger = false,
  bool barrierDismissible = true,
}) {
  return showCatchAdaptiveDialog<bool>(
    context: context,
    title: title,
    message: message,
    barrierDismissible: barrierDismissible,
    actions: [
      CatchDialogAction(label: cancelLabel, value: false),
      CatchDialogAction(
        label: confirmLabel,
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
            _buildDialogActions<T>(context, actions),
          ],
        ),
      ),
    );
  }
}

class CatchFormDialog extends StatelessWidget {
  const CatchFormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
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
            Text(title, style: CatchTextStyles.titleL(context, color: t.ink)),
            gapH16,
            child,
            if (actions.isNotEmpty) ...[
              gapH20,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (final indexed in actions.indexed) ...[
                    if (indexed.$1 > 0) gapW8,
                    indexed.$2,
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildDialogActions<T>(
  BuildContext context,
  List<CatchDialogAction<T>> actions,
) {
  if (actions.length <= 2) {
    return Row(
      children: [
        for (final indexed in actions.indexed) ...[
          if (indexed.$1 > 0) gapW10,
          Expanded(child: _buildDialogActionButton(context, indexed.$2)),
        ],
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final indexed in actions.indexed) ...[
        if (indexed.$1 > 0) gapH10,
        _buildDialogActionButton(context, indexed.$2),
      ],
    ],
  );
}

Widget _buildDialogActionButton<T>(
  BuildContext context,
  CatchDialogAction<T> action,
) {
  return CatchButton(
    label: action.label,
    variant: action.isDestructive
        ? CatchButtonVariant.danger
        : action.isDefault
        ? CatchButtonVariant.primary
        : CatchButtonVariant.secondary,
    fullWidth: true,
    onPressed: () => Navigator.of(context).pop(action.value),
  );
}
