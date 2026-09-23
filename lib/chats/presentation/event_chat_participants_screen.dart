import 'dart:async';
import 'package:catch_dating_app/chats/presentation/event_chat_participants_controller.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventChatParticipantsScreen extends ConsumerStatefulWidget {
  const EventChatParticipantsScreen({super.key, required this.eventId});
  final String eventId;
  @override
  ConsumerState<EventChatParticipantsScreen> createState() =>
      _EventChatParticipantsScreenState();
}

class _EventChatParticipantsScreenState
    extends ConsumerState<EventChatParticipantsScreen>
    with WidgetsBindingObserver {
  bool _resumed = true;
  bool? _active;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _resumed = state == AppLifecycleState.resumed);
  }

  void _syncActive(bool active) {
    if (_active == active) return;
    _active = active;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _active != active) return;
      ref
          .read(
            eventChatParticipantsControllerProvider(widget.eventId).notifier,
          )
          .setForeground(active);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = eventChatParticipantsControllerProvider(widget.eventId);
    final value = ref.watch(provider);
    final active = _resumed && (ModalRoute.isCurrentOf(context) ?? true);
    _syncActive(active);
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar.route(
        title: context.l10n.eventChatParticipantsTitle,
        navigation: const CatchTopBarNavigation(
          mode: CatchTopBarNavigationMode.back,
        ),
        emphasis: scrolledUnder
            ? CatchTopBarEmphasis.divided
            : CatchTopBarEmphasis.plain,
        actions: [
          CatchIconAction.toolbar(
            tooltip: context.l10n.eventChatRefresh,
            icon: CatchIcons.refreshRounded,
            onPressed: !active || value.isLoading
                ? null
                : () => unawaited(ref.read(provider.notifier).refresh()),
          ),
        ],
      ),
      body: CatchRouteBody.standardConstrained(
        child: !active
            ? const SizedBox.shrink()
            : CatchAsyncBoundary<EventChatParticipantsState>(
                value: value,
                retainDataOn: const {},
                onRetry: () => unawaited(ref.read(provider.notifier).refresh()),
                builder: (context, state) => EventChatParticipantsList(
                  state: state,
                  onOpen: (uid) => context.pushNamed(
                    Routes.eventParticipantProfileScreen.name,
                    pathParameters: {
                      'eventId': widget.eventId,
                      'participantUid': uid,
                    },
                  ),
                  onLoadMore: () =>
                      unawaited(ref.read(provider.notifier).loadMore()),
                ),
              ),
      ),
    );
  }
}

class EventChatParticipantsList extends StatelessWidget {
  const EventChatParticipantsList({
    super.key,
    required this.state,
    required this.onOpen,
    required this.onLoadMore,
  });
  final EventChatParticipantsState state;
  final ValueChanged<String> onOpen;
  final VoidCallback onLoadMore;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.eventChatParticipantsDescription,
          style: CatchTextStyles.proseM(context),
        ),
        gapH24,
        if (state.page.items.isEmpty)
          Text(
            state.page.nextCursor == null
                ? l.eventChatParticipantsEmpty
                : l.eventChatParticipantsContinue,
            style: CatchTextStyles.supporting(context),
          ),
        if (state.page.items.isNotEmpty)
          CatchSection.fieldRows(
            first: true,
            children: [
              for (final person in state.page.items)
                CatchField.nav(
                  key: ValueKey('event-participant-${person.uid}'),
                  copy: catchFieldCopy(l),
                  title: person.displayName,
                  body: [
                    if (person.uid == state.uid) l.eventChatYou,
                    person.isHost
                        ? l.eventChatParticipantHost
                        : l.eventChatParticipantAttendee,
                  ].join(' · '),
                  emphasis: CatchFieldEmphasis.title,
                  titleMaxLines: 3,
                  bodyMaxLines: 3,
                  onTap: () => onOpen(person.uid),
                ),
            ],
          ),
        if (state.page.nextCursor != null) ...[
          gapH24,
          CatchButton(
            label: l.eventChatParticipantsMore,
            variant: CatchButtonVariant.secondary,
            fullWidth: true,
            onPressed: onLoadMore,
          ),
        ],
      ],
    );
  }
}
