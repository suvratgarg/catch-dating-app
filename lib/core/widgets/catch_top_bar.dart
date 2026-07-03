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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
export 'package:catch_dating_app/core/widgets/catch_icon_action.dart';

enum CatchTopBarLeading { auto, back, close, none }

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
    this.bottom,
    this.actionIcon,
    this.actionVariant = CatchIconButtonVariant.plain,
    this.actionLabel,
    this.actionText,
    this.onAction,
    this.trailing,
    this.searchValue,
    this.searchEnabled,
    this.searchExpanded,
    this.onSearchExpandedChanged,
    this.onSearch,
    this.searchPlaceholder = 'Search',
    this.searchAutofocus = false,
    this.searchTextInputAction = TextInputAction.done,
    this.onSearchSubmitted,
    this.onSearchFocusChanged,
    this.searchTooltip = 'Search',
    this.searchSemanticLabel,
    this.searchCollapsedExtent = CatchIconButton.navSize,
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
    this.bottom,
    this.trailing,
  }) : title = null,
       subtitle = null,
       kicker = null,
       large = false,
       titleWidget = null,
       actionIcon = null,
       actionVariant = CatchIconButtonVariant.plain,
       actionLabel = null,
       actionText = null,
       onAction = null,
       searchValue = null,
       searchEnabled = null,
       searchExpanded = null,
       onSearchExpandedChanged = null,
       onSearch = null,
       searchPlaceholder = 'Search',
       searchAutofocus = false,
       searchTextInputAction = TextInputAction.done,
       onSearchSubmitted = null,
       onSearchFocusChanged = null,
       searchTooltip = 'Search',
       searchSemanticLabel = null,
       searchCollapsedExtent = CatchIconButton.navSize;

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
  final PreferredSizeWidget? bottom;
  final IconData? actionIcon;
  final CatchIconButtonVariant actionVariant;
  final String? actionLabel;
  final String? actionText;
  final VoidCallback? onAction;
  final Widget? trailing;
  final String? searchValue;
  final bool? searchEnabled;
  final bool? searchExpanded;
  final ValueChanged<bool>? onSearchExpandedChanged;
  final ValueChanged<String>? onSearch;
  final String searchPlaceholder;
  final bool searchAutofocus;
  final TextInputAction searchTextInputAction;
  final ValueChanged<String>? onSearchSubmitted;
  final ValueChanged<bool>? onSearchFocusChanged;
  final String searchTooltip;
  final String? searchSemanticLabel;
  final double searchCollapsedExtent;

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

  bool get _searchEnabled =>
      widget.searchEnabled ??
      (widget.onSearch != null || widget.searchValue != null);

  bool get _searchOpenEffective {
    if (!_searchEnabled) return false;
    return widget.searchExpanded ?? _searchOpen;
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
            search: _buildSearch,
            trailing: _buildTrailingActions(context),
          )
        else
          _buildCompactTopBarFrame(
            context,
            height: widget.height,
            gutter: widget.gutter,
            contentPadding: widget.contentPadding,
            showDivider: showDivider && widget.bottom == null,
            leading: _buildLeading(context),
            title: _buildTitleBlock(context),
            searchOpen: _searchOpenEffective,
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
      return _buildTopBarActionRow(widget.actions);
    }
    if (widget.actionIcon != null) {
      return CatchIconAction(
        icon: widget.actionIcon!,
        tooltip: widget.actionLabel ?? 'Action',
        onPressed: widget.onAction,
        variant: widget.actionVariant,
      );
    }
    if (widget.actionText != null && widget.actionText!.isNotEmpty) {
      return CatchTopBarTextAction(
        label: widget.actionText!,
        onPressed: widget.onAction,
        foregroundColor: CatchTokens.of(context).ink2,
      );
    }
    return widget.trailing;
  }

  Widget? _buildSearch(double maxWidth) {
    if (!_searchEnabled) return null;
    return CatchSearchField(
      mode: CatchSearchFieldMode.expanding,
      expanded: _searchOpenEffective,
      maxWidth: maxWidth,
      value: widget.searchValue ?? '',
      onChanged: widget.onSearch,
      placeholder: widget.searchPlaceholder,
      autofocus: widget.searchAutofocus,
      textInputAction: widget.searchTextInputAction,
      onSubmitted: widget.onSearchSubmitted,
      onFocusChanged: widget.onSearchFocusChanged,
      semanticLabel: widget.searchSemanticLabel,
      onOpenSearch: () => _setSearchOpen(true),
      onCloseSearch: () => _setSearchOpen(false),
      tooltip: widget.searchTooltip,
      collapsedExtent: widget.searchCollapsedExtent,
    );
  }

  void _setSearchOpen(bool value) {
    widget.onSearchExpandedChanged?.call(value);
    if (widget.searchExpanded == null) {
      setState(() => _searchOpen = value);
    }
  }
}

