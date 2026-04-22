import 'package:catch_dating_app/swipes/presentation/widgets/profile_section_card.dart';
import 'package:flutter/material.dart';

class ProfileBioSection extends StatelessWidget {
  const ProfileBioSection({super.key, required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'ABOUT ME',
      child: Text(
        bio,
        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
      ),
    );
  }
}
