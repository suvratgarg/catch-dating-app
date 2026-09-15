import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventSuccessReportEmptyState extends StatelessWidget {
  const EventSuccessReportEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => CatchSection.contained(
    child: CatchEmptyState(
      icon: icon,
      title: title,
      message: message,
      variant: CatchEmptyStateVariant.inline,
      padding: EdgeInsets.zero,
    ),
  );
}
