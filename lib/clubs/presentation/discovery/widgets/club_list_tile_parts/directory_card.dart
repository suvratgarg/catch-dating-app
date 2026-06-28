part of '../club_list_tile.dart';

Widget _buildDirectoryCard(
  BuildContext context, {
  required Club club,
  required bool isJoined,
  VoidCallback? onTap,
}) {
  final sash = _membershipSashFor(isJoined: isJoined);
  final hasCoverImage = _hasCoverImage(club);

  return Semantics(
    button: onTap != null,
    label: 'Open ${club.name} club',
    child: hasCoverImage
        ? _buildDirectoryPhotoCard(
            context,
            club: club,
            isJoined: isJoined,
            sash: sash,
            onTap: onTap,
          )
        : _buildDirectoryIdentityCard(
            context,
            club: club,
            isJoined: isJoined,
            sash: sash,
            onTap: onTap,
          ),
  );
}

Widget _buildDirectoryPhotoCard(
  BuildContext context, {
  required Club club,
  required bool isJoined,
  required _MembershipSash? sash,
  VoidCallback? onTap,
}) {
  final t = CatchTokens.of(context);
  final palette = ClubCoverVisualPalette.forClub(context, club);
  final visibleTags = _visibleTags(club);

  return CatchPolaroid(
    onTap: onTap,
    media: _buildClubPhotoMediaOverlay(club: club),
    mediaOverlay: _buildClubPhotoChrome(
      club: club,
      sash: sash,
      palette: palette,
    ),
    caption: _directoryCaption(club),
    captionColor: t.ink3,
    title: club.name,
    subtitle: club.description,
    showArrow: false,
    footer: _buildClubDirectoryFooter(
      context,
      club: club,
      isJoined: isJoined,
      visibleTags: visibleTags,
    ),
  );
}

Widget _buildDirectoryIdentityCard(
  BuildContext context, {
  required Club club,
  required bool isJoined,
  required _MembershipSash? sash,
  VoidCallback? onTap,
}) {
  final t = CatchTokens.of(context);
  final palette = ClubCoverVisualPalette.forClub(context, club);
  final visibleTags = _visibleTags(club);

  return CatchPolaroid(
    onTap: onTap,
    media: ClubPolaroidArtwork(club: club),
    mediaOverlay: _buildClubPhotoChrome(
      club: club,
      sash: sash,
      palette: palette,
    ),
    caption: _directoryCaption(club),
    captionColor: t.ink3,
    title: club.name,
    titleMaxLines: 2,
    subtitle: club.description,
    showArrow: false,
    footer: _buildClubDirectoryFooter(
      context,
      club: club,
      isJoined: isJoined,
      visibleTags: visibleTags,
    ),
  );
}

Widget _buildClubPhotoMediaOverlay({required Club club}) {
  return _buildClubImage(club: club, coverOnly: true, fallbackCompact: false);
}

Widget _buildClubPhotoChrome({
  required Club club,
  required _MembershipSash? sash,
  required ClubCoverVisualPalette palette,
}) {
  return Stack(
    fit: StackFit.expand,
    children: [
      _buildClubPhotoScrim(),
      Positioned(
        top: CatchSpacing.s3,
        left: CatchSpacing.s3,
        child: _buildClubLogoCrest(
          club: club,
          palette: palette,
          size: 38,
          borderColor: CatchTokens.editorialLight,
          borderWidth: 2,
        ),
      ),
      if (sash != null)
        Positioned(
          left: 0,
          bottom: 0,
          child: CatchCornerSash(
            label: sash.label,
            icon: sash.icon,
            tone: sash.tone,
          ),
        ),
      Positioned(
        top: CatchSpacing.s3,
        right: CatchSpacing.s3,
        child: ClubMemberSeal(
          label: clubMemberCountLabel(club),
          accent: palette.accent,
          compact: true,
        ),
      ),
    ],
  );
}

