import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_icon_action.dart';
import 'package:catch_ui/src/components/catch_top_bar_tab_label.dart';
import 'package:catch_ui/src/foundations/catch_adaptive_platform.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_scaled_preferred_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CatchTopBarTabBar extends StatefulWidget
    implements CatchScaledPreferredSize {
  const CatchTopBarTabBar({super.key, required this.tabs, this.controller});

  final List<Widget> tabs;
  final TabController? controller;

  @override
  Size get preferredSize => Size.fromHeight(
    CatchIconAction.targetExtentFor(CatchLayout.topBarTabHeight),
  );

  @override
  Size preferredSizeFor(BuildContext context) {
    final style = CatchTextStyles.labelL(context);
    final lineHeight =
        MediaQuery.textScalerOf(context).scale(style.fontSize!) *
        (style.height ?? 1);
    final height = lineHeight + CatchSpacing.s4;
    return Size.fromHeight(
      height > preferredSize.height ? height : preferredSize.height,
    );
  }

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
        height: widget.preferredSizeFor(context).height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _controller!.index,
            backgroundColor: t.raised,
            thumbColor: t.surface,
            padding: EdgeInsets.zero,
            onValueChanged: (index) {
              if (index == null || index == _controller!.index) return;
              _controller!.animateTo(index);
            },
            children: {
              for (var index = 0; index < widget.tabs.length; index++)
                index: CatchTopBarTabLabel(
                  tab: widget.tabs[index],
                  selected: index == _controller!.index,
                ),
            },
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.preferredSizeFor(context).height,
      child: TabBar(
        controller: widget.controller,
        tabs: [
          for (final tab in widget.tabs)
            SizedBox(
              height: widget.preferredSizeFor(context).height,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: CatchPlatformTokens.minimumInteractiveExtent,
                ),
                child: tab,
              ),
            ),
        ],
        labelColor: t.ink,
        unselectedLabelColor: t.ink3,
        indicatorColor: t.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: CatchTextStyles.labelL(context),
        unselectedLabelStyle: CatchTextStyles.labelL(context),
      ),
    );
  }
}
