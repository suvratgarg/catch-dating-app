import 'package:catch_dating_app/core/theme/catch_tokens.dart';
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
    final count = (vm?.newMatches.length ?? 0) + (vm?.conversations.length ?? 0);

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ...ChatsSliverHeader(count: count).buildSlivers(context),
            const ChatsList(),
          ],
        ),
      ),
    );
  }
}
