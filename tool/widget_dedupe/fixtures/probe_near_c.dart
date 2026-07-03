// ignore_for_file: avoid_relative_lib_imports, depend_on_referenced_packages

import 'package:flutter/widgets.dart';

import '../../../lib/core/theme/catch_tokens.dart';

class ProbeNearC extends StatelessWidget {
  const ProbeNearC({super.key, required this.heading, this.active = true});

  final String heading;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        children: [
          Text(heading),
          if (active)
            const SizedBox(height: CatchSpacing.s2)
          else
            const SizedBox(height: CatchSpacing.s1),
          const SizedBox(width: CatchSpacing.s3),
          const Text('ready'),
          const SizedBox(height: CatchSpacing.s2),
          const SizedBox(width: CatchSpacing.s1),
        ],
      ),
    );
  }
}
