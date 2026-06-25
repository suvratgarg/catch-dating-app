import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/labs/design_fixtures/catches_surface_fixtures.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/profile_surface.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_empty_content.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_hub_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_queue_notifier.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/attended_event_tile.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/catches_pass_button.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/swipe_empty_state.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Hub route states',
  type: SwipeHubScreen,
  path: '[P1 product surfaces]/Catches',
)
Widget catchesHubRouteStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'SwipeHubScreen',
    contractId: 'screen.catches.hub',
    children: [
      _StateCard(
        label: 'uid loading',
        child: const _DeviceFrame(
          child: _HubRouteScope(uidValue: AsyncLoading<String?>()),
        ),
      ),
      _StateCard(
        label: 'auth error',
        child: _DeviceFrame(
          child: _HubRouteScope(
            uidValue: AsyncError<String?>(
              StateError('Session failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'signed out shell-hidden',
        child: const _DeviceFrame(
          child: _HubRouteScope(uidValue: AsyncData<String?>(null)),
        ),
      ),
      _StateCard(
        label: 'attended events loading',
        child: const _DeviceFrame(
          child: _HubRouteScope(eventsValue: AsyncLoading<List<Event>>()),
        ),
      ),
      _StateCard(
        label: 'attended events error',
        child: _DeviceFrame(
          child: _HubRouteScope(
            eventsValue: AsyncError<List<Event>>(
              StateError('Events failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'offline event load',
        child: _DeviceFrame(
          child: _HubRouteScope(
            eventsValue: AsyncError<List<Event>>(
              _offlineException(action: 'load attended events'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'no active windows',
        child: _DeviceFrame(
          child: _HubRouteScope(
            eventsValue: AsyncData<List<Event>>([
              CatchesSurfaceFixtures.closedWindowEvent(),
            ]),
          ),
        ),
      ),
      _StateCard(
        label: 'active catch windows',
        child: _DeviceFrame(
          child: _HubRouteScope(
            eventsValue: AsyncData<List<Event>>([
              CatchesSurfaceFixtures.openWindowEvent(),
              CatchesSurfaceFixtures.closingSoonEvent(),
            ]),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: const _DeviceFrame(
          child: _MediaOverride(
            textScaler: TextScaler.linear(2),
            child: _HubRouteScope(),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: const _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _HubRouteScope(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Event deck route states',
  type: SwipeScreen,
  path: '[P1 product surfaces]/Catches',
)
Widget catchesEventDeckRouteStates(BuildContext context) {
  final openEvent = CatchesSurfaceFixtures.openWindowEvent();
  final upcomingEvent = CatchesSurfaceFixtures.upcomingEvent();
  final closedEvent = CatchesSurfaceFixtures.closedWindowEvent();

  return _CatchesCatalog(
    title: 'SwipeScreen',
    contractId: 'screen.catches.event',
    children: [
      _StateCard(
        label: 'queue loading',
        child: _DeviceFrame(
          child: _DeckRouteScope(event: openEvent, queue: _neverQueue),
        ),
      ),
      _StateCard(
        label: 'queue error',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: openEvent,
            queue: () => Future<List<PublicProfile>>.error(
              StateError('Queue failed'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'offline queue error',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: openEvent,
            queue: () => Future<List<PublicProfile>>.error(
              _offlineException(action: 'load swipe candidates'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'profile deck with reactions',
        child: _DeviceFrame(child: _DeckRouteScope(event: openEvent)),
      ),
      _StateCard(
        label: 'vibe-prioritized deck',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: openEvent,
            vibeIds: const {CatchesSurfaceFixtures.secondCandidateUid},
          ),
        ),
      ),
      _StateCard(
        label: 'empty queue',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: openEvent,
            queue: () async => const <PublicProfile>[],
          ),
        ),
      ),
      _StateCard(
        label: 'event missing',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: openEvent,
            eventStream: Stream<Event?>.value(null),
            queue: () async => const <PublicProfile>[],
          ),
        ),
      ),
      _StateCard(
        label: 'signed out',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: openEvent,
            uid: null,
            profileStream: Stream<UserProfile?>.value(null),
            queue: () async => const <PublicProfile>[],
          ),
        ),
      ),
      _StateCard(
        label: 'event in progress',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: upcomingEvent,
            participation: CatchesSurfaceFixtures.attendedParticipation(
              event: upcomingEvent,
            ),
            queue: () async => const <PublicProfile>[],
          ),
        ),
      ),
      _StateCard(
        label: 'did not attend',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: openEvent,
            participation: CatchesSurfaceFixtures.signedUpParticipation(
              event: openEvent,
            ),
            queue: () async => const <PublicProfile>[],
          ),
        ),
      ),
      _StateCard(
        label: 'catch window closed',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: closedEvent,
            participation: CatchesSurfaceFixtures.attendedParticipation(
              event: closedEvent,
            ),
            queue: () async => const <PublicProfile>[],
          ),
        ),
      ),
      _StateCard(
        label: 'mutation failure on interaction',
        child: _DeviceFrame(
          child: _DeckRouteScope(
            event: openEvent,
            swipeRepository: const _ThrowingSwipeRepository(),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _DeckRouteScope(event: openEvent),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _DeckRouteScope(event: openEvent),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hub composition',
  type: CatchesHubContent,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesHubContentStates(BuildContext context) {
  final ready = _hubReadyState();

  return _CatchesCatalog(
    title: 'CatchesHubContent',
    contractId: 'screen.catches.hub sections',
    children: [
      _StateCard(
        label: 'active windows',
        child: _DeviceFrame(
          child: CatchesHubContent(
            state: ready,
            onOpenCatch: _ignoreCatchesRow,
            onOpenRecap: _ignoreCatchesRow,
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: CatchesHubContent(
              state: ready,
              onOpenCatch: _ignoreCatchesRow,
              onOpenRecap: _ignoreCatchesRow,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Header states',
  type: CatchesHubHeader,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesHubHeaderStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'CatchesHubHeader',
    contractId: 'screen.catches.hub.header',
    children: [
      _StateCard(
        label: 'default',
        child: _SectionFrame(
          height: 108,
          child: Padding(
            padding: CatchInsets.content,
            child: CatchesHubHeader(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Intro card states',
  type: CatchesIntroCard,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesIntroCardStates(BuildContext context) {
  final rows = _hubRows();

  return _CatchesCatalog(
    title: 'CatchesIntroCard',
    contractId: 'screen.catches.hub.intro',
    children: [
      _StateCard(
        label: 'window open',
        child: _SectionFrame(
          height: 360,
          child: Padding(
            padding: CatchInsets.content,
            child: CatchesIntroCard(row: rows.first, onTap: _noopTap),
          ),
        ),
      ),
      _StateCard(
        label: 'closing soon',
        child: _SectionFrame(
          height: 360,
          child: Padding(
            padding: CatchInsets.content,
            child: CatchesIntroCard(row: rows.last, onTap: _noopTap),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tile states',
  type: AttendedEventTile,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget attendedEventTileStates(BuildContext context) {
  final rows = _hubRows();

  return _CatchesCatalog(
    title: 'AttendedEventTile',
    contractId: 'screen.catches.hub.event_tile',
    children: [
      _StateCard(
        label: 'open and closing soon',
        child: _SectionFrame(
          height: 260,
          child: Padding(
            padding: CatchInsets.content,
            child: Column(
              children: [
                AttendedEventTile(
                  row: rows.first,
                  onOpenCatch: _noopTap,
                  onOpenRecap: _noopTap,
                ),
                gapH12,
                AttendedEventTile(
                  row: rows.last,
                  onOpenCatch: _noopTap,
                  onOpenRecap: _noopTap,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Empty states',
  type: CatchesHubEmptyState,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesHubEmptyStateStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'CatchesHubEmptyState',
    contractId: 'screen.catches.hub.empty',
    children: [
      _StateCard(
        label: 'no active catches',
        child: _DeviceFrame(child: CatchesHubEmptyState(onFindEvent: _noopTap)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Deck composition',
  type: CatchesProfileReview,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesProfileReviewStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'CatchesProfileReview',
    contractId: 'screen.catches.event sections',
    children: [
      _StateCard(
        label: 'profile review',
        child: _DeviceFrame(
          child: CatchesProfileReview(
            profile: CatchesSurfaceFixtures.candidates.first,
            remainingCount: CatchesSurfaceFixtures.candidates.length,
            viewerProfile: CatchesSurfaceFixtures.viewer,
            sharedRunTitle: CatchesSurfaceFixtures.openWindowEvent().title,
            onBack: _noopTap,
            onFilters: _noopTap,
            onPass: _noopTap,
            onReact: _noopReaction,
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: CatchesProfileReview(
              profile: CatchesSurfaceFixtures.candidates.last,
              remainingCount: 1,
              viewerProfile: CatchesSurfaceFixtures.viewer,
              sharedRunTitle: CatchesSurfaceFixtures.closingSoonEvent().title,
              onBack: _noopTap,
              onFilters: _noopTap,
              onPass: _noopTap,
              onReact: _noopReaction,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Catches profile states',
  type: ProfileSurface,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesProfileSurfaceStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'ProfileSurface',
    contractId: 'screen.catches.event.profile_surface',
    children: [
      _StateCard(
        label: 'reactable catches mode',
        child: _DeviceFrame(
          child: ProfileSurface(
            profile: CatchesSurfaceFixtures.candidates.first,
            mode: ProfileSurfaceMode.catches,
            viewerProfile: CatchesSurfaceFixtures.viewer,
            sharedRunTitle: CatchesSurfaceFixtures.openWindowEvent().title,
            bottomPadding: CatchLayout.catchesProfileBottomPadding,
            onReact: _noopReaction,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Top overlay states',
  type: CatchesTopOverlay,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesTopOverlayStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'CatchesTopOverlay',
    contractId: 'screen.catches.event.top_overlay',
    children: [
      _StateCard(
        label: 'default',
        child: _DeckChromeFrame(
          height: 168,
          child: CatchesTopOverlay(
            remainingCount: 7,
            onBack: _noopTap,
            onFilters: _noopTap,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Bottom scrim states',
  type: CatchesBottomScrim,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesBottomScrimStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'CatchesBottomScrim',
    contractId: 'screen.catches.event.bottom_scrim',
    children: [
      _StateCard(
        label: 'default',
        child: _DeckChromeFrame(height: 220, child: CatchesBottomScrim()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Pass button states',
  type: CatchesPassButton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesPassButtonStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'CatchesPassButton',
    contractId: 'screen.catches.event.pass_button',
    children: [
      _StateCard(
        label: 'default',
        child: _SectionFrame(
          height: 140,
          child: Center(child: CatchesPassButton(onPressed: _noopTap)),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Reaction control states',
  type: ProfileReactionControls,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesReactionControlStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileReactionControls',
    contractId: 'screen.catches.event.reaction_controls',
    children: [
      _StateCard(
        label: 'surface and overlay',
        child: _SectionFrame(
          height: 180,
          child: Center(
            child: Wrap(
              spacing: CatchSpacing.s5,
              runSpacing: CatchSpacing.s4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: _noopReaction,
                ),
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: _noopReaction,
                  style: ProfileReactionControlsStyle.overlay,
                ),
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: _noopReaction,
                  axis: Axis.vertical,
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Deck empty states',
  type: SwipeEmptyState,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget swipeEmptyStateStates(BuildContext context) {
  final openEvent = CatchesSurfaceFixtures.openWindowEvent();
  final closedEvent = CatchesSurfaceFixtures.closedWindowEvent();
  final upcomingEvent = CatchesSurfaceFixtures.upcomingEvent();

  return _CatchesCatalog(
    title: 'SwipeEmptyState',
    contractId: 'screen.catches.event.empty_states',
    children: [
      _StateCard(
        label: 'default empty queue',
        child: _DeviceFrame(child: SwipeEmptyState()),
      ),
      _StateCard(
        label: 'sign in required',
        child: _DeviceFrame(
          child: SwipeEmptyState(
            content: buildSwipeEmptyContent(
              event: openEvent,
              currentUser: null,
              currentUserParticipation: null,
              now: CatchesSurfaceFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'event in progress',
        child: _DeviceFrame(
          child: SwipeEmptyState(
            content: buildSwipeEmptyContent(
              event: upcomingEvent,
              currentUser: CatchesSurfaceFixtures.viewer,
              currentUserParticipation:
                  CatchesSurfaceFixtures.attendedParticipation(
                    event: upcomingEvent,
                  ),
              now: CatchesSurfaceFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'did not attend',
        child: _DeviceFrame(
          child: SwipeEmptyState(
            content: buildSwipeEmptyContent(
              event: openEvent,
              currentUser: CatchesSurfaceFixtures.viewer,
              currentUserParticipation:
                  CatchesSurfaceFixtures.signedUpParticipation(
                    event: openEvent,
                  ),
              now: CatchesSurfaceFixtures.now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'catch window closed',
        child: _DeviceFrame(
          child: SwipeEmptyState(
            content: buildSwipeEmptyContent(
              event: closedEvent,
              currentUser: CatchesSurfaceFixtures.viewer,
              currentUserParticipation:
                  CatchesSurfaceFixtures.attendedParticipation(
                    event: closedEvent,
                  ),
              now: CatchesSurfaceFixtures.now,
            ),
          ),
        ),
      ),
    ],
  );
}

class _HubRouteScope extends StatelessWidget {
  const _HubRouteScope({this.uidValue, this.eventsValue});

  final AsyncValue<String?>? uidValue;
  final AsyncValue<List<Event>>? eventsValue;

  @override
  Widget build(BuildContext context) {
    final effectiveUid =
        uidValue ?? const AsyncData<String?>(CatchesSurfaceFixtures.viewerUid);
    final uid = effectiveUid.asData?.value;

    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(effectiveUid),
        if (uid != null)
          watchAttendedEventsProvider(uid).overrideWithValue(
            eventsValue ??
                AsyncData<List<Event>>([
                  CatchesSurfaceFixtures.openWindowEvent(),
                  CatchesSurfaceFixtures.closingSoonEvent(),
                ]),
          ),
      ],
      child: SwipeHubScreen(now: CatchesSurfaceFixtures.now),
    );
  }
}

class _DeckRouteScope extends StatelessWidget {
  const _DeckRouteScope({
    required this.event,
    this.uid = CatchesSurfaceFixtures.viewerUid,
    this.eventStream,
    this.profileStream,
    this.participation,
    this.queue,
    this.vibeIds = const {},
    this.swipeRepository = const _NoopSwipeRepository(),
  });

  final Event event;
  final String? uid;
  final Stream<Event?>? eventStream;
  final Stream<UserProfile?>? profileStream;
  final EventParticipation? participation;
  final Future<List<PublicProfile>> Function()? queue;
  final Set<String> vibeIds;
  final SwipeRepository swipeRepository;

  @override
  Widget build(BuildContext context) {
    final viewerParticipation =
        participation ??
        CatchesSurfaceFixtures.attendedParticipation(event: event);

    return ProviderScope(
      overrides: [
        uidProvider.overrideWithValue(AsyncData<String?>(uid)),
        watchUserProfileProvider.overrideWith(
          (ref) =>
              profileStream ??
              Stream<UserProfile?>.value(
                uid == null ? null : CatchesSurfaceFixtures.viewer,
              ),
        ),
        watchEventProvider(
          event.id,
        ).overrideWith((ref) => eventStream ?? Stream<Event?>.value(event)),
        watchEventParticipationProvider(
          event.id,
          CatchesSurfaceFixtures.viewerUid,
        ).overrideWith(
          (ref) => Stream<EventParticipation?>.value(viewerParticipation),
        ),
        swipeQueueProvider(event.id, vibeIds: vibeIds).overrideWithBuild((
          ref,
          notifier,
        ) async {
          if (queue != null) return queue!();
          final candidates = CatchesSurfaceFixtures.candidates;
          if (vibeIds.isEmpty) return candidates;
          return [
            ...candidates.where((profile) => vibeIds.contains(profile.uid)),
            ...candidates.where((profile) => !vibeIds.contains(profile.uid)),
          ];
        }),
        swipeRepositoryProvider.overrideWithValue(swipeRepository),
      ],
      child: SwipeScreen(
        eventId: event.id,
        vibeIds: vibeIds,
        now: CatchesSurfaceFixtures.now,
      ),
    );
  }
}

const _reactionTarget = ProfileReactionTarget(
  id: 'design-catches-prompt',
  type: SwipeReactionTargetType.profilePrompt,
  label: 'prompt',
  preview:
      'Ask me about the bookshop detour I take after long runs and the breakfast order I defend every Sunday.',
);

List<CatchesHubEventRow> _hubRows() {
  return catchesHubRowsFromEvents([
    CatchesSurfaceFixtures.openWindowEvent(),
    CatchesSurfaceFixtures.closingSoonEvent(),
  ], now: CatchesSurfaceFixtures.now);
}

CatchesHubReady _hubReadyState() {
  return CatchesHubReady(
    uid: CatchesSurfaceFixtures.viewerUid,
    rows: _hubRows(),
  );
}

void _noopTap() {}

void _ignoreCatchesRow(CatchesHubEventRow row) {}

Future<void> _noopReaction(
  ProfileReactionTarget target,
  String? comment,
) async {}

class _CatchesCatalog extends StatelessWidget {
  const _CatchesCatalog({
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.content,
          children: [
            Text(title, style: CatchTextStyles.titleL(context)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH24,
            for (final child in children) ...[child, gapH20],
          ],
        ),
      ),
    );
  }
}

class _SectionFrame extends StatelessWidget {
  const _SectionFrame({required this.child, this.height = 360});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: height, child: child),
          ),
        ),
      ),
    );
  }
}

class _DeckChromeFrame extends StatelessWidget {
  const _DeckChromeFrame({required this.child, this.height = 180});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return _SectionFrame(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: t.heroGrad),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: 720, child: child),
          ),
        ),
      ),
    );
  }
}

class _MediaOverride extends StatelessWidget {
  const _MediaOverride({
    required this.child,
    this.textScaler,
    this.disableAnimations = false,
  });

  final Widget child;
  final TextScaler? textScaler;
  final bool disableAnimations;

  @override
  Widget build(BuildContext context) {
    final base = MediaQuery.of(context);
    return MediaQuery(
      data: base.copyWith(
        textScaler: textScaler ?? base.textScaler,
        disableAnimations: disableAnimations || base.disableAnimations,
      ),
      child: child,
    );
  }
}

Future<List<PublicProfile>> _neverQueue() =>
    Completer<List<PublicProfile>>().future;

NetworkException _offlineException({required String action}) {
  return obviousOfflineException(
    context: BackendErrorContext(
      service: BackendService.firestore,
      action: action,
      resource: 'catches',
    ),
  );
}

class _NoopSwipeRepository implements SwipeRepository {
  const _NoopSwipeRepository();

  @override
  Future<Set<String>> fetchSwipedUserIds({required String uid}) async =>
      const <String>{};

  @override
  Future<void> recordSwipe({required Swipe swipe}) async {}
}

class _ThrowingSwipeRepository implements SwipeRepository {
  const _ThrowingSwipeRepository();

  @override
  Future<Set<String>> fetchSwipedUserIds({required String uid}) async =>
      const <String>{};

  @override
  Future<void> recordSwipe({required Swipe swipe}) async {
    throw const BackendOperationException(
      code: 'design-swipe-write-failed',
      message: 'Unable to save that catch. Please try again.',
      context: BackendErrorContext(
        service: BackendService.firestore,
        action: 'record swipe',
        resource: 'profile_decisions',
      ),
      retryable: true,
    );
  }
}
