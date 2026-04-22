part of '../run_club_list_tile.dart';

class _ClubImage extends StatelessWidget {
  const _ClubImage({required this.imageUrl, required this.seed});

  final String? imageUrl;
  final String seed;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() => PersonAvatar(size: double.infinity, name: seed);
}
