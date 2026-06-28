part of '../club_list_tile.dart';

Widget _buildClubImage({
  required Club club,
  bool preferProfileImage = false,
  bool coverOnly = false,
  bool fallbackCompact = true,
}) {
  final String? imageUrl;
  if (coverOnly) {
    imageUrl = club.imageUrl;
  } else if (preferProfileImage) {
    imageUrl = club.profileImageUrl ?? club.imageUrl;
  } else {
    imageUrl = club.imageUrl ?? club.profileImageUrl;
  }

  Widget placeholder() =>
      ClubPolaroidArtwork(club: club, compact: fallbackCompact);

  if (imageUrl != null && imageUrl.isNotEmpty) {
    return CatchGradedImage(
      child: CatchNetworkImage(
        imageUrl,
        errorBuilder: (_, _, _) => placeholder(),
      ),
    );
  }
  return placeholder();
}
