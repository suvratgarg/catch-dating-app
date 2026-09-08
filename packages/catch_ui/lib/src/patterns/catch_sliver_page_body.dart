import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_field_interaction_plane.dart';
import 'package:flutter/widgets.dart';

/// Sliver-native page body padding wrapper.
class CatchSliverPageBody extends StatelessWidget {
  const CatchSliverPageBody({
    super.key,
    required this.sliver,
    this.padding = CatchInsets.pageBody,
  });

  final Widget sliver;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: CatchFieldInteractionPlane(padding: padding, child: sliver),
    );
  }
}
