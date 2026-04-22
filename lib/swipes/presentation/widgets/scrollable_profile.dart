import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
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
    final photos = profile.photoUrls;
    final attrs = _buildAttributes(profile);
    final lifestyle = _buildLifestyle(profile);

    return ColoredBox(
      color: const Color(0xFF111111),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardPhotoSection(
              url: photos.isNotEmpty ? photos[0] : null,
              height: cardHeight,
              overlayChild: NameOverlay(profile: profile),
            ),
            if (attrs.isNotEmpty) ProfileAttributesSection(attrs: attrs),
            if (profile.bio.isNotEmpty) ProfileBioSection(bio: profile.bio),
            if (photos.length > 1)
              CardPhotoSection(url: photos[1], height: cardHeight * 0.75),
            if (lifestyle.isNotEmpty) ProfileLifestyleSection(items: lifestyle),
            for (var i = 2; i < photos.length; i++)
              CardPhotoSection(url: photos[i], height: cardHeight * 0.75),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

List<({IconData icon, String text})> buildProfileAttributes(PublicProfile p) {
  final attrs = <({IconData icon, String text})>[];
  if (p.height != null) {
    attrs.add((icon: Icons.straighten_rounded, text: '${p.height} cm'));
  }
  if (p.occupation != null && p.occupation!.isNotEmpty) {
    final label = (p.company != null && p.company!.isNotEmpty)
        ? '${p.occupation} at ${p.company}'
        : p.occupation!;
    attrs.add((icon: Icons.work_outline_rounded, text: label));
  }
  if (p.education != null) {
    attrs.add((icon: Icons.school_outlined, text: p.education!.label));
  }
  if (p.religion != null) {
    attrs.add((icon: Icons.brightness_3_outlined, text: p.religion!.label));
  }
  if (p.languages.isNotEmpty) {
    attrs.add((
      icon: Icons.translate_rounded,
      text: p.languages.map((l) => l.label).join(', '),
    ));
  }
  return attrs;
}

List<({IconData icon, String text})> buildProfileLifestyle(PublicProfile p) {
  final items = <({IconData icon, String text})>[];
  if (p.drinking != null) {
    items.add((icon: Icons.local_bar_outlined, text: p.drinking!.label));
  }
  if (p.smoking != null) {
    items.add((icon: Icons.smoke_free_rounded, text: p.smoking!.label));
  }
  if (p.workout != null) {
    items.add((icon: Icons.fitness_center_rounded, text: p.workout!.label));
  }
  if (p.diet != null) {
    items.add((icon: Icons.eco_outlined, text: p.diet!.label));
  }
  if (p.children != null) {
    items.add((
      icon: Icons.child_friendly_outlined,
      text: p.children!.label,
    ));
  }
  return items;
}

// Keep internal alias for backward compat within this file
List<({IconData icon, String text})> _buildAttributes(PublicProfile p) =>
    buildProfileAttributes(p);
List<({IconData icon, String text})> _buildLifestyle(PublicProfile p) =>
    buildProfileLifestyle(p);
