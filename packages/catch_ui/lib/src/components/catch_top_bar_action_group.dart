import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_button.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:flutter/material.dart';

/// Canonical trailing-action layout for Catch top bars and screen headers.
///
/// Action spacing is intentionally owned here so callers cannot create subtly
/// different header geometry by composing their own [Row].
class CatchTopBarActionGroup extends StatelessWidget {
  const CatchTopBarActionGroup({super.key, required this.actions});

  final List<Widget> actions;

  double get minimumWidth => actions.isEmpty
      ? 0
      : CatchPlatformTokens.minimumInteractiveExtent * actions.length +
            CatchSpacing.s2 * (actions.length - 1);

  @override
  Widget build(BuildContext context) {
    assert(() {
      for (final action in actions) {
        if (action is! CatchButton) continue;
        throw FlutterError.fromParts([
          ErrorSummary('CatchButton cannot be a direct top-bar action.'),
          ErrorDescription(
            'Use CatchTopBarPrimaryAction for a primary action that compacts '
            'to an icon, CatchIconAction for an icon-only action, '
            'CatchTopBarTextAction for a semantic text action, or '
            'CatchTopBarMenuAction for overflow actions.',
          ),
        ]);
      }
      return true;
    }());

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          Flexible(child: actions[index]),
          if (index != actions.length - 1) gapW8,
        ],
      ],
    );
  }
}
