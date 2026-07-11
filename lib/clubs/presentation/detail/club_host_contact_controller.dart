import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'club_host_contact_controller.g.dart';

@riverpod
class ClubHostContactController extends _$ClubHostContactController {
  static final startConversationMutation = Mutation<String>();

  @override
  void build() {}

  Future<String> startConversation({
    required String clubId,
    required String hostUid,
    String? eventId,
  }) async {
    requireSignedInUid(ref, action: 'message a club host');
    return ref
        .read(clubsRepositoryProvider)
        .startClubHostConversation(
          clubId: clubId,
          hostUid: hostUid,
          eventId: eventId,
        );
  }
}
