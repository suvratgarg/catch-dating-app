import 'dart:async';

import "package:catch_dating_app/core/widgets/catch_stat_column.dart";
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/labs/design_fixtures/catches_surface_fixtures.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_repository.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_screen_state.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_view_model.dart';
import 'package:catch_dating_app/swipes/presentation/filters_screen.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_card_content.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/catch_profile_view.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_view.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_view_mapper.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_surface.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_empty_content.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_screen.dart';
import 'package:catch_dating_app/swipes/presentation/swipe_queue_controller.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/catches_pass_button.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_info_chip.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_reaction_controls.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/swipe_empty_state.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

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
      _StateCard(
        label: 'pass pending',
        child: _DeviceFrame(
          child: CatchesProfileReview(
            profile: CatchesSurfaceFixtures.candidates.first,
            remainingCount: CatchesSurfaceFixtures.candidates.length,
            viewerProfile: CatchesSurfaceFixtures.viewer,
            sharedRunTitle: CatchesSurfaceFixtures.openWindowEvent().title,
            actionState: const CatchesProfileReviewActionState.passPending(),
            onBack: _noopTap,
            onFilters: _noopTap,
            onPass: _noopTap,
            onReact: _noopReaction,
          ),
        ),
      ),
      _StateCard(
        label: 'reaction pending',
        child: _DeviceFrame(
          child: CatchesProfileReview(
            profile: CatchesSurfaceFixtures.candidates.first,
            remainingCount: CatchesSurfaceFixtures.candidates.length,
            viewerProfile: CatchesSurfaceFixtures.viewer,
            sharedRunTitle: CatchesSurfaceFixtures.openWindowEvent().title,
            actionState:
                const CatchesProfileReviewActionState.reactionPending(),
            onBack: _noopTap,
            onFilters: _noopTap,
            onPass: _noopTap,
            onReact: _noopReaction,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Event recap route states',
  type: EventRecapScreen,
  path: '[P1 product surfaces]/Catches',
)
Widget eventRecapScreenRouteStates(BuildContext context) {
  final event = CatchesSurfaceFixtures.closedWindowEvent();
  final openEvent = CatchesSurfaceFixtures.openWindowEvent();
  final attendeeIds = CatchesSurfaceFixtures.candidates
      .map((profile) => profile.uid)
      .toList(growable: false);
  final partialAttendeeIds = [
    CatchesSurfaceFixtures.candidateUid,
    _missingRecapProfileUid,
  ];
  final partialRoster = {
    CatchesSurfaceFixtures.candidateUid:
        CatchesSurfaceFixtures.candidates.first,
  };

  return _CatchesCatalog(
    title: 'EventRecapScreen',
    contractId: 'screen.catches.recap',
    children: [
      _StateCard(
        label: 'recap loading',
        child: _DeviceFrame(
          child: _RecapRouteScope(
            event: event,
            recapValue: const AsyncLoading(),
          ),
        ),
      ),
      _StateCard(
        label: 'view-model error',
        child: _DeviceFrame(
          child: _RecapRouteScope(
            event: event,
            recapValue: AsyncError<EventRecapViewModel?>(
              _offlineException(action: 'load event recap'),
              StackTrace.empty,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'checked-in roster',
        child: _DeviceFrame(
          child: _RecapRouteScope(
            event: event,
            recapValue: AsyncData(
              _recapViewModel(event: event, attendeeIds: attendeeIds),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'partial profile fallback',
        child: _DeviceFrame(
          child: _RecapRouteScope(
            event: event,
            recapValue: AsyncData(
              _recapViewModel(event: event, attendeeIds: partialAttendeeIds),
            ),
            rosterProfiles: partialRoster,
          ),
        ),
      ),
      _StateCard(
        label: 'selected vibe tile',
        child: _DeviceFrame(
          child: _RecapReadyBodyPreview(
            event: event,
            attendeeIds: attendeeIds,
            selectedVibeIds: const {CatchesSurfaceFixtures.secondCandidateUid},
          ),
        ),
      ),
      _StateCard(
        label: 'open catch window',
        child: _DeviceFrame(
          child: _RecapRouteScope(
            event: openEvent,
            recapValue: AsyncData(
              _recapViewModel(event: openEvent, attendeeIds: attendeeIds),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'empty roster',
        child: _DeviceFrame(
          child: _RecapRouteScope(
            event: event,
            recapValue: AsyncData(
              _recapViewModel(event: event, attendeeIds: const []),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'event missing',
        child: _DeviceFrame(
          child: _RecapRouteScope(
            event: event,
            recapValue: const AsyncData<EventRecapViewModel?>(null),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        child: _DeviceFrame(
          child: _MediaOverride(
            textScaler: const TextScaler.linear(2),
            child: _RecapRouteScope(
              event: event,
              recapValue: AsyncData(
                _recapViewModel(event: event, attendeeIds: attendeeIds),
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: _DeviceFrame(
          child: _MediaOverride(
            disableAnimations: true,
            child: _RecapRouteScope(
              event: event,
              recapValue: AsyncData(
                _recapViewModel(event: event, attendeeIds: attendeeIds),
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'dark theme',
        child: Theme(
          data: AppTheme.dark,
          child: _DeviceFrame(
            child: _RecapRouteScope(
              event: event,
              recapValue: AsyncData(
                _recapViewModel(event: event, attendeeIds: attendeeIds),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Loading composition',
  type: EventRecapLoadingBody,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget eventRecapLoadingBodyStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'EventRecapLoadingBody',
    contractId: 'screen.catches.recap.loading',
    children: [
      _StateCard(
        label: 'content skeleton',
        child: _DeviceFrame(child: EventRecapLoadingBody()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Ready body states',
  type: EventRecapReadyBody,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget eventRecapReadyBodyStates(BuildContext context) {
  final event = CatchesSurfaceFixtures.closedWindowEvent();
  final attendeeIds = CatchesSurfaceFixtures.candidates
      .map((profile) => profile.uid)
      .toList(growable: false);

  return _CatchesCatalog(
    title: 'EventRecapReadyBody',
    contractId: 'screen.catches.recap.ready_body',
    children: [
      _StateCard(
        label: 'checked-in roster',
        child: _DeviceFrame(
          child: _RecapReadyBodyPreview(
            event: event,
            attendeeIds: attendeeIds,
            selectedVibeIds: const <String>{},
          ),
        ),
      ),
      _StateCard(
        label: 'selected vibe tile',
        child: _DeviceFrame(
          child: _RecapReadyBodyPreview(
            event: event,
            attendeeIds: attendeeIds,
            selectedVibeIds: const {CatchesSurfaceFixtures.secondCandidateUid},
          ),
        ),
      ),
      _StateCard(
        label: 'empty roster',
        child: _DeviceFrame(
          child: _RecapReadyBodyPreview(
            event: event,
            attendeeIds: const <String>[],
            selectedVibeIds: const <String>{},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Vibe grid states',
  type: VibeGrid,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget eventRecapVibeGridStates(BuildContext context) {
  final event = CatchesSurfaceFixtures.closedWindowEvent();
  final attendeeIds = CatchesSurfaceFixtures.candidates
      .map((profile) => profile.uid)
      .toList(growable: false);
  final partialAttendeeIds = [
    CatchesSurfaceFixtures.candidateUid,
    _missingRecapProfileUid,
  ];
  final partialRoster = {
    CatchesSurfaceFixtures.candidateUid:
        CatchesSurfaceFixtures.candidates.first,
  };

  return _CatchesCatalog(
    title: 'VibeGrid',
    contractId: 'component.catches.recap.vibe_grid',
    children: [
      _StateCard(
        label: 'profile tiles',
        child: VibeGrid(
          rows: _recapReadyState(
            event: event,
            attendeeIds: attendeeIds,
          ).attendeeRows,
          onToggleVibe: _ignoreString,
        ),
      ),
      _StateCard(
        label: 'selected and fallback',
        child: VibeGrid(
          rows: _recapReadyState(
            event: event,
            attendeeIds: partialAttendeeIds,
            rosterProfiles: partialRoster,
            selectedVibeIds: const {CatchesSurfaceFixtures.candidateUid},
          ).attendeeRows,
          onToggleVibe: _ignoreString,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Filters loading composition',
  type: FiltersContentSkeleton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget filtersContentSkeletonStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'FiltersContentSkeleton',
    contractId: 'screen.catches.filters.loading',
    children: [
      _StateCard(
        label: 'loading',
        child: _DeviceFrame(child: FiltersContentSkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Filter section states',
  type: FiltersSection,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget filtersSectionStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'FiltersSection',
    contractId: 'screen.catches.filters.section',
    children: [
      _StateCard(
        label: 'value section',
        child: _SectionFrame(
          height: 140,
          child: Padding(
            padding: CatchInsets.content,
            child: FiltersSection(
              title: 'Age',
              child: FiltersValue(value: '24 - 36'),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Filter value states',
  type: FiltersValue,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget filtersValueStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'FiltersValue',
    contractId: 'screen.catches.filters.value',
    children: [
      _StateCard(
        label: 'default',
        child: _SectionFrame(
          height: 96,
          child: Padding(
            padding: CatchInsets.content,
            child: FiltersValue(value: '24 - 36'),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Raw profile view states',
  type: CatchProfileView,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchProfileViewStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'CatchProfileView',
    contractId: 'screen.catches.profile.raw',
    children: [
      _StateCard(
        label: 'read only',
        child: _DeviceFrame(child: CatchProfileView(data: _profileView())),
      ),
      _StateCard(
        label: 'reactable',
        child: _DeviceFrame(
          child: CatchProfileView(data: _profileView(), onReact: _noopReaction),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero states',
  type: ProfileHeroWidget,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileHeroWidgetStates(BuildContext context) {
  final data = _profileView();
  return _CatchesCatalog(
    title: 'ProfileHeroWidget',
    contractId: 'screen.catches.profile.hero',
    children: [
      _StateCard(
        label: 'read only',
        child: _SectionFrame(height: 520, child: ProfileHeroWidget(data: data)),
      ),
      _StateCard(
        label: 'reactable',
        child: _SectionFrame(
          height: 520,
          child: ProfileHeroWidget(data: data, onReact: _noopReaction),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo states',
  type: ProfilePhoto,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profilePhotoStates(BuildContext context) {
  final data = _profileView();
  return _CatchesCatalog(
    title: 'ProfilePhoto',
    contractId: 'screen.catches.profile.photo',
    children: [
      _StateCard(
        label: 'graded photo',
        child: _SectionFrame(
          height: 520,
          child: ProfilePhoto(image: data.heroPhoto),
        ),
      ),
      _StateCard(
        label: 'activity fallback',
        child: _SectionFrame(
          height: 520,
          child: ProfilePhoto(image: null, activity: data.kickerActivity),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo block states',
  type: ProfilePhotoBlock,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profilePhotoBlockStates(BuildContext context) {
  final section = _profileSection<ProfilePhotoSection>();
  return _CatchesCatalog(
    title: 'ProfilePhotoBlock',
    contractId: 'screen.catches.profile.photo_block',
    children: [
      _StateCard(
        label: 'caption',
        child: _SectionFrame(
          height: 520,
          child: ProfilePhotoBlock(section: section),
        ),
      ),
      _StateCard(
        label: 'reactable',
        child: _SectionFrame(
          height: 520,
          child: ProfilePhotoBlock(section: section, onReact: _noopReaction),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo caption states',
  type: PhotoCaption,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget photoCaptionStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'PhotoCaption',
    contractId: 'screen.catches.profile.photo_caption',
    children: [
      _StateCard(
        label: 'overlay copy',
        child: _DeckChromeFrame(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: CatchInsets.content,
              child: PhotoCaption(text: 'Post-run coffee is non-negotiable.'),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Section dispatch states',
  type: ProfileSectionView,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSectionViewStates(BuildContext context) {
  final section = _profileSection<ProfileCompatibilitySection>();
  return _CatchesCatalog(
    title: 'ProfileSectionView',
    contractId: 'screen.catches.profile.section_view',
    children: [
      _StateCard(
        label: 'passive section',
        child: _SectionFrame(
          height: 220,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileSectionView(section: section),
          ),
        ),
      ),
      _StateCard(
        label: 'reactable section',
        child: _SectionFrame(
          height: 260,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileSectionView(section: section, onReact: _noopReaction),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Section kicker states',
  type: ProfileSectionKicker,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSectionKickerStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileSectionKicker',
    contractId: 'screen.catches.profile.section_kicker',
    children: [
      _StateCard(
        label: 'mono label',
        child: ProfileSectionKicker('Running rhythm'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Compatibility states',
  type: ProfileCompatibility,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileCompatibilityStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'ProfileCompatibility',
    contractId: 'screen.catches.profile.compatibility',
    children: [
      _StateCard(
        label: 'reasons and signals',
        child: _SectionFrame(
          height: 260,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileCompatibility(
              section: _profileSection<ProfileCompatibilitySection>(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Prompt states',
  type: ProfilePrompt,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profilePromptStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'ProfilePrompt',
    contractId: 'screen.catches.profile.prompt',
    children: [
      _StateCard(
        label: 'prompt answer',
        child: ProfilePrompt(
          section: _profileSection<ProfilePromptSectionData>(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Running states',
  type: ProfileRunning,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileRunningStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'ProfileRunning',
    contractId: 'screen.catches.profile.running',
    children: [
      _StateCard(
        label: 'running rhythm',
        child: _SectionFrame(
          height: 230,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileRunning(
              section: _profileSection<ProfileRunningSection>(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Running stat states',
  type: CatchStatColumn,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget runningStatStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'CatchStatColumn',
    contractId: 'screen.catches.profile.running_stat',
    children: [
      _StateCard(
        label: 'pace',
        child: CatchStatColumn(label: 'Pace', value: '5:30/km'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Facts states',
  type: ProfileFacts,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileFactsStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'ProfileFacts',
    contractId: 'screen.catches.profile.facts',
    children: [
      _StateCard(
        label: 'details',
        child: _SectionFrame(
          height: 260,
          child: Padding(
            padding: CatchInsets.content,
            child: ProfileFacts(
              section: _profileSection<ProfileFactsSection>(),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Rule states',
  type: ProfileRule,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileRuleStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatchesCatalog(
    title: 'ProfileRule',
    contractId: 'screen.catches.profile.rule',
    children: [
      _StateCard(
        label: 'hairline',
        child: ProfileRule(color: t.line),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile skeleton states',
  type: ProfileSurfaceSkeleton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSurfaceSkeletonStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileSurfaceSkeleton',
    contractId: 'screen.catches.profile.skeleton',
    children: [
      _StateCard(
        label: 'default',
        child: _DeviceFrame(child: ProfileSurfaceSkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile hero skeleton states',
  type: ProfileSurfaceHeroSkeleton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSurfaceHeroSkeletonStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileSurfaceHeroSkeleton',
    contractId: 'screen.catches.profile.hero_skeleton',
    children: [
      _StateCard(
        label: 'portrait hero',
        child: _SectionFrame(height: 440, child: ProfileSurfaceHeroSkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile section skeleton states',
  type: ProfileSurfaceSectionSkeleton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSurfaceSectionSkeletonStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileSurfaceSectionSkeleton',
    contractId: 'screen.catches.profile.section_skeleton',
    children: [
      _StateCard(
        label: 'prompt block',
        child: _SectionFrame(
          height: 210,
          child: ProfileSurfaceSectionSkeleton(lines: 3),
        ),
      ),
      _StateCard(
        label: 'compact block',
        child: _SectionFrame(
          height: 180,
          child: ProfileSurfaceSectionSkeleton(lines: 1),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile running skeleton states',
  type: ProfileSurfaceRunningSkeleton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSurfaceRunningSkeletonStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileSurfaceRunningSkeleton',
    contractId: 'screen.catches.profile.running_skeleton',
    children: [
      _StateCard(
        label: 'running rhythm',
        child: _SectionFrame(
          height: 220,
          child: ProfileSurfaceRunningSkeleton(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile photo skeleton states',
  type: ProfileSurfacePhotoSkeleton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSurfacePhotoSkeletonStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileSurfacePhotoSkeleton',
    contractId: 'screen.catches.profile.photo_skeleton',
    children: [
      _StateCard(
        label: 'portrait photo block',
        child: _SectionFrame(height: 460, child: ProfileSurfacePhotoSkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile facts skeleton states',
  type: ProfileSurfaceFactsSkeleton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSurfaceFactsSkeletonStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileSurfaceFactsSkeleton',
    contractId: 'screen.catches.profile.facts_skeleton',
    children: [
      _StateCard(
        label: 'fact rows',
        child: _SectionFrame(height: 260, child: ProfileSurfaceFactsSkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile surface rule states',
  type: ProfileSurfaceRule,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileSurfaceRuleStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileSurfaceRule',
    contractId: 'screen.catches.profile.surface_rule',
    children: [
      _StateCard(
        label: 'section divider',
        child: _SectionFrame(height: 72, child: ProfileSurfaceRule()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Review skeleton states',
  type: CatchesProfileReviewSkeleton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget catchesProfileReviewSkeletonStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'CatchesProfileReviewSkeleton',
    contractId: 'screen.catches.event.review_skeleton',
    children: [
      _StateCard(
        label: 'loading deck',
        child: _DeviceFrame(child: CatchesProfileReviewSkeleton()),
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
      _StateCard(
        label: 'reaction pending',
        child: _DeviceFrame(
          child: ProfileSurface(
            profile: CatchesSurfaceFixtures.candidates.first,
            mode: ProfileSurfaceMode.catches,
            viewerProfile: CatchesSurfaceFixtures.viewer,
            sharedRunTitle: CatchesSurfaceFixtures.openWindowEvent().title,
            bottomPadding: CatchLayout.catchesProfileBottomPadding,
            onReact: _noopReaction,
            reactionsEnabled: false,
            reactionsPending: true,
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
      _StateCard(
        label: 'pending',
        child: _SectionFrame(
          height: 140,
          child: Center(
            child: CatchesPassButton(onPressed: _noopTap, isPending: true),
          ),
        ),
      ),
      _StateCard(
        label: 'disabled',
        child: _SectionFrame(
          height: 140,
          child: Center(child: CatchesPassButton(onPressed: null)),
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
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: _noopReaction,
                  enabled: false,
                ),
                ProfileReactionControls(
                  target: _reactionTarget,
                  onReact: _noopReaction,
                  isPending: true,
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
  name: 'Reaction button states',
  type: ReactionControlButton,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget reactionControlButtonStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'ReactionControlButton',
    contractId: 'screen.catches.event.reaction_button',
    children: [
      _StateCard(
        label: 'surface',
        child: _SectionFrame(
          height: 140,
          child: Center(
            child: ReactionControlButton(
              tooltip: 'Like prompt',
              icon: CatchIcons.favoriteBorderRounded,
              onPressed: _noopTap,
              style: ProfileReactionControlsStyle.surface,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'overlay pending disabled',
        child: _SectionFrame(
          height: 140,
          child: Center(
            child: Wrap(
              spacing: CatchSpacing.s3,
              children: [
                ReactionControlButton(
                  tooltip: 'Comment on photo',
                  icon: CatchIcons.chatBubbleOutlineRounded,
                  onPressed: _noopTap,
                  style: ProfileReactionControlsStyle.overlay,
                  isPending: true,
                ),
                ReactionControlButton(
                  tooltip: 'Like section unavailable',
                  icon: CatchIcons.favoriteBorderRounded,
                  onPressed: null,
                  style: ProfileReactionControlsStyle.surface,
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
  name: 'Reaction comment sheet states',
  type: ProfileReactionCommentSheet,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileReactionCommentSheetStates(BuildContext context) {
  return const _CatchesCatalog(
    title: 'ProfileReactionCommentSheet',
    contractId: 'screen.catches.event.reaction_comment_sheet',
    children: [
      _StateCard(
        label: 'empty draft',
        child: _SectionFrame(
          height: 440,
          child: ProfileReactionCommentSheet(target: _reactionTarget),
        ),
      ),
      _StateCard(
        label: 'filled draft',
        child: _SectionFrame(
          height: 440,
          child: ProfileReactionCommentSheet(
            target: _reactionTarget,
            initialComment: 'Your sunrise loop sounds like my kind of Sunday.',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Profile info chip states',
  type: ProfileInfoChip,
  path: '[P1 product surfaces]/Catches/Sections',
)
Widget profileInfoChipStates(BuildContext context) {
  return _CatchesCatalog(
    title: 'ProfileInfoChip',
    contractId: 'screen.catches.profile.info_chip',
    children: [
      _StateCard(
        label: 'short and long labels',
        child: _SectionFrame(
          height: 160,
          child: Padding(
            padding: CatchInsets.content,
            child: Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                ProfileInfoChip(
                  icon: CatchIcons.locationOnOutlined,
                  text: 'Bandra',
                ),
                ProfileInfoChip(
                  icon: CatchIcons.directionsRunOutlined,
                  text: 'Long run person who likes morning miles',
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

class _RecapRouteScope extends StatelessWidget {
  const _RecapRouteScope({
    required this.event,
    required this.recapValue,
    this.rosterProfiles,
  });

  final Event event;
  final AsyncValue<EventRecapViewModel?> recapValue;
  final Map<String, PublicProfile>? rosterProfiles;

  @override
  Widget build(BuildContext context) {
    final roster = rosterProfiles ?? _recapRosterProfiles();
    final attendeeIds = recapValue.asData?.value?.attendeeIds ?? roster.keys;

    return ProviderScope(
      overrides: [
        eventRecapViewModelProvider(event.id).overrideWith((ref) => recapValue),
        publicProfilesByIdsProvider(
          PublicProfilesQuery(attendeeIds),
        ).overrideWith((ref) async => roster),
      ],
      child: EventRecapScreen(eventId: event.id),
    );
  }
}

class _RecapReadyBodyPreview extends StatelessWidget {
  const _RecapReadyBodyPreview({
    required this.event,
    required this.attendeeIds,
    required this.selectedVibeIds,
  });

  final Event event;
  final List<String> attendeeIds;
  final Set<String> selectedVibeIds;

  @override
  Widget build(BuildContext context) {
    final ready = _recapReadyState(
      event: event,
      attendeeIds: attendeeIds,
      selectedVibeIds: selectedVibeIds,
    );

    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      body: EventRecapReadyBody(
        state: ready,
        onToggleVibe: _ignoreString,
        onOpenCatchesDeck: _ignoreRecapOpenDeck,
      ),
    );
  }
}

EventRecapReady _recapReadyState({
  required Event event,
  required List<String> attendeeIds,
  Map<String, PublicProfile>? rosterProfiles,
  Set<String> selectedVibeIds = const <String>{},
}) {
  final screenState = buildEventRecapScreenState(
    eventId: event.id,
    viewModel: CatchAsyncState.data(
      _recapViewModel(event: event, attendeeIds: attendeeIds),
    ),
    rosterProfiles: rosterProfiles ?? _recapRosterProfiles(),
    selectedVibeIds: selectedVibeIds,
    now: CatchesSurfaceFixtures.now,
  );

  return screenState as EventRecapReady;
}

const _missingRecapProfileUid = 'design-catches-missing-profile';

const _reactionTarget = ProfileReactionTarget(
  id: 'design-catches-prompt',
  type: SwipeReactionTargetType.profilePrompt,
  label: 'prompt',
  preview:
      'Ask me about the bookshop detour I take after long runs and the breakfast order I defend every Sunday.',
);

Map<String, PublicProfile> _recapRosterProfiles() {
  return {
    for (final profile in CatchesSurfaceFixtures.candidates)
      profile.uid: profile,
  };
}

EventRecapViewModel _recapViewModel({
  required Event event,
  required List<String> attendeeIds,
}) {
  return EventRecapViewModel(
    event: event,
    attendeeIds: attendeeIds,
    checkedInCount: attendeeIds.length + 1,
  );
}

ProfileView _profileView() {
  final profile = CatchesSurfaceFixtures.candidates.first;
  final content = ProfileCardContent.fromProfile(
    profile,
    viewerProfile: CatchesSurfaceFixtures.viewer,
    sharedRunTitle: CatchesSurfaceFixtures.openWindowEvent().title,
  );

  return profileViewFromCardContent(
    content,
    name: profile.name,
    age: profile.age,
    running: profile.activityPreferences.running,
    kicker: 'Was at · ${CatchesSurfaceFixtures.openWindowEvent().title}',
    kickerActivity: CatchesSurfaceFixtures.openWindowEvent().activityKind,
    metaLine: profile.city,
  );
}

T _profileSection<T extends ProfileSection>() {
  return _profileView().sections.whereType<T>().first;
}

void _noopTap() {}

void _ignoreString(String value) {}

void _ignoreRecapOpenDeck(EventRecapOpenDeckIntent intent) {}

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
