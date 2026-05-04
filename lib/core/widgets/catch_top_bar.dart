import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';

/// Canonical Catch top-bar primitive.
///
/// Mirrors the design handoff's `TopBar`: surface fill, 16 px horizontal
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
                icon: Icons.arrow_back_ios_new_rounded,
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
      color: backgroundColor ?? t.surface,
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

class CatchTopBarTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CatchTopBarTabBar({super.key, required this.tabs});

  final List<Widget> tabs;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return TabBar(
      tabs: tabs,
      labelColor: t.ink,
      unselectedLabelColor: t.ink3,
      indicatorColor: t.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: CatchTextStyles.labelL(context),
      unselectedLabelStyle: CatchTextStyles.labelL(context),
    );
  }
}

class CatchTopBarMenuAction<T> extends StatelessWidget {
  const CatchTopBarMenuAction({
    super.key,
    required this.itemBuilder,
    required this.tooltip,
    this.onSelected,
    this.enabled = true,
    this.icon = Icons.more_horiz_rounded,
  });

  final PopupMenuItemBuilder<T> itemBuilder;
  final PopupMenuItemSelected<T>? onSelected;
  final String tooltip;
  final bool enabled;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return PopupMenuButton<T>(
      enabled: enabled,
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: itemBuilder,
      position: PopupMenuPosition.under,
      child: IconBtn(
        child: Icon(icon, size: CatchIcon.md, color: t.ink),
      ),
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
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Tooltip(
      message: tooltip,
      child: IconBtn(
        onTap: onPressed,
        background: backgroundColor ?? background,
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

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor ?? t.primary,
        disabledForegroundColor: foregroundColor ?? t.ink3,
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s2),
        textStyle: CatchTextStyles.labelL(context),
      ),
      child: Text(label),
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
    this.titleHeight = 80,
    this.bottomHeight = 52,
  });

  final Widget title;
  final Widget? bottom;
  final double titleHeight;
  final double bottomHeight;

  List<Widget> buildSlivers(BuildContext context) {
    return [
      SliverPersistentHeader(
        pinned: false,
        delegate: _CollapsibleHeaderDelegate(
          child: title,
          height: titleHeight,
        ),
      ),
      if (bottom != null)
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedHeaderDelegate(
            child: bottom!,
            height: bottomHeight,
          ),
        ),
    ];
  }
}

class _CollapsibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _CollapsibleHeaderDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(covariant _CollapsibleHeaderDelegate old) =>
      child != old.child || height != old.height;
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
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate old) =>
      child != old.child || height != old.height;
}
