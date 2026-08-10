// ignore_for_file: avoid_relative_lib_imports, depend_on_referenced_packages

import 'package:flutter/widgets.dart';

class ProbeParameterShapes extends StatelessWidget {
  const ProbeParameterShapes(
    String label, {
    required void onTap(),
    bool enabled = true,
  }) : _label = label,
       _onTap = onTap,
       _enabled = enabled;

  final String _label;
  final VoidCallback _onTap;
  final bool _enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _enabled ? _onTap : null,
      child: Text(_label),
    );
  }
}
