import 'package:catch_ui/src/components/catch_count_badge.dart';
import 'package:flutter/material.dart';

class CatchPersonUnreadCountPill extends StatelessWidget {
  const CatchPersonUnreadCountPill({
    super.key,
    required this.count,
    required this.semanticsLabel,
  });

  final int count;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(child: CatchCountBadge.label(count: count)),
    );
  }
}
