import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/widgets/catch_action_menu.dart';

/// Canonical Catch top-bar primitive.
///
/// Mirrors the design handoff's `TopBar`: page background fill, 16 px horizontal
/// padding, 40 px circular icon controls, left-aligned display title, and
/// optional right-side action slots.
class CatchTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CatchTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions = const <Widget>[],
    this.showBackButton,
    this.onBack,
    this.backgroundColor,
    this.border = false,
    this.height = 56,
    this.bottom,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget> actions;
  final bool? showBackButton;
  final VoidCallback? onBack;
  final Color? backgroundColor;
  final bool border;
  final double height;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final canPop = Navigator.maybeOf(context)?.canPop() ?? false;
    final shouldShowBack = showBackButton ?? canPop;

    final effectiveLeading =
        leading ??
        (shouldShowBack
            ? CatchTopBarIconAction(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: CatchIcons.arrowBackIosNewRounded,
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              )
            : null);

    final titleChild =
        titleWidget ??
        (title == null
            ? const SizedBox.shrink()
            : Text(
                title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.titleL(context, color: t.ink),
              ));

    return Material(
      color: backgroundColor ?? t.bg,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
              decoration: BoxDecoration(
                border: border && bottom == null
                    ? Border(bottom: BorderSide(color: t.line))
                    : const Border(),
              ),
              child: Row(
                children: [
                  if (effectiveLeading != null) ...[
                    effectiveLeading,
                    const SizedBox(width: CatchSpacing.s3),
                  ],
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: titleChild,
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(width: CatchSpacing.s2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (
                          var index = 0;
                          index < actions.length;
                          index++
                        ) ...[
                          actions[index],
                          if (index != actions.length - 1)
                            const SizedBox(width: CatchSpacing.s2),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (bottom != null)
              DecoratedBox(
                decoration: BoxDecoration(
                  border: border
                      ? Border(bottom: BorderSide(color: t.line))
                      : const Border(),
                ),
                child: bottom!,
              ),
          ],
        ),
      ),
    );
  }
}

class CatchTopBarTabBar extends StatefulWidget implements PreferredSizeWidget {
  const CatchTopBarTabBar({super.key, required this.tabs, this.controller});

  final List<Widget> tabs;
  final TabController? controller;

  @override
  Size get preferredSize => const Size.fromHeight(48);

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
            padding: const EdgeInsets.all(3),
            onValueChanged: (index) {
              if (index == null || index == _controller!.index) return;
              _controller!.animateTo(index);
            },
            children: {
              for (var index = 0; index < widget.tabs.length; index++)
                index: _CupertinoTabLabel(
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

class _CupertinoTabLabel extends StatelessWidget {
  const _CupertinoTabLabel({required this.tab, required this.selected});

  final Widget tab;
  final bool selected;

  @override
  Widget build(BuildContext context) {
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
          child: _tabChild(style),
        ),
      ),
    );
  }

  Widget _tabChild(TextStyle style) {
    final tab = this.tab;
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
}

class CatchTopBarMenuAction<T> extends StatelessWidget {
  const CatchTopBarMenuAction({
    super.key,
    required this.items,
    required this.tooltip,
    this.onSelected,
    this.enabled = true,
    IconData? icon,
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

class CatchTopBarIconAction extends StatelessWidget {
  const CatchTopBarIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.background,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Tooltip(
      message: tooltip,
      child: IconBtn(
        onTap: onPressed,
        background: backgroundColor ?? background,
        size: size ?? IconBtn.defaultSize,
        child: Icon(icon, size: CatchIcon.md, color: foregroundColor ?? t.ink),
      ),
    );
  }
}

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
  static const double compactSearchBottomHeight = 68;
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
