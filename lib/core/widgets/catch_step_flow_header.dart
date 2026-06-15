import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:flutter/material.dart';

/// Handoff `StepHeader`: wizard header built from the shared large AppBar plus
/// a 2px progress hairline.
class CatchStepHeader extends StatelessWidget {
  const CatchStepHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.kicker,
    this.step,
    this.total,
    this.onBack,
    this.showBack = true,
    this.trailing,
    this.gutter = true,
  });

  final String title;
  final String? subtitle;
  final String? kicker;
  final int? step;
  final int? total;
  final VoidCallback? onBack;
  final bool showBack;
  final Widget? trailing;
  final bool gutter;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasProgress = step != null && total != null && total! > 0;
    final clampedStep = hasProgress ? step!.clamp(1, total!) : null;
    final fraction = hasProgress
        ? (clampedStep! / total!).clamp(0.0, 1.0)
        : 0.0;
    final topRight =
        trailing ??
        (hasProgress
            ? Text(
                'STEP $clampedStep OF $total',
                style: CatchTextStyles.monoLabel(context, color: t.ink3),
              )
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchTopBar(
          title: title,
          subtitle: subtitle,
          kicker: kicker,
          large: true,
          leadingType: showBack
              ? CatchTopBarLeading.back
              : CatchTopBarLeading.none,
          onBack: onBack,
          trailing: topRight,
          gutter: gutter,
        ),
        if (hasProgress)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: gutter ? CatchSpacing.screenPx : CatchSpacing.s0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              child: SizedBox(
                height: CatchLayout.stepHeaderProgressHeight,
                child: ColoredBox(
                  color: t.line,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: ColoredBox(color: t.ink),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Compatibility wrapper for older zero-based multi-step flows.
class CatchStepFlowHeader extends StatelessWidget {
  const CatchStepFlowHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return CatchStepHeader(
      title: title,
      subtitle: subtitle,
      step: currentStep + 1,
      total: totalSteps,
      onBack: onBack,
    );
  }
}
