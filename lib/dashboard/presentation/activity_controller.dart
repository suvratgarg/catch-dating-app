import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_controller.g.dart';

/// **Pattern B: Stateless controller + static Mutations**
///
/// Performs batch operations on matches. [markAllReadMutation] tracks the
/// async lifecycle so the UI can show a loading indicator.
@riverpod
class ActivityController extends _$ActivityController {
  static final markAllReadMutation = Mutation<void>();

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
