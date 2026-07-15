import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart'
    show CatchField, CatchFieldInsetScope;
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/widgets/catch_divider.dart';

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

/// Sliver-native terminal clearance for root scroll views.
///
/// Use this as the final sliver when a screen owns a full-height
/// [CustomScrollView] and needs enough room for home-indicator safe area plus
/// Catch's standard bottom breathing space.
class CatchSliverTerminalPadding extends StatelessWidget {
  const CatchSliverTerminalPadding({
    super.key,
    this.extra = CatchSpacing.screenPb,
    this.includeSafeArea = true,
  });

  final double extra;
  final bool includeSafeArea;

  @override
  Widget build(BuildContext context) {
    final safeBottomInset = includeSafeArea
        ? math.max(
            MediaQuery.paddingOf(context).bottom,
            MediaQuery.viewPaddingOf(context).bottom,
          )
        : 0.0;
    return SliverToBoxAdapter(child: SizedBox(height: safeBottomInset + extra));
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
/// Section-to-section rhythm belongs to [CatchSection] itself; this
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

enum _CatchSectionVariant { divided, contained, plain }

/// Design-system `Section`: the canonical primitive for grouping information.
///
/// Screens that adopt the handoff composition should place these inside
/// [CatchSectionStack] or [CatchDetailSliverSectionList] with no ad-hoc gaps.
class CatchSection extends StatelessWidget {
  const CatchSection._({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    this.count,
    this.activityKind,
    this.lead = false,
    this.first = false,
    this._variant = _CatchSectionVariant.divided,
    this.dividerColor,
    this.dividerIndent = 0,
    this.dividerRole = CatchDividerRole.section,
    this.internalDividerRole = CatchDividerRole.fieldRow,
    this.titleColor,
    this.bodyGap = CatchSpacing.s3,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.tone = CatchSurfaceTone.surface,
    this.elevation = CatchSurfaceElevation.card,
    this.boxShadow,
    this.showInternalDividers = true,
    this.footer,
    this.focused = false,
    this.hasError = false,
    this._fieldRows = false,
    this.children,
    this.child,
  }) : assert(
         child != null || children != null,
         'CatchSection needs either child or children.',
       ),
       assert(
         child == null || children == null,
         'CatchSection accepts either child or children, not both.',
       );

  const CatchSection.divided({
    Key? key,
    String? title,
    Object? count,
    Widget? trailing,
    ActivityKind? activityKind,
    bool lead = false,
    bool first = false,
    Color? dividerColor,
    double dividerIndent = 0,
    CatchDividerRole dividerRole = CatchDividerRole.section,
    CatchDividerRole internalDividerRole = CatchDividerRole.fieldRow,
    Color? titleColor,
    double bodyGap = CatchSpacing.s3,
    bool showInternalDividers = true,
    List<Widget>? children,
    Widget? child,
  }) : this._(
         key: key,
         title: title,
         count: count,
         trailing: trailing,
         activityKind: activityKind,
         lead: lead,
         first: first,
         variant: _CatchSectionVariant.divided,
         dividerColor: dividerColor,
         dividerIndent: dividerIndent,
         dividerRole: dividerRole,
         internalDividerRole: internalDividerRole,
         titleColor: titleColor,
         bodyGap: bodyGap,
         showInternalDividers: showInternalDividers,
         children: children,
         child: child,
       );

  const CatchSection.fieldRows({
    Key? key,
    String? title,
    Object? count,
    Widget? trailing,
    ActivityKind? activityKind,
    bool lead = false,
    bool first = false,
    Widget? footer,
    Color? dividerColor,
    double? dividerInset,
    CatchDividerRole dividerRole = CatchDividerRole.section,
    Color? titleColor,
    double bodyGap = CatchFieldTokens.sectionRuleGap,
    bool showInternalDividers = true,
    List<Widget>? children,
    Widget? child,
  }) : this._(
         key: key,
         title: title,
         count: count,
         trailing: trailing,
         activityKind: activityKind,
         lead: lead,
         first: first,
         variant: _CatchSectionVariant.divided,
         dividerColor: dividerColor,
         dividerIndent: dividerInset ?? double.nan,
         dividerRole: dividerRole,
         internalDividerRole: CatchDividerRole.fieldSection,
         titleColor: titleColor,
         bodyGap: bodyGap,
         showInternalDividers: showInternalDividers,
         footer: footer,
         fieldRows: true,
         children: children,
         child: child,
       );

  /// Contained FieldSection variant from the form-field handoff. Unlike the
  /// generic card constructor, this surface clips field rows, owns a 1px
  /// line/ink focus border, and never adds generic card elevation.
  const CatchSection.containedFieldRows({
    Key? key,
    String? title,
    Object? count,
    Widget? trailing,
    Widget? footer,
    Color? backgroundColor,
    Color? borderColor,
    Color? titleColor,
    double? dividerInset,
    bool showInternalDividers = true,
    bool focused = false,
    bool hasError = false,
    List<Widget>? children,
    Widget? child,
  }) : this._(
         key: key,
         title: title,
         count: count,
         trailing: trailing,
         variant: _CatchSectionVariant.contained,
         titleColor: titleColor,
         bodyGap: CatchFieldTokens.sectionHeaderGap,
         padding: EdgeInsets.zero,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         elevation: CatchSurfaceElevation.none,
         showInternalDividers: showInternalDividers,
         footer: footer,
         focused: focused,
         hasError: hasError,
         dividerIndent: dividerInset ?? double.nan,
         internalDividerRole: CatchDividerRole.fieldSection,
         fieldRows: true,
         children: children,
         child: child,
       );

  const CatchSection.contained({
    Key? key,
    String? title,
    String? subtitle,
    Widget? trailing,
    Object? count,
    Color? titleColor,
    double bodyGap = CatchSpacing.s3,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? borderColor,
    CatchSurfaceTone tone = CatchSurfaceTone.surface,
    CatchSurfaceElevation elevation = CatchSurfaceElevation.card,
    List<BoxShadow>? boxShadow,
    bool showInternalDividers = true,
    bool focused = false,
    bool hasError = false,
    List<Widget>? children,
    Widget? child,
  }) : this._(
         key: key,
         title: title,
         subtitle: subtitle,
         trailing: trailing,
         count: count,
         variant: _CatchSectionVariant.contained,
         titleColor: titleColor,
         bodyGap: bodyGap,
         padding: padding,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         tone: tone,
         elevation: elevation,
         boxShadow: boxShadow,
         showInternalDividers: showInternalDividers,
         focused: focused,
         hasError: hasError,
         children: children,
         child: child,
       );

  const CatchSection.plain({
    Key? key,
    String? title,
    String? subtitle,
    Widget? trailing,
    Object? count,
    Color? titleColor,
    double bodyGap = CatchSpacing.s3,
    EdgeInsetsGeometry? padding,
    bool showInternalDividers = true,
    List<Widget>? children,
    Widget? child,
  }) : this._(
         key: key,
         title: title,
         subtitle: subtitle,
         trailing: trailing,
         count: count,
         variant: _CatchSectionVariant.plain,
         titleColor: titleColor,
         bodyGap: bodyGap,
         padding: padding,
         showInternalDividers: showInternalDividers,
         children: children,
         child: child,
       );

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Object? count;
  final ActivityKind? activityKind;
  final bool lead;
  final bool first;
  final _CatchSectionVariant _variant;
  final Color? dividerColor;
  final double dividerIndent;
  final CatchDividerRole dividerRole;
  final CatchDividerRole internalDividerRole;
  final Color? titleColor;
  final double bodyGap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final CatchSurfaceTone tone;
  final CatchSurfaceElevation elevation;
  final List<BoxShadow>? boxShadow;
  final bool showInternalDividers;
  final Widget? footer;
  final bool focused;
  final bool hasError;
  final bool _fieldRows;
  final List<Widget>? children;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final section = switch (_variant) {
      _CatchSectionVariant.divided => _buildDivided(context),
      _CatchSectionVariant.contained => _buildContained(context),
      _CatchSectionVariant.plain => _buildPlain(context),
    };
    if (footer == null ||
        (_variant == _CatchSectionVariant.contained && _fieldRows)) {
      return section;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section,
        if (_fieldRows)
          Padding(
            padding: const EdgeInsets.only(
              top: CatchFieldTokens.dividedSectionFooterTopPadding,
            ),
            child: DefaultTextStyle.merge(
              style: CatchTextStyles.fieldLabel(
                context,
                color: CatchTokens.of(context).ink3,
              ).copyWith(height: 1.5),
              child: footer!,
            ),
          )
        else
          footer!,
      ],
    );
  }