Widget _buildCompactTopBarFrame(
  BuildContext context, {
  required double height,
  required bool gutter,
  required EdgeInsetsGeometry? contentPadding,
  required bool showDivider,
  required Widget? leading,
  required Widget title,
  required bool searchOpen,
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
        children: [
          if (leading != null) ...[leading, gapW12],
          if (searchOpen)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    search(constraints.maxWidth) ?? const SizedBox.shrink(),
              ),
            )
          else ...[
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: title),
            ),
            _buildTopBarTrailingEdge(
              maxWidth:
                  constraints.maxWidth * CatchLayout.topBarTrailingMaxRatio,
              search: search(CatchIconButton.navSize),
              trailing: trailing,
            ),
          ],
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
          if (searchOpen)
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    search(constraints.maxWidth) ?? const SizedBox.shrink(),
              ),
            )
          else ...[
            Expanded(child: title),
            _buildTopBarTrailingEdge(
              maxWidth:
                  constraints.maxWidth * CatchLayout.topBarTrailingMaxRatio,
              search: search(CatchIconButton.navSize),
              trailing: trailing,
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _buildTopBarTrailingEdge({
  required double maxWidth,
  required Widget? search,
  required Widget? trailing,
}) {
  if (search == null && trailing == null) return const SizedBox.shrink();
  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?search,
        if (search != null && trailing != null) gapW4,
        if (trailing != null) Flexible(child: trailing),
      ],
    ),
  );
}

