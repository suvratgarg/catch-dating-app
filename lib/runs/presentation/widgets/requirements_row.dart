import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';

class RequirementsRow extends StatelessWidget {
  const RequirementsRow({super.key, required this.run});

  final Run run;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final c = run.constraints;
    final chips = <String>[];

    if (c.minAge > 0 && c.maxAge < 99) {
      chips.add('Age ${c.minAge}–${c.maxAge}');
    } else if (c.minAge > 0) {
      chips.add('${c.minAge}+ years');
    } else if (c.maxAge < 99) {
      chips.add('Up to ${c.maxAge} years');
    }
    if (c.maxMen != null) chips.add('Max ${c.maxMen} men');
    if (c.maxWomen != null) chips.add('Max ${c.maxWomen} women');

    if (chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements',
          style: CatchTextStyles.labelMd(context, color: t.ink2),
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
