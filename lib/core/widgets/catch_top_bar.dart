import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_action.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_kicker.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart'
    show CatchContractConstraints, CatchContractFieldConstraints;
export 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
export 'package:catch_dating_app/core/widgets/catch_icon_action.dart';

part 'catch_top_bar_components.dart';

enum CatchTopBarLeading { auto, back, close, none }

/// Immutable expanding-search contract shared by both Catch top bars.
///
/// Copy and interaction text are required so a top bar cannot silently fall
/// back to English. Passing no config removes the search affordance.
@immutable
class CatchTopBarSearch {
  const CatchTopBarSearch({
    required this.placeholder,
    required this.tooltip,
    this.value = '',
    this.contract,
    this.contractExemption,
    this.enabled = true,
    this.expanded,
    this.onExpandedChanged,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.semanticLabel,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.collapsedExtent = CatchIconButton.navSize,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.mutedForegroundColor,
  });

  final String value;
  final CatchContractFieldConstraints? contract;
  final String? contractExemption;
  final bool enabled;
  final bool? expanded;
  final ValueChanged<bool>? onExpandedChanged;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;
  final String placeholder;
  final String tooltip;
  final String? semanticLabel;
  final bool autofocus;
  final TextInputAction textInputAction;
  final double collapsedExtent;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final Color? mutedForegroundColor;
}

/// Canonical trailing-action layout for Catch top bars and screen headers.
///
/// Action spacing is intentionally owned here so callers cannot create subtly
/// different header geometry by composing their own [Row].
class CatchTopBarActionGroup extends StatelessWidget {
  const CatchTopBarActionGroup({super.key, required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < actions.length; index++) ...[
          Flexible(child: actions[index]),
          if (index != actions.length - 1) gapW8,
        ],
      ],
    );
  }
}

/// Root-screen title stack shared by the main tabs and root-like app bars.
class CatchScreenHeaderTitle extends StatelessWidget {
  const CatchScreenHeaderTitle({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.titleMaxLines = 1,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.padding,
    this.material = false,
    this.backgroundColor,
  });

  const CatchScreenHeaderTitle.block({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.leading,
    this.actions = const <Widget>[],
    this.titleMaxLines = 1,
    this.rowCrossAxisAlignment = CrossAxisAlignment.center,
    this.padding = CatchInsets.screenTitleBlock,
    this.backgroundColor,
  }) : material = true;

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;
  final int titleMaxLines;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final EdgeInsetsGeometry? padding;
  final bool material;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasEyebrow = eyebrow != null && eyebrow!.isNotEmpty;
    final hasSubtitle = subtitle != null && subtitle!.isNotEmpty;

    Widget child = Row(
      crossAxisAlignment: rowCrossAxisAlignment,
      children: [
        if (leading != null) ...[leading!, gapW12],
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasEyebrow) ...[
                Text(
                  eyebrow!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.kicker(context, color: t.ink3),
                ),
                gapH2,
              ],
              Text(
                title,
                maxLines: titleMaxLines,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.headline(context, color: t.ink),
              ),
              if (hasSubtitle) ...[
                const SizedBox(height: CatchGaps.headerTitleToSubtitle),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          gapW12,
          CatchTopBarActionGroup(actions: actions),
        ],
      ],
    );

    final resolvedPadding = padding;
    if (resolvedPadding != null) {
      child = Padding(padding: resolvedPadding, child: child);
    }

    final resolvedBackground = backgroundColor ?? t.bg;
    if (material) {
      return Material(color: resolvedBackground, child: child);
    }
    if (backgroundColor != null) {
      return ColoredBox(color: resolvedBackground, child: child);
    }
    return child;
  }
}

