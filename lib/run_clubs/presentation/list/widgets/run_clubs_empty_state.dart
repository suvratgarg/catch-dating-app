import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:flutter/material.dart';

class RunClubsEmptyState extends StatelessWidget {
  const RunClubsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: CatchEmptyState(
          icon: Icons.groups_outlined,
          title: 'No run clubs in this city yet',
          message: 'Be the first to create one!',
          surface: false,
        ),
      ),
    );
  }
}
