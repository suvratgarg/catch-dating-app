import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum HostDraftExitDecision { keepEditing, discardAndExit, saveDraftAndExit }

List<CatchDialogAction<HostDraftExitDecision>> hostDraftExitDialogActions(
  AppLocalizations l10n,
) => [
  CatchDialogAction(
    label: l10n.hostsDraftExitKeepEditing,
    value: HostDraftExitDecision.keepEditing,
  ),
  CatchDialogAction(
    label: l10n.hostsDraftExitDiscardAndExit,
    value: HostDraftExitDecision.discardAndExit,
    isDestructive: true,
  ),
  CatchDialogAction(
    label: l10n.hostsDraftExitSaveAndExit,
    value: HostDraftExitDecision.saveDraftAndExit,
    isDefault: true,
  ),
];

class HostDraftExitDialog extends StatelessWidget {
  const HostDraftExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CatchConfirmDialog<HostDraftExitDecision>(
      title: context.l10n.hostsDraftExitTitle,
      message: context.l10n.hostsDraftExitMessage,
      actions: hostDraftExitDialogActions(context.l10n),
    );
  }
}

Future<HostDraftExitDecision?> showHostDraftExitDialog(BuildContext context) {
  return showCatchAdaptiveDialog<HostDraftExitDecision>(
    context: context,
    title: context.l10n.hostsDraftExitTitle,
    message: context.l10n.hostsDraftExitMessage,
    actions: hostDraftExitDialogActions(context.l10n),
    barrierDismissible: false,
  );
}
