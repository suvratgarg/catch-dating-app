import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';

final class HostSettingsState {
  const HostSettingsState({
    required this.profile,
    required this.clubs,
    required this.actions,
  });

  final HostSettingsProfileState profile;
  final HostSettingsClubsState clubs;
  final HostSettingsActionState actions;
}

final class HostSettingsActionState {
  const HostSettingsActionState({
    required this.uid,
    required this.editMode,
    required this.creatingProfile,
    required this.signOutPending,
    required this.canCreateProfile,
    required this.profileForEdit,
  });

  factory HostSettingsActionState.from({
    required String? uid,
    required bool editMode,
    required bool creatingProfile,
    required bool signOutPending,
    required HostSettingsProfileState profile,
  }) {
    return HostSettingsActionState(
      uid: uid,
      editMode: editMode,
      creatingProfile: creatingProfile,
      signOutPending: signOutPending,
      canCreateProfile:
          uid != null &&
          !creatingProfile &&
          profile is HostSettingsProfileMissing,
      profileForEdit: switch (profile) {
        HostSettingsProfileContent(:final profile) => profile,
        _ => null,
      },
    );
  }

  final String? uid;
  final bool editMode;
  final bool creatingProfile;
  final bool signOutPending;
  final bool canCreateProfile;
  final HostProfile? profileForEdit;

  bool get canSignOut => !signOutPending;
  bool get canEditProfile => editMode && uid != null && profileForEdit != null;

  HostSettingsClubNavigationState clubNavigationFor(Club club) {
    final isOwner = club.isOwnedBy(uid);
    return HostSettingsClubNavigationState(
      club: club,
      roleLabel: isOwner ? 'Owner' : 'Host team',
      destination: editMode && isOwner
          ? HostSettingsClubDestination.edit
          : HostSettingsClubDestination.preview,
    );
  }
}

enum HostSettingsClubDestination { edit, preview }

final class HostSettingsClubNavigationState {
  const HostSettingsClubNavigationState({
    required this.club,
    required this.roleLabel,
    required this.destination,
  });

  final Club club;
  final String roleLabel;
  final HostSettingsClubDestination destination;
}

sealed class HostSettingsProfileState {
  const HostSettingsProfileState();
}

final class HostSettingsProfileLoading extends HostSettingsProfileState {
  const HostSettingsProfileLoading();
}

final class HostSettingsProfileError extends HostSettingsProfileState {
  const HostSettingsProfileError({required this.error});

  final Object error;
}

final class HostSettingsProfileMissing extends HostSettingsProfileState {
  const HostSettingsProfileMissing();
}

final class HostSettingsProfileContent extends HostSettingsProfileState {
  const HostSettingsProfileContent({
    required this.profile,
    this.isFallback = false,
  });

  final HostProfile profile;
  final bool isFallback;
}

sealed class HostSettingsClubsState {
  const HostSettingsClubsState();
}

final class HostSettingsClubsLoading extends HostSettingsClubsState {
  const HostSettingsClubsLoading();
}

final class HostSettingsClubsError extends HostSettingsClubsState {
  const HostSettingsClubsError({required this.error});

  final Object error;
}

final class HostSettingsClubsEmpty extends HostSettingsClubsState {
  const HostSettingsClubsEmpty();
}

final class HostSettingsClubsContent extends HostSettingsClubsState {
  const HostSettingsClubsContent({required this.clubs});

  final List<Club> clubs;
}

sealed class HostProfileEditState {
  const HostProfileEditState();
}

final class HostProfileEditAuthRequired extends HostProfileEditState {
  const HostProfileEditAuthRequired();
}

final class HostProfileEditLoading extends HostProfileEditState {
  const HostProfileEditLoading();
}

final class HostProfileEditError extends HostProfileEditState {
  const HostProfileEditError({required this.error});

  final Object error;
}

final class HostProfileEditMissing extends HostProfileEditState {
  const HostProfileEditMissing();
}

final class HostProfileEditContent extends HostProfileEditState {
  const HostProfileEditContent({required this.profile});

  final HostProfile profile;
}
