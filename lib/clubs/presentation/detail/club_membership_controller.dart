import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'club_membership_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns membership actions from both the club list and detail screens.
/// The UI watches mutation state to show loading spinners and error banners.
@riverpod
class ClubMembershipController extends _$ClubMembershipController {
  static final joinMutation = Mutation<void>();
  static final leaveMutation = Mutation<void>();
  static final pushNotificationsMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> join(String clubId) async {
    requireSignedInUid(ref, action: 'join a club');
    await ref.read(clubsRepositoryProvider).joinClub(clubId);
  }

  Future<void> leave(String clubId) async {
    requireSignedInUid(ref, action: 'leave a club');
    await ref.read(clubsRepositoryProvider).leaveClub(clubId);
  }

  Future<void> setPushNotifications({
    required String clubId,
    required bool enabled,
  }) async {
    requireSignedInUid(ref, action: 'update club notifications');
    await ref
        .read(clubsRepositoryProvider)
        .setClubPushNotifications(clubId: clubId, enabled: enabled);
  }
}
