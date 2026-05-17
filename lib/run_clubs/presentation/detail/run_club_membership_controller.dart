import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_club_membership_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns membership actions from both the run-club list and detail screens.
/// The UI watches mutation state to show loading spinners and error banners.
@riverpod
class RunClubMembershipController extends _$RunClubMembershipController {
  static final joinMutation = Mutation<void>();
  static final leaveMutation = Mutation<void>();
  static final pushNotificationsMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> join(String clubId) async {
    requireSignedInUid(ref, action: 'join a club');
    await ref.read(runClubsRepositoryProvider).joinClub(clubId);
  }

  Future<void> leave(String clubId) async {
    requireSignedInUid(ref, action: 'leave a club');
    await ref.read(runClubsRepositoryProvider).leaveClub(clubId);
  }

  Future<void> setPushNotifications({
    required String clubId,
    required bool enabled,
  }) async {
    requireSignedInUid(ref, action: 'update club notifications');
    await ref
        .read(runClubsRepositoryProvider)
        .setClubPushNotifications(clubId: clubId, enabled: enabled);
  }
}