Widget _buildTopBarActionRow(List<Widget> actions) {
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

Widget _buildCatchTopBarIdentityTitle(
  BuildContext context, {
  required String name,
  required String? photoUrl,
  required VoidCallback? onTap,
}) {
  final t = CatchTokens.of(context);

  return Semantics(
    button: onTap != null,
    label: onTap == null ? null : 'View $name profile',
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

class CatchTopBarTabBar extends StatefulWidget implements PreferredSizeWidget {
  const CatchTopBarTabBar({super.key, required this.tabs, this.controller});

  final List<Widget> tabs;
  final TabController? controller;

  @override
  Size get preferredSize => const Size.fromHeight(CatchLayout.topBarTabHeight);

  @override
  State<CatchTopBarTabBar> createState() => _CatchTopBarTabBarState();
}

class _CatchTopBarTabBarState extends State<CatchTopBarTabBar> {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _setController(widget.controller);
  }

  @override
  void didUpdateWidget(CatchTopBarTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _setController(widget.controller);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _setController(TabController? controller) {
    if (_controller == controller) return;
    _controller?.removeListener(_handleControllerChanged);
    _controller = controller;
    _controller?.addListener(_handleControllerChanged);
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    if (prefersCupertinoControls() && _controller != null) {
      return SizedBox(
        height: widget.preferredSize.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CatchSpacing.s4,
            vertical: CatchSpacing.s1,
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _controller!.index,
            backgroundColor: t.raised,
            thumbColor: t.surface,
            padding: const EdgeInsets.all(CatchSpacing.micro3),
            onValueChanged: (index) {
              if (index == null || index == _controller!.index) return;
              _controller!.animateTo(index);
            },
            children: {
              for (var index = 0; index < widget.tabs.length; index++)
                index: _buildCupertinoTabLabel(
                  context,
                  tab: widget.tabs[index],
                  selected: index == _controller!.index,
                ),
            },
          ),
        ),
      );
    }

    return TabBar(
      controller: widget.controller,
      tabs: widget.tabs,
      labelColor: t.ink,
      unselectedLabelColor: t.ink3,
      indicatorColor: t.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: CatchTextStyles.labelL(context),
      unselectedLabelStyle: CatchTextStyles.labelL(context),
    );
  }
}

Widget _buildCupertinoTabLabel(
  BuildContext context, {
  required Widget tab,
  required bool selected,
}) {
  final t = CatchTokens.of(context);
  final color = selected ? t.ink : t.ink2;
  final style = CatchTextStyles.labelL(context, color: color);

  return Center(
    child: DefaultTextStyle(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: style,
      child: IconTheme(
        data: IconThemeData(color: color, size: CatchIcon.sm),
        child: _tabChild(tab, style),
      ),
    ),
  );
}

Widget _tabChild(Widget tab, TextStyle style) {
  if (tab is Tab) {
    final text = tab.text;
    if (text != null) return Text(text, style: style);
    final child = tab.child;
    if (child != null) return child;
    final icon = tab.icon;
    if (icon != null) return icon;
  }
  return tab;
}

class CatchTopBarMenuAction<T> extends StatelessWidget {
  const CatchTopBarMenuAction({
    super.key,
    required this.items,
    required this.tooltip,
    this.onSelected,
    this.enabled = true,
    IconData? icon,
    // Keep the public parameter name as `icon` while storing the optional
    // override privately.
    // ignore: prefer_initializing_formals
  }) : _icon = icon;

  final List<CatchActionMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final String tooltip;
  final bool enabled;
  final IconData? _icon;

  IconData get icon => _icon ?? CatchIcons.moreHorizRounded;

  @override
  Widget build(BuildContext context) {
    return CatchActionMenu<T>(
      items: items,
      tooltip: tooltip,
      onSelected: onSelected,
      enabled: enabled,
      icon: icon,
    );
  }
}

@Deprecated('Use CatchIconAction')
typedef CatchTopBarIconAction = CatchIconAction;

class CatchTopBarTextAction extends StatelessWidget {
  const CatchTopBarTextAction({
    super.key,
    required this.label,
    this.onPressed,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchTextButton(
      label: label,
      onPressed: onPressed,
      foregroundColor: foregroundColor ?? t.primary,
    );
  }
}

/// Catch-styled [SliverAppBar] for use in [CustomScrollView.slivers].
///
/// Mirrors [CatchTopBar]'s API while behaving as a collapsible sliver header:
/// [titleWidget] scrolls away, [bottom] remains pinned, and [actions] stay
/// visible in the collapsed toolbar.
///
/// Use this instead of [CatchTopBar] when the content below should scroll
/// beneath the header.
class CatchSliverTopBar extends SliverAppBar {
  const CatchSliverTopBar({
    super.key,
    Widget? titleWidget,
    super.leading,
    List<Widget> super.actions = const [],
    super.backgroundColor,
    double expandedHeight = 56,
    super.bottom,
  }) : super(
         pinned: true,
         floating: false,
         snap: false,
         elevation: 0,
         surfaceTintColor: Colors.transparent,
         title: const SizedBox.shrink(),
         expandedHeight: expandedHeight,
         flexibleSpace: titleWidget,
       );
}

/// Toolbar title that appears only after a flexible sliver header collapses.
class CatchCollapsedSliverTitle extends StatelessWidget {
  const CatchCollapsedSliverTitle({
    super.key,
    required this.title,
    this.textKey,
    this.color,
    this.style,
  });

  static const double _fadeExtent = CatchLayout.topBarCollapsedFadeExtent;

  final String title;
  final Key? textKey;
  final Color? color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final opacity = settings == null ? 1.0 : _opacityFor(settings);

    if (opacity <= 0) return const SizedBox.shrink();

    final t = CatchTokens.of(context);

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Text(
          title,
          key: textKey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              style ?? CatchTextStyles.titleL(context, color: color ?? t.ink),
        ),
      ),
    );
  }

  static double _opacityFor(FlexibleSpaceBarSettings settings) {
    final distanceFromCollapsed = settings.currentExtent - settings.minExtent;
    if (distanceFromCollapsed <= 0) return 1.0;
    if (distanceFromCollapsed >= _fadeExtent) return 0.0;
    return 1 - (distanceFromCollapsed / _fadeExtent);
  }
}

/// A sliver header with a collapsible title and an optional pinned bottom.
///
/// Unlike [CatchSliverTopBar] (which wraps [SliverAppBar]), this builds two
/// [SliverPersistentHeader] slivers directly: the title scrolls away
/// completely ([minExtent] 0), and the bottom stays pinned. No hidden toolbar.
///
/// Use [buildSlivers] inside a [CustomScrollView.slivers] list.
class CatchSliverHeader {
  const CatchSliverHeader({
    required this.title,
    this.bottom,
    this.bottomHeight = 52,
  });

  /// Pinned search header height for one compact search field plus the
  /// vertical padding used by simple search-only headers.
  static const double compactSearchBottomHeight =
      CatchLayout.topBarCompactSearchBottomHeight;
  static const double searchControlTopPadding = CatchSpacing.s2;
  static const double contentAfterSearchGap = CatchSpacing.s3;

  final Widget title;
  final Widget? bottom;
  final double bottomHeight;

  List<Widget> buildSlivers(BuildContext context) {
    return [
      SliverToBoxAdapter(child: title),
      if (bottom != null)
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedHeaderDelegate(child: bottom!, height: bottomHeight),
        ),
    ];
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _PinnedHeaderDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: CatchTokens.of(context).bg,
    child: SizedBox.expand(child: child),
  );

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate old) =>
      child != old.child || height != old.height;
}
