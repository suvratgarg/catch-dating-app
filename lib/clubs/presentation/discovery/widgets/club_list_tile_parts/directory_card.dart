part of '../club_list_tile.dart';

class ClubIndexRow extends StatelessWidget {
  const ClubIndexRow({
    super.key,
    required this.club,
    required this.isJoined,
    this.onTap,
  });

  final Club club;
  final bool isJoined;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activitySwatch = ActivityPalette.of(
      context,
    ).forKind(club.hostDefaults.primaryActivityKind);

    return Semantics(
      button: onTap != null,
      label: context.l10n.clubsDirectoryCardLabelOpenNameClub(name: club.name),
      child: CatchSurface(
        onTap: onTap,
        borderColor: t.line,
        elevation: CatchSurfaceElevation.card,
        radius: CatchRadius.md,
        padding: CatchInsets.tileContentCompact,
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(
                  CatchLayout.clubPolaroidRadius,
                ),
                border: Border.all(color: t.line),
              ),
              child: Padding(
                padding: const EdgeInsets.all(CatchSpacing.micro3),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    CatchLayout.clubPolaroidMediaRadius,
                  ),
                  child: SizedBox.square(
                    dimension: CatchSpacing.s16,
                    child: ClubImage(club: club, coverOnly: true),
                  ),
                ),
              ),
            ),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    club.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.titleS(context, color: t.ink),
                  ),
                  gapH8,
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CatchBadge.functional(
                      label: _clubIndexActivityLabel(club),
                      accentColor: activitySwatch.accent,
                    ),
                  ),
                  gapH6,
                  Text(
                    _clubIndexMetaLabel(club),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.monoLabelS(context, color: t.ink3),
                  ),
                ],
              ),
            ),
            gapW12,
            MembershipTrailingController(clubId: club.id, isJoined: isJoined),
          ],
        ),
      ),
    );
  }
}

String _clubIndexActivityLabel(Club club) {
  return club.hostDefaults.primaryActivityKind.label;
}

String _clubIndexMetaLabel(Club club) {
  final area = club.area.trim();
  final location = area.isEmpty
      ? cityLabel(club.location)
      : '$area / ${cityLabel(club.location)}';
  return '$location · ${clubMemberCountLabel(club)}'.toUpperCase();
}

class MembershipTrailingController extends ConsumerWidget {
  const MembershipTrailingController({
    super.key,
    required this.clubId,
    required this.isJoined,
  });

  final String clubId;
  final bool isJoined;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isJoined) {
      return const MembershipTrailing(
        isJoined: true,
        isPending: false,
        onJoinPressed: null,
      );
    }

    // Key by clubId so each tile observes only its own join state; an unkeyed
    // shared mutation would spin/disable every visible Join button at once.
    final mutation = ClubMembershipController.joinMutation(clubId);
    final joinMutation = ref.watch(mutation);
    void joinClub() {
      unawaited(
        mutation
            .run(ref, (transaction) async {
              await transaction
                  .get(clubMembershipControllerProvider.notifier)
                  .join(clubId);
            })
            .catchError((Object error, StackTrace stackTrace) {
              ref
                  .read(errorLoggerProvider)
                  .logError(
                    error,
                    stackTrace,
                    reason: 'MembershipTrailingController._joinClub failed',
                  );
            }),
      );
    }

    return CatchMutationErrorListener(
      mutation: mutation,
      errorContext: AppErrorContext.club,
      child: MembershipTrailing(
        isJoined: false,
        isPending: joinMutation.isPending,
        onJoinPressed: () {
          final uid = ref.read(uidProvider).asData?.value;
          if (uid == null) {
            context.go(
              Uri(
                path: Routes.authScreen.path,
                queryParameters: {'from': '/organizers/$clubId'},
              ).toString(),
            );
            return;
          }
          joinClub();
        },
      ),
    );
  }
}

class MembershipTrailing extends StatelessWidget {
  const MembershipTrailing({
    super.key,
    required this.isJoined,
    required this.isPending,
    required this.onJoinPressed,
  });

  final bool isJoined;
  final bool isPending;
  final VoidCallback? onJoinPressed;

  @override
  Widget build(BuildContext context) {
    if (isJoined) {
      return CatchBadge(
        label: context.l10n.clubsDirectoryCardLabelJoined,
        tone: CatchBadgeTone.success,
        icon: CatchIcons.joinedCheck,
      );
    }

    final t = CatchTokens.of(context);
    return CatchButton(
      label: context.l10n.clubsDirectoryCardLabelJoin,
      icon: Icon(CatchIcons.groupAddOutlined),
      onPressed: isPending ? null : onJoinPressed,
      size: CatchButtonSize.sm,
      backgroundColor: t.ink,
      foregroundColor: t.primaryInk,
    );
  }
}
