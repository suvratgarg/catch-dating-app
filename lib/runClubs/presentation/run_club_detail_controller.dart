import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/runClubs/data/run_clubs_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_club_detail_controller.g.dart';

@riverpod
class RunClubDetailController extends _$RunClubDetailController {
  static final joinMutation = Mutation<void>();
  static final leaveMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> join(String clubId) async {
    final uid = ref.read(uidProvider).asData?.value ?? '';
    await ref.read(runClubsRepositoryProvider).joinClub(clubId, uid);
  }

  Future<void> leave(String clubId) async {
    final uid = ref.read(uidProvider).asData?.value ?? '';
    await ref.read(runClubsRepositoryProvider).leaveClub(clubId, uid);
  }
}
