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
    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      appBar: CatchTopBar(title: title, border: true),
      body: SafeArea(child: HostRouteLoadingBody(showTabRail: showTabRail)),
    );
  }
}
