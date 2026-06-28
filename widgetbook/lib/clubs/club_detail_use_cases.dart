import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_screen.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/catch_club_dock.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_share_card.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_avatar_rail.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_discover_list.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_list_tile.dart';
import 'package:catch_dating_app/clubs/presentation/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
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
        child: ClubAvatarRail(clubs: [_club, _minimalClub], showDivider: false),
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
  name: 'Host avatar states',
  type: ClubHostAvatar,
  path: '[Club Discovery]/Atoms',
)
Widget clubHostAvatarStates(BuildContext context) {
  return _CatalogScreen(
    title: 'ClubHostAvatar',
    catalogId: 'atom.club.host_avatar',
    children: [
      _StateCard(
        label: 'photo',
        child: ClubHostAvatar(
          name: _club.displayHostName,
          imageUrl: _club.hostAvatarUrl,
          size: 56,
        ),
      ),
      const _StateCard(
        label: 'initials',
        child: ClubHostAvatar(name: 'Ana Rao', size: 56),
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
        label: 'cover',
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
        label: 'no cover',
        child: _SliverFrame(
          height: 500,
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
      _StateCard(
        label: 'host badge',
        child: _SliverFrame(
          height: 560,
          slivers: [
            ClubHeroAppBar(
              club: _club,
              isHost: true,
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
        child: ClubReviewsSection(reviews: _reviews, currentUid: _viewerUid),
      ),
      const _StateCard(
        label: 'empty',
        child: ClubReviewsSection(reviews: [], currentUid: _viewerUid),
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
        ? CatchClubDockState.guest
        : isMember
        ? CatchClubDockState.member
        : CatchClubDockState.visitor;
    final footnote = switch (state) {
      CatchClubDockState.visitor => 'FREE TO JOIN · LEAVE ANYTIME',
      CatchClubDockState.member => 'MEMBER · MANAGE ANYTIME',
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
              club: previewClub,
              upcoming: previewEvents,
              reviews: previewReviews,
              userProfile: isAuthenticated ? _viewer : null,
              uid: isAuthenticated ? _viewerUid : null,
              isHost: false,
              isMember: isMember,
              isMutating: isMutating,
              clubPushNotificationsEnabled: isMember,
              isClubPushMutating: false,
              isAuthenticated: isAuthenticated,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CatchClubDock(
        state: state,
        activityKind: previewClub.hostDefaults.primaryActivityKind,
        members: state == CatchClubDockState.owner
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
