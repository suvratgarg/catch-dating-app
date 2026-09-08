import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:catch_ui/src/components/catch_screen_top_bar.dart';
import 'package:catch_ui/src/components/catch_search_field.dart';
import 'package:catch_ui/src/components/catch_top_bar_action_row.dart';
import 'package:catch_ui/src/components/catch_top_bar_leading.dart';
import 'package:catch_ui/src/components/catch_top_bar_search.dart';
import 'package:catch_ui/src/components/catch_top_bar_title_role.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_gap.dart';
import 'package:catch_ui/src/primitives/catch_kicker_text.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/material.dart';

/// Canonical Catch app-bar primitive.
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
    this.large,
    this.titleRole = CatchTopBarTitleRole.route,
    this.titleMaxLines,
    this.titleWidget,
    this.titleWidgetIncludesSupplementalText = false,
    this.leading,
    this.leadingType = CatchTopBarLeading.auto,
    this.leadingActionVariant = CatchIconActionVariant.bordered,
    this.actions = const <Widget>[],
    this.showBackButton,
    this.onBack,
    this.backgroundColor,
    this.surface = false,
    this.divider = false,
    this.gutter = true,
    this.applySafeArea = true,
    this.contentPadding,
    this.height = CatchLayout.topBarHeight,
    this.largeHeight = CatchLayout.topBarLargeHeight,
    this.allowContentHeightExpansion = false,
    this.contentCrossAxisAlignment = CrossAxisAlignment.center,
    this.bottom,
    this.trailing,
    this.search,
  }) : assert(eyebrow == null || kicker == null),
       identityName = null,
       identitySemanticLabel = null,
       identityPhotoUrl = null,
       onIdentityTap = null;

  const CatchTopBar.identity({
    super.key,
    required this.identityName,
    required String this.identitySemanticLabel,
    this.identityPhotoUrl,
    this.onIdentityTap,
    this.leading,
    this.leadingType = CatchTopBarLeading.auto,
    this.leadingActionVariant = CatchIconActionVariant.bordered,
    this.actions = const <Widget>[],
    this.showBackButton,
    this.onBack,
    this.backgroundColor,
    this.surface = false,
    this.divider = false,
    this.gutter = true,
    this.applySafeArea = true,
    this.contentPadding,
    this.height = CatchLayout.topBarHeight,
    this.largeHeight = CatchLayout.topBarLargeHeight,
    this.allowContentHeightExpansion = false,
    this.contentCrossAxisAlignment = CrossAxisAlignment.center,
    this.bottom,
    this.trailing,
  }) : title = null,
       subtitle = null,
       eyebrow = null,
       kicker = null,
       large = false,
       titleRole = CatchTopBarTitleRole.identity,
       titleMaxLines = 1,
       titleWidget = null,
       titleWidgetIncludesSupplementalText = false,
       search = null;

  final String? title;
  final String? subtitle;
  final String? eyebrow;
  final String? kicker;
  final bool? large;
  final CatchTopBarTitleRole titleRole;
  final int? titleMaxLines;
  final Widget? titleWidget;
  final bool titleWidgetIncludesSupplementalText;
  final String? identityName;
  final String? identitySemanticLabel;
  final String? identityPhotoUrl;
  final VoidCallback? onIdentityTap;
  final Widget? leading;
  final CatchTopBarLeading leadingType;
  final CatchIconActionVariant leadingActionVariant;
  final List<Widget> actions;
  final bool? showBackButton;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final bool surface;
  final bool divider;
  final bool gutter;
  final bool applySafeArea;
  final EdgeInsetsGeometry? contentPadding;
  final double height;
  final double largeHeight;
  final bool allowContentHeightExpansion;
  final CrossAxisAlignment contentCrossAxisAlignment;
  final PreferredSizeWidget? bottom;
  final Widget? trailing;
  final CatchTopBarSearch? search;

  @override
  Size get preferredSize => Size.fromHeight(
    (isLarge ? largeHeight : height) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Size preferredSizeFor(BuildContext context) {
    final bottomHeight = switch (bottom) {
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

  bool get isLarge => large ?? (kicker != null && kicker!.isNotEmpty);

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
  }) => CatchScreenTopBar.heightFor(
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
    final showDivider = widget.divider;
    final background =
        widget.backgroundColor ?? (widget.surface ? t.surface : t.bg);
    final large = widget.isLarge;
    final crossAxisAlignment = large
        ? CrossAxisAlignment.start
        : widget.contentCrossAxisAlignment;
    Widget? leading = widget.leading;
    if (leading == null) {
      final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
      final type = widget.leadingType;
      final wantsLeading = switch (type) {
        CatchTopBarLeading.none => false,
        CatchTopBarLeading.back || CatchTopBarLeading.close => true,
        CatchTopBarLeading.auto => widget.showBackButton ?? canPop,
      };
      if (wantsLeading) {
        final isClose = type == CatchTopBarLeading.close;
        final localizations = MaterialLocalizations.of(context);
        leading = CatchIconAction.toolbar(
          tooltip: isClose
              ? localizations.closeButtonTooltip
              : localizations.backButtonTooltip,
          icon: isClose ? CatchIcons.close : CatchIcons.arrowBackIosNewRounded,
          variant: widget.leadingActionVariant,
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        );
      }
    }
    final hasEyebrow = widget.eyebrow != null && widget.eyebrow!.isNotEmpty;
    final hasKicker = widget.kicker != null && widget.kicker!.isNotEmpty;
    final hasSubtitle = widget.subtitle != null && widget.subtitle!.isNotEmpty;
    final titleWidgetOwnsSupplementalText =
        widget.titleWidget != null &&
        widget.titleWidgetIncludesSupplementalText;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final collapseSupplementalText = widget.isLarge && textScale >= 1.4;
    final showKicker =
        hasKicker &&
        !titleWidgetOwnsSupplementalText &&
        !collapseSupplementalText;
    final showEyebrow =
        hasEyebrow &&
        !titleWidgetOwnsSupplementalText &&
        !collapseSupplementalText;
    final showSubtitle =
        hasSubtitle && !titleWidgetOwnsSupplementalText && textScale < 1.4;
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
    final identityName = widget.identityName;
    final titleWidget =
        widget.titleWidget ??
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
                    : switch (widget.titleRole) {
                        CatchTopBarTitleRole.route =>
                          CatchTextStyles.routeTitle(context, color: t.ink),
                        CatchTopBarTitleRole.identity => CatchTextStyles.titleL(
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
        titleWidget,
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

    final trailing = widget.actions.isNotEmpty
        ? CatchTopBarActionRow(actions: widget.actions)
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
          height: widget.allowContentHeightExpansion ? null : height,
          constraints: widget.allowContentHeightExpansion
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
            border: showDivider && widget.bottom == null
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
        if (widget.bottom != null)
          DecoratedBox(
            decoration: BoxDecoration(
              border: showDivider
                  ? Border(bottom: BorderSide(color: t.line))
                  : const Border(),
            ),
            child: widget.bottom!,
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
