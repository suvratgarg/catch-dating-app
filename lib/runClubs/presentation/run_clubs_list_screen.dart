import 'package:catch_dating_app/commonWidgets/enum_dropdown.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runClubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/runClubs/presentation/run_club_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum _SortOrder { newest, topRated }

class RunClubsListScreen extends ConsumerStatefulWidget {
  const RunClubsListScreen({super.key});

  @override
  ConsumerState<RunClubsListScreen> createState() => _RunClubsListScreenState();
}

class _RunClubsListScreenState extends ConsumerState<RunClubsListScreen> {
  IndianCity _selectedCity = IndianCity.mumbai;
  _SortOrder _sortOrder = _SortOrder.newest;

  @override
  Widget build(BuildContext context) {
    final runClubsAsync = _sortOrder == _SortOrder.newest
        ? ref.watch(watchRunClubsByLocationProvider(_selectedCity))
        : ref.watch(
            watchRunClubsByLocationSortedByRatingProvider(_selectedCity));

    return Scaffold(
      appBar: AppBar(
        title: EnumDropdown<IndianCity>(
          values: IndianCity.values,
          value: _selectedCity,
          onChanged: (city) => setState(() => _selectedCity = city),
        ),
        actions: [
          IconButton(
            tooltip: _sortOrder == _SortOrder.newest ? 'Sort: Newest' : 'Sort: Top Rated',
            icon: Icon(
              _sortOrder == _SortOrder.newest
                  ? Icons.schedule_outlined
                  : Icons.star_outline_rounded,
            ),
            onPressed: () => setState(() {
              _sortOrder = _sortOrder == _SortOrder.newest
                  ? _SortOrder.topRated
                  : _SortOrder.newest;
            }),
          ),
          IconButton(
            tooltip: 'Create run club',
            icon: const Icon(Icons.add),
            onPressed: () => context.pushNamed(Routes.createRunClubScreen.name),
          ),
        ],
      ),
      body: runClubsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (runClubs) => runClubs.isEmpty
            ? const Center(child: Text('No run clubs yet'))
            : ListView.builder(
                itemCount: runClubs.length,
                itemBuilder: (context, index) =>
                    RunClubListTile(runClub: runClubs[index]),
              ),
      ),
    );
  }
}
