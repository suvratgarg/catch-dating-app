import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

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
    return Padding(padding: padding, child: child);
  }
}

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
    return Padding(padding: padding, child: child);
  }
}

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
    return SliverPadding(padding: padding, sliver: sliver);
  }
}

/// Vertical layout primitive for semantically distinct sections.
///
/// Use this instead of manually interleaving section widgets with spacer
/// widgets. The caller chooses a semantic gap token, and this widget owns the
/// mechanics of placing that gap between sections.
class CatchSectionList extends StatelessWidget {
  const CatchSectionList({
    super.key,
    required this.children,
    this.gap = CatchGaps.section,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final spacedChildren = <Widget>[];
    for (final child in children) {
      if (spacedChildren.isNotEmpty) {
        spacedChildren.add(SizedBox(height: gap));
      }
      spacedChildren.add(child);
    }

    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: spacedChildren,
    );
  }
}

/// Sliver-native detail body wrapper with Catch's detail-screen page insets.
class CatchDetailSliverSectionList extends StatelessWidget {
  const CatchDetailSliverSectionList({
    super.key,
    required this.sections,
    this.gap = CatchLayout.detailScreenSectionGap,
    this.horizontalPadding = CatchLayout.detailScreenHorizontalPadding,
    this.topPadding = CatchLayout.detailScreenTopPadding,
    this.bottomPadding = CatchLayout.detailScreenBottomPadding,
  });

  final List<Widget> sections;
  final double gap;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
      ),
      sliver: SliverToBoxAdapter(
        child: CatchSectionList(gap: gap, children: sections),
      ),
    );
  }
}
