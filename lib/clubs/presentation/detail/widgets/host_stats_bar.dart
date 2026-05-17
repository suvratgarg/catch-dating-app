import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/host_tools/presentation/host_club_tools.dart';
import 'package:flutter/material.dart';

class HostStatsBar extends StatelessWidget {
  const HostStatsBar({super.key, required this.events});

  final List<Event> events;

  @override
  Widget build(BuildContext context) => HostStatsStrip(events: events);
}
