// ignore_for_file: avoid_relative_lib_imports, depend_on_referenced_packages

import 'package:flutter/widgets.dart';

import '../../../lib/core/theme/catch_tokens.dart';

class ProbeBetaStatusPill extends StatelessWidget {
  const ProbeBetaStatusPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: CatchSpacing.s10,
          right: CatchSpacing.s8,
          top: CatchSpacing.s6,
          left: CatchSpacing.s5,
          child: Text(label),
        ),
      ],
    );
  }
}
