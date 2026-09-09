import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_divided_field_interaction.dart';
import 'package:catch_ui/src/components/catch_divided_field_interaction_scope.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope.dart';
import 'package:catch_ui/src/components/catch_field_gutter_ownership.dart';
import 'package:catch_ui/src/components/catch_field_interaction_shape.dart';
import 'package:catch_ui/src/components/catch_horizontal_scroll_view.dart';
import 'package:catch_ui/src/components/catch_section_body.dart';
import 'package:catch_ui/src/components/catch_section_body_mode.dart';
import 'package:catch_ui/src/components/catch_section_field_group.dart';
import 'package:catch_ui/src/components/catch_section_header.dart';
import 'package:catch_ui/src/components/catch_section_header_placement.dart';
import 'package:catch_ui/src/components/catch_section_surface.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_divider.dart';
import 'package:catch_ui/src/primitives/catch_kicker_text.dart';
import 'package:catch_ui/src/primitives/catch_surface.dart';
import 'package:flutter/material.dart';

part 'catch_section_configs.dart';

enum _CatchSectionVariant { divided, contained, plain }

/// Design-system `Section`: the canonical primitive for grouping information.
///
/// Screens that adopt the handoff composition should place these inside
/// `CatchSectionList` or `CatchSectionList` with no ad-hoc gaps.
class CatchSection extends StatelessWidget {
  const CatchSection.divided({
    super.key,
    String? title,
    Object? count,
    this.trailing,
    Color? leadAccent,
    bool lead = false,
    bool first = false,
    Color? dividerColor,
    double dividerIndent = 0,
    CatchDividerVariant dividerVariant = CatchDividerVariant.section,
    CatchDividerVariant internalDividerVariant = CatchDividerVariant.fieldRow,
    Color? titleColor,
    double bodyGap = CatchSpacing.s3,
    bool showInternalDividers = true,
    this.children,
    this.child,
  }) : footer = null,
       assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = (
         common: (
           title: title,
           subtitle: null,
           count: count,
           titleColor: titleColor,
           bodyGap: bodyGap,
         ),
         leadAccent: leadAccent,
         lead: lead,
         first: first,
         dividerColor: dividerColor,
         dividerIndent: dividerIndent,
         dividerVariant: dividerVariant,
         internalDividerVariant: internalDividerVariant,
         showInternalDividers: showInternalDividers,
       ),
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = null,
       _containedConfig = null,
       _plainConfig = null,
       _horizontalConfig = null;

  const CatchSection.fieldRows({
    super.key,
    String? title,
    Object? count,
    this.trailing,
    Color? leadAccent,
    bool lead = false,
    bool first = false,
    this.footer,
    CatchDividedFieldInteraction? interaction,
    this.children,
    this.child,
  }) : assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = null,
       _fieldRowsConfig = (
         common: (
           title: title,
           subtitle: null,
           count: count,
           titleColor: null,
           bodyGap: CatchFieldTokens.sectionRuleGap,
         ),
         leadAccent: leadAccent,
         lead: lead,
         first: first,
         interaction: interaction,
       ),
       _containedFieldRowsConfig = null,
       _containedConfig = null,
       _plainConfig = null,
       _horizontalConfig = null;

  /// Contained FieldSection variant from the form-field handoff. Unlike the
  /// generic card constructor, this surface clips field rows, owns a 1px
  /// line/ink focus border, and never adds generic card shadows. Its optional
  /// title, count, and trailing action form an outside group header by
  /// default, so the outline begins with the first row. Set [headerPlacement]
  /// to [CatchSectionHeaderPlacement.inside] when the label belongs to
  /// the bounded field group itself; that mode places the header inside the
  /// outline and gives it the same padded section rule as [fieldRows].
  const CatchSection.containedFieldRows({
    super.key,
    String? title,
    Object? count,
    this.trailing,
    this.footer,
    bool focused = false,
    bool hasError = false,
    CatchSectionHeaderPlacement headerPlacement =
        CatchSectionHeaderPlacement.outside,
    this.children,
    this.child,
  }) : assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = null,
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = (
         common: (
           title: title,
           subtitle: null,
           count: count,
           titleColor: null,
           bodyGap: CatchSpacing.s2,
         ),
         groups: null,

         focused: focused,
         hasError: hasError,
         headerPlacement: headerPlacement,
       ),
       _containedConfig = null,
       _plainConfig = null,
       _horizontalConfig = null;