Widget _buildClubPhotoScrim() {
  return IgnorePointer(
    child: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.48, 1.0],
          colors: [
            CatchTokens.editorialDark.withValues(
              alpha: CatchOpacity.photoScrimLight,
            ),
            Colors.transparent,
            CatchTokens.editorialDark.withValues(
              alpha: CatchOpacity.eventSuccessSubtleBorder,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildClubLogoCrest({
  required Club club,
  required ClubCoverVisualPalette palette,
  required double size,
  required Color borderColor,
  required double borderWidth,
}) {
  final logoUrl = club.profileImageUrl?.trim();
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: palette.accent,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: CatchElevation.card,
    ),
    child: ClipOval(
      child: logoUrl != null && logoUrl.isNotEmpty
          ? CatchNetworkImage(
              logoUrl,
              errorBuilder: (_, _, _) => _buildClubLogoFallback(),
            )
          : _buildClubLogoFallback(),
    ),
  );
}

Widget _buildClubLogoFallback() {
  return const SizedBox.expand();
}

Widget _buildClubDirectoryFooter(
  BuildContext context, {
  required Club club,
  required bool isJoined,
  required List<String> visibleTags,
}) {
  final t = CatchTokens.of(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (club.rating > 0) ...[
        Align(
          alignment: Alignment.centerLeft,
          child: ClubRatingPill(rating: club.rating),
        ),
        gapH10,
      ],
      _buildClubHostActionRow(club: club, isJoined: isJoined),
      if (visibleTags.isNotEmpty) ...[
        gapH10,
        _buildClubRule(color: t.line),
        gapH10,
        ClubTagWrap(tags: visibleTags.take(3).toList(growable: false)),
      ],
    ],
  );
}

Widget _buildClubRule({required Color color}) {
  return SizedBox(
    height: 1,
    child: DecoratedBox(decoration: BoxDecoration(color: color)),
  );
}

Widget _buildClubHostActionRow({required Club club, required bool isJoined}) {
  return ClubHostIdentityLine(
    hostName: club.displayHostName,
    hostAvatarUrl: club.hostAvatarUrl,
    trailing: _membershipTrailing(clubId: club.id, isJoined: isJoined),
  );
}

bool _hasCoverImage(Club club) {
  return club.imageUrl?.trim().isNotEmpty ?? false;
}

String _directoryCaption(Club club) {
  final nextEventLabel = club.nextEventLabel?.trim();
  if (nextEventLabel != null && nextEventLabel.isNotEmpty) {
    return nextEventLabel.toUpperCase();
  }
  return '${club.area} / ${cityLabel(club.location)}'.toUpperCase();
}

_MembershipSash? _membershipSashFor({required bool isJoined}) {
  if (isJoined) {
    return _MembershipSash(
      label: 'Joined',
      icon: CatchIcons.joinedCheck,
      tone: CatchSashTone.success,
    );
  }
  return null;
}

class _MembershipSash {
  const _MembershipSash({
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final CatchSashTone tone;
}

List<String> _visibleTags(Club club) {
  return visibleClubTags(club);
}

Widget _membershipTrailing({required String clubId, required bool isJoined}) {
  if (isJoined) {
    // Membership state is communicated via the corner sash on the photo now; no
    // redundant button needed.
    return const SizedBox.shrink();
  }
  return Consumer(
    builder: (context, ref, _) {
      final t = CatchTokens.of(context);
      // Key by clubId so each tile observes only its own join state; an unkeyed
      // shared mutation would spin/disable every visible Join button at once.
      final joinMutation = ref.watch(
        ClubMembershipController.joinMutation(clubId),
      );

      return CatchButton(
        label: 'Join',
        icon: Icon(CatchIcons.groupAddOutlined),
        onPressed: joinMutation.isPending
            ? null
            : () {
                final uid = ref.read(uidProvider).asData?.value;
                if (uid == null) {
                  context.go(
                    Uri(
                      path: Routes.authScreen.path,
                      queryParameters: {'from': '/clubs/$clubId'},
                    ).toString(),
                  );
                  return;
                }
                _joinClub(ref, clubId);
              },
        size: CatchButtonSize.sm,
        backgroundColor: t.ink,
        foregroundColor: t.primaryInk,
      );
    },
  );
}

void _joinClub(WidgetRef ref, String clubId) {
  ClubMembershipController.joinMutation(clubId).run(ref, (transaction) async {
    await transaction
        .get(clubMembershipControllerProvider.notifier)
        .join(clubId);
  });
}
