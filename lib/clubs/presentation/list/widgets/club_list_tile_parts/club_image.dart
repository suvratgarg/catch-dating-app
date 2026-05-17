part of '../club_list_tile.dart';

class _ClubImage extends StatelessWidget {
  const _ClubImage({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final imageUrl = club.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => ClubCoverFallback(club: club, compact: true);
}