  /// One outlined collection containing one or more labelled field groups.
  ///
  /// This is the grouped sibling of [containedFieldRows]. It preserves one
  /// section-owned perimeter while giving each internal group its own kicker
  /// and inset boundary. It is intended for one collection of mutually related
  /// actions or choices, not for nesting independent cards inside a card.
  const CatchSection.containedFieldGroups({
    super.key,
    required List<CatchSectionFieldGroup> groups,
    this.footer,
    bool focused = false,
    bool hasError = false,
  }) : trailing = null,
       children = null,
       child = null,
       _dividedConfig = null,
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = (
         common: (
           title: null,
           subtitle: null,
           count: null,
           titleColor: null,
           bodyGap: CatchSpacing.s2,
         ),
         groups: groups,

         focused: focused,
         hasError: hasError,
         headerPlacement: CatchSectionHeaderPlacement.inside,
       ),
       _containedConfig = null,
       _plainConfig = null,
       _horizontalConfig = null;

  const CatchSection.contained({
    super.key,
    String? title,
    String? subtitle,
    this.trailing,
    Object? count,
    Color? titleColor,
    double bodyGap = CatchSpacing.s3,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? borderColor,
    CatchSurfaceTone tone = CatchSurfaceTone.surface,
    CatchSurfaceEmphasis emphasis = CatchSurfaceEmphasis.subtle,
    List<BoxShadow>? boxShadow,
    bool showInternalDividers = true,
    bool focused = false,
    bool hasError = false,
    this.children,
    this.child,
  }) : footer = null,
       assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = null,
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = null,
       _containedConfig = (
         common: (
           title: title,
           subtitle: subtitle,
           count: count,
           titleColor: titleColor,
           bodyGap: bodyGap,
         ),
         padding: padding,
         backgroundColor: backgroundColor,
         borderColor: borderColor,
         tone: tone,
         emphasis: emphasis,
         boxShadow: boxShadow,
         showInternalDividers: showInternalDividers,
         focused: focused,
         hasError: hasError,
       ),
       _plainConfig = null,
       _horizontalConfig = null;

  const CatchSection.plain({
    super.key,
    String? title,
    String? subtitle,
    this.trailing,
    Object? count,
    Color? titleColor,
    double bodyGap = CatchSpacing.s3,
    EdgeInsetsGeometry? padding,
    bool showInternalDividers = true,
    this.children,
    this.child,
  }) : footer = null,
       assert(child != null || children != null),
       assert(child == null || children == null),
       _dividedConfig = null,
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = null,
       _containedConfig = null,
       _plainConfig = (
         common: (
           title: title,
           subtitle: subtitle,
           count: count,
           titleColor: titleColor,
           bodyGap: bodyGap,
         ),
         padding: padding,
         showInternalDividers: showInternalDividers,
       ),
       _horizontalConfig = null;

  /// A titled horizontal collection, embedded or with page-owned gutters.
  /// [footer] is the final scrollable item, such as a "More" action.
  const CatchSection.horizontal({
    super.key,
    required String title,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
    this.footer,
    bool fullBleed = false,
    bool? showDivider,
    double? height = CatchLayout.horizontalRailHeight,
    double spacing = CatchSpacing.s3,
    CatchRailItemWidth? itemWidth,
    EdgeInsets? headerPadding,
    EdgeInsetsGeometry? listPadding,
  }) : trailing = null,
       children = null,
       child = null,
       _dividedConfig = null,
       _fieldRowsConfig = null,
       _containedFieldRowsConfig = null,
       _containedConfig = null,
       _plainConfig = null,
       _horizontalConfig = (
         common: (
           title: title,
           subtitle: null,
           count: null,
           titleColor: null,
           bodyGap: 0,
         ),
         itemCount: itemCount,
         itemBuilder: itemBuilder,
         height: height,
         spacing: spacing,
         itemWidth: itemWidth,
         showDivider: showDivider ?? fullBleed,
         headerPadding:
             headerPadding ??
             (fullBleed ? CatchInsets.sectionHeader : EdgeInsets.zero),
         listPadding:
             listPadding ??
             (fullBleed ? CatchInsets.pageHorizontal : EdgeInsets.zero),
       );

  final _DividedSectionConfig? _dividedConfig;
  final _DividedFieldRowsSectionConfig? _fieldRowsConfig;
  final _ContainedFieldRowsSectionConfig? _containedFieldRowsConfig;
  final _ContainedSectionConfig? _containedConfig;
  final _PlainSectionConfig? _plainConfig;
  final _HorizontalSectionConfig? _horizontalConfig;

  _SectionCommonConfig get _common =>
      _horizontalConfig?.common ??
      _dividedConfig?.common ??
      _fieldRowsConfig?.common ??
      _containedFieldRowsConfig?.common ??
      _containedConfig?.common ??
      _plainConfig!.common;

