import 'dart:math' as math;

import 'package:catch_dating_app/core/widgets/catch_field.dart' show CatchField;
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

part 'catch_section_configs.dart';

enum _CatchSectionVariant { divided, contained, plain }

/// Design-system `Section`: the canonical primitive for grouping information.
///
/// Screens that adopt the handoff composition should place these inside
/// [CatchSectionStack] or [CatchDetailSliverSectionList] with no ad-hoc gaps.
class CatchSection extends StatelessWidget {
  const CatchSection.divided({
    super.key,
    String? title,
    Object? count,
    Widget? trailing,
    Color? leadAccent,
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
  }) : assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = (
         common: (
           title: title,
           subtitle: null,
           trailing: trailing,
           count: count,
           titleColor: titleColor,
           bodyGap: bodyGap,
           children: children,
           child: child,
         ),
         leadAccent: leadAccent,
         lead: lead,
         first: first,
         dividerColor: dividerColor,
         dividerIndent: dividerIndent,
         dividerRole: dividerRole,
         internalDividerRole: internalDividerRole,
         showInternalDividers: showInternalDividers,
       ),
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = null,
       _containedConfig = null,
       _plainConfig = null;

  const CatchSection.fieldRows({
    super.key,
    String? title,
    Object? count,
    Widget? trailing,
    Color? leadAccent,
    bool lead = false,
    bool first = false,
    Widget? footer,
    CatchDividedFieldInteraction? interaction,
    List<Widget>? children,
    Widget? child,
  }) : assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = null,
       _fieldRowsConfig = (
         common: (
           title: title,
           subtitle: null,
           trailing: trailing,
           count: count,
           titleColor: null,
           bodyGap: CatchFieldTokens.sectionRuleGap,
           children: children,
           child: child,
         ),
         leadAccent: leadAccent,
         lead: lead,
         first: first,
         footer: footer,
         interaction: interaction,
       ),
       _containedFieldRowsConfig = null,
       _containedConfig = null,
       _plainConfig = null;

  /// Contained FieldSection variant from the form-field handoff. Unlike the
  /// generic card constructor, this surface clips field rows, owns a 1px
  /// line/ink focus border, and never adds generic card elevation. Its optional
  /// title, count, and trailing action form an outside group header by
  /// default, so the outline begins with the first row. Set [headerPlacement]
  /// to [CatchSectionHeaderPlacement.inside] when the label belongs to
  /// the bounded field group itself; that mode places the header inside the
  /// outline and gives it the same padded section rule as [fieldRows].
  const CatchSection.containedFieldRows({
    super.key,
    String? title,
    Object? count,
    Widget? trailing,
    Widget? footer,
    bool focused = false,
    bool hasError = false,
    CatchSectionHeaderPlacement headerPlacement =
        CatchSectionHeaderPlacement.outside,
    List<Widget>? children,
    Widget? child,
  }) : assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = null,
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = (
         common: (
           title: title,
           subtitle: null,
           trailing: trailing,
           count: count,
           titleColor: null,
           bodyGap: CatchSpacing.s2,
           children: children,
           child: child,
         ),
         groups: null,
         footer: footer,
         focused: focused,
         hasError: hasError,
         headerPlacement: headerPlacement,
       ),
       _containedConfig = null,
       _plainConfig = null;

  /// One outlined collection containing one or more labelled field groups.
  ///
  /// This is the grouped sibling of [containedFieldRows]. It preserves one
  /// section-owned perimeter while giving each internal group its own kicker
  /// and inset boundary. It is intended for one collection of mutually related
  /// actions or choices, not for nesting independent cards inside a card.
  const CatchSection.containedFieldGroups({
    super.key,
    required List<CatchSectionFieldGroup> groups,
    Widget? footer,
    bool focused = false,
    bool hasError = false,
  }) : _dividedConfig = null,
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = (
         common: (
           title: null,
           subtitle: null,
           trailing: null,
           count: null,
           titleColor: null,
           bodyGap: CatchSpacing.s2,
           children: null,
           child: null,
         ),
         groups: groups,
         footer: footer,
         focused: focused,
         hasError: hasError,
         headerPlacement: CatchSectionHeaderPlacement.inside,
       ),
       _containedConfig = null,
       _plainConfig = null;

  const CatchSection.contained({
    super.key,
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
  }) : assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = null,
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = null,
       _containedConfig = (
         common: (
           title: title,
           subtitle: subtitle,
           trailing: trailing,
           count: count,
           titleColor: titleColor,
           bodyGap: bodyGap,
           children: children,
           child: child,
         ),
         padding: padding,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         tone: tone,
         elevation: elevation,
         boxShadow: boxShadow,
         showInternalDividers: showInternalDividers,
         focused: focused,
         hasError: hasError,
       ),
       _plainConfig = null;

  const CatchSection.plain({
    super.key,
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
  }) : assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = null,
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = null,
       _containedConfig = null,
       _plainConfig = (
         common: (
           title: title,
           subtitle: subtitle,
           trailing: trailing,
           count: count,
           titleColor: titleColor,
           bodyGap: bodyGap,
           children: children,
           child: child,
         ),
         padding: padding,
         showInternalDividers: showInternalDividers,
       );

