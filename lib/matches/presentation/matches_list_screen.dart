import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_list.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_sliver_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final viewModelAsync = ref.watch(chatsListViewModelProvider);
    final vm = viewModelAsync.asData?.value;
    final count =
        (vm?.newMatches.length ?? 0) + (vm?.conversations.length ?? 0);
    final query = ref.watch(chatSearchQueryProvider).trim();
    final uid = ref.watch(uidProvider).asData?.value;
    final sourceMatchCount = uid == null
        ? 0
        : ref.watch(watchMatchesForUserProvider(uid)).asData?.value.length ?? 0;
    final showSearchField = sourceMatchCount > 0 || query.isNotEmpty;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ...ChatsSliverHeader(
              count: count,
              showSearchField: showSearchField,
            ).buildSlivers(context),
            const ChatsList(),
          ],
        ),
      ),
    );
  }
}
