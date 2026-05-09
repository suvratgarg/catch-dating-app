import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/domain/city_data.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_membership.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_clubs_list_view_model.freezed.dart';
part 'run_clubs_list_view_model.g.dart';

@freezed
abstract class RunClubsListViewModel with _$RunClubsListViewModel {
  const RunClubsListViewModel._();

  const factory RunClubsListViewModel({
    required List<RunClub> joinedClubs,
    required List<RunClub> allClubs,
    @Default({}) Set<String> joinedClubIds,
  }) = _RunClubsListViewModel;

  bool get isEmpty => allClubs.isEmpty;

  factory RunClubsListViewModel.partition({
    required List<RunClub> clubs,
    required Set<String> joinedClubIds,
  }) {
    final joinedClubs = <RunClub>[];

    for (final club in clubs) {
      if (joinedClubIds.contains(club.id)) {
        joinedClubs.add(club);
      }
    }

    return RunClubsListViewModel(
      joinedClubs: List.unmodifiable(joinedClubs),
      allClubs: List.unmodifiable(clubs),
      joinedClubIds: joinedClubs.map((c) => c.id).toSet(),
    );
  }
}

/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for run club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.
@Riverpod(keepAlive: true)
class SelectedRunClubCity extends _$SelectedRunClubCity {
  bool _userSelected = false;

  @override
  CityData build() => _mumbaiDefault;

  void setCity(CityData city) {
    _userSelected = true;
    if (state != city) {
      state = city;
      ref.read(runClubSearchQueryProvider.notifier).clear();
    }
  }

  void autoSelectCity(CityData city) {
    if (_userSelected) return;
    if (state != city) {
      state = city;
      ref.read(runClubSearchQueryProvider.notifier).clear();
    }
  }
}

final _mumbaiDefault = CityData(
  name: 'mumbai',
  label: 'Mumbai',
  latitude: 19.0760,
  longitude: 72.8777,
);

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.
@Riverpod(keepAlive: true)
class RunClubSearchQuery extends _$RunClubSearchQuery {
  @override
  String build() => '';

  void setQuery(String query) {
    final normalizedQuery = query.trimLeft();
    if (state != normalizedQuery) {
      state = normalizedQuery;
    }
  }

  void clear() => state = '';
}

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.
///
/// **Pattern D variant:** Combines location-filtered clubs with client-side
/// search to produce a filtered list for the UI.
@riverpod
AsyncValue<List<RunClub>> filteredRunClubs(Ref ref) {
  final city = ref.watch(selectedRunClubCityProvider);
  final query = ref.watch(runClubSearchQueryProvider);
  final clubsAsync = ref.watch(
    watchRunClubsByLocationProvider(
      IndianCity.fromName(city.name) ?? IndianCity.mumbai,
    ),
  );

  return clubsAsync.whenData((clubs) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return clubs;
    }

    return clubs
        .where((club) => matchesRunClubSearchQuery(club, normalizedQuery))
        .toList(growable: false);
  });
}

/// **Pattern D: View-model provider**
///
/// Combines the signed-in user, membership edges, and filtered club streams into
/// a
/// [RunClubsListViewModel] that partitions clubs into joined and discover
/// lists for the UI.
@riverpod
AsyncValue<RunClubsListViewModel> runClubsListViewModel(Ref ref) {
  final uidAsync = ref.watch(uidProvider);
  final filteredAsync = ref.watch(filteredRunClubsProvider);

  if (uidAsync.isLoading || filteredAsync.isLoading) {
    return const AsyncLoading();
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (filteredAsync.hasError) {
    return AsyncError(
      filteredAsync.error!,
      filteredAsync.stackTrace ?? StackTrace.current,
    );
  }

  final uid = uidAsync.asData?.value;
  final membershipsAsync = uid == null
      ? const AsyncData<List<RunClubMembership>>([])
      : ref.watch(watchActiveRunClubMembershipsForUserProvider(uid));

  if (membershipsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (membershipsAsync.hasError) {
    return AsyncError(
      membershipsAsync.error!,
      membershipsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final membershipClubIds =
      membershipsAsync.asData?.value
          .map((membership) => membership.clubId)
          .toSet() ??
      <String>{};
  final clubs = filteredAsync.asData?.value ?? const <RunClub>[];
  final hostedClubIds = uid == null
      ? <String>{}
      : clubs
            .where((club) => club.hostUserId == uid)
            .map((club) => club.id)
            .toSet();
  final joinedClubIds = {...membershipClubIds, ...hostedClubIds};

  return AsyncData(
    RunClubsListViewModel.partition(clubs: clubs, joinedClubIds: joinedClubIds),
  );
}

/// **Pattern D: View-model provider**
///
/// Derives the create-club affordance from the server-owned hosted-club query.
/// The callable enforces the one-club invariant; this provider keeps the list
/// UI from offering a creation path after a host already has a club.
@riverpod
AsyncValue<bool> canCreateRunClub(Ref ref) {
  final uidAsync = ref.watch(uidProvider);
  if (uidAsync.isLoading) {
    return const AsyncLoading();
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }

  final uid = uidAsync.asData?.value;
  if (uid == null) {
    return const AsyncData(false);
  }

  final hostedAsync = ref.watch(watchRunClubsHostedByProvider(uid));
  return hostedAsync.whenData((clubs) => clubs.isEmpty);
}

bool matchesRunClubSearchQuery(RunClub club, String normalizedQuery) {
  return club.name.toLowerCase().contains(normalizedQuery) ||
      club.area.toLowerCase().contains(normalizedQuery) ||
      club.hostName.toLowerCase().contains(normalizedQuery) ||
      club.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
}
