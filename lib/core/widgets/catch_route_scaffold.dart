import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

typedef CatchRouteTopBarBuilder =
    PreferredSizeWidget Function(BuildContext context, bool scrolledUnder);

/// Canonical shell for pushed utility, list, and identity routes.
///
/// The shell owns the route surface and scroll-under divider so callers cannot
/// independently choose competing background/border behavior. Root tab screens
/// keep using sliver headers because their title is part of the scroll content.
class CatchRouteScaffold extends StatefulWidget {
  const CatchRouteScaffold({
    super.key,
    required this.topBarBuilder,
    required this.body,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
  });

  final CatchRouteTopBarBuilder topBarBuilder;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;

  @override
  State<CatchRouteScaffold> createState() => _CatchRouteScaffoldState();
}

class _CatchRouteScaffoldState extends State<CatchRouteScaffold> {
  bool _scrolledUnder = false;

  bool _handleScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final scrolledUnder = notification.metrics.extentBefore > 0;
    if (scrolledUnder != _scrolledUnder) {
      setState(() => _scrolledUnder = scrolledUnder);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.backgroundColor ?? CatchTokens.of(context).bg;
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      appBar: widget.topBarBuilder(context, _scrolledUnder),
      bottomNavigationBar: widget.bottomNavigationBar,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: widget.body,
      ),
    );
  }
}
