part of '../host_operations_screen.dart';

class HostLoadingScreen extends StatelessWidget {
  const HostLoadingScreen({
    super.key,
    required this.title,
    this.showTabRail = false,
  });

  final String title;
  final bool showTabRail;

  @override
  Widget build(BuildContext context) {
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) =>
          CatchTopBar(title: title, divider: scrolledUnder),
      body: CatchRouteBody.standardViewport(
        child: HostRouteLoadingBody(
          showTabRail: showTabRail,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
