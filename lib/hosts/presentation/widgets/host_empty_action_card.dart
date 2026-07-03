import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

/// Empty-state card with CTA actions for host surfaces.
class HostEmptyActionCard extends StatelessWidget {
  const HostEmptyActionCard({
    super.key,
    required this.title,
    required this.body,
    this.actions = const <Widget>[],
  });

  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CatchTextStyles.sectionTitle(context)),
          gapH8,
          Text(body, style: CatchTextStyles.supporting(context, color: t.ink2)),
          if (actions.isNotEmpty) ...[
            gapH18,
            if (actions.length == 1)
              actions.single
            else
              Row(
                children: [
                  for (final indexed in actions.indexed) ...[
                    if (indexed.$1 > 0) gapW8,
                    Expanded(child: indexed.$2),
                  ],
                ],
              ),
          ],
        ],
      ),
    );
  }
}
