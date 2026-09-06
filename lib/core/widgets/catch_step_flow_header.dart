import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
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
    this.leadingType,
    this.onStepOverview,
    this.stepOverviewSemanticsLabel,
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
  final CatchTopBarLeading? leadingType;
  final VoidCallback? onStepOverview;
  final String? stepOverviewSemanticsLabel;
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
    final stepLabel = hasProgress
        ? context.l10n.coreCatchStepFlowHeaderTextStepClampedstepOfTotal(
            clampedStep: clampedStep!,
            total: total!,
          )
        : null;
    final visibleStepLabel =
        hasProgress && MediaQuery.textScalerOf(context).scale(1) >= 1.6
        ? context.l10n.coreCatchStepFlowHeaderTextCompactStepClampedstepTotal(
            clampedStep: clampedStep!,
            total: total!,
          )
        : stepLabel;
    final topRight =
        trailing ??
        (hasProgress
            ? Padding(
                padding: EdgeInsets.only(
                  top: kicker == null
                      ? CatchLayout.stepHeaderCounterTopPadding
                      : CatchSpacing.s0,
                ),
                child: onStepOverview == null
                    ? Text(
                        visibleStepLabel!,
                        style: CatchTextStyles.monoLabel(
                          context,
                          color: t.ink3,
                        ),
                      )
                    : Semantics(
                        button: true,
                        label: stepOverviewSemanticsLabel ?? stepLabel,
                        excludeSemantics: true,
                        child: CatchTextButton(
                          label: visibleStepLabel!,
                          onPressed: onStepOverview,
                          tone: CatchTextButtonTone.neutral,
                          minimumSize: const Size(
                            CatchSpacing.s0,
                            CatchIconButton.navSize,
                          ),
                          padding: EdgeInsets.zero,
                          textStyle: CatchTextStyles.monoLabel(
                            context,
                            color: t.ink3,
                          ),
                        ),
                      ),
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
          leadingType:
              leadingType ??
              (showBack ? CatchTopBarLeading.back : CatchTopBarLeading.none),
          onBack: onBack,
          trailing: topRight,
          gutter: gutter,
          largeHeight: CatchLayout.stepHeaderTopBarHeight,
          allowContentHeightExpansion: true,
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