  Widget _buildDivided(BuildContext context) {
    final t = CatchTokens.of(context);
    final activityAccent = activityKind == null
        ? null
        : ActivityPalette.resolve(context, activityKind!).accent;
    final effectiveTitleColor =
        titleColor ??
        (lead && activityAccent != null
            ? activityAccent
            : _fieldRows
            ? t.ink2
            : t.ink);
    final displayTitle = title?.trim();
    final displayCount = count?.toString().trim();
    final hasTitle = displayTitle != null && displayTitle.isNotEmpty;
    final hasCount = displayCount != null && displayCount.isNotEmpty;
    final hasHeader = hasTitle || hasCount || trailing != null;
    if (_fieldRows) {
      final fieldContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeader) ...[
            _buildCatchSectionKicker(
              context,
              text: hasTitle ? displayTitle : null,
              count: hasCount ? displayCount : null,
              trailing: trailing,
              color: effectiveTitleColor,
              size: CatchKickerSize.fieldSection,
            ),
            SizedBox(height: bodyGap),
          ],
          // FieldSection's divided variant always owns the rule separating
          // it from its rows. Headerless groups (for example destructive
          // account actions) still need that boundary; only the kicker-to-
          // rule gap is conditional on a header.
          CatchDivider(
            color: dividerColor ?? CatchDivider.colorFor(t, dividerRole),
            role: dividerRole,
          ),
          CatchFieldInsetScope(flush: true, child: _body(context, t)),
        ],
      );
      if (first) return fieldContent;
      return Padding(
        padding: const EdgeInsets.only(top: CatchSpacing.s6),
        child: fieldContent,
      );
    }
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasHeader) ...[
          _buildCatchSectionKicker(
            context,
            text: hasTitle ? displayTitle : null,
            count: hasCount ? displayCount : null,
            trailing: trailing,
            color: effectiveTitleColor,
          ),
          SizedBox(height: bodyGap),
        ],
        // Divided sections own the horizontal gutter: field rows inside
        // render flush so content, trailing affordances, and the section's
        // dividers share the same edges.
        CatchFieldInsetScope(flush: true, child: _body(context, t)),
      ],
    );

    if (first) return content;

    return Padding(
      padding: const EdgeInsets.only(top: CatchSpacing.s6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: dividerColor ?? CatchDivider.colorFor(t, dividerRole),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.s6),
          child: content,
        ),
      ),
    );
  }

  Widget _buildContained(BuildContext context) {
    final t = CatchTokens.of(context);
    final displayTitle = title?.trim();
    final hasTitle = displayTitle != null && displayTitle.isNotEmpty;
    final displayCount = count?.toString().trim();
    final hasCount = displayCount != null && displayCount.isNotEmpty;
    final sectionTrailing = trailing;
    final sectionFooter = footer;
    final hasHeader = hasTitle || hasCount || sectionTrailing != null;
    final content = _fieldRows
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasHeader)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CatchFieldTokens.rowHorizontalPadding,
                    CatchFieldTokens.sectionHeaderTopPadding,
                    CatchFieldTokens.rowHorizontalPadding,
                    CatchFieldTokens.sectionHeaderBottomPadding,
                  ),
                  child: _buildCatchSectionKicker(
                    context,
                    text: hasTitle ? displayTitle : null,
                    count: hasCount ? displayCount : null,
                    trailing: sectionTrailing,
                    color: titleColor ?? t.ink2,
                    size: CatchKickerSize.fieldSection,
                  ),
                ),
              _body(context, t),
              if (sectionFooter != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CatchFieldTokens.rowHorizontalPadding,
                    CatchFieldTokens.containedSectionFooterTopPadding,
                    CatchFieldTokens.rowHorizontalPadding,
                    CatchFieldTokens.rowVerticalPadding,
                  ),
                  child: DefaultTextStyle.merge(
                    style: CatchTextStyles.fieldLabel(
                      context,
                      color: t.ink3,
                    ).copyWith(height: 1.5),
                    child: sectionFooter,
                  ),
                ),
            ],
          )
        : _sectionContent(context, t, contained: true);
    return CatchSectionFocusSurface(
      padding: padding ?? const EdgeInsets.all(CatchSpacing.s4),
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      tone: tone,
      elevation: elevation,
      boxShadow: boxShadow,
      focused: focused,
      hasError: hasError,
      fieldRows: _fieldRows,
      child: CatchFieldInsetScope(flush: !_fieldRows, child: content),
    );
  }

  Widget _buildPlain(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: _sectionContent(context, t, contained: false),
    );
  }

  Widget _sectionContent(
    BuildContext context,
    CatchTokens t, {
    required bool contained,
  }) {
    final header = _header(context, t, contained: contained);
    final body = _body(context, t);
    if (header == null) return body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        SizedBox(height: bodyGap),
        body,
      ],
    );
  }

  Widget? _header(
    BuildContext context,
    CatchTokens t, {
    required bool contained,
  }) {
    final displayTitle = title?.trim();
    final displaySubtitle = subtitle?.trim();
    final hasTitle = displayTitle != null && displayTitle.isNotEmpty;
    final hasSubtitle = displaySubtitle != null && displaySubtitle.isNotEmpty;
    if (!hasTitle && !hasSubtitle && trailing == null) return null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasTitle || hasSubtitle)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle)
                  contained
                      ? Text(
                          count == null
                              ? displayTitle
                              : context.l10n
                                    .coreCatchSectionLayoutTextDisplaytitleCount(
                                      displayTitle: displayTitle,
                                      count: count!,
                                    ),
                          style: CatchTextStyles.sectionTitle(
                            context,
                            color: titleColor ?? t.ink,
                          ),
                        )
                      : _buildCatchSectionKicker(
                          context,
                          text: displayTitle,
                          count: count,
                          color: titleColor ?? t.ink,
                        ),
                if (hasSubtitle) ...[
                  const SizedBox(height: CatchSpacing.s1),
                  Text(
                    displaySubtitle,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
              ],
            ),
          )
        else
          const Spacer(),
        if (trailing != null) ...[
          const SizedBox(width: CatchSpacing.s3),
          DefaultTextStyle.merge(
            style: CatchTextStyles.sectionTitle(context, color: t.ink),
            child: trailing!,
          ),
        ],
      ],
    );
  }

  Widget _body(BuildContext context, CatchTokens t) {
    final directChild = child;
    if (directChild != null) return directChild;

    final sectionChildren = children ?? const <Widget>[];
    if (sectionChildren.isEmpty) return const SizedBox.shrink();
    final effectiveDividerIndent = _fieldRows && dividerIndent.isNaN
        ? _automaticFieldDividerInset(sectionChildren)
        : dividerIndent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_fieldRows)
          for (var i = 0; i < sectionChildren.length; i++)
            if (!showInternalDividers || i == sectionChildren.length - 1)
              sectionChildren[i]
            else
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: -CatchStroke.hairline,
                    left: effectiveDividerIndent,
                    right: _variant == _CatchSectionVariant.contained
                        ? CatchFieldTokens.rowHorizontalPadding
                        : 0,
                    child: CatchDivider(role: internalDividerRole),
                  ),
                  sectionChildren[i],
                ],
              )
        else
          for (var i = 0; i < sectionChildren.length; i++)
            if (i == 0 || !showInternalDividers)
              sectionChildren[i]
            else
              Stack(
                children: [
                  sectionChildren[i],
                  Positioned(
                    top: 0,
                    left: effectiveDividerIndent,
                    right: 0,
                    child: CatchDivider(role: internalDividerRole),
                  ),
                ],
              ),
      ],
    );
  }

  double _automaticFieldDividerInset(List<Widget> sectionChildren) {
    final directFields = sectionChildren.whereType<CatchField>().toList();
    // Direct CatchField children can be inspected exactly like the React
    // handoff. Existing adapter rows cannot expose their leading metadata, so
    // preserve the pre-migration text-lane default unless their caller opts
    // into an explicit zero inset.
    final canInferEveryRow = directFields.length == sectionChildren.length;
    final hasLeadingIcon = directFields.any(
      (field) => !field.add && (field.icon != null || field.prefixIcon != null),
    );
    final rowEdgeInset = _variant == _CatchSectionVariant.contained
        ? CatchFieldTokens.rowHorizontalPadding
        : 0.0;
    return rowEdgeInset +
        (hasLeadingIcon || !canInferEveryRow
            ? CatchFieldTokens.textLaneInset
            : 0.0);
  }
}

