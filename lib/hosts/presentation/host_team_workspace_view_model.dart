import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/hosts/presentation/host_team_workspace_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

HostTeamWorkspaceState buildHostTeamWorkspaceState({
  required String? uid,
  required AsyncValue<HostProfile?> profile,
  required AsyncValue<List<Club>> clubs,
  bool editMode = true,
  bool creatingProfile = false,
  bool signOutPending = false,
}) {
  final profileState = buildHostTeamProfileState(
    uid: uid,
    profile: profile,
    clubs: clubs,
  );
  return HostTeamWorkspaceState(
    profile: profileState,
    clubs: buildHostTeamHostedClubsState(clubs),
    actions: HostTeamWorkspaceActionState.from(
      uid: uid,
      editMode: editMode,
      creatingProfile: creatingProfile,
      signOutPending: signOutPending,
      profile: profileState,
    ),
  );
}

HostTeamProfileState buildHostTeamProfileState({
  required String? uid,
  required AsyncValue<HostProfile?> profile,
  required AsyncValue<List<Club>> clubs,
}) {
  final loadedProfile = profile.asData?.value;
  if (loadedProfile != null) {
    return HostTeamProfileContent(profile: loadedProfile);
  }

  final fallbackProfile = uid == null
      ? null
      : _fallbackHostProfileFromClubs(uid, clubs.asData?.value);
  if (fallbackProfile != null) {
    return HostTeamProfileContent(profile: fallbackProfile, isFallback: true);
  }

  return switch (profile) {
    AsyncError(:final error) => HostTeamProfileError(error: error),
    AsyncLoading() => const HostTeamProfileLoading(),
    AsyncData() => const HostTeamProfileMissing(),
  };
}

HostTeamHostedClubsState buildHostTeamHostedClubsState(
  AsyncValue<List<Club>> clubs,
) {
  return switch (clubs) {
    AsyncError(:final error) => HostTeamHostedClubsError(error: error),
    AsyncData(:final value) =>
      value.isEmpty
          ? const HostTeamHostedClubsEmpty()
          : HostTeamHostedClubsContent(clubs: value),
    _ => const HostTeamHostedClubsLoading(),
  };
}

HostProfile? _fallbackHostProfileFromClubs(String uid, List<Club>? clubs) {
  if (clubs == null || clubs.isEmpty) return null;
  final hostedClubs = clubs.where((club) => club.isHostedBy(uid)).toList();
  if (hostedClubs.isEmpty) return null;
  final firstClub = hostedClubs.first;
  ClubHostProfile? clubHostProfile;
  for (final club in hostedClubs) {
    for (final profile in club.displayHostProfiles) {
      if (profile.uid == uid) {
        clubHostProfile = profile;
        break;
      }
    }
    if (clubHostProfile != null) break;
  }

  final displayName = _firstNonBlank([
    clubHostProfile?.displayName,
    firstClub.hostName,
    firstClub.displayHostName,
    'Catch Host',
  ]);
  final avatarUrl = _firstNonBlank([
    clubHostProfile?.avatarUrl,
    firstClub.hostAvatarUrl,
  ]);
  final ownsAnyClub = hostedClubs.any((club) => club.isOwnedBy(uid));

  return HostProfile(
    uid: uid,
    displayName: displayName,
    avatarUrl: avatarUrl,
    roleTitle: ownsAnyClub ? 'Owner' : 'Host team',
    status: HostProfileStatus.active,
    linkedClubIds: [for (final club in hostedClubs) club.id],
    createdAt: null,
    updatedAt: null,
  );
}

String _firstNonBlank(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return 'Catch Host';
}
