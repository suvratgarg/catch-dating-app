part of 'catch_top_bar.dart';

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
/// This builds two [SliverPersistentHeader] slivers directly: the title scrolls
/// away completely ([minExtent] 0), and the bottom stays pinned.
class CatchSliverHeader {
  const CatchSliverHeader({
    required this.title,
    this.bottom,
    this.bottomHeight = 52,
  });

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