  final _DividedSectionConfig? _dividedConfig;
  final _DividedFieldRowsSectionConfig? _fieldRowsConfig;
  final _ContainedFieldRowsSectionConfig? _containedFieldRowsConfig;
  final _ContainedSectionConfig? _containedConfig;
  final _PlainSectionConfig? _plainConfig;

  _SectionCommonConfig get _common =>
      _dividedConfig?.common ??
      _fieldRowsConfig?.common ??
      _containedFieldRowsConfig?.common ??
      _containedConfig?.common ??
      _plainConfig!.common;

  String? get title => _common.title;
  String? get subtitle => _common.subtitle;
  Widget? get trailing => _common.trailing;
  Object? get count => _common.count;
  Color? get titleColor => _common.titleColor;
  double get bodyGap => _common.bodyGap;
  List<Widget>? get children => _common.children;
  Widget? get child => _common.child;

  /// Caller-resolved accent used only for a lead divided section.
  /// An explicit [titleColor] takes precedence.
  Color? get leadAccent =>
      _dividedConfig?.leadAccent ?? _fieldRowsConfig?.leadAccent;
  bool get lead => _dividedConfig?.lead ?? _fieldRowsConfig?.lead ?? false;
  bool get first => _dividedConfig?.first ?? _fieldRowsConfig?.first ?? false;
  _CatchSectionVariant get _variant =>
      _containedConfig != null || _containedFieldRowsConfig != null
      ? _CatchSectionVariant.contained
      : _plainConfig != null
      ? _CatchSectionVariant.plain
      : _CatchSectionVariant.divided;
  Color? get dividerColor => _dividedConfig?.dividerColor;
  double? get dividerIndent =>
      _dividedConfig?.dividerIndent ??
      (_fieldRowsConfig != null || _containedFieldRowsConfig != null
          ? null
          : 0);
  CatchDividerRole get dividerRole =>
      _dividedConfig?.dividerRole ?? CatchDividerRole.section;
  CatchDividerRole get internalDividerRole =>
      _dividedConfig?.internalDividerRole ??
      (_fieldRowsConfig != null || _containedFieldRowsConfig != null
          ? CatchDividerRole.fieldSection
          : CatchDividerRole.fieldRow);
  EdgeInsetsGeometry? get padding => _containedFieldRowsConfig != null
      ? EdgeInsets.zero
      : _containedConfig?.padding ?? _plainConfig?.padding;
  Color? get backgroundColor => _containedConfig?.backgroundColor;
  Color? get borderColor => _containedConfig?.borderColor;
  CatchSurfaceTone get tone =>
      _containedConfig?.tone ?? CatchSurfaceTone.surface;
  CatchSurfaceElevation get elevation => _containedFieldRowsConfig != null
      ? CatchSurfaceElevation.none
      : _containedConfig?.elevation ?? CatchSurfaceElevation.card;
  List<BoxShadow>? get boxShadow => _containedConfig?.boxShadow;
  bool get showInternalDividers =>
      _dividedConfig?.showInternalDividers ??
      _containedConfig?.showInternalDividers ??
      _plainConfig?.showInternalDividers ??
      true;
  Widget? get footer =>
      _fieldRowsConfig?.footer ?? _containedFieldRowsConfig?.footer;
  bool get focused =>
      _containedFieldRowsConfig?.focused ?? _containedConfig?.focused ?? false;
  bool get hasError =>
      _containedFieldRowsConfig?.hasError ??
      _containedConfig?.hasError ??
      false;
  bool get _fieldRows =>
      _fieldRowsConfig != null || _containedFieldRowsConfig != null;
  CatchSectionHeaderPlacement get fieldHeaderPlacement =>
      _containedFieldRowsConfig?.headerPlacement ??
      CatchSectionHeaderPlacement.outside;
  List<CatchSectionFieldGroup>? get fieldGroups =>
      _containedFieldRowsConfig?.groups;
  CatchDividedFieldInteraction? get dividedFieldInteraction =>
      _fieldRowsConfig?.interaction;

