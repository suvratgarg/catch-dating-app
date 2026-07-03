// ignore_for_file: avoid_relative_lib_imports, depend_on_referenced_packages

import 'package:flutter/widgets.dart';

import '../../../lib/core/theme/catch_tokens.dart';

class ProbeAlphaStatusPill extends StatelessWidget {
  const ProbeAlphaStatusPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: CatchSpacing.s2,
          top: CatchSpacing.s3,
          right: CatchSpacing.s4,
          bottom: CatchSpacing.s5,
          child: Text(label),
        ),
      ],
    );
  }
}
