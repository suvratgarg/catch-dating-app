import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
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

/// Design-system `ScreenBody`: the scrolling/content body owns the app gutter.
///
/// Use this as the standard middle region under full-bleed chrome. It owns the
/// app-wide horizontal gutter, scrolls vertically by default, and lets screens
/// override only the top/bottom rhythm without rebuilding the side insets.
class CatchScreenBody extends StatelessWidget {
  const CatchScreenBody({
    super.key,
    required this.child,
    this.gutter = true,
    this.pt,
    this.pb,
    this.padding,
    this.scrollable = true,
    this.controller,
    this.physics,
    this.primary,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.clipBehavior = Clip.hardEdge,
  });

  final Widget child;
  final bool gutter;
  final double? pt;
  final double? pb;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool? primary;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final paddedChild = Padding(
      padding: _effectivePadding(),
      child: SizedBox(width: double.infinity, child: child),
    );

    if (!scrollable) return paddedChild;

    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : 0.0;

        return SingleChildScrollView(
          controller: controller,
          physics: physics,
          primary: primary,
          keyboardDismissBehavior: keyboardDismissBehavior,
          clipBehavior: clipBehavior,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: paddedChild,
          ),
        );
      },
    );
  }

  EdgeInsetsGeometry _effectivePadding() {
    final padding = this.padding;
    if (padding != null) return padding;

    final horizontal = gutter ? CatchSpacing.screenPx : CatchSpacing.s0;
    return EdgeInsets.fromLTRB(
      horizontal,
      pt ?? CatchSpacing.screenPt,
      horizontal,
      pb ?? CatchSpacing.screenPb,
    );
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
      if (spacedChildren.isNotEmpty && gap > 0) {
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

/// Design-system `SectionStack`: standard body gutter for handoff sections.
///
/// Section-to-section rhythm belongs to [CatchDesignSection] itself; this
/// wrapper intentionally defaults to no inserted gap.
class CatchSectionStack extends StatelessWidget {
  const CatchSectionStack({
    super.key,
    required this.children,
    this.padding = CatchInsets.pageBody,
    this.gap = 0,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: CatchSectionList(gap: gap, children: children),
    );
  }
}

/// Design-system `Section`: a kicker plus body with codified separators.
///
/// Screens that adopt the handoff composition should place these inside
/// [CatchSectionStack] or [CatchDetailSliverSectionList] with no ad-hoc gaps.
class CatchDesignSection extends StatelessWidget {
  const CatchDesignSection({
    super.key,
    required this.kicker,
    required this.child,
    this.count,
    this.activityKind,
    this.lead = false,
    this.first = false,
    this.dividerColor,
    this.kickerColor,
    this.bodyGap = CatchSpacing.s3,
  });

  final String kicker;
  final Object? count;
  final ActivityKind? activityKind;
  final bool lead;
  final bool first;
  final Color? dividerColor;
  final Color? kickerColor;
  final double bodyGap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activityAccent = activityKind == null
        ? null
        : ActivityPalette.resolve(context, activityKind!).accent;
    final effectiveKickerColor =
        kickerColor ??
        (lead && activityAccent != null ? activityAccent : t.ink);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CatchSectionKicker(
          text: kicker,
          count: count,
          color: effectiveKickerColor,
        ),
        SizedBox(height: bodyGap),
        child,
      ],
    );

    if (first) return content;

    return Padding(
      padding: const EdgeInsets.only(top: CatchSpacing.s6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: dividerColor ?? t.line)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.s6),
          child: content,
        ),
      ),
    );
  }
}

class _CatchSectionKicker extends StatelessWidget {
  const _CatchSectionKicker({
    required this.text,
    required this.color,
    this.count,
  });

  final String text;
  final Color color;
  final Object? count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final count = this.count;
    if (count == null || count.toString().isEmpty) {
      return CatchKicker(label: text, color: color);
    }
    final style = CatchKicker.styleOf(context, color: color);
    return Text.rich(
      TextSpan(
        text: text.toUpperCase(),
        children: [
          TextSpan(
            text: ' · $count',
            style: style.copyWith(color: t.ink3, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      style: style,
    );
  }
}

/// Sliver-native detail body wrapper with Catch's detail-screen page insets.
///
/// Defaults to no inserted gap so [CatchDesignSection] owns its delimiter and
/// top rhythm in sliver-native detail pages too.
class CatchDetailSliverSectionList extends StatelessWidget {
  const CatchDetailSliverSectionList({
    super.key,
    required this.sections,
    this.gap = 0,
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
