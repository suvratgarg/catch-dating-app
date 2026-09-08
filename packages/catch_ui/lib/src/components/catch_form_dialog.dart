import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchFormDialog extends StatelessWidget {
  const CatchFormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Dialog(
      elevation: 0,
      insetPadding: const EdgeInsets.all(CatchLayout.confirmDialogInset),
      backgroundColor: Colors.transparent,
      child: CatchSurface(
        emphasis: CatchSurfaceEmphasis.floating,
        borderWidth: 0,
        padding: CatchInsets.confirmDialogCard,
        width: CatchLayout.confirmDialogMaxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: CatchTextStyles.titleL(context, color: t.ink)),
            gapH16,
            child,
            if (actions.isNotEmpty) ...[
              gapH20,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (final indexed in actions.indexed) ...[
                    if (indexed.$1 > 0) gapW8,
                    indexed.$2,
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
