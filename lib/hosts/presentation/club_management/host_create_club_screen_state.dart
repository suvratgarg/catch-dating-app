import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:flutter/foundation.dart';

enum HostClubEditMode { loadingIdentity, ownerFull, cohostMediaOnly, forbidden }

@immutable
class HostClubEditState {
  const HostClubEditState({
    required this.mode,
    required this.club,
    required this.uid,
  });

  factory HostClubEditState.resolve({
    required Club club,
    required bool uidLoading,
    required String? uid,
  }) {
    if (uidLoading) {
      return HostClubEditState(
        mode: HostClubEditMode.loadingIdentity,
        club: club,
        uid: null,
      );
    }

    if (uid != null && club.isOwnedBy(uid)) {
      return HostClubEditState(
        mode: HostClubEditMode.ownerFull,
        club: club,
        uid: uid,
      );
    }
    if (uid != null && club.isHostedBy(uid)) {
      return HostClubEditState(
        mode: HostClubEditMode.cohostMediaOnly,
        club: club,
        uid: uid,
      );
    }
    return HostClubEditState(
      mode: HostClubEditMode.forbidden,
      club: club,
      uid: uid,
    );
  }

  final HostClubEditMode mode;
  final Club club;
  final String? uid;

  bool get canEdit =>
      mode == HostClubEditMode.ownerFull ||
      mode == HostClubEditMode.cohostMediaOnly;

  bool get mediaOnly => mode == HostClubEditMode.cohostMediaOnly;
}
