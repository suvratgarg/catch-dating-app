import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'club_host_management_controller.g.dart';

@riverpod
class ClubHostManagementController extends _$ClubHostManagementController {
  static final addHostMutation = Mutation<void>();
  static final removeHostMutation = Mutation<void>();
  static final transferOwnershipMutation = Mutation<void>();
  static final startConversationMutation = Mutation<String>();

  @override
  void build() {}

  Future<void> addHostByPhone({
    required String clubId,
    required String phoneNumber,
  }) async {
    requireSignedInUid(ref, action: 'add a club host');
    await ref
        .read(clubsRepositoryProvider)
        .addClubHost(clubId: clubId, phoneNumber: phoneNumber);
  }

  Future<void> removeHost({required String clubId, required String uid}) async {
    requireSignedInUid(ref, action: 'remove a club host');
    await ref
        .read(clubsRepositoryProvider)
        .removeClubHost(clubId: clubId, uid: uid);
  }

  Future<void> transferOwnership({
    required String clubId,
    required String uid,
  }) async {
    requireSignedInUid(ref, action: 'transfer club ownership');
    await ref
        .read(clubsRepositoryProvider)
        .transferClubOwnership(clubId: clubId, uid: uid);
  }

  Future<String> startConversation({
    required String clubId,
    required String hostUid,
  }) async {
    requireSignedInUid(ref, action: 'message a club host');
    return ref
        .read(clubsRepositoryProvider)
        .startClubHostConversation(clubId: clubId, hostUid: hostUid);
  }
}
