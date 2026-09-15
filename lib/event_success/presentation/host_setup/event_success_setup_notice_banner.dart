import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventSuccessSetupNoticeBanner extends StatelessWidget {
  const EventSuccessSetupNoticeBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return CatchBanner(title: title, message: body, icon: icon);
  }
}
