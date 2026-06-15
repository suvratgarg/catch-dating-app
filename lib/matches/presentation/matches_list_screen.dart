import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/host_inbox_filter.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_list.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_sliver_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});

  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen> {
  HostInboxFilter _hostInboxFilter = HostInboxFilter.all;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isHostApp = AppConfig.appRole.isHost;

    final viewModelAsync = ref.watch(chatsListViewModelProvider);
    final vm = viewModelAsync.asData?.value;
    final count = vm?.totalThreadCount ?? 0;
    final unreadThreadCount = _unreadThreadCount(vm);
    final query = ref.watch(chatSearchQueryProvider).trim();
    final showSearchAction = count > 0 || query.isNotEmpty;
    final hostFilter = isHostApp ? _hostInboxFilter : null;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ...ChatsSliverHeader(
              showSearchAction: showSearchAction,
              hostFilter: hostFilter,
              hostUnreadCount: unreadThreadCount,
              onHostFilterChanged: _handleHostFilterChanged,
            ).buildSlivers(context),
            ChatsList(hostFilter: hostFilter),
          ],
        ),
      ),
    );
  }

  int _unreadThreadCount(ChatsListViewModel? vm) {
    if (vm == null) return 0;
    return [
      ...vm.newMatches,
      ...vm.conversations,
    ].where((preview) => preview.unreadCount > 0).length;
  }

  void _handleHostFilterChanged(HostInboxFilter filter) {
    if (filter == _hostInboxFilter) return;
    setState(() => _hostInboxFilter = filter);
  }
}
