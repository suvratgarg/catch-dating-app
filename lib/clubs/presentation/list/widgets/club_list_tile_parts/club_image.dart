part of '../club_list_tile.dart';

class _ClubImage extends StatelessWidget {
  const _ClubImage({
    required this.club,
    this.preferProfileImage = false,
    this.coverOnly = false,
    this.fallbackCompact = true,
    this.showFallbackLocationChip,
    this.showFallbackFooterLabel,
  });

  final Club club;
  final bool preferProfileImage;
  final bool coverOnly;
  final bool fallbackCompact;
  final bool? showFallbackLocationChip;
  final bool? showFallbackFooterLabel;

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
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => ClubCoverFallback(
    club: club,
    compact: fallbackCompact,
    showLocationChip: showFallbackLocationChip,
    showFooterLabel: showFallbackFooterLabel,
  );
}
