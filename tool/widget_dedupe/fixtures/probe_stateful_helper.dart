// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/widgets.dart';

class ProbeStatefulHelper extends StatefulWidget {
  const ProbeStatefulHelper({super.key, required this.label});

  final String label;

  @override
  State<ProbeStatefulHelper> createState() => _ProbeStatefulHelperState();
}

class _ProbeStatefulHelperState extends State<ProbeStatefulHelper> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(widget.label), _buildTrailing()]);
  }

  Widget _buildTrailing() {
    return const SizedBox(height: 12);
  }
}
