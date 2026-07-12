import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_surface_style.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class RequirementsRow extends StatelessWidget {
  const RequirementsRow({super.key, required this.event, this.surfaceStyle});

  final Event event;
  final EventDetailSurfaceStyle? surfaceStyle;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final chips = event.constraints.requirementLabels;

    if (chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.eventsRequirementsRowTextRequirements,
          style: CatchTextStyles.labelL(
            context,
            color: surfaceStyle?.bodyColor ?? t.ink2,
          ),
        ),
        gapH8,
        Wrap(
          spacing: CatchSpacing.micro6,
          runSpacing: CatchSpacing.micro6,
          children: [
            for (final label in chips)
              CatchBadge(
                label: label,
                tone: CatchBadgeTone.brand,
                uppercase: true,
              ),
          ],
        ),
      ],
    );
  }
}
