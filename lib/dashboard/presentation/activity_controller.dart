import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_controller.g.dart';

@riverpod
class ActivityController extends _$ActivityController {
  @override
  void build() {}

  Future<void> markAllRead({
    required List<Match> matches,
    required String uid,
  }) async {
    final repository = ref.read(matchRepositoryProvider);
    for (final match in matches) {
      if ((match.unreadCounts[uid] ?? 0) > 0) {
        await repository.resetUnread(matchId: match.id, uid: uid);
      }
    }
  }
}
