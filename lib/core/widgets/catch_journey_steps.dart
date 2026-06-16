import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// One step in a [CatchJourneySteps] sequence.
class CatchJourneyStep {
  const CatchJourneyStep({required this.title, this.body});

  final String title;
  final String? body;
}

/// Design-system `JourneySteps` (`components/events/JourneySteps`): a numbered,
/// line-traced sequence — the Itinerary grammar applied to ordered steps. A mono
/// index, a node rail with a connecting line tracing one step into the next, and
/// a function-font title + body. Indices auto-number (01, 02 …). Use where a list
/// is genuinely a sequence (first-run dashboard, multi-step "how it works"); the
/// trace is the point. [accent] defaults to the ink primary.
class CatchJourneySteps extends StatelessWidget {
  const CatchJourneySteps({super.key, required this.steps, this.accent});

  final List<CatchJourneyStep> steps;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final accentColor = accent ?? t.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: CatchLayout.journeyStepsIndexColumnWidth,
                  child: Padding(
                    padding: const EdgeInsets.only(top: CatchStroke.hairline),
                    child: Text(
                      (i + 1).toString().padLeft(2, '0'),
                      style: CatchTextStyles.mono(
                        context,
                        color: accentColor,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                SizedBox(
                  width: CatchLayout.journeyStepsRailColumnWidth,
                  child: Column(
                    children: [
                      const SizedBox(height: CatchSpacing.micro3),
                      _JourneyNode(accent: accentColor),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: CatchStroke.underline,
                            color: t.line2,
                          ),
                        ),
                    ],
                  ),
                ),
                gapW10,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < steps.length - 1 ? CatchSpacing.s5 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].title,
                          style: CatchTextStyles.titleS(context),
                        ),
                        if (steps[i].body != null) ...[
                          const SizedBox(height: CatchSpacing.micro3),
                          Text(
                            steps[i].body!,
                            style: CatchTextStyles.bodyS(context),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The 11px traced node — a [CatchTokens.bg]-filled disc with a 2px accent ring.
class _JourneyNode extends StatelessWidget {
  const _JourneyNode({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      width: CatchLayout.journeyStepsNodeExtent,
      height: CatchLayout.journeyStepsNodeExtent,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: t.bg,
        border: Border.all(color: accent, width: CatchStroke.clubMemberSeal),
      ),
    );
  }
}