  String? get title => _common.title;
  String? get subtitle => _common.subtitle;
  final Widget? trailing;
  Object? get count => _common.count;
  Color? get titleColor => _common.titleColor;
  double get bodyGap => _common.bodyGap;
  final List<Widget>? children;
  final Widget? child;

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
  CatchDividerVariant get dividerVariant =>
      _dividedConfig?.dividerVariant ?? CatchDividerVariant.section;
  CatchDividerVariant get internalDividerVariant =>
      _dividedConfig?.internalDividerVariant ??
      (_fieldRowsConfig != null || _containedFieldRowsConfig != null
          ? CatchDividerVariant.fieldSection
          : CatchDividerVariant.fieldRow);
  EdgeInsetsGeometry? get padding => _containedFieldRowsConfig != null
      ? EdgeInsets.zero
      : _containedConfig?.padding ?? _plainConfig?.padding;
  Color? get backgroundColor => _containedConfig?.backgroundColor;
  Color? get borderColor => _containedConfig?.borderColor;
  CatchSurfaceTone get tone =>
      _containedConfig?.tone ?? CatchSurfaceTone.surface;
  CatchSurfaceEmphasis get emphasis => _containedFieldRowsConfig != null
      ? CatchSurfaceEmphasis.flat
      : _containedConfig?.emphasis ?? CatchSurfaceEmphasis.subtle;
  List<BoxShadow>? get boxShadow => _containedConfig?.boxShadow;
  bool get showInternalDividers =>
      _dividedConfig?.showInternalDividers ??
      _containedConfig?.showInternalDividers ??
      _plainConfig?.showInternalDividers ??
      true;
  final Widget? footer;
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
    if (_horizontalConfig case final rail?) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSectionHeader(
            title: title!,
            heavy: true,
            padding: rail.headerPadding,
          ),
          CatchHorizontalScrollView(
            itemCount: rail.itemCount,
            itemBuilder: rail.itemBuilder,
            footer: footer,
            height: rail.height,
            spacing: rail.spacing,
            listPadding: rail.listPadding,
            itemWidth: rail.itemWidth,
          ),
          if (rail.showDivider)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: CatchSpacing.screenPx),
              child: CatchDivider.section(),
            ),
        ],
      );
    }
    final groups = fieldGroups;
    assert(
      groups == null ||
          (groups.isNotEmpty &&
              groups.every((group) => group.children.isNotEmpty)),
      'containedFieldGroups requires at least one non-empty field group.',
    );
    final t = CatchTokens.of(context);
    final variant = _variant;
    final fieldRows = _fieldRows;
    final sectionTrailing = trailing;
    final sectionFooter = footer;
    final displayTitle = title?.trim();
    final displayCount = count?.toString().trim();
    final hasTitle = displayTitle != null && displayTitle.isNotEmpty;
    final hasCount = displayCount != null && displayCount.isNotEmpty;
    final hasHeader = hasTitle || hasCount || sectionTrailing != null;
    final bodyMode = !fieldRows
        ? CatchSectionBodyMode.content
        : variant == _CatchSectionVariant.contained
        ? CatchSectionBodyMode.containedFields
        : CatchSectionBodyMode.dividedFields;
    final body = CatchSectionBody(
      mode: bodyMode,
      dividerIndent: dividerIndent,
      dividerVariant: internalDividerVariant,
      showInternalDividers: showInternalDividers,
      children: children ?? const [],
      child: child,
    );
    Widget section;
    if (variant == _CatchSectionVariant.divided) {
      final accent = leadAccent;
      final effectiveTitleColor =
          titleColor ??
          (lead && accent != null
              ? accent
              : fieldRows
              ? t.ink2
              : t.ink);
      final content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasHeader) ...[
            CatchSectionHeader.kicker(
              title: hasTitle ? displayTitle : null,
              count: hasCount ? displayCount : null,
              trailing: sectionTrailing,
              color: effectiveTitleColor,
              textVariant: fieldRows
                  ? CatchKickerTextVariant.fieldSection
                  : CatchKickerTextVariant.md,
            ),
            SizedBox(height: bodyGap),
          ],
          // Field sections own the header-to-row boundary even without a title.
          if (fieldRows)
            CatchDivider(
              color: dividerColor ?? CatchDivider.colorFor(t, dividerVariant),
              variant: dividerVariant,
            ),
          CatchFieldGeometryScope(
            gutterOwnership: CatchFieldGutterOwnership.container,
            interactionShape: fieldRows
                ? (dividedFieldInteraction ??
                              CatchDividedFieldInteractionScope.interactionOf(
                                context,
                              )) ==
                          CatchDividedFieldInteraction.fullBleed
                      ? CatchFieldInteractionShape.fullBleedBand
                      : CatchFieldInteractionShape.roundedTile
                : CatchFieldInteractionShape.roundedTile,
            child: body,
          ),
        ],
      );
      section = first
          ? content
          : Padding(
              padding: const EdgeInsets.only(top: CatchSpacing.s6),
              child: fieldRows
                  ? content
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color:
                                dividerColor ??
                                CatchDivider.colorFor(t, dividerVariant),
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: CatchSpacing.s6),
                        child: content,
                      ),
                    ),
            );
    } else {
      final contained = variant == _CatchSectionVariant.contained;
      final hasInternalFieldHeader =
          fieldRows &&
          hasHeader &&
          fieldHeaderPlacement == CatchSectionHeaderPlacement.inside;
      Widget content;
      if (fieldRows) {
        content = Column(
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
                    CatchSectionHeader.kicker(
                      title: hasTitle ? displayTitle : null,
                      count: hasCount ? displayCount : null,
                      trailing: sectionTrailing,
                      color: titleColor ?? t.ink2,
                      textVariant: CatchKickerTextVariant.fieldSection,
                    ),
                    const SizedBox(height: CatchFieldTokens.sectionRuleGap),
                    const CatchDivider.section(),
                  ],
                ),
              ),
            if (groups != null)
              Column(
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
                          CatchSectionHeader.kicker(
                            title: group.title.trim(),
                            count: group.count?.toString().trim(),
                            trailing: group.trailing,
                            color: t.ink2,
                            textVariant: CatchKickerTextVariant.fieldSection,
                          ),
                          const SizedBox(
                            height: CatchFieldTokens.sectionRuleGap,
                          ),
                          const CatchDivider.section(),
                        ],
                      ),
                    ),
                    CatchSectionBody(
                      mode: bodyMode,
                      dividerIndent: dividerIndent,
                      dividerVariant: internalDividerVariant,
                      showInternalDividers: showInternalDividers,
                      children: group.children,
                    ),
                  ],
                ],
              )
            else
              body,
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
        );
      } else {
        final displaySubtitle = subtitle?.trim();
        final hasSubtitle =
            displaySubtitle != null && displaySubtitle.isNotEmpty;
        final header = !hasTitle && !hasSubtitle && sectionTrailing == null
            ? null
            : Row(
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
                                : CatchSectionHeader.kicker(
                                    title: displayTitle,
                                    count: count,
                                    color: titleColor ?? t.ink,
                                  ),
                          if (hasSubtitle) ...[
                            const SizedBox(height: CatchSpacing.s1),
                            Text(
                              displaySubtitle,
                              style: CatchTextStyles.supporting(
                                context,
                                color: t.ink2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    const Spacer(),
                  if (sectionTrailing != null) ...[
                    const SizedBox(width: CatchSpacing.s3),
                    DefaultTextStyle.merge(
                      style: CatchTextStyles.sectionTitle(
                        context,
                        color: t.ink,
                      ),
                      child: sectionTrailing,
                    ),
                  ],
                ],
              );
        content = header == null
            ? body
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  SizedBox(height: bodyGap),
                  body,
                ],
              );
      }
      if (!contained) {
        section = Padding(padding: padding ?? EdgeInsets.zero, child: content);
      } else {
        final surface = CatchFieldGeometryScope(
          gutterOwnership: fieldRows
              ? CatchFieldGutterOwnership.field
              : CatchFieldGutterOwnership.container,
          child: fieldRows
              ? CatchSectionSurface.fieldRows(
                  padding: padding ?? const EdgeInsets.all(CatchSpacing.s4),
                  backgroundColor: backgroundColor,
                  borderColor: borderColor,
                  states: {
                    if (focused) WidgetState.focused,
                    if (hasError) WidgetState.error,
                  },
                  child: content,
                )
              : CatchSectionSurface(
                  padding: padding ?? const EdgeInsets.all(CatchSpacing.s4),
                  backgroundColor: backgroundColor,
                  borderColor: borderColor,
                  tone: tone,
                  emphasis: emphasis,
                  boxShadow: boxShadow,
                  states: {
                    if (focused) WidgetState.focused,
                    if (hasError) WidgetState.error,
                  },
                  child: content,
                ),
        );
        section = !fieldRows || !hasHeader || hasInternalFieldHeader
            ? surface
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: CatchFieldTokens.rowHorizontalPadding,
                    ),
                    child: CatchSectionHeader.kicker(
                      title: hasTitle ? displayTitle : null,
                      count: hasCount ? displayCount : null,
                      trailing: sectionTrailing,
                      color: titleColor ?? t.ink2,
                      textVariant: CatchKickerTextVariant.fieldSection,
                    ),
                  ),
                  SizedBox(height: bodyGap),
                  surface,
                ],
              );
      }
    }
    if (sectionFooter == null ||
        (variant == _CatchSectionVariant.contained && fieldRows)) {
      return section;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section,
        if (fieldRows)
          Padding(
            padding: const EdgeInsets.only(
              top: CatchFieldTokens.dividedSectionFooterTopPadding,
            ),
            child: DefaultTextStyle.merge(
              style: CatchTextStyles.fieldLabel(
                context,
                color: t.ink3,
              ).copyWith(height: 1.5),
              child: sectionFooter,
            ),
          )
        else
          sectionFooter,
      ],
    );
  }
}
