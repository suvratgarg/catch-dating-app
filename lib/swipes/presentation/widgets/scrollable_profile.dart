import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/card_photo_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/name_overlay.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_attributes_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_bio_section.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_lifestyle_section.dart';
import 'package:flutter/material.dart';

class ScrollableProfile extends StatelessWidget {
  const ScrollableProfile({
    super.key,
    required this.profile,
    required this.cardHeight,
  });

  final PublicProfile profile;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final content = ProfileCardContent.fromProfile(profile);
    final firstAdditionalPhotoUrl = content.additionalPhotoUrls.firstOrNull;
    final remainingPhotoUrls = content.additionalPhotoUrls.skip(1);

    return ColoredBox(
      color: const Color(0xFF111111),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardPhotoSection(
              url: content.primaryPhotoUrl,
              height: cardHeight,
              overlayChild: NameOverlay(profile: profile),
            ),
            if (content.attributes.isNotEmpty)
              ProfileAttributesSection(attrs: content.attributes),
            if (content.hasBio) ProfileBioSection(bio: content.bio),
            if (firstAdditionalPhotoUrl != null)
              CardPhotoSection(
                url: firstAdditionalPhotoUrl,
                height: cardHeight * 0.75,
              ),
            if (content.lifestyle.isNotEmpty)
              ProfileLifestyleSection(items: content.lifestyle),
            for (final photoUrl in remainingPhotoUrls)
              CardPhotoSection(url: photoUrl, height: cardHeight * 0.75),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
