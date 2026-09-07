import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_field_interaction_plane.dart';
import 'package:flutter/widgets.dart';

/// Standard form-step body padding wrapper for create/edit flows.
class CatchFormStepBody extends StatelessWidget {
  const CatchFormStepBody({
    super.key,
    required this.child,
    this.padding = CatchInsets.formStepBody,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CatchFieldInteractionPlane(padding: padding, child: child),
    );
  }
}
