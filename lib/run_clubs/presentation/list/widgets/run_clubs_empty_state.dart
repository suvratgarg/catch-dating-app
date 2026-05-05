import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:flutter/material.dart';

class RunClubsEmptyState extends StatelessWidget {
  const RunClubsEmptyState({
    super.key,
    this.title = 'No run clubs in this city yet',
    this.message = 'Be the first to create one!',
  });

  const RunClubsEmptyState.noSearchResults({super.key})
    : title = 'No clubs match your search',
      message = 'Try another club, neighborhood, host, or tag.';

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: CatchEmptyState(
          icon: Icons.groups_outlined,
          title: title,
          message: message,
          surface: false,
        ),
      ),
    );
  }
}
