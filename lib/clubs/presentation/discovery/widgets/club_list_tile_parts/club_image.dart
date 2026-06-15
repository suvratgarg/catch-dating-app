part of '../club_list_tile.dart';

class _ClubImage extends StatelessWidget {
  const _ClubImage({
    required this.club,
    this.preferProfileImage = false,
    this.coverOnly = false,
    this.fallbackCompact = true,
  });

  final Club club;
  final bool preferProfileImage;
  final bool coverOnly;
  final bool fallbackCompact;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl;
    if (coverOnly) {
      imageUrl = club.imageUrl;
    } else if (preferProfileImage) {
      imageUrl = club.profileImageUrl ?? club.imageUrl;
    } else {
      imageUrl = club.imageUrl ?? club.profileImageUrl;
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CatchGradedImage(
        child: CatchNetworkImage(
          imageUrl,
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() =>
      ClubPolaroidArtwork(club: club, compact: fallbackCompact);
}
