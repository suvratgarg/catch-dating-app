import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunClubNameLookupQuery {
  RunClubNameLookupQuery(Iterable<String> runClubIds)
    : runClubIds = List.unmodifiable((runClubIds.toSet().toList()..sort()));

  final List<String> runClubIds;

  @override
  bool operator ==(Object other) {
    return other is RunClubNameLookupQuery &&
        listEquals(other.runClubIds, runClubIds);
  }

  @override
  int get hashCode => Object.hashAll(runClubIds);
}

final runClubNameLookupProvider =
    FutureProvider.family<Map<String, String>, RunClubNameLookupQuery>((
      ref,
      query,
    ) async {
      if (query.runClubIds.isEmpty) return const <String, String>{};

      final repository = ref.watch(runClubsRepositoryProvider);
      final clubs = await Future.wait(
        query.runClubIds.map(repository.fetchRunClub),
      );

      return {
        for (final club in clubs)
          if (club != null) club.id: club.name,
      };
    });
