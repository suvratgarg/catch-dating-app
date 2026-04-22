import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_clubs_list_state.freezed.dart';
part 'run_clubs_list_state.g.dart';

@freezed
abstract class RunClubsListViewModel with _$RunClubsListViewModel {
  const RunClubsListViewModel._();

  const factory RunClubsListViewModel({
    required List<RunClub> joinedClubs,
    required List<RunClub> discoverClubs,
  }) = _RunClubsListViewModel;

  bool get isEmpty => joinedClubs.isEmpty && discoverClubs.isEmpty;

  factory RunClubsListViewModel.partition({
    required List<RunClub> clubs,
    required String uid,
    required Set<String> followedClubIds,
  }) {
    final joinedClubs = <RunClub>[];
    final discoverClubs = <RunClub>[];

    for (final club in clubs) {
      if (club.hasMember(uid) || followedClubIds.contains(club.id)) {
        joinedClubs.add(club);
      } else {
        discoverClubs.add(club);
      }
    }

    return RunClubsListViewModel(
      joinedClubs: List.unmodifiable(joinedClubs),
      discoverClubs: List.unmodifiable(discoverClubs),
    );
  }
}

@Riverpod(keepAlive: true)
class SelectedRunClubCity extends _$SelectedRunClubCity {
  @override
  IndianCity build() => IndianCity.mumbai;

  void setCity(IndianCity city) {
    if (state != city) {
      state = city;
      ref.read(runClubSearchQueryProvider.notifier).clear();
    }
  }
}

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
@riverpod
AsyncValue<List<RunClub>> filteredRunClubs(Ref ref) {
  final city = ref.watch(selectedRunClubCityProvider);
  final query = ref.watch(runClubSearchQueryProvider);
  final clubsAsync = ref.watch(watchRunClubsByLocationProvider(city));

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

@riverpod
AsyncValue<RunClubsListViewModel> runClubsListViewModel(Ref ref) {
  final appUserAsync = ref.watch(appUserStreamProvider);
  final filteredAsync = ref.watch(filteredRunClubsProvider);

  if (appUserAsync.isLoading || filteredAsync.isLoading) {
    return const AsyncLoading();
  }
  if (appUserAsync.hasError) {
    return AsyncError(
      appUserAsync.error!,
      appUserAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (filteredAsync.hasError) {
    return AsyncError(
      filteredAsync.error!,
      filteredAsync.stackTrace ?? StackTrace.current,
    );
  }

  final appUser = appUserAsync.asData?.value;
  final uid = appUser?.uid ?? '';
  final followedClubIds = appUser?.followedRunClubIds.toSet() ?? <String>{};
  final clubs = filteredAsync.asData?.value ?? const <RunClub>[];

  return AsyncData(
    RunClubsListViewModel.partition(
      clubs: clubs,
      uid: uid,
      followedClubIds: followedClubIds,
    ),
  );
}

bool matchesRunClubSearchQuery(RunClub club, String normalizedQuery) {
  return club.name.toLowerCase().contains(normalizedQuery) ||
      club.area.toLowerCase().contains(normalizedQuery) ||
      club.hostName.toLowerCase().contains(normalizedQuery) ||
      club.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
}
