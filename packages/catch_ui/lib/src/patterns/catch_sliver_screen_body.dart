import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/patterns/catch_screen_body_layout.dart';
import 'package:catch_ui/src/patterns/catch_sliver_content_width.dart';
import 'package:catch_ui/src/patterns/catch_sliver_page_body.dart';
import 'package:flutter/widgets.dart';

/// Canonical sliver body shared by root screens and nested tab pages.
///
/// It owns one semantic body inset, the page interaction plane used by field
/// rows, and the optional responsive content-width clamp. Terminal clearance
/// remains a sibling owned by the enclosing scroll view so it always spans the
/// physical viewport.
class CatchSliverScreenBody extends StatelessWidget {
  const CatchSliverScreenBody({
    super.key,
    required this.layout,
    required this.slivers,
    this.constrainToContentWidth = false,
    this.maxContentExtent = CatchLayout.screenPageMaxExtent,
  }) : assert(maxContentExtent > 0);

  final CatchScreenBodyLayout layout;
  final List<Widget> slivers;
  final bool constrainToContentWidth;
  final double maxContentExtent;

  @override
  Widget build(BuildContext context) {
    assert(
      slivers.isNotEmpty,
      'CatchSliverScreenBody requires at least one sliver.',
    );
    Widget body = SliverMainAxisGroup(slivers: slivers);
    final padding = switch (layout) {
      CatchScreenBodyLayout.standard => CatchInsets.pageBody.copyWith(
        bottom: 0,
      ),
      CatchScreenBodyLayout.fullBleed => null,
    };
    if (padding != null) {
      body = CatchSliverPageBody(padding: padding, sliver: body);
    }
    if (constrainToContentWidth) {
      body = CatchSliverContentWidth(maxExtent: maxContentExtent, sliver: body);
    }
    return body;
  }
}
