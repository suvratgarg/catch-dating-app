import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:catch_ui/src/components/catch_screen_header.dart';
import 'package:catch_ui/src/components/catch_search_field.dart';
import 'package:catch_ui/src/components/catch_top_bar_action_row.dart';
import 'package:catch_ui/src/components/catch_top_bar_emphasis.dart';
import 'package:catch_ui/src/components/catch_top_bar_mode.dart';
import 'package:catch_ui/src/components/catch_top_bar_navigation.dart';
import 'package:catch_ui/src/components/catch_top_bar_search.dart';
import 'package:catch_ui/src/components/catch_top_bar_size.dart';
import 'package:catch_ui/src/components/catch_top_bar_tone.dart';
import 'package:catch_ui/src/components/catch_top_bar_variant.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_kicker_text.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

/// Canonical Catch top-bar component.
///
/// Mirrors the design handoff's `AppBar`: compact or large title chrome,
/// standard back/close [CatchIconAction] composition, optional trailing action, and
/// declarative expanding search.
class CatchTopBar extends StatefulWidget implements CatchScaledPreferredSize {
  const CatchTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.eyebrow,
    this.kicker,
    this.size = CatchTopBarSize.automatic,
    this.variant = CatchTopBarVariant.route,
    this.titleMaxLines,
    this.body,
    this.leading,
    this.navigation = const CatchTopBarNavigation(),
    this.actions = const <Widget>[],
    this.backgroundColor,
    this.tone = CatchTopBarTone.page,
    this.emphasis = CatchTopBarEmphasis.plain,
    this.gutter = true,
    this.applySafeArea = true,
    this.contentPadding,
    this.height = CatchLayout.topBarHeight,
    this.largeHeight = CatchLayout.topBarLargeHeight,
    this.mode = CatchTopBarMode.fixed,
    this.contentCrossAxisAlignment = CrossAxisAlignment.center,
    this.footer,
    this.trailing,
    this.search,
  }) : assert(eyebrow == null || kicker == null),
       identityName = null,
       identitySemanticLabel = null,
       identityPhotoUrl = null,
       onIdentityTap = null,
       _screen = null;

  const CatchTopBar.identity({
    super.key,
    required this.identityName,
    required String this.identitySemanticLabel,
    this.identityPhotoUrl,
    this.onIdentityTap,
    this.leading,
    this.navigation = const CatchTopBarNavigation(),
    this.actions = const <Widget>[],
    this.backgroundColor,
    this.tone = CatchTopBarTone.page,
    this.emphasis = CatchTopBarEmphasis.plain,
    this.gutter = true,
    this.applySafeArea = true,
    this.contentPadding,
    this.height = CatchLayout.topBarHeight,
    this.largeHeight = CatchLayout.topBarLargeHeight,
    this.mode = CatchTopBarMode.fixed,
    this.contentCrossAxisAlignment = CrossAxisAlignment.center,
    this.footer,
    this.trailing,
  }) : title = null,
       subtitle = null,
       eyebrow = null,
       kicker = null,
       size = CatchTopBarSize.compact,
       variant = CatchTopBarVariant.identity,
       titleMaxLines = 1,
       body = null,
       search = null,
       _screen = null;

  /// Root-title chrome with synchronous, text-scaled preferred height.
  factory CatchTopBar.screen({
    Key? key,
    required BuildContext context,
    required String title,
    String? eyebrow,
    String? subtitle,
    Widget? leading,
    CatchTopBarNavigation navigation = const CatchTopBarNavigation(),
    List<Widget> actions = const [],
    int titleMaxLines = 1,
    TextStyle? titleStyle,
    CrossAxisAlignment rowCrossAxisAlignment = CrossAxisAlignment.center,
    Color? backgroundColor,
    CatchTopBarTone tone = CatchTopBarTone.page,
    CatchTopBarEmphasis emphasis = CatchTopBarEmphasis.plain,
    bool gutter = false,
    bool applySafeArea = true,
    PreferredSizeWidget? footer,
    Widget? trailing,
    CatchTopBarSearch? search,
  }) => CatchTopBar._root(
    key: key,
    title: title,
    eyebrow: eyebrow,
    subtitle: subtitle,
    leading: leading,
    navigation: navigation,
    actions: actions,
    titleMaxLines: titleMaxLines,
    titleStyle: titleStyle,
    rowCrossAxisAlignment: rowCrossAxisAlignment,
    backgroundColor: backgroundColor,
    tone: tone,
    emphasis: emphasis,
    gutter: gutter,
    applySafeArea: applySafeArea,
    contentPadding: CatchInsets.screenTitleBlock,
    height: heightFor(
      context: context,
      hasEyebrow: eyebrow?.isNotEmpty ?? false,
      hasSubtitle: subtitle?.isNotEmpty ?? false,
      titleMaxLines: titleMaxLines,
      hasActions: actions.isNotEmpty,
      titleStyle: titleStyle,
    ),
    footer: footer,
    trailing: trailing,
    search: search,
  );

  /// Embedded root title; the root scroll owner supplies safe area and rail.
  factory CatchTopBar.primaryRail({
    Key? key,
    required BuildContext context,
    required String title,
    String? eyebrow,
    String? subtitle,
    Widget? leading,
    List<Widget> actions = const [],
    int titleMaxLines = 1,
    CrossAxisAlignment rowCrossAxisAlignment = CrossAxisAlignment.center,
    CatchTopBarSearch? search,
  }) => CatchTopBar._root(
    key: key,
    title: title,
    eyebrow: eyebrow,
    subtitle: subtitle,
    leading: leading,
    navigation: const CatchTopBarNavigation(
      mode: CatchTopBarNavigationMode.none,
    ),
    actions: actions,
    titleMaxLines: titleMaxLines,
    titleStyle: null,
    rowCrossAxisAlignment: rowCrossAxisAlignment,
    applySafeArea: false,
    contentPadding: CatchInsets.primaryRailTitleBlock,
    height: _heightFor(
      context: context,
      hasEyebrow: eyebrow?.isNotEmpty ?? false,
      hasSubtitle: subtitle?.isNotEmpty ?? false,
      titleMaxLines: titleMaxLines,
      hasActions: actions.isNotEmpty,
      contentPadding: CatchInsets.primaryRailTitleBlock,
      minimumHeight: 0,
    ),
    search: search,
  );

  const CatchTopBar._root({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.leading,
    this.navigation = const CatchTopBarNavigation(),
    this.actions = const [],
    required this.titleMaxLines,
    required TextStyle? titleStyle,
    required CrossAxisAlignment rowCrossAxisAlignment,
    this.backgroundColor,
    this.tone = CatchTopBarTone.page,
    this.emphasis = CatchTopBarEmphasis.plain,
    this.gutter = false,
    this.applySafeArea = true,
    required this.contentPadding,
    required this.height,
    this.footer,
    this.trailing,
    this.search,
  }) : _screen = (
         titleStyle: titleStyle,
         rowCrossAxisAlignment: rowCrossAxisAlignment,
       ),
       kicker = null,
       size = CatchTopBarSize.compact,
       variant = CatchTopBarVariant.route,
       body = null,
       identityName = null,
       identitySemanticLabel = null,
       identityPhotoUrl = null,
       onIdentityTap = null,
       largeHeight = CatchLayout.topBarLargeHeight,
       mode = CatchTopBarMode.fixed,
       contentCrossAxisAlignment = CrossAxisAlignment.start;

  final ({TextStyle? titleStyle, CrossAxisAlignment rowCrossAxisAlignment})?
  _screen;

  static double heightFor({
    required BuildContext context,
    bool hasEyebrow = false,
    bool hasSubtitle = false,
    int titleMaxLines = 1,
    bool hasActions = false,
    TextStyle? titleStyle,
  }) => _heightFor(
    context: context,
    hasEyebrow: hasEyebrow,
    hasSubtitle: hasSubtitle,
    titleMaxLines: titleMaxLines,
    hasActions: hasActions,
    titleStyle: titleStyle,
    contentPadding: CatchInsets.screenTitleBlock,
    minimumHeight: hasEyebrow || hasSubtitle || titleMaxLines > 1
        ? CatchLayout.browseHeaderHeight
        : CatchLayout.topBarHeight,
  );

  static double _heightFor({
    required BuildContext context,
    required bool hasEyebrow,
    required bool hasSubtitle,
    required int titleMaxLines,
    required bool hasActions,
    TextStyle? titleStyle,
    required EdgeInsetsGeometry contentPadding,
    required double minimumHeight,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final largeText = textScaler.scale(1) >= 1.5;
    final resolvedPadding = contentPadding.resolve(Directionality.of(context));
    double lineHeight(TextStyle style) =>
        textScaler.scale(style.fontSize!) * (style.height ?? 1);

    var textHeight =
        lineHeight(titleStyle ?? CatchTextStyles.headline(context)) *
        titleMaxLines;
    if (hasEyebrow) {
      textHeight +=
          lineHeight(CatchTextStyles.kicker(context)) + CatchSpacing.micro2;
    }
    if (hasSubtitle) {
      textHeight +=
          CatchGaps.headerTitleToSubtitle +
          lineHeight(CatchTextStyles.supporting(context)) * (largeText ? 2 : 1);
    }
    if (largeText && hasActions) {
      textHeight += CatchLayout.topBarLargeTextActionReserve;
    }

    final actionExtent = CatchIconAction.targetExtentFor(
      CatchIconAction.navSize,
    );
    final contentHeight = textHeight > actionExtent ? textHeight : actionExtent;
    // Text layout can round a scaled glyph run slightly above the nominal
    // style height, so reserve the next logical pixel in the preferred size.
    final requiredHeight = (contentHeight + resolvedPadding.vertical)
        .ceilToDouble();
    return requiredHeight > minimumHeight ? requiredHeight : minimumHeight;
  }

  final String? title;
  final String? subtitle;
  final String? eyebrow;
  final String? kicker;
  final CatchTopBarSize size;
  final CatchTopBarVariant variant;
  final int? titleMaxLines;
  final Widget? body;
  final String? identityName;
  final String? identitySemanticLabel;
  final String? identityPhotoUrl;
  final VoidCallback? onIdentityTap;
  final Widget? leading;
  final CatchTopBarNavigation navigation;
  final List<Widget> actions;
  final Color? backgroundColor;
  final CatchTopBarTone tone;
  final CatchTopBarEmphasis emphasis;
  final bool gutter;
  final bool applySafeArea;
  final EdgeInsetsGeometry? contentPadding;
  final double height;
  final double largeHeight;
  final CatchTopBarMode mode;
  final CrossAxisAlignment contentCrossAxisAlignment;
  final PreferredSizeWidget? footer;
  final Widget? trailing;
  final CatchTopBarSearch? search;

  @override
  Size get preferredSize => Size.fromHeight(
    (isLarge ? largeHeight : height) + (footer?.preferredSize.height ?? 0),
  );

  @override
  Size preferredSizeFor(BuildContext context) {
    final bottomHeight = switch (footer) {
      final CatchScaledPreferredSize scaled =>
        scaled.preferredSizeFor(context).height,
      final bar? => bar.preferredSize.height,
      null => 0.0,
    };
    return Size.fromHeight(contentHeightFor(context) + bottomHeight);
  }

  double contentHeightFor(BuildContext context) {
    final original = isLarge ? largeHeight : height;
    if (search == null) return original;
    final searchHeight = CatchSearchField.heightFor(
      context,
      visualExtent: search!.collapsedExtent,
    );
    final padding =
        contentPadding?.resolve(Directionality.of(context)).vertical ??
        (isLarge ? CatchSpacing.s3 : 0);
    final required = searchHeight + padding;
    return required > original ? required : original;
  }

  bool get isLarge => switch (size) {
    CatchTopBarSize.automatic => kicker?.isNotEmpty ?? false,
    CatchTopBarSize.compact => false,
    CatchTopBarSize.large => true,
  };

  /// Preferred height for a compact operational workspace title stack.
  ///
  /// The workspace screens still use compact route typography, but may need a
  /// kicker and several title lines at large text sizes. Keeping this resolver
  /// here prevents feature screens from restating the route-title style merely
  /// to calculate their app-bar height.
  static double workspaceHeightFor({
    required BuildContext context,
    bool hasEyebrow = false,
    bool hasSubtitle = false,
    int titleMaxLines = 1,
    bool hasActions = false,
  }) => heightFor(
    context: context,
    hasEyebrow: hasEyebrow,
    hasSubtitle: hasSubtitle,
    titleMaxLines: titleMaxLines,
    hasActions: hasActions,
    titleStyle: CatchTextStyles.routeTitle(context),
  );

  @override
  State<CatchTopBar> createState() => _CatchTopBarState();
}

