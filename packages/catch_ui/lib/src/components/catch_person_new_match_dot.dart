import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/primitives/catch_status_dot.dart';
import 'package:flutter/material.dart';

class CatchPersonNewMatchDot extends StatelessWidget {
  const CatchPersonNewMatchDot({super.key, required this.semanticsLabel});

  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: CatchStatusDot(
          color: CatchTokens.of(context).primary,
          size: CatchSpacing.s2,
        ),
      ),
    );
  }
}
