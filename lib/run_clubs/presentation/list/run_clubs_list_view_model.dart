import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
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
    required String uid,
    required Set<String> joinedClubIds,
  }) {
    final joinedClubs = <RunClub>[];

    for (final club in clubs) {
      if (club.hasMember(uid) || joinedClubIds.contains(club.id)) {
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

@Riverpod(keepAlive: true)
class SelectedRunClubCity extends _$SelectedRunClubCity {
  bool _userSelected = false;

  @override
  IndianCity build() => IndianCity.mumbai;

  void setCity(IndianCity city) {
    _userSelected = true;
    if (state != city) {
      state = city;
      ref.read(runClubSearchQueryProvider.notifier).clear();
    }
  }

  void autoSelectCity(IndianCity city) {
    if (_userSelected) return;
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
  final userProfileAsync = ref.watch(userProfileStreamProvider);
  final filteredAsync = ref.watch(filteredRunClubsProvider);

  if (userProfileAsync.isLoading || filteredAsync.isLoading) {
    return const AsyncLoading();
  }
  if (userProfileAsync.hasError) {
    return AsyncError(
      userProfileAsync.error!,
      userProfileAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (filteredAsync.hasError) {
    return AsyncError(
      filteredAsync.error!,
      filteredAsync.stackTrace ?? StackTrace.current,
    );
  }

  final userProfile = userProfileAsync.asData?.value;
  final uid = userProfile?.uid ?? '';
  final joinedClubIds = userProfile?.joinedRunClubIds.toSet() ?? <String>{};
  final clubs = filteredAsync.asData?.value ?? const <RunClub>[];

  return AsyncData(
    RunClubsListViewModel.partition(
      clubs: clubs,
      uid: uid,
      joinedClubIds: joinedClubIds,
    ),
  );
}

bool matchesRunClubSearchQuery(RunClub club, String normalizedQuery) {
  return club.name.toLowerCase().contains(normalizedQuery) ||
      club.area.toLowerCase().contains(normalizedQuery) ||
      club.hostName.toLowerCase().contains(normalizedQuery) ||
      club.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));
}
