import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class StepperFooter extends StatelessWidget {
  const StepperFooter({
    super.key,
    required this.isLastStep,
    required this.isLoading,
    required this.onPrimary,
    this.onSaveDraft,
    this.primaryLabel,
    this.lastStepLabel = 'Done',
  });

  final bool isLastStep;
  final bool isLoading;
  final VoidCallback onPrimary;
  final VoidCallback? onSaveDraft;
  final String? primaryLabel;
  final String lastStepLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final label =
        primaryLabel ??
        (isLastStep ? lastStepLabel : context.l10n.hostsStepperFooterLabelNext);
    return CatchBottomDock(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s3,
        CatchSpacing.s4,
        CatchSpacing.s3,
      ),
      child: Row(
        children: [
          if (onSaveDraft != null) ...[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CatchButton(
                  label: context.l10n.hostsStepperFooterLabelSaveDraft,
                  onPressed: isLoading ? null : onSaveDraft,
                  variant: CatchButtonVariant.ghost,
                  size: CatchButtonSize.lg,
                  icon: Icon(CatchIcons.saveOutlined),
                  foregroundColor: t.primary,
                ),
              ),
            ),
            const SizedBox(width: CatchSpacing.s3),
          ],
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: CatchButton(
                label: label,
                onPressed: onPrimary,
                isLoading: isLoading,
                fullWidth: true,
                icon: isLastStep ? null : Icon(CatchIcons.arrowForwardRounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
