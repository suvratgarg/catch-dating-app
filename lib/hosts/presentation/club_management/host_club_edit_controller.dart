import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hostClubEditControllerProvider = Provider<HostClubEditActions>(
  (ref) => HostClubEditController(ref),
);

abstract interface class HostClubEditActions {
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  });
}

class HostClubEditController implements HostClubEditActions {
  const HostClubEditController(this._ref);

  static final updateClubMutation = Mutation<void>();

  final Ref _ref;

  @override
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {
    requireSignedInUid(_ref, action: 'edit this club');
    if (patch.isEmpty) return;
    await _ref
        .read(clubsRepositoryProvider)
        .updateClub(clubId: clubId, patch: patch);
  }
}
