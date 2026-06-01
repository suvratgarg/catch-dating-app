import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/city_catalog.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/rich_share_card_sheet.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:flutter/material.dart';

Future<void> showClubShareCardSheet(
  BuildContext context, {
  required Club club,
  required ExternalShareController share,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => RichShareCardSheet(
      card: ClubShareCard(club: club),
      share: share,
      fileName: 'catch-club-card.png',
      buttonLabel: 'Share club',
      footnote: 'Shares a visual club card with the club link.',
      subject: club.name,
      text: clubShareText(club),
    ),
  );
}

String clubShareText(Club club) {
  final uri = AppDeepLinks.club(club.id);
  return [
    'Check out ${club.name} on Catch.',
    '${club.area}, ${cityLabel(club.location)}',
    uri.toString(),
  ].join('\n');
}

class ClubShareCard extends StatelessWidget {
  const ClubShareCard({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final tags = visibleClubTags(club, limit: CatchLayout.richShareCardMaxTags);

    return AspectRatio(
      aspectRatio: CatchLayout.richShareCardAspectRatio,
      child: CatchSurface(
        backgroundColor: t.bg,
        borderColor: t.line2,
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(CatchRadius.md),
                child: _ClubShareArtwork(club: club),
              ),
            ),
            gapH14,
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CLUB ON CATCH',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.kicker(context, color: t.primary),
                  ),
                  gapH6,
                  Text(
                    club.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.clubDisplay(
                      context,
                      size: 34,
                      height: 0.96,
                      fontStyle: FontStyle.italic,
                      color: t.ink,
                    ),
                  ),
                  gapH8,
                  _ClubShareInfoRow(
                    icon: CatchIcons.locationOnOutlined,
                    label: '${club.area}, ${cityLabel(club.location)}',
                  ),
                  gapH8,
                  _ClubShareInfoRow(
                    icon: CatchIcons.group,
                    label: clubMemberCountLabel(club),
                  ),
                  if (tags.isNotEmpty) ...[gapH10, ClubTagWrap(tags: tags)],
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'CATCH',
                        style: CatchTextStyles.kicker(context, color: t.ink),
                      ),
                      const Spacer(),
                      Text(
                        'Hosted by ${club.hostName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.labelS(context, color: t.ink2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubShareArtwork extends StatelessWidget {
  const _ClubShareArtwork({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final photoUrl = club.primaryClubPhotoUrl;
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      return CatchDetailHeroBackdrop(
        imageUrl: photoUrl,
        semanticLabel: '${club.name} cover photo',
        showScrim: false,
      );
    }
    return ClubPolaroidArtwork(club: club);
  }
}

class _ClubShareInfoRow extends StatelessWidget {
  const _ClubShareInfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Icon(icon, size: CatchIcon.md, color: t.primary),
        gapW8,
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.labelM(context, color: t.ink2),
          ),
        ),
      ],
    );
  }
}
