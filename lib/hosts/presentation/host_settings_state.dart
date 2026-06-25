import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class HostSettingsState {
  const HostSettingsState({required this.profile, required this.clubs});

  factory HostSettingsState.fromAsync({
    required String? uid,
    required AsyncValue<HostProfile?> profile,
    required AsyncValue<List<Club>> clubs,
  }) {
    return HostSettingsState(
      profile: HostSettingsProfileState.fromAsync(
        uid: uid,
        profile: profile,
        clubs: clubs,
      ),
      clubs: HostSettingsClubsState.fromAsync(clubs),
    );
  }

  final HostSettingsProfileState profile;
  final HostSettingsClubsState clubs;
}

sealed class HostSettingsProfileState {
  const HostSettingsProfileState();

  factory HostSettingsProfileState.fromAsync({
    required String? uid,
    required AsyncValue<HostProfile?> profile,
    required AsyncValue<List<Club>> clubs,
  }) {
    final loadedProfile = profile.asData?.value;
    if (loadedProfile != null) {
      return HostSettingsProfileContent(profile: loadedProfile);
    }

    final fallbackProfile = uid == null
        ? null
        : _fallbackHostProfileFromClubs(uid, clubs.asData?.value);
    if (fallbackProfile != null) {
      return HostSettingsProfileContent(
        profile: fallbackProfile,
        isFallback: true,
      );
    }

    return switch (profile) {
      AsyncError(:final error) => HostSettingsProfileError(error: error),
      AsyncLoading() => const HostSettingsProfileLoading(),
      AsyncData() => const HostSettingsProfileMissing(),
    };
  }
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

  factory HostSettingsClubsState.fromAsync(AsyncValue<List<Club>> clubs) {
    return switch (clubs) {
      AsyncError(:final error) => HostSettingsClubsError(error: error),
      AsyncData(:final value) =>
        value.isEmpty
            ? const HostSettingsClubsEmpty()
            : HostSettingsClubsContent(clubs: value),
      _ => const HostSettingsClubsLoading(),
    };
  }
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

  factory HostProfileEditState.fromAsync({
    required String? uid,
    required AsyncValue<HostProfile?> profile,
  }) {
    if (uid == null) return const HostProfileEditAuthRequired();

    return switch (profile) {
      AsyncError(:final error) => HostProfileEditError(error: error),
      AsyncData(:final value) =>
        value == null
            ? const HostProfileEditMissing()
            : HostProfileEditContent(profile: value),
      _ => const HostProfileEditLoading(),
    };
  }
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
