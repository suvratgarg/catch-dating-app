import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:flutter/material.dart';

class ClubsEmptyState extends StatelessWidget {
  const ClubsEmptyState({super.key, required String cityLabel, this.action})
    : title = 'No clubs in $cityLabel yet',
      message =
          'Try another city from the location control, or create the first '
          'club when you are ready to host.';

  const ClubsEmptyState.noSearchResults({
    super.key,
    required bool hasFilters,
    this.action,
  }) : title = 'No clubs match this search',
       message = hasFilters
           ? 'Clear the filters or try a broader club, neighborhood, host, or '
                 'tag.'
           : 'Try another club, neighborhood, host, or tag.';

  const ClubsEmptyState.noFilterResults({super.key, this.action})
    : title = 'No clubs match these filters',
      message =
          'Clear one or more filters to bring nearby clubs back into view.';

  const ClubsEmptyState.noFilteredSearchResults({super.key, this.action})
    : title = 'No clubs match this search',
      message =
          'Clear the search or filters to bring nearby clubs back into view.';

  const ClubsEmptyState.generic({
    super.key,
    this.title = 'No clubs in this city yet',
    this.message = 'Try another city or create the first club.',
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: CatchEmptyState(
          icon: Icons.groups_outlined,
          title: title,
          message: message,
          action: action,
          surface: false,
        ),
      ),
    );
  }
}