class _CatchTopBarState extends State<CatchTopBar> {
  bool _searchOpen = false;

  bool get _searchEnabled => widget.search?.enabled ?? false;

  bool get _searchOpenEffective {
    if (!_searchEnabled) return false;
    return widget.search?.expanded ?? _searchOpen;
  }

  @override
  void didUpdateWidget(covariant CatchTopBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_searchEnabled && _searchOpen) _searchOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final showDivider = widget.emphasis == CatchTopBarEmphasis.divided;
    final background =
        widget.backgroundColor ??
        (widget.tone == CatchTopBarTone.surface ? t.surface : t.bg);
    final large = widget.isLarge;
    final crossAxisAlignment = large
        ? CrossAxisAlignment.start
        : widget.contentCrossAxisAlignment;
    Widget? leading = widget.leading;
    if (leading == null) {
      final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
      final type = widget.navigation.mode;
      final wantsLeading = switch (type) {
        CatchTopBarNavigationMode.none => false,
        CatchTopBarNavigationMode.back ||
        CatchTopBarNavigationMode.close => true,
        CatchTopBarNavigationMode.auto => canPop,
      };
      if (wantsLeading) {
        final isClose = type == CatchTopBarNavigationMode.close;
        final localizations = MaterialLocalizations.of(context);
        leading = CatchIconAction.toolbar(
          tooltip: isClose
              ? localizations.closeButtonTooltip
              : localizations.backButtonTooltip,
          icon: isClose ? CatchIcons.close : CatchIcons.arrowBackIosNewRounded,
          variant: widget.navigation.variant,
          onPressed:
              widget.navigation.onPressed ??
              () => Navigator.of(context).maybePop(),
        );
      }
    }
    final hasEyebrow = widget.eyebrow != null && widget.eyebrow!.isNotEmpty;
    final hasKicker = widget.kicker != null && widget.kicker!.isNotEmpty;
    final hasSubtitle = widget.subtitle != null && widget.subtitle!.isNotEmpty;
    final bodyOwnsSupplementalText = widget._screen != null;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final collapseSupplementalText = widget.isLarge && textScale >= 1.4;
    final showKicker =
        hasKicker && !bodyOwnsSupplementalText && !collapseSupplementalText;
    final showEyebrow =
        hasEyebrow && !bodyOwnsSupplementalText && !collapseSupplementalText;
    final showSubtitle =
        hasSubtitle && !bodyOwnsSupplementalText && textScale < 1.4;
    final hiddenTextLabel =
        widget.title != null &&
            ((hasEyebrow && !showEyebrow) ||
                (hasKicker && !showKicker) ||
                (hasSubtitle && !showSubtitle))
        ? [
            if (hasEyebrow && !showEyebrow) widget.eyebrow!,
            if (hasKicker && !showKicker) widget.kicker!,
            widget.title!,
            if (hasSubtitle && !showSubtitle) widget.subtitle!,
          ].join('. ')
        : null;
    final screen = widget._screen;
    final largeText = textScale >= 1.5;
    final effectiveActions = screen != null && largeText
        ? const <Widget>[]
        : widget.actions;
    final screenBody = screen == null
        ? null
        : CatchScreenHeader(
            title: widget.title!,
            kicker: widget.eyebrow,
            subtitle: widget.subtitle,
            actions: largeText ? widget.actions : const <Widget>[],
            titleMaxLines: widget.titleMaxLines!,
            titleStyle: screen.titleStyle,
            rowCrossAxisAlignment: screen.rowCrossAxisAlignment,
          );
    final identityName = widget.identityName;
    final body =
        screenBody ??
        widget.body ??
        (identityName != null && identityName.isNotEmpty
            ? Semantics(
                button: widget.onIdentityTap != null,
                label: widget.onIdentityTap == null
                    ? null
                    : widget.identitySemanticLabel,
                child: InkWell(
                  onTap: widget.onIdentityTap,
                  borderRadius: BorderRadius.circular(CatchRadius.lg),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: CatchPlatformTokens.minimumInteractiveExtent,
                      minWidth: CatchPlatformTokens.minimumInteractiveExtent,
                    ),
                    child: Padding(
                      padding: CatchInsets.controlVerticalTight,
                      child: Row(
                        children: [
                          CatchAvatar(
                            size: 36,
                            name: identityName,
                            imageUrl: widget.identityPhotoUrl,
                          ),
                          gapW10,
                          Expanded(
                            child: Text(
                              identityName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CatchTextStyles.titleL(
                                context,
                                color: t.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : widget.title == null || widget.title!.isEmpty
            ? const SizedBox.shrink()
            : Text(
                widget.title!,
                semanticsLabel: hiddenTextLabel,
                maxLines:
                    widget.titleMaxLines ??
                    (widget.isLarge && !collapseSupplementalText ? 2 : 1),
                overflow: TextOverflow.ellipsis,
                style: widget.isLarge
                    ? CatchTextStyles.titleL(context, color: t.ink)
                    : switch (widget.variant) {
                        CatchTopBarVariant.route => CatchTextStyles.routeTitle(
                          context,
                          color: t.ink,
                        ),
                        CatchTopBarVariant.identity => CatchTextStyles.titleL(
                          context,
                          color: t.ink,
                        ),
                      },
              ));

    final titleBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showEyebrow) ...[
          Text(
            widget.eyebrow!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.monoLabel(context, color: t.ink3),
          ),
          gapH2,
        ],
        if (showKicker) ...[CatchKickerText(label: widget.kicker!), gapH6],
        body,
        if (showSubtitle) ...[
          gapH3,
          Text(
            widget.subtitle!,
            maxLines: widget.isLarge ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.appBarSubtitle(context, color: t.ink2),
          ),
        ],
      ],
    );

    final trailing = effectiveActions.isNotEmpty
        ? CatchTopBarActionRow(actions: effectiveActions)
        : widget.trailing;
    final title = large
        ? titleBlock
        : Align(
            alignment: crossAxisAlignment == CrossAxisAlignment.start
                ? Alignment.topLeft
                : Alignment.centerLeft,
            child: titleBlock,
          );
    final height = widget.contentHeightFor(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: (widget.mode == CatchTopBarMode.content) ? null : height,
          constraints: (widget.mode == CatchTopBarMode.content)
              ? BoxConstraints(minHeight: height)
              : null,
          padding:
              widget.contentPadding ??
              (large
                  ? EdgeInsets.fromLTRB(
                      widget.gutter ? CatchSpacing.screenPx : CatchSpacing.s0,
                      CatchSpacing.s3,
                      widget.gutter ? CatchSpacing.screenPx : CatchSpacing.s0,
                      CatchSpacing.s0,
                    )
                  : EdgeInsets.symmetric(
                      horizontal: widget.gutter
                          ? CatchSpacing.screenPx
                          : CatchSpacing.s0,
                    )),
          // The scroll divider paints inside the frame without reducing its title lane.
          foregroundDecoration: BoxDecoration(
            border: showDivider && widget.footer == null
                ? Border(bottom: BorderSide(color: t.line))
                : const Border(),
          ),
          child: LayoutBuilder(
            builder: (context, frameConstraints) => Row(
              crossAxisAlignment: crossAxisAlignment,
              children: [
                if (leading != null) ...[leading, gapW12],
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, laneConstraints) {
                      final search = _searchEnabled ? widget.search : null;
                      final searchWidget = search == null
                          ? null
                          : CatchSearchField.expanding(
                              copy: search.copy,
                              key: search.fieldKey,
                              expanded: _searchOpenEffective,
                              maxWidth: laneConstraints.maxWidth,
                              value: search.value,
                              contract: search.contract,
                              contractExemption: search.contractExemption,
                              onChanged: search.onChanged,
                              placeholder: search.placeholder,
                              autofocus: search.autofocus,
                              textInputAction: search.textInputAction,
                              onSubmitted: search.onSubmitted,
                              onFocusChanged: search.onFocusChanged,
                              semanticLabel: search.semanticLabel,
                              onOpenSearch: () => _setSearchOpen(true),
                              onCloseSearch: () => _setSearchOpen(false),
                              tooltip: search.tooltip,
                              collapsedExtent: search.collapsedExtent,
                              backgroundColor: search.backgroundColor,
                              borderColor: search.borderColor,
                              foregroundColor: search.foregroundColor,
                              mutedForegroundColor: search.mutedForegroundColor,
                            );
                      final maxTrailingWidth =
                          frameConstraints.maxWidth *
                          CatchLayout.topBarTrailingMaxRatio;
                      final minimumTrailingWidth =
                          trailing is CatchTopBarActionRow
                          ? trailing.minimumWidth
                          : CatchPlatformTokens.minimumInteractiveExtent;
                      final trailingEdge = trailing == null
                          ? const SizedBox.shrink()
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    maxTrailingWidth < minimumTrailingWidth
                                    ? minimumTrailingWidth
                                    : maxTrailingWidth,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [Flexible(child: trailing)],
                              ),
                            );
                      if (searchWidget == null) {
                        return Row(
                          crossAxisAlignment: crossAxisAlignment,
                          children: [
                            Expanded(child: title),
                            trailingEdge,
                          ],
                        );
                      }
                      return Stack(
                        alignment: large
                            ? Alignment.topRight
                            : Alignment.centerRight,
                        children: [
                          IgnorePointer(
                            ignoring: _searchOpenEffective,
                            child: AnimatedOpacity(
                              opacity: _searchOpenEffective ? 0 : 1,
                              duration: CatchMotion.base,
                              curve: CatchMotion.standardCurve,
                              child: Row(
                                crossAxisAlignment: crossAxisAlignment,
                                children: [
                                  Expanded(child: title),
                                  trailingEdge,
                                  if (trailing != null) gapW4,
                                  SizedBox(
                                    width: CatchIconAction.targetExtentFor(
                                      widget.search?.collapsedExtent ??
                                          CatchIconAction.navSize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          searchWidget,
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.footer != null)
          DecoratedBox(
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(bottom: BorderSide(color: t.line))
                  : const Border(),
            ),
            child: widget.footer!,
          ),
      ],
    );
    return Material(
      color: background,
      surfaceTintColor: Colors.transparent,
      child: widget.applySafeArea
          ? SafeArea(bottom: false, child: content)
          : content,
    );
  }

  void _setSearchOpen(bool value) {
    widget.search?.onExpandedChanged?.call(value);
    if (widget.search?.expanded == null) {
      setState(() => _searchOpen = value);
    }
  }
}
