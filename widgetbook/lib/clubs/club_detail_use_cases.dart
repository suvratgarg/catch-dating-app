import "package:catch_dating_app/core/widgets/catch_meta_row.dart";
import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen_state.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_dock.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_contact_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_skeleton.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_host_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_photo_strip.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_share_card.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_avatar_rail.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_discover_list.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_list_tile.dart';
import 'package:catch_dating_app/clubs/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/shared/reviews_section.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _viewerUid = 'widgetbook-club-viewer';
const _clubId = 'widgetbook-sea-face-social';
final _now = DateTime(2026, 6, 22, 9);

final _club = Club(
  id: _clubId,
  name: 'Sea Face Social',
  description:
      'A member-led running club for low-pressure miles, good coffee, and people who remember your name.',
  location: 'mumbai',
  area: 'Bandra',
  hostUserId: 'host-mira',
  hostName: 'Mira',
  hostAvatarUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&q=80',
  ownerUserId: 'host-mira',
  hostUserIds: const ['host-mira', 'host-rishi'],
  hostProfiles: const [
    ClubHostProfile(
      uid: 'host-mira',
      displayName: 'Mira Shah',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&q=80',
      role: ClubHostRole.owner,
    ),
    ClubHostProfile(
      uid: 'host-rishi',
      displayName: 'Rishi Mehta',
      avatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=160&q=80',
    ),
  ],
  createdAt: DateTime(2025, 9, 12),
  imageUrl:
      'https://images.unsplash.com/photo-1502904550040-7534597429ae?w=1200&q=80',
  clubPhotos: [
    _photo('club-photo-cafe', 0),
    _photo('club-photo-bandstand', 1),
    _photo('club-photo-post-run', 2),
  ],
  tags: const ['running', 'coffee', 'new members', 'sunrise'],
  memberCount: 214,
  rating: 4.9,
  reviewCount: 58,
  nextEventAt: DateTime(2026, 6, 24, 6, 45),
  nextEventLabel: 'Wed 6:45 AM',
  instagramHandle: '@seafacesocial',
  phoneNumber: '+91 98765 43210',
  email: 'hello@seafacesocial.example',
  hostDefaults: const ClubHostDefaults(
    primaryActivityKind: ActivityKind.socialRun,
    supportedActivityKinds: [ActivityKind.walking, ActivityKind.dinner],
  ),
);

final _minimalClub = _club.copyWith(
  id: 'widgetbook-quiet-club',
  name: 'Quiet Table Club',
  description:
      'A small supper club for regulars who want familiar faces and low-key evenings.',
  imageUrl: null,
  clubPhotos: const [],
  hostProfiles: const [
    ClubHostProfile(
      uid: 'host-ana',
      displayName: 'Ana Rao',
      role: ClubHostRole.owner,
    ),
  ],
  tags: const ['dinner', 'conversation'],
  memberCount: 28,
  rating: 0,
  reviewCount: 0,
  instagramHandle: null,
  phoneNumber: null,
  email: null,
  hostDefaults: const ClubHostDefaults(
    primaryActivityKind: ActivityKind.dinner,
  ),
);

final _logoClub = _club.copyWith(
  profileImageUrl:
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=160&q=80',
);

final _logoOnlyHeroClub = _minimalClub.copyWith(
  id: 'widgetbook-logo-only-club',
  name: 'Bandra Dawn Club',
  logoPhoto: _photo('club-logo-dawn', 0),
);

final _events = [
  _event(
    id: 'widgetbook-sunrise-6k',
    startTime: DateTime(2026, 6, 24, 6, 45),
    meetingPoint: 'Bandstand promenade',
    distanceKm: 6,
    bookedCount: 16,
    capacityLimit: 22,
    description: 'Morning miles with regroup points and a cafe finish.',
  ),
  _event(
    id: 'widgetbook-weekend-walk',
    startTime: DateTime(2026, 6, 28, 8),
    meetingPoint: 'Bandra Fort gate',
    activityKind: ActivityKind.walking,
    distanceKm: 3,
    bookedCount: 19,
    capacityLimit: 28,
    description: 'A social weekend walk for new members.',
  ),
];

final _sameDayScheduleEvents = [
  _event(
    id: 'widgetbook-thursday-dawn-5k',
    startTime: DateTime(2026, 6, 25, 6, 30),
    meetingPoint: 'Bandra Fort gate',
    distanceKm: 5,
    bookedCount: 12,
    capacityLimit: 18,
    description: 'A steady start for weekday regulars.',
  ),
  _event(
    id: 'widgetbook-thursday-evening-8k',
    startTime: DateTime(2026, 6, 25, 18, 15),
    meetingPoint: 'Carter Road amphitheatre',
    distanceKm: 8,
    bookedCount: 17,
    capacityLimit: 20,
    description: 'A social evening loop with a cool-down walk.',
  ),
];

final _reviews = [
  Review(
    id: 'widgetbook-club-review-1',
    clubId: _club.id,
    reviewerUserId: 'runner-neha',
    reviewerName: 'Neha',
    rating: 5,
    comment: 'Friendly hosts, clear routes, and zero awkward hovering.',
    createdAt: DateTime(2026, 5, 24),
  ),
  Review(
    id: 'widgetbook-club-review-2',
    clubId: _club.id,
    reviewerUserId: 'runner-dev',
    reviewerName: 'Dev',
    rating: 5,
    comment: 'The pace groups make it easy to show up without knowing anyone.',
    createdAt: DateTime(2026, 5, 31),
    ownerResponse: ReviewOwnerResponse(
      hostUserId: 'host-mira',
      hostName: 'Mira Shah',
      hostAvatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&q=80',
      message: 'Thanks for joining the new 6K group. We will keep that pace.',
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
    ),
  ),
];

final _viewer = UserProfile(
  uid: _viewerUid,
  name: 'Neha Kapoor',
  firstName: 'Neha',
  lastName: 'Kapoor',
  displayName: 'Neha',
  dateOfBirth: DateTime(1996, 4, 12),
  gender: Gender.woman,
  phoneNumber: '+919876543210',
  profileComplete: true,
  city: 'Mumbai',
  interestedInGenders: const [Gender.man],
);

