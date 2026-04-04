import 'package:catch_dating_app/reviews/presentation/star_rating.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runClubs/domain/run_club.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RunClubListTile extends StatelessWidget {
  const RunClubListTile({super.key, required this.runClub});

  final RunClub runClub;

  String get _initials => runClub.name
      .split(' ')
      .take(2)
      .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
      .join();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushNamed(
          Routes.runClubDetailScreen.name,
          pathParameters: {'runClubId': runClub.id},
          extra: runClub,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            AspectRatio(
              aspectRatio: 16 / 7,
              child: runClub.imageUrl != null
                  ? Image.network(runClub.imageUrl!, fit: BoxFit.cover)
                  : Container(
                      color: colorScheme.primaryContainer,
                      child: Center(
                        child: Text(
                          _initials,
                          style: textTheme.displaySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    runClub.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        runClub.location.label,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${runClub.memberUserIds.length} members',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (runClub.reviewCount > 0) ...[
                        const SizedBox(width: 12),
                        StarRating(rating: runClub.rating.round(), size: 12),
                        const SizedBox(width: 3),
                        Text(
                          runClub.rating.toStringAsFixed(1),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (runClub.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      runClub.description,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
