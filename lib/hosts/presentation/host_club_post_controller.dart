import 'package:catch_dating_app/clubs/data/club_posts_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hostClubPostControllerProvider = Provider<HostClubPostController>(
  (ref) => HostClubPostController(
    ref.watch(clubPostsRepositoryProvider),
    ref.watch(appAnalyticsProvider),
  ),
);

/// Owns the create-post operation and its analytics side effect.
class HostClubPostController {
  const HostClubPostController(this._postsRepository, this._analytics);

  final ClubPostsRepository _postsRepository;
  final AppAnalytics _analytics;

  Future<void> createPost({
    required String clubId,
    required String text,
  }) async {
    await _postsRepository.createPost(clubId: clubId, text: text);
    _analytics.logEvent(
      AnalyticsEvents.clubPostCreated,
      parameters: {AnalyticsParameters.clubId: clubId},
    );
  }
}
