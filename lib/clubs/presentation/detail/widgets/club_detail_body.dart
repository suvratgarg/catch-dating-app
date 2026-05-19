import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/membership_button.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/stats_strip.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_club_tools.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClubDetailBody extends StatelessWidget {
  const ClubDetailBody({
    super.key,
    required this.club,
    required this.upcoming,
    required this.reviews,
    required this.userProfile,
    required this.uid,
    required this.isHost,
    required this.isMember,
    required this.isMutating,
    required this.clubPushNotificationsEnabled,
    required this.isClubPushMutating,
    required this.isAuthenticated,
  });

  final Club club;
  final List<Event> upcoming;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final String? uid;
  final bool isHost;
  final bool isMember;
  final bool isMutating;
  final bool clubPushNotificationsEnabled;
  final bool isClubPushMutating;
  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final showMembershipControls = isAuthenticated && !isHost;

    return CustomScrollView(
      slivers: [
        ClubHeroAppBar(club: club, isHost: isHost),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            20,
            CatchSpacing.s5,
            0,
          ),
          sliver: SliverList.list(
            children: [
              if (isHost) ...[
                HostClubManagementPanel(
                  club: club,
                  events: upcoming,
                  onEditClub: () => context.pushNamed(
                    Routes.editClubScreen.name,
                    pathParameters: {'clubId': club.id},
                    extra: club,
                  ),
                  onCreateEvent: () => context.pushNamed(
                    Routes.createEventScreen.name,
                    pathParameters: {'clubId': club.id},
                    extra: club,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              StatsStrip(club: club, upcomingCount: upcoming.length),
              const SizedBox(height: 16),
              if (!isHost) ...[
                _ClubHostSection(club: club, canViewProfile: isAuthenticated),
                const SizedBox(height: 16),
              ],
              Text(
                club.description,
                style: CatchTextStyles.bodyM(context, color: t.ink2),
              ),
              const SizedBox(height: 20),
              if (club.instagramHandle != null ||
                  club.phoneNumber != null ||
                  club.email != null) ...[
                _ClubContactSection(club: club),
                const SizedBox(height: 20),
              ],
              if (showMembershipControls)
                MembershipButton(
                  clubId: club.id,
                  isMember: isMember,
                  isMutating: isMutating,
                  pushNotificationsEnabled: clubPushNotificationsEnabled,
                  isPushMutating: isClubPushMutating,
                ),
              if (showMembershipControls) const SizedBox(height: 24),
              if (!isAuthenticated) ...[
                _GuestPrompt(club: club),
                const SizedBox(height: 24),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
        ClubScheduleSection(
          events: upcoming,
          isHost: isHost,
          onEventSelected: (event) => context.pushNamed(
            Routes.eventDetailScreen.name,
            pathParameters: {'clubId': club.id, 'eventId': event.id},
            extra: event,
          ),
        ),
        if (isAuthenticated)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              0,
              CatchSpacing.s5,
              CatchSpacing.s6,
            ),
            sliver: SliverToBoxAdapter(
              child: ClubReviewsSection(
                reviews: reviews,
                currentUid: uid,
                maxVisibleReviews: 3,
              ),
            ),
          ),
      ],
    );
  }
}

class _ClubHostSection extends StatelessWidget {
  const _ClubHostSection({required this.club, required this.canViewProfile});

  final Club club;
  final bool canViewProfile;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    void openProfile() {
      context.pushNamed(
        Routes.publicProfileScreen.name,
        pathParameters: {'uid': club.hostUserId},
      );
    }

    return Semantics(
      button: canViewProfile,
      label: canViewProfile ? 'View ${club.hostName} profile' : null,
      child: CatchSurface(
        borderColor: t.line,
        padding: const EdgeInsets.all(14),
        onTap: canViewProfile ? openProfile : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: 'HOST', heavy: true),
            Row(
              children: [
                PersonAvatar(
                  size: 54,
                  name: club.hostName,
                  imageUrl: club.hostAvatarUrl,
                  borderWidth: 2,
                  borderColor: t.primarySoft,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        club.hostName,
                        style: CatchTextStyles.titleM(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CatchBadge(
                            label: 'Club host',
                            tone: CatchBadgeTone.brand,
                            icon: Icons.groups_outlined,
                          ),
                          Text(
                            'Hosts events in ${club.area}',
                            style: CatchTextStyles.bodyS(
                              context,
                              color: t.ink2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canViewProfile) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 24, color: t.ink3),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ClubContactSection extends ConsumerWidget {
  const _ClubContactSection({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final links = ref.watch(externalLinkControllerProvider);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'CONTACT', heavy: true),
          const SizedBox(height: 12),
          if (club.instagramHandle != null)
            _ContactRow(
              icon: Icons.alternate_email_rounded,
              label: club.instagramHandle!,
              onTap: () => unawaited(
                links.openExternal(_instagramUri(club.instagramHandle!)),
              ),
            ),
          if (club.phoneNumber != null)
            _ContactRow(
              icon: Icons.call_outlined,
              label: club.phoneNumber!,
              onTap: () => unawaited(links.open(_phoneUri(club.phoneNumber!))),
            ),
          if (club.email != null)
            _ContactRow(
              icon: Icons.email_outlined,
              label: club.email!,
              onTap: () => unawaited(links.open(_emailUri(club.email!))),
            ),
        ],
      ),
    );
  }

  static Uri _instagramUri(String handle) =>
      Uri.parse('https://instagram.com/${handle.replaceFirst('@', '')}');

  static Uri _phoneUri(String phoneNumber) =>
      Uri(scheme: 'tel', path: phoneNumber);

  static Uri _emailUri(String email) => Uri(scheme: 'mailto', path: email);
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: true,
      label: label,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(icon, size: 18, color: t.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: CatchTextStyles.bodyM(context, color: t.ink),
                  ),
                ),
                Icon(Icons.open_in_new_rounded, size: 14, color: t.ink3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuestPrompt extends StatelessWidget {
  const _GuestPrompt({required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(
            'Sign in to join this club, see member reviews, and connect with the community.',
            style: CatchTextStyles.bodyM(context, color: t.ink2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          CatchButton(
            label: 'Sign in to join',
            onPressed: () => context.go(
              Uri(
                path: Routes.authScreen.path,
                queryParameters: {'from': '/clubs/${club.id}'},
              ).toString(),
            ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
