import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClubPostsHomeSection extends ConsumerWidget {
  const ClubPostsHomeSection({
    super.key,
    required this.notifications,
    required this.onOpenPost,
  });

  final List<ActivityNotification> notifications;
  final ValueChanged<ActivityNotification> onOpenPost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (notifications.isEmpty) return const SizedBox.shrink();

    final clubIds = notifications
        .map((notification) => notification.clubId)
        .whereType<String>()
        .toSet()
        .toList(growable: false);
    final clubsAsync = ref.watch(
      watchClubsByIdsProvider(ClubsByIdQuery(clubIds)),
    );
    final clubsById = {
      for (final club in clubsAsync.asData?.value ?? const <Club>[])
        club.id: club,
    };

    return CatchSection.fieldRows(
      title: context.l10n.dashboardClubPostsHomeSectionTitleClubUpdates,
      children: [
        for (final entry in notifications.indexed)
          ClubPostHomeCard(
            notification: entry.$2,
            club: entry.$2.clubId == null ? null : clubsById[entry.$2.clubId],
            onTap: () => onOpenPost(entry.$2),
          ),
      ],
    );
  }
}

class ClubPostHomeCard extends StatelessWidget {
  const ClubPostHomeCard({
    super.key,
    required this.notification,
    required this.club,
    required this.onTap,
  });

  final ActivityNotification notification;
  final Club? club;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final clubName = club?.name ?? notification.actorName ?? notification.title;
    final hasEventLink = notification.eventId != null;

    return CatchSurface(
      padding: CatchInsets.contentVerticalMedium,
      borderWidth: 0,
      backgroundColor: Colors.transparent,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchPersonAvatar(
            size: CatchLayout.avatarRowExtent,
            name: clubName,
            imageUrl: club?.logoPhotoUrl,
            shape: CatchPersonAvatarShape.square,
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.monoLabelS(context, color: t.ink3),
                ),
                gapH4,
                Text(
                  notification.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.fieldRowTitle(context),
                ),
                if (hasEventLink) ...[
                  gapH8,
                  Row(
                    children: [
                      Icon(
                        CatchIcons.eventOutlined,
                        size: CatchIcon.sm,
                        color: t.ink2,
                      ),
                      gapW6,
                      Expanded(
                        child: Text(
                          context
                              .l10n
                              .dashboardClubPostsHomeSectionTextLinkedEvent,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.supporting(
                            context,
                            color: t.ink2,
                          ),
                        ),
                      ),
                      Icon(
                        CatchIcons.chevronRightRounded,
                        size: CatchIcon.sm,
                        color: t.ink3,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
