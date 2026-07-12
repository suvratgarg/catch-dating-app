import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class ClubPhotoStrip extends StatelessWidget {
  const ClubPhotoStrip({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final photos = club.clubPhotos.take(3).toList();

    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < photos.length; index++) ...[
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(CatchRadius.infoTile),
                    child: ColoredBox(
                      color: t.primarySoft,
                      child: CatchNetworkImage(
                        photos[index].thumbnailOrUrl,
                        errorBuilder: (_, _, _) => Icon(
                          CatchIcons.groupsOutlined,
                          color: t.ink2,
                          size: CatchIcon.lg,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (index != photos.length - 1) gapW8,
            ],
          ],
        ),
        gapH8,
        Row(
          children: [
            Text(
              context.l10n.clubsClubPhotoStripTextFromTheClub,
              style: CatchTextStyles.monoLabelS(context, color: t.ink),
            ),
            const Spacer(),
            Text(
              context.l10n.clubsClubPhotoStripTextLengthPhotos(
                length: club.clubPhotos.length,
              ),
              style: CatchTextStyles.monoLabelS(context, color: t.ink3),
            ),
          ],
        ),
      ],
    );
  }
}