/// App-bar wrapper for static/root screens that use the tab-screen title voice.
///
/// The factory requires [BuildContext] because [preferredSize] must be resolved
/// synchronously from the caller's text scaler and direction before this
/// widget's own [build] method runs. Stateful search and identity headers use
/// [CatchTopBar] directly.
class CatchScreenTopBar extends StatelessWidget implements PreferredSizeWidget {
  factory CatchScreenTopBar({
    Key? key,
    required BuildContext context,
    required String title,
    String? eyebrow,
    String? subtitle,
    Widget? leading,
    CatchTopBarLeading leadingType = CatchTopBarLeading.auto,
    List<Widget> actions = const <Widget>[],
    int titleMaxLines = 1,
    CrossAxisAlignment rowCrossAxisAlignment = CrossAxisAlignment.center,
    Color? backgroundColor,
    bool surface = false,
    bool border = false,
    bool? divider,
    bool gutter = false,
    bool applySafeArea = true,
    PreferredSizeWidget? bottom,
    Widget? trailing,
    CatchTopBarSearch? search,
  }) => CatchScreenTopBar._(
    heightFor(
      context: context,
      hasEyebrow: eyebrow?.isNotEmpty ?? false,
      hasSubtitle: subtitle?.isNotEmpty ?? false,
      titleMaxLines: titleMaxLines,
    ),
    key: key,
    title: title,
    eyebrow: eyebrow,
    subtitle: subtitle,
    leading: leading,
    leadingType: leadingType,
    actions: actions,
    titleMaxLines: titleMaxLines,
    rowCrossAxisAlignment: rowCrossAxisAlignment,
    backgroundColor: backgroundColor,
    surface: surface,
    border: border,
    divider: divider,
    gutter: gutter,
    applySafeArea: applySafeArea,
    contentPadding: CatchInsets.screenTitleBlock,
    bottom: bottom,
    trailing: trailing,
    search: search,
  );