  @override
  Widget build(BuildContext context) {
    assert(
      fieldGroups == null ||
          (fieldGroups!.isNotEmpty &&
              fieldGroups!.every((group) => group.children.isNotEmpty)),
      'containedFieldGroups requires at least one non-empty field group.',
    );
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
    final accent = leadAccent;
    final effectiveTitleColor =
        titleColor ??
        (lead && accent != null
            ? accent
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
          CatchFieldGeometryScope(
            gutterOwnership: CatchFieldGutterOwnership.container,
            interactionShape:
                (dividedFieldInteraction ??
                        CatchDividedFieldInteractionScope.interactionOf(
                          context,
                        )) ==
                    CatchDividedFieldInteraction.fullBleed
                ? CatchFieldInteractionShape.fullBleedBand
                : CatchFieldInteractionShape.roundedTile,
            child: _body(context, t),
          ),
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
        CatchFieldGeometryScope(
          gutterOwnership: CatchFieldGutterOwnership.container,
          child: _body(context, t),
        ),
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
    final hasInternalFieldHeader =
        _fieldRows &&
        hasHeader &&
        fieldHeaderPlacement == CatchSectionHeaderPlacement.inside;
    final containedGroups = fieldGroups;
    final content = _fieldRows
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasInternalFieldHeader)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CatchFieldTokens.rowHorizontalPadding,
                    CatchFieldTokens.rowVerticalPadding,
                    CatchFieldTokens.rowHorizontalPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCatchSectionKicker(
                        context,
                        text: hasTitle ? displayTitle : null,
                        count: hasCount ? displayCount : null,
                        trailing: sectionTrailing,
                        color: titleColor ?? t.ink2,
                        size: CatchKickerSize.fieldSection,
                      ),
                      const SizedBox(height: CatchFieldTokens.sectionRuleGap),
                      const CatchDivider.section(),
                    ],
                  ),
                ),
              if (containedGroups != null)
                _buildContainedFieldGroups(context, t, containedGroups)
              else
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
    final surface = CatchFieldGeometryScope(
      // Generic contained sections own their content gutter. Field-row
      // sections leave row gutters to CatchField, while the focus surface
      // below owns the active edge geometry for every composition path.
      gutterOwnership: _fieldRows
          ? CatchFieldGutterOwnership.field
          : CatchFieldGutterOwnership.container,
      child: CatchSectionFocusSurface(
        padding: padding ?? const EdgeInsets.all(CatchSpacing.s4),
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        tone: tone,
        elevation: elevation,
        boxShadow: boxShadow,
        focused: focused,
        hasError: hasError,
        fieldRows: _fieldRows,
        child: content,
      ),
    );
    if (!_fieldRows || !hasHeader || hasInternalFieldHeader) return surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CatchFieldTokens.rowHorizontalPadding,
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
        SizedBox(height: bodyGap),
        surface,
      ],
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
      crossAxisAlignment: hasSubtitle
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
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
                              : '$displayTitle · $count',
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

    if (_fieldRows) {
      return _buildFieldRows(sectionChildren);
    }
    final effectiveDividerIndent = dividerIndent ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
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

  Widget _buildContainedFieldGroups(
    BuildContext context,
    CatchTokens t,
    List<CatchSectionFieldGroup> groups,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchFieldTokens.rowHorizontalPadding,
              CatchFieldTokens.rowVerticalPadding,
              CatchFieldTokens.rowHorizontalPadding,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCatchSectionKicker(
                  context,
                  text: group.title.trim(),
                  count: group.count?.toString().trim(),
                  trailing: group.trailing,
                  color: t.ink2,
                  size: CatchKickerSize.fieldSection,
                ),
                const SizedBox(height: CatchFieldTokens.sectionRuleGap),
                const CatchDivider.section(),
              ],
            ),
          ),
          _buildFieldRows(group.children),
        ],
      ],
    );
  }

  Widget _buildFieldRows(List<Widget> sectionChildren) {
    final effectiveDividerIndent = dividerIndent == null
        ? _automaticFieldDividerInset(sectionChildren)
        : dividerIndent ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
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
    final leadingTextLaneInset = directFields.fold<double>(0, (inset, field) {
      if (field.add) return inset;
      final fieldInset = field.leading != null
          ? (field.leadingExtent ?? CatchFieldTokens.leadingIconExtent) +
                CatchFieldTokens.leadingGap
          : field.icon != null || field.prefixIcon != null
          ? CatchFieldTokens.textLaneInset
          : 0.0;
      return math.max(inset, fieldInset);
    });
    final rowEdgeInset = _variant == _CatchSectionVariant.contained
        ? CatchFieldTokens.rowHorizontalPadding
        : 0.0;
    return rowEdgeInset +
        (!canInferEveryRow
            ? CatchFieldTokens.textLaneInset
            : leadingTextLaneInset);
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
    return Semantics(
      header: true,
      child: CatchKicker(label: displayText, color: color, size: size),
    );
  }
  final header = Row(
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
  final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
  final responsiveHeader = largeText && trailing != null
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (hasText)
                  Expanded(
                    child: CatchKicker(
                      label: displayText,
                      color: color,
                      size: size,
                    ),
                  )
                else
                  const Spacer(),
                if (hasCount) ...[
                  if (hasText)
                    const SizedBox(width: CatchFieldTokens.sectionHeaderGap),
                  Flexible(
                    child: Text(
                      displayCount,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: CatchTextStyles.sectionCount(
                        context,
                        color: t.ink3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: CatchSpacing.s2),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: DefaultTextStyle.merge(
                style: CatchTextStyles.sectionCount(context, color: t.ink3),
                child: trailing,
              ),
            ),
          ],
        )
      : header;
  return hasText
      ? Semantics(header: true, child: responsiveHeader)
      : responsiveHeader;
}
