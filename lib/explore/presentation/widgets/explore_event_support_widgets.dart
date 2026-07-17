import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:flutter/material.dart';

class ExploreMonoLabel extends StatelessWidget {
  const ExploreMonoLabel(this.label, {super.key, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.kicker(context, color: color),
    );
  }
}