  const CatchScreenTopBar._(
    this._resolvedHeight, {
    super.key,
    required this.title,
    required this.eyebrow,
    required this.subtitle,
    required this.leading,
    required this.leadingType,
    required this.actions,
    required this.titleMaxLines,
    required this.rowCrossAxisAlignment,
    required this.backgroundColor,
    required this.surface,
    required this.border,
    required this.divider,
    required this.gutter,
    required this.applySafeArea,
    required this.contentPadding,
    required this.bottom,
    required this.trailing,
    required this.search,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? leading;
  final CatchTopBarLeading leadingType;
  final List<Widget> actions;
  final int titleMaxLines;
  final CrossAxisAlignment rowCrossAxisAlignment;
  final Color? backgroundColor;
  final bool surface;
  final bool border;
  final bool? divider;
  final bool gutter;
  final bool applySafeArea;
  final EdgeInsetsGeometry? contentPadding;
  final PreferredSizeWidget? bottom;
  final Widget? trailing;
  final CatchTopBarSearch? search;
  final double _resolvedHeight;

  static double heightFor({
    required BuildContext context,
    bool hasEyebrow = false,
    bool hasSubtitle = false,
    int titleMaxLines = 1,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final resolvedPadding = CatchInsets.screenTitleBlock.resolve(
      Directionality.of(context),
    );
    double lineHeight(TextStyle style) =>
        textScaler.scale(style.fontSize!) * (style.height ?? 1);

    var textHeight =
        lineHeight(CatchTextStyles.headline(context)) * titleMaxLines;
    if (hasEyebrow) {
      textHeight +=
          lineHeight(CatchTextStyles.kicker(context)) + CatchSpacing.micro2;
    }
    if (hasSubtitle) {
      textHeight +=
          CatchGaps.headerTitleToSubtitle +
          lineHeight(CatchTextStyles.supporting(context));
    }

    final baseline = hasEyebrow || hasSubtitle || titleMaxLines > 1
        ? CatchLayout.browseHeaderHeight
        : CatchLayout.topBarHeight;
    final contentHeight = textHeight > CatchIconButton.navSize
        ? textHeight
        : CatchIconButton.navSize;
    // Text layout can round a scaled glyph run slightly above the nominal
    // style height, so reserve the next logical pixel in the preferred size.
    final requiredHeight = (contentHeight + resolvedPadding.vertical)
        .ceilToDouble();
    return requiredHeight > baseline ? requiredHeight : baseline;
  }

  double get height => _resolvedHeight;

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return CatchTopBar(
      titleWidget: CatchScreenHeaderTitle(
        title: title,
        eyebrow: eyebrow,
        subtitle: subtitle,
        titleMaxLines: titleMaxLines,
        rowCrossAxisAlignment: rowCrossAxisAlignment,
      ),
      large: false,
      leading: leading,
      leadingType: leadingType,
      actions: actions,
      backgroundColor: backgroundColor,
      surface: surface,
      border: border,
      divider: divider,
      gutter: gutter,
      applySafeArea: applySafeArea,
      contentPadding: contentPadding,
      height: height,
      contentCrossAxisAlignment: CrossAxisAlignment.start,
      bottom: bottom,
      trailing: trailing,
      search: search,
    );
  }
}

/// Canonical Catch app-bar primitive.
///
/// Mirrors the design handoff's `AppBar`: compact or large title chrome,
/// standard back/close [CatchIconButton] composition, optional trailing action, and
/// declarative expanding search.
class CatchTopBar extends StatefulWidget implements PreferredSizeWidget {
  const CatchTopBar({
    super.key,
    this.title,
    this.subtitle,
    this.kicker,
    this.large,
    this.titleWidget,
    this.leading,
    this.leadingType = CatchTopBarLeading.auto,
    this.actions = const <Widget>[],
    this.showBackButton,
    this.onBack,
    this.backgroundColor,
    this.surface = false,
    this.border = false,
    this.divider,
    this.gutter = true,
    this.applySafeArea = true,
    this.contentPadding,
    this.height = CatchLayout.topBarHeight,
    this.contentCrossAxisAlignment = CrossAxisAlignment.center,
    this.bottom,
    this.trailing,
    this.search,
  }) : identityName = null,
       identityPhotoUrl = null,
       onIdentityTap = null;

  const CatchTopBar.identity({
    super.key,
    required this.identityName,
    this.identityPhotoUrl,
    this.onIdentityTap,
    this.leading,
    this.leadingType = CatchTopBarLeading.auto,
    this.actions = const <Widget>[],
    this.showBackButton,
    this.onBack,
    this.backgroundColor,
    this.surface = false,
    this.border = false,
    this.divider,
    this.gutter = true,
    this.applySafeArea = true,
    this.contentPadding,
    this.height = CatchLayout.topBarHeight,
    this.contentCrossAxisAlignment = CrossAxisAlignment.center,
    this.bottom,
    this.trailing,
  }) : title = null,
       subtitle = null,
       kicker = null,
       large = false,
       titleWidget = null,
       search = null;

  final String? title;
  final String? subtitle;
  final String? kicker;
  final bool? large;
  final Widget? titleWidget;
  final String? identityName;
  final String? identityPhotoUrl;
  final VoidCallback? onIdentityTap;
  final Widget? leading;
  final CatchTopBarLeading leadingType;
  final List<Widget> actions;
  final bool? showBackButton;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final bool surface;
  final bool border;
  final bool? divider;
  final bool gutter;
  final bool applySafeArea;
  final EdgeInsetsGeometry? contentPadding;
  final double height;
  final CrossAxisAlignment contentCrossAxisAlignment;
  final PreferredSizeWidget? bottom;
  final Widget? trailing;
  final CatchTopBarSearch? search;

  @override
  Size get preferredSize => Size.fromHeight(
    (isLarge ? CatchLayout.topBarLargeHeight : height) +
        (bottom?.preferredSize.height ?? 0),
  );

  bool get isLarge => large ?? (kicker != null && kicker!.isNotEmpty);

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
    final showDivider = widget.divider ?? (widget.border || widget.surface);
    final background =
        widget.backgroundColor ?? (widget.surface ? t.surface : t.bg);

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isLarge)
          _buildLargeTopBarFrame(
            context,
            height: CatchLayout.topBarLargeHeight,
            gutter: widget.gutter,
            contentPadding: widget.contentPadding,
            showDivider: showDivider && widget.bottom == null,
            leading: _buildLeading(context),
            title: _buildTitleBlock(context),
            searchOpen: _searchOpenEffective,
            searchCollapsedExtent:
                widget.search?.collapsedExtent ?? CatchIconButton.navSize,
            search: _buildSearch,
            trailing: _buildTrailingActions(context),
          )
        else
          _buildCompactTopBarFrame(
            context,
            height: widget.height,
            contentCrossAxisAlignment: widget.contentCrossAxisAlignment,
            gutter: widget.gutter,
            contentPadding: widget.contentPadding,
            showDivider: showDivider && widget.bottom == null,
            leading: _buildLeading(context),
            title: _buildTitleBlock(context),
            searchOpen: _searchOpenEffective,
            searchCollapsedExtent:
                widget.search?.collapsedExtent ?? CatchIconButton.navSize,
            search: _buildSearch,
            trailing: _buildTrailingActions(context),
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

  Widget? _buildLeading(BuildContext context) {
    if (widget.leading != null) return widget.leading;
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final type = widget.leadingType;
    final wantsLeading = switch (type) {
      CatchTopBarLeading.none => false,
      CatchTopBarLeading.back || CatchTopBarLeading.close => true,
      CatchTopBarLeading.auto => widget.showBackButton ?? canPop,
    };

    if (!wantsLeading) return null;

    final isClose = type == CatchTopBarLeading.close;
    final localizations = MaterialLocalizations.of(context);
    return CatchIconAction(
      tooltip: isClose
          ? localizations.closeButtonTooltip
          : localizations.backButtonTooltip,
      icon: isClose ? CatchIcons.close : CatchIcons.arrowBackIosNewRounded,
      onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
    );
  }

  Widget _buildTitleBlock(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasKicker = widget.kicker != null && widget.kicker!.isNotEmpty;
    final hasSubtitle = widget.subtitle != null && widget.subtitle!.isNotEmpty;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final collapseSupplementalText = widget.isLarge && textScale >= 1.4;
    final showKicker = hasKicker && !collapseSupplementalText;
    final showSubtitle = hasSubtitle && textScale < 1.4;
    final hiddenTextLabel =
        widget.title != null &&
            ((hasKicker && !showKicker) || (hasSubtitle && !showSubtitle))
        ? [
            if (hasKicker && !showKicker) widget.kicker!,
            widget.title!,
            if (hasSubtitle && !showSubtitle) widget.subtitle!,
          ].join('. ')
        : null;
    final identityName = widget.identityName;
    final titleWidget =
        widget.titleWidget ??
        (identityName != null && identityName.isNotEmpty
            ? _buildCatchTopBarIdentityTitle(
                context,
                name: identityName,
                photoUrl: widget.identityPhotoUrl,
                onTap: widget.onIdentityTap,
              )
            : widget.title == null || widget.title!.isEmpty
            ? const SizedBox.shrink()
            : Text(
                widget.title!,
                semanticsLabel: hiddenTextLabel,
                maxLines: widget.isLarge && !collapseSupplementalText ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.titleL(context, color: t.ink),
              ));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showKicker) ...[CatchKicker(label: widget.kicker!), gapH6],
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
  }

  Widget? _buildTrailingActions(BuildContext context) {
    if (widget.actions.isNotEmpty) {
      return CatchTopBarActionGroup(actions: widget.actions);
    }
    return widget.trailing;
  }

  Widget? _buildSearch(double maxWidth) {
    if (!_searchEnabled) return null;
    final search = widget.search!;
    return CatchSearchField(
      mode: CatchSearchFieldMode.expanding,
      expanded: _searchOpenEffective,
      maxWidth: maxWidth,
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
  }

  void _setSearchOpen(bool value) {
    widget.search?.onExpandedChanged?.call(value);
    if (widget.search?.expanded == null) {
      setState(() => _searchOpen = value);
    }
  }
}

Widget _buildCompactTopBarFrame(
  BuildContext context, {
  required double height,
  required CrossAxisAlignment contentCrossAxisAlignment,
  required bool gutter,
  required EdgeInsetsGeometry? contentPadding,
  required bool showDivider,
  required Widget? leading,
  required Widget title,
  required bool searchOpen,
  required double searchCollapsedExtent,
  required Widget? Function(double maxWidth) search,
  required Widget? trailing,
}) {
  final t = CatchTokens.of(context);
  return Container(
    height: height,
    padding:
        contentPadding ??
        EdgeInsets.symmetric(
          horizontal: gutter ? CatchSpacing.screenPx : CatchSpacing.s0,
        ),
    decoration: BoxDecoration(
      border: showDivider
          ? Border(bottom: BorderSide(color: t.line))
          : const Border(),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: contentCrossAxisAlignment,
        children: [
          if (leading != null) ...[leading, gapW12],
          Expanded(
            child: _TopBarSearchLane(
              alignment: Alignment.centerRight,
              crossAxisAlignment: contentCrossAxisAlignment,
              searchOpen: searchOpen,
              searchCollapsedExtent: searchCollapsedExtent,
              search: search,
              trailing: trailing,
              title: Align(
                alignment: contentCrossAxisAlignment == CrossAxisAlignment.start
                    ? Alignment.topLeft
                    : Alignment.centerLeft,
                child: title,
              ),
              trailingMaxWidth:
                  constraints.maxWidth * CatchLayout.topBarTrailingMaxRatio,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLargeTopBarFrame(
  BuildContext context, {
  required double height,
  required bool gutter,
  required EdgeInsetsGeometry? contentPadding,
  required bool showDivider,
  required Widget? leading,
  required Widget title,
  required bool searchOpen,
  required double searchCollapsedExtent,
  required Widget? Function(double maxWidth) search,
  required Widget? trailing,
}) {
  final t = CatchTokens.of(context);
  return Container(
    height: height,
    padding:
        contentPadding ??
        EdgeInsets.fromLTRB(
          gutter ? CatchSpacing.screenPx : CatchSpacing.s0,
          CatchSpacing.s3,
          gutter ? CatchSpacing.screenPx : CatchSpacing.s0,
          CatchSpacing.s0,
        ),
    decoration: BoxDecoration(
      border: showDivider
          ? Border(bottom: BorderSide(color: t.line))
          : const Border(),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading, gapW12],
          Expanded(
            child: _TopBarSearchLane(
              alignment: Alignment.topRight,
              crossAxisAlignment: CrossAxisAlignment.start,
              searchOpen: searchOpen,
              searchCollapsedExtent: searchCollapsedExtent,
              search: search,
              trailing: trailing,
              title: title,
              trailingMaxWidth:
                  constraints.maxWidth * CatchLayout.topBarTrailingMaxRatio,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TopBarSearchLane extends StatelessWidget {
  const _TopBarSearchLane({
    required this.alignment,
    required this.crossAxisAlignment,
    required this.searchOpen,
    required this.searchCollapsedExtent,
    required this.search,
    required this.trailing,
    required this.title,
    required this.trailingMaxWidth,
  });

  final Alignment alignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool searchOpen;
  final double searchCollapsedExtent;
  final Widget? Function(double maxWidth) search;
  final Widget? trailing;
  final Widget title;
  final double trailingMaxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final searchWidget = search(constraints.maxWidth);
        if (searchWidget == null) {
          return Row(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Expanded(child: title),
              _buildTopBarTrailingEdge(
                maxWidth: trailingMaxWidth,
                trailing: trailing,
              ),
            ],
          );
        }

        return Stack(
          alignment: alignment,
          children: [
            IgnorePointer(
              ignoring: searchOpen,
              child: AnimatedOpacity(
                opacity: searchOpen ? 0 : 1,
                duration: CatchMotion.base,
                curve: CatchMotion.standardCurve,
                child: Row(
                  crossAxisAlignment: crossAxisAlignment,
                  children: [
                    Expanded(child: title),
                    _buildTopBarTrailingEdge(
                      maxWidth: trailingMaxWidth,
                      trailing: trailing,
                    ),
                    if (trailing != null) gapW4,
                    SizedBox(width: searchCollapsedExtent),
                  ],
                ),
              ),
            ),
            searchWidget,
          ],
        );
      },
    );
  }
}

Widget _buildTopBarTrailingEdge({
  required double maxWidth,
  required Widget? trailing,
}) {
  if (trailing == null) return const SizedBox.shrink();
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: trailing)],
    ),
  );
}

Widget _buildCatchTopBarIdentityTitle(
  BuildContext context, {
  required String name,
  required String? photoUrl,
  required VoidCallback? onTap,
}) {
  final t = CatchTokens.of(context);

  return Semantics(
    button: onTap != null,
    label: onTap == null
        ? null
        : context.l10n.coreCatchTopBarLabelViewNameProfile(name: name),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CatchRadius.lg),
      child: Padding(
        padding: CatchInsets.controlVerticalTight,
        child: Row(
          children: [
            CatchPersonAvatar(size: 36, name: name, imageUrl: photoUrl),
            gapW10,
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.titleL(context, color: t.ink),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
