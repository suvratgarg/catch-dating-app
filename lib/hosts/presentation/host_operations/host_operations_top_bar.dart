part of '../host_operations_screen.dart';

class HostOperationsTopBar extends StatelessWidget
    implements PreferredSizeWidget {
  const HostOperationsTopBar({
    super.key,
    required this.kicker,
    required this.title,
    this.actions = const [],
    this.bottom,
  });

  final String kicker;
  final String title;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
    CatchLayout.topBarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final compactTextScale = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    return CatchTopBar(
      border: true,
      actions: actions,
      bottom: bottom,
      titleWidget: compactTextScale
          ? Text(
              title,
              semanticsLabel: '$kicker. $title',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.titleL(context, color: t.ink),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kicker,
                  style: CatchTextStyles.kicker(context, color: t.ink3),
                ),
                gapH2,
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.titleL(context, color: t.ink),
                ),
              ],
            ),
    );
  }
}