class CatchSectionFocusSurface extends StatefulWidget {
  const CatchSectionFocusSurface({
    super.key,
    required this.child,
    required this.padding,
    this.backgroundColor,
    this.borderColor,
    this.tone = CatchSurfaceTone.surface,
    this.elevation = CatchSurfaceElevation.card,
    this.boxShadow,
    required this.focused,
    required this.hasError,
    this.fieldRows = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final CatchSurfaceTone tone;
  final CatchSurfaceElevation elevation;
  final List<BoxShadow>? boxShadow;
  final bool focused;
  final bool hasError;
  final bool fieldRows;

  @override
  State<CatchSectionFocusSurface> createState() =>
      _CatchSectionFocusSurfaceState();
}

class _CatchSectionFocusSurfaceState extends State<CatchSectionFocusSurface> {
  bool _descendantFocused = false;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    if (widget.fieldRows) {
      final duration = MediaQuery.maybeOf(context)?.disableAnimations == true
          ? Duration.zero
          : CatchFieldTokens.standard;
      return AnimatedContainer(
        duration: duration,
        curve: CatchFieldTokens.curve,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? t.surface,
          borderRadius: BorderRadius.circular(CatchFieldTokens.sectionRadius),
        ),
        // Paint the perimeter after the row tiles. Active first/last rows
        // intentionally bleed over their internal hairlines, but must never
        // obscure the section's neutral outer border.
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CatchFieldTokens.sectionRadius),
          border: Border.all(
            color: widget.hasError
                ? t.danger
                : widget.focused
                ? t.ink
                : widget.borderColor ?? t.line2,
          ),
        ),
        child: Padding(
          // A decoration border contributes its dimensions to Container's
          // child layout; a foreground border does not. Preserve that exact
          // one-hairline content inset while moving only paint order forward.
          padding: const EdgeInsets.all(CatchStroke.hairline),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      );
    }

