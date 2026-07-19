import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/catch_polaroid.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:flutter/material.dart';

/// Shared club-cover resolver for editorial cards and detail heroes.
class CatchClubCover extends StatelessWidget {
  const CatchClubCover({
    super.key,
    required this.club,
    this.compact = false,
    this.semanticLabel,
  });

  final Club club;
  final bool compact;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final url = club.primaryClubPhotoUrl?.trim();
    final fallback = ClubPolaroidArtwork(club: club, compact: compact);
    if (url == null || url.isEmpty) return fallback;
    return CatchGradedImage(
      child: CatchNetworkImage(
        url,
        semanticLabel: semanticLabel,
        errorBuilder: (_, _, _) => fallback,
      ),
    );
  }
}
