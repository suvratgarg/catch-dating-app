import 'package:catch_dating_app/host_tools/presentation/host_club_tools.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';

class HostStatsBar extends StatelessWidget {
  const HostStatsBar({super.key, required this.runs});

  final List<Run> runs;

  @override
  Widget build(BuildContext context) => HostStatsStrip(runs: runs);
}
