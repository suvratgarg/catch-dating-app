import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_club_membership_controller.g.dart';

@riverpod
class RunClubMembershipController extends _$RunClubMembershipController {
  static final joinMutation = Mutation<void>();
  static final leaveMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> join(String clubId) async {
    final uid = requireSignedInUid(ref, action: 'join a club');
    await ref.read(runClubsRepositoryProvider).joinClub(clubId, uid);
  }

  Future<void> leave(String clubId) async {
    final uid = requireSignedInUid(ref, action: 'leave a club');
    await ref.read(runClubsRepositoryProvider).leaveClub(clubId, uid);
  }
}
