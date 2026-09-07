import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_commit_button.dart';
import 'package:flutter/material.dart';

/// Trailing Cancel/Done group used by explicit-save field drawers.
class CatchFieldActionBar extends StatelessWidget {
  const CatchFieldActionBar({
    super.key,
    required this.onCancel,
    required this.onSubmit,
    required this.cancelLabel,
    required this.doneLabel,
    required this.savingLabel,
    this.loading = false,
    this.actionLeading,
    this.revealTargetKey,
  });

  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final String cancelLabel;
  final String doneLabel;
  final String savingLabel;
  final bool loading;
  final Widget? actionLeading;
  final Key? revealTargetKey;

  @override
  Widget build(BuildContext context) {
    final cancelButton = CatchFieldCommitButton(
      key: const ValueKey('catch-field-cancel'),
      label: cancelLabel,
      onPressed: loading ? null : onCancel,
    );
    final doneButton = CatchFieldCommitButton(
      key: const ValueKey('catch-field-done'),
      label: loading ? savingLabel : doneLabel,
      primary: true,
      loading: loading,
      onPressed: loading ? null : onSubmit,
    );

    return KeyedSubtree(
      key: revealTargetKey,
      child: SizedBox(
        key: const ValueKey('catch-field-action-bar'),
        width: double.infinity,
        child: Row(
          children: [
            if (actionLeading != null)
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: actionLeading,
                ),
              )
            else
              const Spacer(),
            cancelButton,
            const SizedBox(width: CatchFieldTokens.actionButtonGap),
            doneButton,
          ],
        ),
      ),
    );
  }
}
