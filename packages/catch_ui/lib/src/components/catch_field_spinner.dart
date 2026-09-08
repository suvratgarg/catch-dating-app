import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:flutter/material.dart';

/// Fixed-cadence Phosphor spinner from the Field handoff.
class CatchFieldSpinner extends StatefulWidget {
  const CatchFieldSpinner({
    super.key,
    this.size = CatchFieldTokens.spinnerExtent,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  State<CatchFieldSpinner> createState() => _CatchFieldSpinnerState();
}

class _CatchFieldSpinnerState extends State<CatchFieldSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: CatchFieldTokens.spinnerPeriod,
  )..repeat();

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      key: const ValueKey('catch-field-spinner'),
      turns: _rotation,
      child: Icon(
        CatchIcons.fieldSpinner,
        size: widget.size,
        color: widget.color,
      ),
    );
  }
}
