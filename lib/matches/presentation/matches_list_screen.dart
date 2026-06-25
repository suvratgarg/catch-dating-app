import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/matches/presentation/chats_list_view_model.dart';
import 'package:catch_dating_app/matches/presentation/host_inbox_filter.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_list.dart';
import 'package:catch_dating_app/matches/presentation/widgets/chats_sliver_header.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    final uid = ref.watch(uidProvider).asData?.value;
    final viewModelAsync = ref.watch(chatsListViewModelProvider);
    final query = ref.watch(chatSearchQueryProvider).trim();
    final screenState = HostInboxScreenState.fromAsync(
      viewModel: viewModelAsync,
      uid: uid,
      query: query,
      selectedFilter: _hostInboxFilter,
      isHostApp: isHostApp,
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            ...ChatsSliverHeader(
              showSearchAction: screenState.showSearchAction,
              hostFilter: screenState.hostFilter,
              hostUnreadCount: screenState.unreadThreadCount,
              onHostFilterChanged: _handleHostFilterChanged,
            ).buildSlivers(context),
            ChatsList(
              hostFilter: screenState.hostFilter,
              displayState: screenState.displayState,
              onThreadSelected: _openChatThread,
              onHostBroadcastSelected: isHostApp
                  ? _showHostBroadcastComposer
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _handleHostFilterChanged(HostInboxFilter filter) {
    if (filter == _hostInboxFilter) return;
    setState(() => _hostInboxFilter = filter);
  }

  void _openChatThread(ChatThreadPreview preview) {
    final routeName = AppConfig.appRole.isHost
        ? Routes.hostChatScreen.name
        : Routes.chatScreen.name;
    context.goNamed(routeName, pathParameters: {'matchId': preview.matchId});
  }

  void _showHostBroadcastComposer() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HostBroadcastComposerSheet(),
    );
  }
}

class HostInboxScreenState {
  const HostInboxScreenState({
    required this.hostFilter,
    required this.unreadThreadCount,
    required this.showSearchAction,
    required this.displayState,
  });

  factory HostInboxScreenState.fromAsync({
    required AsyncValue<ChatsListViewModel> viewModel,
    required String? uid,
    required String query,
    required HostInboxFilter selectedFilter,
    required bool isHostApp,
  }) {
    final source = viewModel.asData?.value;
    final normalizedQuery = query.trim();
    final hostFilter = isHostApp ? selectedFilter : null;

    return HostInboxScreenState(
      hostFilter: hostFilter,
      unreadThreadCount: _unreadThreadCount(source),
      showSearchAction:
          (source?.totalThreadCount ?? 0) > 0 || normalizedQuery.isNotEmpty,
      displayState: ChatsListDisplayState.fromAsync(
        viewModel: viewModel,
        uid: uid,
        query: normalizedQuery,
        hostFilter: hostFilter,
      ),
    );
  }

  final HostInboxFilter? hostFilter;
  final int unreadThreadCount;
  final bool showSearchAction;
  final ChatsListDisplayState displayState;

  static int _unreadThreadCount(ChatsListViewModel? vm) {
    if (vm == null) return 0;
    return [
      ...vm.newMatches,
      ...vm.conversations,
    ].where((preview) => preview.unreadCount > 0).length;
  }
}

class _HostBroadcastComposerSheet extends StatelessWidget {
  const _HostBroadcastComposerSheet();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: CatchSurface(
          backgroundColor: t.surface,
          borderColor: t.line,
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            CatchSpacing.s4,
            CatchSpacing.s5,
            CatchSpacing.s5,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CatchSurface(
                  width: CatchSpacing.s10,
                  height: CatchStroke.hairline * 3,
                  radius: CatchRadius.pill,
                  backgroundColor: t.line,
                  borderWidth: 0,
                  child: const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: CatchSpacing.s4),
              Text('New blast', style: CatchTextStyles.titleL(context)),
              const SizedBox(height: CatchSpacing.s1),
              Text(
                'Broadcast sending is not connected yet. Use this as the review surface for audience and template states.',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              const SizedBox(height: CatchSpacing.s4),
              const _HostBroadcastTemplateRow(
                label: 'Reminder',
                body: 'See you tonight at 8. Doors open at 7:45.',
              ),
              const SizedBox(height: CatchSpacing.s2),
              const _HostBroadcastTemplateRow(
                label: 'Meeting point',
                body: 'Share arrival notes, parking, or table details.',
              ),
              const SizedBox(height: CatchSpacing.s4),
              const CatchButton(
                label: 'Send broadcast',
                onPressed: null,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HostBroadcastTemplateRow extends StatelessWidget {
  const _HostBroadcastTemplateRow({required this.label, required this.body});

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      radius: CatchRadius.md,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CatchTextStyles.infoRowTitle(context)),
          const SizedBox(height: CatchSpacing.micro2),
          Text(body, style: CatchTextStyles.supporting(context, color: t.ink2)),
        ],
      ),
    );
  }
}