    final effectiveFocused = widget.focused || _descendantFocused;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: _handleFocusChange,
      child: CatchSurface(
        role: CatchSurfaceRole.card,
        padding: widget.padding,
        radius: CatchRadius.md,
        tone: widget.tone,
        elevation: widget.elevation,
        backgroundColor: widget.backgroundColor,
        borderColor: widget.hasError
            ? t.danger
            : effectiveFocused
            ? t.primary
            : widget.borderColor,
        boxShadow: effectiveFocused && !widget.hasError
            ? CatchElevation.focusRing(t)
            : widget.boxShadow,
        child: widget.child,
      ),
    );
  }

  void _handleFocusChange(bool focused) {
    if (_descendantFocused == focused) return;
    setState(() => _descendantFocused = focused);
  }
}

Widget _buildCatchSectionKicker(
  BuildContext context, {
  required String? text,
  required Color color,
  Object? count,
  Widget? trailing,
  CatchKickerSize size = CatchKickerSize.md,
}) {
  final t = CatchTokens.of(context);
  final displayText = text?.trim();
  final hasText = displayText != null && displayText.isNotEmpty;
  final displayCount = count?.toString().trim();
  final hasCount = displayCount != null && displayCount.isNotEmpty;
  if (hasText && !hasCount && trailing == null) {
    return CatchKicker(label: displayText, color: color, size: size);
  }
  return Row(
    crossAxisAlignment: CrossAxisAlignment.baseline,
    textBaseline: TextBaseline.alphabetic,
    children: [
      if (hasText)
        Expanded(
          child: CatchKicker(label: displayText, color: color, size: size),
        )
      else
        const Spacer(),
      if (hasCount) ...[
        if (hasText) const SizedBox(width: CatchFieldTokens.sectionHeaderGap),
        Text(
          displayCount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.end,
          style: CatchTextStyles.sectionCount(context, color: t.ink3),
        ),
      ],
      if (trailing != null) ...[
        if (hasText || hasCount)
          const SizedBox(width: CatchFieldTokens.sectionHeaderGap),
        DefaultTextStyle.merge(
          style: CatchTextStyles.sectionCount(context, color: t.ink3),
          child: trailing,
        ),
      ],
    ],
  );
}

/// Sliver-native detail body wrapper with Catch's detail-screen page insets.
///
/// Defaults to no inserted gap so [CatchSection] owns its delimiter and
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
