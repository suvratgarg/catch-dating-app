import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card.dart';
import 'package:flutter/material.dart';

class PreviewTab extends StatelessWidget {
  const PreviewTab({super.key, required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(profile: profile);
  }
}
