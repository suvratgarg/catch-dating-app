// ignore_for_file: avoid_relative_lib_imports, depend_on_referenced_packages

import 'package:flutter/widgets.dart';

import '../../../lib/core/theme/catch_tokens.dart';

class ProbeDupeA extends StatelessWidget {
  const ProbeDupeA({super.key, required this.title, this.enabled = true});

  final String title;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Column(
        children: [
          Text(title),
          if (enabled)
            const SizedBox(height: CatchSpacing.s2)
          else
            const SizedBox(height: CatchSpacing.s1),
          const SizedBox(width: CatchSpacing.s3),
          const Text('ready'),
          const SizedBox(height: CatchSpacing.s2),
        ],
      ),
    );
  }
}
