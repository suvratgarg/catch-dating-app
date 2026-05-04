import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_empty_state.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_list_body.dart';
import 'package:catch_dating_app/matches/presentation/widgets/match_celebration_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsList extends ConsumerWidget {
  const ChatsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value;

    if (uid != null) {
      ref.listen(watchMatchesForUserProvider(uid), (previous, next) {
        if (!context.mounted) return;
        if (previous == null || !previous.hasValue || !next.hasValue) return;
        final prevIds = previous.value!.map((m) => m.id).toSet();
        final newMatches =
            next.value!.where((m) => !prevIds.contains(m.id)).toList();
        for (final match in newMatches) {
          showMatchCelebration(context, ref, match, uid);
        }
      });
    }

    final viewModelAsync = ref.watch(chatsListViewModelProvider);

    return switch (viewModelAsync) {
      AsyncLoading() => const SliverFillRemaining(
          child: CatchSkeletonList(count: 4),
        ),
      AsyncError(:final error) => SliverFillRemaining(
          child: CatchErrorText(error),
        ),
      AsyncData(:final value) => value.isEmpty || uid == null
          ? const SliverFillRemaining(child: ChatsEmptyState())
          : SliverToBoxAdapter(
              child: ChatsListBody(viewModel: value, uid: uid),
            ),
    };
  }
}
