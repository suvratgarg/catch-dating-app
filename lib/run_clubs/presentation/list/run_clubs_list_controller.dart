import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/presentation/shared/run_clubs_controller_utils.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_clubs_list_controller.g.dart';

@riverpod
class RunClubsListController extends _$RunClubsListController {
  static final followMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> followClub(String clubId) async {
    final uid = requireSignedInUid(ref, action: 'follow a club');
    await ref.read(runClubsRepositoryProvider).joinClub(clubId, uid);
  }
}
