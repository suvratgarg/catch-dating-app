import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_interaction_plane_scope.dart';
import 'package:catch_ui/src/patterns/catch_page_body_mode.dart';
import 'package:catch_ui/src/patterns/catch_page_body_variant.dart';
import 'package:catch_ui/src/patterns/catch_scroll_view.dart';
import 'package:catch_ui/src/patterns/catch_viewport.dart';
import 'package:flutter/widgets.dart';

/// Page insets and field paint geometry, with form, screen and sliver recipes.
///
/// Use one semantic body owner at each page boundary. Nested component content
/// keeps its own geometry; terminal shell clearance remains with the route or
/// scroll owner. The screen recipe delegates scrolling to [CatchScrollView].
class CatchPageBody extends StatelessWidget {
  const CatchPageBody({
    super.key,
    required Widget child,
    EdgeInsetsGeometry padding = CatchInsets.pageBody,
  }) : _inset = (child: child, padding: padding, sliver: false),
       _screen = null,
       _slivers = null;

  const CatchPageBody.formStep({
    super.key,
    required Widget child,
    EdgeInsetsGeometry padding = CatchInsets.formStepBody,
  }) : _inset = (child: child, padding: padding, sliver: false),
       _screen = null,
       _slivers = null;

  const CatchPageBody.sliver({
    super.key,
    required Widget child,
    EdgeInsetsGeometry padding = CatchInsets.pageBody,
  }) : _inset = (child: child, padding: padding, sliver: true),
       _screen = null,
       _slivers = null;

  const CatchPageBody.slivers({
    super.key,
    required CatchPageBodyMode mode,
    required List<Widget> children,
    bool constrainToContentWidth = false,
    double maxContentExtent = CatchLayout.screenPageMaxExtent,
  }) : assert(maxContentExtent > 0),
       _inset = null,
       _screen = null,
       _slivers = (
         mode: mode,
         children: children,
         constrainToContentWidth: constrainToContentWidth,
         maxContentExtent: maxContentExtent,
       );

  const CatchPageBody.screen({
    super.key,
    required Widget child,
    bool gutter = true,
    double? pt,
    double? pb,
    EdgeInsetsGeometry? padding,
    CatchPageBodyVariant variant = CatchPageBodyVariant.scrolling,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.onDrag,
    Clip clipBehavior = Clip.hardEdge,
  }) : _inset = null,
       _slivers = null,
       _screen = (
         child: child,
         gutter: gutter,
         pt: pt,
         pb: pb,
         padding: padding,
         variant: variant,
         controller: controller,
         physics: physics,
         primary: primary,
         keyboardDismissBehavior: keyboardDismissBehavior,
         clipBehavior: clipBehavior,
       );

  final ({Widget child, EdgeInsetsGeometry padding, bool sliver})? _inset;
  final ({
    CatchPageBodyMode mode,
    List<Widget> children,
    bool constrainToContentWidth,
    double maxContentExtent,
  })?
  _slivers;
  final ({
    Widget child,
    bool gutter,
    double? pt,
    double? pb,
    EdgeInsetsGeometry? padding,
    CatchPageBodyVariant variant,
    ScrollController? controller,
    ScrollPhysics? physics,
    bool? primary,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior,
    Clip clipBehavior,
  })?
  _screen;

  @override
  Widget build(BuildContext context) {
    final screen = _screen;
    if (screen != null) {
      final horizontal = screen.gutter
          ? CatchSpacing.screenPx
          : CatchSpacing.s0;
      final padding =
          screen.padding ??
          EdgeInsets.fromLTRB(
            horizontal,
            screen.pt ?? CatchSpacing.screenPt,
            horizontal,
            screen.pb ?? CatchSpacing.screenPb,
          );
      final body = Padding(
        padding: padding,
        child: CatchFieldInteractionPlaneScope.fromPadding(
          context: context,
          padding: padding,
          child: SizedBox(width: double.infinity, child: screen.child),
        ),
      );
      if (screen.variant == CatchPageBodyVariant.fixed) return body;
      return CatchScrollView(
        controller: screen.controller,
        physics: screen.physics,
        primary: screen.primary,
        keyboardDismissBehavior: screen.keyboardDismissBehavior,
        clipBehavior: screen.clipBehavior,
        child: body,
      );
    }
    final slivers = _slivers;
    if (slivers != null) {
      assert(
        slivers.children.isNotEmpty,
        'CatchPageBody.slivers requires at least one sliver.',
      );
      Widget body = SliverMainAxisGroup(slivers: slivers.children);
      if (slivers.mode == CatchPageBodyMode.standard) {
        final padding = CatchInsets.pageBody.copyWith(bottom: 0);
        body = SliverPadding(
          padding: padding,
          sliver: CatchFieldInteractionPlaneScope.fromPadding(
            context: context,
            padding: padding,
            child: body,
          ),
        );
      }
      if (slivers.constrainToContentWidth) {
        body = CatchViewport.sliverLane(
          maxExtent: slivers.maxContentExtent,
          child: body,
        );
      }
      return body;
    }
    final inset = _inset!;
    final body = CatchFieldInteractionPlaneScope.fromPadding(
      context: context,
      padding: inset.padding,
      child: inset.child,
    );
    return inset.sliver
        ? SliverPadding(padding: inset.padding, sliver: body)
        : Padding(padding: inset.padding, child: body);
  }
}