@widgetbook.UseCase(
  name: 'Screen states',
  type: ClubDetailScreen,
  path: '[Club Detail]/Screen',
)
Widget clubDetailScreenStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubDetailScreen',
    catalogId: 'screen.club.detail',
    children: [
      _StateCard(
        label: 'member default',
        description:
            'Authenticated member with events, hosts, photos, contact, and reviews.',
        child: _DeviceFrame(
          child: _ClubScreenPreview(
            uid: _viewerUid,
            membership: _membership(pushNotificationsEnabled: true),
            viewModel: AsyncData(_viewModel(isMember: true)),
          ),
        ),
      ),
      _StateCard(
        label: 'visitor',
        description: 'Authenticated user who can join the club.',
        child: _DeviceFrame(
          child: _ClubScreenPreview(
            uid: _viewerUid,
            membership: null,
            viewModel: AsyncData(_viewModel(isMember: false)),
          ),
        ),
      ),
      _StateCard(
        label: 'guest join',
        description:
            'Signed-out viewer; the dock switches to sign-in affordance.',
        child: _DeviceFrame(
          child: _ClubScreenPreview(
            uid: null,
            membership: null,
            viewModel: AsyncData(
              _viewModel(
                uid: null,
                includeUserProfile: false,
                isMember: false,
                isAuthenticated: false,
              ),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'loading',
        child: const _DeviceFrame(
          height: 480,
          child: _ClubScreenPreview(
            uid: _viewerUid,
            membership: null,
            viewModel: AsyncLoading<ClubDetailViewModel?>(),
            useInitialClub: false,
          ),
        ),
      ),
      _StateCard(
        label: 'missing club',
        child: const _DeviceFrame(
          height: 480,
          child: _ClubScreenPreview(
            uid: _viewerUid,
            membership: null,
            viewModel: AsyncData<ClubDetailViewModel?>(null),
            useInitialClub: false,
          ),
        ),
      ),
      _StateCard(
        label: 'fatal error',
        child: _DeviceFrame(
          height: 480,
          child: _ClubScreenPreview(
            uid: _viewerUid,
            membership: null,
            viewModel: AsyncError<ClubDetailViewModel?>(
              StateError('Widgetbook club detail load failed'),
              StackTrace.empty,
            ),
            useInitialClub: false,
          ),
        ),
      ),
      _StateCard(
        label: 'offline fallback',
        description:
            'Current generic data-load fallback until explicit offline copy is defined.',
        child: _DeviceFrame(
          height: 480,
          child: _ClubScreenPreview(
            uid: _viewerUid,
            membership: null,
            viewModel: AsyncError<ClubDetailViewModel?>(
              StateError('No network connection for Club Detail'),
              StackTrace.empty,
            ),
            useInitialClub: false,
          ),
        ),
      ),
      _StateCard(
        label: 'pending mutation',
        description: 'Screen composition with a loading Join affordance.',
        child: _DeviceFrame(
          child: _ClubComposedPreview(
            isMember: false,
            isAuthenticated: true,
            isMutating: true,
          ),
        ),
      ),
      _StateCard(
        label: 'failed mutation',
        description: 'Static review state for persistent mutation feedback.',
        child: _DeviceFrame(
          child: _ClubComposedPreview(
            isMember: false,
            isAuthenticated: true,
            mutationError: StateError('Could not join this club.'),
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2.0',
        description:
            'Tall text-scale review target for hero, host rows, reviews, and dock.',
        child: _MediaOverride(
          textScaler: const TextScaler.linear(2),
          child: _DeviceFrame(
            child: _ClubScreenPreview(
              uid: _viewerUid,
              membership: _membership(pushNotificationsEnabled: true),
              viewModel: AsyncData(_viewModel(isMember: true)),
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        description:
            'Screen review target with platform animation suppression enabled.',
        child: _MediaOverride(
          disableAnimations: true,
          child: _DeviceFrame(
            child: _ClubScreenPreview(
              uid: _viewerUid,
              membership: _membership(pushNotificationsEnabled: true),
              viewModel: AsyncData(_viewModel(isMember: true)),
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Loading body states',
  type: ClubDetailLoadingBody,
  path: '[Club Detail]/Sections',
)
Widget clubDetailLoadingBodyStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubDetailLoadingBody',
    catalogId: 'screen.club.detail.loading_body',
    children: const [
      _StateCard(
        label: 'skeleton',
        child: _DeviceFrame(child: ClubDetailLoadingBody()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero skeleton states',
  type: ClubHeroLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubHeroLoadingSkeletonStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ClubHeroLoadingSkeleton',
    catalogId: 'loading.club.detail.hero',
    children: [
      _StateCard(
        label: 'default',
        child: _DeviceFrame(height: 260, child: ClubHeroLoadingSkeleton()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Stats skeleton states',
  type: ClubStatsLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubStatsLoadingSkeletonStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ClubStatsLoadingSkeleton',
    catalogId: 'loading.club.detail.stats',
    children: [
      _StateCard(label: 'four metrics', child: ClubStatsLoadingSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Stat skeleton states',
  type: ClubStatLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubStatLoadingSkeletonStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ClubStatLoadingSkeleton',
    catalogId: 'loading.club.detail.stat',
    children: [
      _StateCard(label: 'value and label', child: ClubStatLoadingSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Stats divider skeleton states',
  type: ClubStatsDividerSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubStatsDividerSkeletonStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ClubStatsDividerSkeleton',
    catalogId: 'loading.club.detail.stats_divider',
    children: [
      _StateCard(
        label: 'hairline',
        child: SizedBox(
          height: 72,
          child: Center(child: ClubStatsDividerSkeleton()),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host skeleton states',
  type: ClubHostLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubHostLoadingSkeletonStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ClubHostLoadingSkeleton',
    catalogId: 'loading.club.detail.host',
    children: [_StateCard(label: 'host row', child: ClubHostLoadingSkeleton())],
  );
}

@widgetbook.UseCase(
  name: 'Text skeleton states',
  type: ClubTextLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubTextLoadingSkeletonStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ClubTextLoadingSkeleton',
    catalogId: 'loading.club.detail.text',
    children: [
      _StateCard(
        label: 'three lines',
        child: ClubTextLoadingSkeleton(lines: 3),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tag skeleton states',
  type: CatchSkeletonChips,
  path: '[Club Detail]/Loading',
)
Widget clubTagLoadingSkeletonStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'CatchSkeletonChips',
    catalogId: 'loading.club.detail.tags',
    children: [
      _StateCard(
        label: 'three chips',
        child: CatchSkeletonChips(height: CatchSpacing.s8),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Schedule skeleton states',
  type: ClubScheduleLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubScheduleLoadingSkeletonStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ClubScheduleLoadingSkeleton',
    catalogId: 'loading.club.detail.schedule',
    children: [
      _StateCard(label: 'two cards', child: ClubScheduleLoadingSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Provider dock states',
  type: ClubMembershipDock,
  path: '[Club Detail]/Sections',
)
Widget clubMembershipDockStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubMembershipDock',
    catalogId: 'section.club.membership_dock_provider',
    children: [
      _StateCard(
        label: 'visitor',
        child: _DockFrame(
          child: ClubMembershipDock(
            club: _club,
            isMember: false,
            isAuthenticated: true,
            isMutating: false,
            pushNotificationsEnabled: false,
            isPushMutating: false,
          ),
        ),
      ),
      _StateCard(
        label: 'member pending push',
        child: _DockFrame(
          child: ClubMembershipDock(
            club: _club,
            isMember: true,
            isAuthenticated: true,
            isMutating: false,
            pushNotificationsEnabled: true,
            isPushMutating: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Dock states',
  type: ClubDetailDock,
  path: '[Club Detail]/Dock',
)
Widget clubDetailDockStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubDetailDock',
    catalogId: 'section.club.detail_dock',
    children: [
      _StateCard(
        label: 'guest',
        child: _DockFrame(
          child: ClubDetailDock(
            state: ClubDetailDockRole.guest,
            activityKind: ActivityKind.socialRun,
            footnote: 'Sign in to request access.',
            onSignIn: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'visitor',
        child: _DockFrame(
          child: ClubDetailDock(
            state: ClubDetailDockRole.visitor,
            activityKind: ActivityKind.pickleball,
            members: 128,
            footnote: 'Requests are approved by the host.',
            onJoin: _noop,
          ),
        ),
      ),
      const _StateCard(
        label: 'visitor pending',
        child: _DockFrame(
          child: ClubDetailDock(
            state: ClubDetailDockRole.visitor,
            activityKind: ActivityKind.dinner,
            members: 42,
            isJoinLoading: true,
          ),
        ),
      ),
      _StateCard(
        label: 'member',
        child: _DockFrame(
          child: ClubDetailDock(
            state: ClubDetailDockRole.member,
            activityKind: ActivityKind.yoga,
            members: 76,
            footnote: 'You are a member.',
            onBell: _noop,
            onManage: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'member bell pending',
        child: _DockFrame(
          child: ClubDetailDock(
            state: ClubDetailDockRole.member,
            activityKind: ActivityKind.socialRun,
            members: 76,
            notificationsEnabled: false,
            isBellLoading: true,
            onBell: _noop,
            onManage: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'owner',
        child: _DockFrame(
          child: ClubDetailDock(
            state: ClubDetailDockRole.owner,
            activityKind: ActivityKind.pubQuiz,
            onManage: _noop,
            onCreate: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Dock count states',
  type: DockCount,
  path: '[Club Detail]/Dock',
)
Widget dockCountStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'DockCount',
    catalogId: 'section.club.dock.count',
    children: [
      _StateCard(
        label: 'member count',
        child: DockCount(members: 214, label: 'MEMBERS'),
      ),
      _StateCard(
        label: 'short label',
        child: DockCount(members: 8, label: 'GOING'),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Dock bell states',
  type: DockBell,
  path: '[Club Detail]/Dock',
)
Widget dockBellStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'DockBell',
    catalogId: 'section.club.dock.bell',
    children: [
      _StateCard(
        label: 'active',
        child: DockBell(
          active: true,
          accent: t.primary,
          isLoading: false,
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'inactive',
        child: DockBell(
          active: false,
          accent: t.primary,
          isLoading: false,
          onPressed: _noop,
        ),
      ),
      _StateCard(
        label: 'loading',
        child: DockBell(
          active: true,
          accent: t.primary,
          isLoading: true,
          onPressed: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Avatar rail states',
  type: ClubAvatarRail,
  path: '[Club Discovery]/Sections',
)
Widget clubAvatarRailStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubAvatarRail',
    catalogId: 'section.club.avatar_rail',
    children: [
      _StateCard(
        label: 'joined clubs',
        child: ClubAvatarRail(clubs: [_club, _minimalClub]),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Discover list states',
  type: ClubDiscoverList,
  path: '[Club Discovery]/Sections',
)
Widget clubDiscoverListStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubDiscoverList',
    catalogId: 'section.club.discover_list',
    children: [
      _StateCard(
        label: 'directory sliver',
        child: _SliverFrame(
          height: 760,
          slivers: [
            ClubDiscoverList(
              clubs: [_club, _minimalClub],
              joinedClubIds: {_club.id},
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'List tile states',
  type: ClubListTile,
  path: '[Club Discovery]/Cards',
)
Widget clubListTileStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubListTile',
    catalogId: 'card.club.list_tile',
    children: [
      _StateCard(
        label: 'directory photo',
        child: ClubListTile(club: _club, isJoined: true),
      ),
      _StateCard(
        label: 'avatar chip',
        child: ClubListTile(
          club: _minimalClub,
          variant: ClubListTileVariant.avatarChip,
          showLiveBadge: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Avatar chip states',
  type: AvatarChip,
  path: '[Club Discovery]/Atoms',
)
Widget avatarChipStates(BuildContext context) {
  return _CatalogScreen(
    title: 'AvatarChip',
    catalogId: 'atom.club.avatar_chip',
    children: [
      _StateCard(
        label: 'default',
        child: AvatarChip(club: _logoClub),
      ),
      _StateCard(
        label: 'event soon',
        child: AvatarChip(club: _minimalClub, showLiveBadge: true),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Club image states',
  type: ClubImage,
  path: '[Club Discovery]/Atoms',
)
Widget clubImageStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubImage',
    catalogId: 'atom.club.image',
    children: [
      _StateCard(
        label: 'cover first',
        child: _ClubMediaFrame(child: ClubImage(club: _club)),
      ),
      _StateCard(
        label: 'profile first',
        child: _ClubMediaFrame(
          child: ClubImage(club: _logoClub, preferProfileImage: true),
        ),
      ),
      _StateCard(
        label: 'fallback',
        child: _ClubMediaFrame(child: ClubImage(club: _minimalClub)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Directory card states',
  type: DirectoryCard,
  path: '[Club Discovery]/Cards',
)
Widget directoryCardStates(BuildContext context) {
  return _CatalogScreen(
    title: 'DirectoryCard',
    catalogId: 'card.club.directory',
    children: [
      _StateCard(
        label: 'photo / joinable',
        child: _ClubDiscoveryFrame(
          child: _ClubDirectoryPreviewScope(
            child: DirectoryCard(club: _logoClub, isJoined: false),
          ),
        ),
      ),
      _StateCard(
        label: 'identity / joined',
        child: _ClubDiscoveryFrame(
          child: DirectoryCard(club: _minimalClub, isJoined: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Directory club card states',
  type: DirectoryClubCard,
  path: '[Club Discovery]/Cards',
)
Widget directoryClubCardStates(BuildContext context) {
  return _CatalogScreen(
    title: 'DirectoryClubCard',
    catalogId: 'card.club.directory_club',
    children: [
      _StateCard(
        label: 'photo / joinable',
        child: _ClubDiscoveryFrame(
          child: _ClubDirectoryPreviewScope(
            child: DirectoryClubCard(
              club: _logoClub,
              isJoined: false,
              hasCoverImage: true,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'identity / joined',
        child: _ClubDiscoveryFrame(
          child: _ClubDirectoryPreviewScope(
            child: DirectoryClubCard(
              club: _minimalClub,
              isJoined: true,
              hasCoverImage: false,
            ),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Directory footer states',
  type: ClubDirectoryFooter,
  path: '[Club Discovery]/Atoms',
)
Widget clubDirectoryFooterStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubDirectoryFooter',
    catalogId: 'atom.club.directory_footer',
    children: [
      _StateCard(
        label: 'rating / host / tags',
        child: _ClubDirectoryPreviewScope(
          child: ClubDirectoryFooter(
            club: _logoClub,
            isJoined: false,
            visibleTags: visibleClubTags(_logoClub, limit: 3),
          ),
        ),
      ),
      _StateCard(
        label: 'joined / no rating',
        child: ClubDirectoryFooter(
          club: _minimalClub,
          isJoined: true,
          visibleTags: visibleClubTags(_minimalClub, limit: 3),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host action row states',
  type: ClubHostActionRow,
  path: '[Club Discovery]/Atoms',
)
Widget clubHostActionRowStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubHostActionRow',
    catalogId: 'atom.club.host_action_row',
    children: [
      _StateCard(
        label: 'joinable',
        child: _ClubDirectoryPreviewScope(
          child: ClubHostActionRow(club: _logoClub, isJoined: false),
        ),
      ),
      _StateCard(
        label: 'joined',
        child: ClubHostActionRow(club: _minimalClub, isJoined: true),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Membership trailing controller states',
  type: MembershipTrailingController,
  path: '[Club Discovery]/Atoms',
)
Widget membershipTrailingControllerStates(BuildContext context) {
  return _CatalogScreen(
    title: 'MembershipTrailingController',
    catalogId: 'atom.club.membership_trailing_controller',
    children: [
      _StateCard(
        label: 'joinable controller',
        child: _ClubDirectoryPreviewScope(
          child: MembershipTrailingController(
            clubId: _club.id,
            isJoined: false,
          ),
        ),
      ),
      const _StateCard(
        label: 'joined controller',
        child: MembershipTrailingController(clubId: _clubId, isJoined: true),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Membership trailing states',
  type: MembershipTrailing,
  path: '[Club Discovery]/Atoms',
)
Widget membershipTrailingStates(BuildContext context) {
  return _CatalogScreen(
    title: 'MembershipTrailing',
    catalogId: 'atom.club.membership_trailing',
    children: [
      _StateCard(
        label: 'join button',
        child: MembershipTrailing(
          isJoined: false,
          isPending: false,
          onJoinPressed: () {},
        ),
      ),
      const _StateCard(
        label: 'pending',
        child: MembershipTrailing(
          isJoined: false,
          isPending: true,
          onJoinPressed: null,
        ),
      ),
      const _StateCard(
        label: 'joined hidden',
        child: MembershipTrailing(
          isJoined: true,
          isPending: false,
          onJoinPressed: null,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo media overlay states',
  type: ClubPhotoMediaOverlay,
  path: '[Club Discovery]/Atoms',
)
Widget clubPhotoMediaOverlayStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubPhotoMediaOverlay',
    catalogId: 'atom.club.photo_media_overlay',
    children: [
      _StateCard(
        label: 'cover image',
        child: _ClubMediaFrame(child: ClubPhotoMediaOverlay(club: _club)),
      ),
      _StateCard(
        label: 'fallback image order',
        child: _ClubMediaFrame(
          child: ClubPhotoMediaOverlay(club: _minimalClub),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo chrome states',
  type: ClubPhotoChrome,
  path: '[Club Discovery]/Atoms',
)
Widget clubPhotoChromeStates(BuildContext context) {
  final palette = ClubCoverVisualPalette.forClub(context, _logoClub);
  return _CatalogScreen(
    title: 'ClubPhotoChrome',
    catalogId: 'atom.club.photo_chrome',
    children: [
      _StateCard(
        label: 'logo / member seal',
        child: _ClubMediaFrame(
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClubPhotoMediaOverlay(club: _club),
              ClubPhotoChrome(club: _logoClub, sash: null, palette: palette),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Logo crest states',
  type: ClubLogoCrest,
  path: '[Club Discovery]/Atoms',
)
Widget clubLogoCrestStates(BuildContext context) {
  final palette = ClubCoverVisualPalette.forClub(context, _logoClub);
  return _CatalogScreen(
    title: 'ClubLogoCrest',
    catalogId: 'atom.club.logo_crest',
    children: [
      _StateCard(
        label: 'photo logo',
        child: ClubLogoCrest(
          club: _logoClub,
          palette: palette,
          size: 64,
          borderColor: CatchTokens.editorialLight,
          borderWidth: 2,
        ),
      ),
      _StateCard(
        label: 'fallback',
        child: ClubLogoCrest(
          club: _minimalClub,
          palette: ClubCoverVisualPalette.forClub(context, _minimalClub),
          size: 64,
          borderColor: CatchTokens.editorialLight,
          borderWidth: 2,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Logo fallback states',
  type: ClubLogoFallback,
  path: '[Club Discovery]/Atoms',
)
Widget clubLogoFallbackStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'ClubLogoFallback',
    catalogId: 'atom.club.logo_fallback',
    children: [
      _StateCard(
        label: 'empty mark',
        child: SizedBox.square(
          dimension: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const ClipOval(child: ClubLogoFallback()),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Rule states',
  type: ClubRule,
  path: '[Club Discovery]/Atoms',
)
Widget clubRuleStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'ClubRule',
    catalogId: 'atom.club.rule',
    children: [
      _StateCard(
        label: 'hairline',
        child: ClubRule(color: t.line),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Polaroid states',
  type: CatchPolaroid,
  path: '[Club Discovery]/Cards',
)
Widget catchPolaroidStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchPolaroid',
    catalogId: 'card.club.polaroid',
    children: [
      _StateCard(
        label: 'with footer',
        child: CatchPolaroid(
          media: ClubPolaroidArtwork(club: _club),
          caption: 'WED 6:45 AM',
          title: _club.name,
          subtitle: _club.description,
          footer: ClubTagWrap(tags: visibleClubTags(_club, limit: 3)),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Artwork states',
  type: ClubPolaroidArtwork,
  path: '[Club Discovery]/Cards',
)
Widget clubPolaroidArtworkStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubPolaroidArtwork',
    catalogId: 'card.club.polaroid_artwork',
    children: [
      _StateCard(
        label: 'standard',
        child: AspectRatio(
          aspectRatio: 1,
          child: ClubPolaroidArtwork(club: _club),
        ),
      ),
      _StateCard(
        label: 'compact',
        child: SizedBox.square(
          dimension: 120,
          child: ClubPolaroidArtwork(club: _minimalClub, compact: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Member seal states',
  type: ClubMemberSeal,
  path: '[Club Discovery]/Atoms',
)
Widget clubMemberSealStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'ClubMemberSeal',
    catalogId: 'atom.club.member_seal',
    children: [
      _StateCard(
        label: 'default',
        child: ClubMemberSeal(
          label: clubMemberCountLabel(_club),
          accent: t.primary,
        ),
      ),
      _StateCard(
        label: 'compact',
        child: ClubMemberSeal(
          label: clubMemberCountLabel(_minimalClub),
          accent: t.primary,
          compact: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tag wrap states',
  type: ClubTagWrap,
  path: '[Club Discovery]/Atoms',
)
Widget clubTagWrapStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubTagWrap',
    catalogId: 'atom.club.tag_wrap',
    children: [
      _StateCard(
        label: 'brand tags',
        child: ClubTagWrap(tags: visibleClubTags(_club, limit: 4)),
      ),
      const _StateCard(
        label: 'neutral mixed case',
        child: ClubTagWrap(
          tags: ['coffee', 'first timers'],
          tone: CatchBadgeTone.neutral,
          uppercase: false,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host identity states',
  type: ClubHostIdentityLine,
  path: '[Club Discovery]/Atoms',
)
Widget clubHostIdentityLineStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubHostIdentityLine',
    catalogId: 'atom.club.host_identity_line',
    children: [
      _StateCard(
        label: 'with trailing',
        child: ClubHostIdentityLine(
          hostName: _club.displayHostName,
          hostAvatarUrl: _club.hostAvatarUrl,
          trailing: const ClubHostRoleBadge(role: ClubHostRole.owner),
        ),
      ),
      _StateCard(
        label: 'fallback avatar',
        child: ClubHostIdentityLine(hostName: _minimalClub.displayHostName),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Role badge states',
  type: ClubHostRoleBadge,
  path: '[Club Discovery]/Atoms',
)
Widget clubHostRoleBadgeStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ClubHostRoleBadge',
    catalogId: 'atom.club.host_role_badge',
    children: [
      _StateCard(
        label: 'owner',
        child: ClubHostRoleBadge(role: ClubHostRole.owner),
      ),
      _StateCard(
        label: 'host',
        child: ClubHostRoleBadge(role: ClubHostRole.host),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Rating pill states',
  type: ClubRatingPill,
  path: '[Club Discovery]/Atoms',
)
Widget clubRatingPillStates(BuildContext context) {
  return const _CatalogScreen(
    title: 'ClubRatingPill',
    catalogId: 'atom.club.rating_pill',
    children: [
      _StateCard(label: 'high rating', child: ClubRatingPill(rating: 4.9)),
      _StateCard(label: 'new rating', child: ClubRatingPill(rating: 3.8)),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Body composition',
  type: ClubDetailBody,
  path: '[Club Detail]/Sections',
)
Widget clubDetailBodyComposition(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubDetailBody',
    catalogId: 'screen.club.detail.sections.body',
    children: [
      _StateCard(
        label: 'host / overview / photos / contact',
        description:
            'Body composition exercises the screen-local hosts, about, photo, and contact sections together.',
        child: _DeviceFrame(
          child: _ClubComposedPreview(isMember: true, isAuthenticated: true),
        ),
      ),
      _StateCard(
        label: 'minimal club',
        description:
            'No cover, no photos, no contact, no reviews, empty schedule.',
        child: _DeviceFrame(
          child: _ClubComposedPreview(
            club: _minimalClub,
            events: const [],
            reviews: const [],
            isMember: false,
            isAuthenticated: true,
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion candidate',
        description:
            'Same composition in a static review frame; future motion checks should pin route transitions separately.',
        child: _DeviceFrame(
          child: _ClubComposedPreview(isMember: true, isAuthenticated: true),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Next run banner states',
  type: ClubNextRunBanner,
  path: '[Club Detail]/Sections',
)
Widget clubNextRunBannerStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubNextRunBanner',
    catalogId: 'section.club.next_run_banner',
    children: [
      _StateCard(
        label: 'tap target',
        child: ClubNextRunBanner(event: _events.first, onTap: _noop),
      ),
      _StateCard(
        label: 'display only',
        child: ClubNextRunBanner(event: _events[1]),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Activity section states',
  type: ClubActivitySection,
  path: '[Club Detail]/Sections',
)
Widget clubActivitySectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubActivitySection',
    catalogId: 'section.club.activity',
    children: [
      _StateCard(
        label: 'activity and tags',
        child: ClubActivitySection(
          club: _club,
          tags: visibleClubTags(_club, limit: 6),
        ),
      ),
      _StateCard(
        label: 'generic dinner tags',
        child: ClubActivitySection(
          club: _minimalClub,
          tags: visibleClubTags(_minimalClub, limit: 4),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host section states',
  type: ClubHostSection,
  path: '[Club Detail]/Sections',
)
Widget clubHostSectionStates(BuildContext context) {
  final messageableState = ClubDetailBodyState.fromDomain(
    club: _club,
    uid: _viewerUid,
    isAuthenticated: true,
  );

  return _CatalogScreen(
    title: 'ClubHostSection',
    catalogId: 'section.club.hosts',
    children: [
      _StateCard(
        label: 'messageable hosts',
        child: ClubHostSection(
          club: _club,
          canViewProfile: true,
          isMessageHostPending: false,
          messageableHostUids: messageableState.messageableHostUids,
          onViewProfile: (_) {},
          onMessageHost: (_, _) async {},
        ),
      ),
      _StateCard(
        label: 'public preview',
        child: ClubHostSection(
          club: _club,
          canViewProfile: false,
          isMessageHostPending: false,
          messageableHostUids: const {},
          onViewProfile: null,
          onMessageHost: null,
        ),
      ),
      _StateCard(
        label: 'message pending',
        child: ClubHostSection(
          club: _club,
          canViewProfile: true,
          isMessageHostPending: true,
          messageableHostUids: messageableState.messageableHostUids,
          onViewProfile: (_) {},
          onMessageHost: (_, _) async {},
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host row states',
  type: ClubHostRow,
  path: '[Club Detail]/Sections',
)
Widget clubHostRowStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubHostRow',
    catalogId: 'section.club.hosts.row',
    children: [
      _StateCard(
        label: 'owner / message / chevron',
        child: ClubHostRow(
          host: _club.displayHostProfiles.first,
          borderColor: CatchTokens.of(context).primarySoft,
          showChevron: true,
          onMessage: _noop,
        ),
      ),
      _StateCard(
        label: 'public profile',
        child: ClubHostRow(
          host: _club.displayHostProfiles.last,
          borderColor: CatchTokens.of(context).primarySoft,
          showChevron: false,
          onMessage: null,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contact section states',
  type: ClubContactSection,
  path: '[Club Detail]/Sections',
)
Widget clubContactSectionStates(BuildContext context) {
  final contactState = ClubDetailBodyState.fromDomain(club: _club);

  return _CatalogScreen(
    title: 'ClubContactSection',
    catalogId: 'section.club.contact',
    children: [
      _StateCard(
        label: 'all channels',
        child: ClubContactSection(
          actions: contactState.contactActions,
          onContactSelected: (_) async {},
        ),
      ),
      const _StateCard(
        label: 'empty',
        child: ClubContactSection(actions: []),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Photo strip states',
  type: ClubPhotoStrip,
  path: '[Club Detail]/Sections',
)
Widget clubPhotoStripStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubPhotoStrip',
    catalogId: 'section.club.photos',
    children: [
      _StateCard(
        label: 'three photos',
        child: ClubPhotoStrip(club: _club),
      ),
      _StateCard(
        label: 'single photo',
        child: ClubPhotoStrip(
          club: _club.copyWith(clubPhotos: [_club.clubPhotos.first]),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero states',
  type: ClubHeroAppBar,
  path: '[Club Detail]/Sections',
)
Widget clubHeroAppBarStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubHeroAppBar',
    catalogId: 'section.club.hero',
    children: [
      _StateCard(
        label: 'photo polaroid',
        child: _SliverFrame(
          height: 560,
          slivers: [
            ClubHeroAppBar(
              club: _club,
              isHost: false,
              onShareClub: _ignoreShare,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 180)),
          ],
        ),
      ),
      _StateCard(
        label: 'logo masthead',
        child: _SliverFrame(
          height: 500,
          slivers: [
            ClubHeroAppBar(
              club: _logoOnlyHeroClub,
              isHost: false,
              onShareClub: _ignoreShare,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 180)),
          ],
        ),
      ),
      _StateCard(
        label: 'art polaroid',
        child: _SliverFrame(
          height: 560,
          slivers: [
            ClubHeroAppBar(
              club: _minimalClub,
              isHost: false,
              onShareClub: _ignoreShare,
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 180)),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero module states',
  type: ClubHeroModule,
  path: '[Club Detail]/Sections',
)
Widget clubHeroModuleStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubHeroModule',
    catalogId: 'section.club.hero.module',
    children: [
      _StateCard(
        label: 'photo polaroid module',
        child: _DeviceFrame(
          height: 460,
          child: ClubHeroModule(
            club: _club,
            variant: ClubHeroVariant.polaroid,
            mediaHeight: 280,
            captionExtent: CatchLayout.clubDetailHeroCaptionExtent,
            kickerLabel: 'BANDRA · MUMBAI',
            locationLabel: 'Bandstand promenade',
          ),
        ),
      ),
      _StateCard(
        label: 'logo masthead module',
        child: _DeviceFrame(
          height: 420,
          child: ClubHeroModule(
            club: _logoOnlyHeroClub,
            variant: ClubHeroVariant.masthead,
            mediaHeight: 220,
            captionExtent: CatchLayout.clubDetailHeroCaptionExtent,
            kickerLabel: 'DINNER · MUMBAI',
            locationLabel: 'Khar Social',
          ),
        ),
      ),
      _StateCard(
        label: 'art polaroid module',
        child: _DeviceFrame(
          height: 420,
          child: ClubHeroModule(
            club: _minimalClub,
            variant: ClubHeroVariant.polaroid,
            mediaHeight: 220,
            captionExtent: CatchLayout.clubDetailHeroCaptionExtent,
            kickerLabel: 'DINNER · MUMBAI',
            locationLabel: 'Khar Social',
          ),
        ),
      ),
      _StateCard(
        label: 'full review module',
        child: _DeviceFrame(
          height: 460,
          child: ClubHeroModule(
            club: _club,
            variant: ClubHeroVariant.full,
            mediaHeight: 280,
            captionExtent: CatchLayout.clubDetailHeroCaptionExtent,
            kickerLabel: 'BANDRA · MUMBAI',
            locationLabel: 'Bandstand promenade',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Share card states',
  type: ClubShareCard,
  path: '[Club Detail]/Cards',
)
Widget clubShareCardStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubShareCard',
    catalogId: 'card.club.share',
    children: [
      _StateCard(
        label: 'cover photo',
        child: ClubShareCard(club: _club),
      ),
      _StateCard(
        label: 'polaroid fallback',
        child: ClubShareCard(club: _minimalClub),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Share artwork states',
  type: ClubShareArtwork,
  path: '[Club Detail]/Cards',
)
Widget clubShareArtworkStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubShareArtwork',
    catalogId: 'card.club.share.artwork',
    children: [
      _StateCard(
        label: 'cover photo',
        child: _ClubMediaFrame(child: ClubShareArtwork(club: _club)),
      ),
      _StateCard(
        label: 'polaroid fallback',
        child: _ClubMediaFrame(child: ClubShareArtwork(club: _minimalClub)),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Share meta row states',
  type: CatchMetaRow,
  path: '[Club Detail]/Cards',
)
Widget clubShareMetaRowStates(BuildContext context) {
  return _CatalogScreen(
    title: 'CatchMetaRow',
    catalogId: 'card.club.share.meta_row',
    children: [
      _StateCard(
        label: 'location',
        child: CatchMetaRow(
          icon: CatchIcons.locationOnOutlined,
          label: 'Bandra, Mumbai',
        ),
      ),
      _StateCard(
        label: 'member count',
        child: CatchMetaRow(
          icon: CatchIcons.group,
          label: clubMemberCountLabel(_club),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Schedule states',
  type: ClubScheduleSection,
  path: '[Club Detail]/Sections',
)
Widget clubScheduleSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubScheduleSection',
    catalogId: 'section.club.schedule',
    children: [
      _StateCard(
        label: 'upcoming events',
        child: _SliverFrame(
          height: 520,
          slivers: [ClubScheduleSection(events: _events)],
        ),
      ),
      _StateCard(
        label: 'same-day strip',
        child: _SliverFrame(
          height: 420,
          slivers: [ClubScheduleSection(events: _sameDayScheduleEvents)],
        ),
      ),
      _StateCard(
        label: 'hosted events',
        child: _SliverFrame(
          height: 420,
          slivers: [
            ClubScheduleSection(events: _sameDayScheduleEvents, isHost: true),
          ],
        ),
      ),
      _StateCard(
        label: 'empty consumer',
        child: const _SliverFrame(
          height: 260,
          slivers: [ClubScheduleSection(events: [])],
        ),
      ),
      _StateCard(
        label: 'empty host',
        child: const _SliverFrame(
          height: 260,
          slivers: [ClubScheduleSection(events: [], isHost: true)],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Review states',
  type: ClubReviewsSection,
  path: '[Club Detail]/Sections',
)
Widget clubReviewsSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubReviewsSection',
    catalogId: 'section.club.reviews',
    children: [
      _StateCard(
        label: 'published reviews',
        child: CatchSection.divided(
          title: 'Reviews',
          first: true,
          child: ClubReviewsSection(reviews: _reviews, currentUid: _viewerUid),
        ),
      ),
      const _StateCard(
        label: 'empty',
        child: CatchSection.divided(
          title: 'Reviews',
          first: true,
          child: ClubReviewsSection(reviews: [], currentUid: _viewerUid),
        ),
      ),
    ],
  );
}

class _ClubScreenPreview extends StatelessWidget {
  const _ClubScreenPreview({
    required this.uid,
    required this.membership,
    required this.viewModel,
    this.useInitialClub = true,
  });

  final String? uid;
  final ClubMembership? membership;
  final AsyncValue<ClubDetailViewModel?> viewModel;
  final bool useInitialClub;

  @override
  Widget build(BuildContext context) {
    final effectiveUid = uid;
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream<String?>.value(effectiveUid)),
        watchUserProfileProvider.overrideWith(
          (ref) =>
              Stream<UserProfile?>.value(effectiveUid == null ? null : _viewer),
        ),
        if (effectiveUid != null)
          watchClubMembershipProvider(
            _club.id,
            effectiveUid,
          ).overrideWith((ref) => Stream<ClubMembership?>.value(membership)),
        clubDetailViewModelProvider(_club.id).overrideWith((ref) => viewModel),
      ],
      child: ClubDetailScreen(
        clubId: _club.id,
        initialClub: useInitialClub ? _club : null,
      ),
    );
  }
}

class _ClubComposedPreview extends StatelessWidget {
  const _ClubComposedPreview({
    this.club,
    this.events,
    this.reviews,
    required this.isMember,
    required this.isAuthenticated,
    this.isMutating = false,
    this.mutationError,
  });

  final Club? club;
  final List<Event>? events;
  final List<Review>? reviews;
  final bool isMember;
  final bool isAuthenticated;
  final bool isMutating;
  final Object? mutationError;

  @override
  Widget build(BuildContext context) {
    final previewClub = club ?? _club;
    final previewEvents = events ?? _events;
    final previewReviews = reviews ?? _reviews;
    final state = !isAuthenticated
        ? ClubDetailDockRole.guest
        : isMember
        ? ClubDetailDockRole.member
        : ClubDetailDockRole.visitor;
    final footnote = switch (state) {
      ClubDetailDockRole.visitor => 'FREE TO JOIN · LEAVE ANYTIME',
      ClubDetailDockRole.member => 'MEMBER · MANAGE ANYTIME',
      _ => null,
    };

    return Scaffold(
      body: Column(
        children: [
          if (mutationError != null)
            CatchErrorBanner.fromError(
              mutationError!,
              context: AppErrorContext.club,
              onRetry: _noop,
            ),
          Expanded(
            child: ClubDetailBody(
              state: ClubDetailBodyState.fromDomain(
                club: previewClub,
                upcomingEvents: previewEvents,
                reviews: previewReviews,
                userProfile: isAuthenticated ? _viewer : null,
                uid: isAuthenticated ? _viewerUid : null,
                isMember: isMember,
                isMutating: isMutating,
                clubPushNotificationsEnabled: isMember,
                isAuthenticated: isAuthenticated,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ClubDetailDock(
        state: state,
        activityKind: previewClub.hostDefaults.primaryActivityKind,
        members: state == ClubDetailDockRole.owner
            ? null
            : previewClub.memberCount,
        notificationsEnabled: true,
        footnote: footnote,
        isJoinLoading: isMutating,
        onSignIn: _noop,
        onJoin: _noop,
        onManage: _noop,
        onBell: _noop,
      ),
    );
  }
}

class _CatalogScreen extends StatelessWidget {
  const _CatalogScreen({
    required this.title,
    required this.catalogId,
    required this.children,
  });

  final String title;
  final String catalogId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CatchInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CatchTextStyles.titleL(context)),
              gapH4,
              Text(
                catalogId,
                style: CatchTextStyles.monoLabel(context, color: t.ink2),
              ),
              gapH24,
              for (final child in children) ...[child, gapH20],
            ],
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.label,
    required this.child,
    this.description,
  });

  final String label;
  final String? description;
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
            if (description != null) ...[
              gapH6,
              Text(
                description!,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child, this.height = 720});

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

class _ClubDirectoryPreviewScope extends StatelessWidget {
  const _ClubDirectoryPreviewScope({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        uidProvider.overrideWith((ref) => Stream<String?>.value(null)),
      ],
      child: IgnorePointer(child: child),
    );
  }
}

class _ClubDiscoveryFrame extends StatelessWidget {
  const _ClubDiscoveryFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: child,
      ),
    );
  }
}

class _ClubMediaFrame extends StatelessWidget {
  const _ClubMediaFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _ClubDiscoveryFrame(
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: child,
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

class _SliverFrame extends StatelessWidget {
  const _SliverFrame({required this.slivers, this.height = 420});

  final List<Widget> slivers;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: SizedBox(
            height: height,
            child: CustomScrollView(slivers: slivers),
          ),
        ),
      ),
    );
  }
}

class _DockFrame extends StatelessWidget {
  const _DockFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: child,
        ),
      ),
    );
  }
}

ClubDetailViewModel _viewModel({
  String? uid = _viewerUid,
  UserProfile? userProfile,
  bool includeUserProfile = true,
  required bool isMember,
  bool isAuthenticated = true,
}) {
  return ClubDetailViewModel(
    club: _club,
    isHost: false,
    isMember: isMember,
    upcomingEvents: _events,
    reviews: _reviews,
    userProfile: includeUserProfile ? userProfile ?? _viewer : null,
    uid: uid,
    isAuthenticated: isAuthenticated,
  );
}

ClubMembership _membership({bool pushNotificationsEnabled = false}) {
  return ClubMembership(
    id: '${_club.id}_$_viewerUid',
    clubId: _club.id,
    uid: _viewerUid,
    role: ClubMembershipRole.member,
    status: ClubMembershipStatus.active,
    pushNotificationsEnabled: pushNotificationsEnabled,
    joinedAt: DateTime(2026, 1, 12),
  );
}

Event _event({
  required String id,
  required DateTime startTime,
  required String meetingPoint,
  required double distanceKm,
  required int bookedCount,
  required int capacityLimit,
  required String description,
  ActivityKind activityKind = ActivityKind.socialRun,
}) {
  return Event(
    id: id,
    clubId: _club.id,
    startTime: startTime,
    endTime: startTime.add(const Duration(hours: 1, minutes: 30)),
    meetingPoint: meetingPoint,
    eventFormat: EventFormatSnapshot.fromActivityKind(activityKind),
    distanceKm: distanceKm,
    pace: PaceLevel.easy,
    capacityLimit: capacityLimit,
    description: description,
    priceInPaise: 0,
    bookedCount: bookedCount,
  );
}

UploadedPhoto _photo(String id, int position) {
  return UploadedPhoto.fromUpload(
    url:
        'https://images.unsplash.com/photo-${['1519681393784-d120267933ba', '1529156069898-49953e39b3ac', '1526676037777-05a232554f77'][position]}?w=600&q=80',
    storagePath: 'widgetbook/clubs/$id.jpg',
    position: position,
    now: _now.add(Duration(minutes: position)),
  );
}

void _noop() {}

Future<void> _ignoreShare(BuildContext context, Club club) async {}
