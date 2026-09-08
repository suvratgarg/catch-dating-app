import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_field_interaction_plane.dart';
import 'package:flutter/widgets.dart';

/// Standard page body padding wrapper for non-sliver content.
///
/// Use this when a screen has one body child and should adopt a named Catch
/// inset role instead of composing [EdgeInsets] directly in feature code.
class CatchPageBody extends StatelessWidget {
  const CatchPageBody({
    super.key,
    required this.child,
    this.padding = CatchInsets.pageBody,
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
