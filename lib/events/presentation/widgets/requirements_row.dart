import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

class RequirementsRow extends StatelessWidget {
  const RequirementsRow({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final chips = event.constraints.requirementLabels;

    if (chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements',
          style: CatchTextStyles.labelL(context, color: t.ink2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: chips.map((l) => VibeTag(label: l)).toList(),
        ),
      ],
    );
  }
}
