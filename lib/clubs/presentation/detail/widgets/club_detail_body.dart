import 'dart:async';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_host_contact_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_schedule_section.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/membership_button.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/stats_strip.dart';
import 'package:catch_dating_app/clubs/presentation/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/events/domain/event.dart';
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
    final isHostApp = AppConfig.appRole.isHost;
    final eventDetailRouteName = isHostApp
        ? Routes.hostAppEventDetailScreen.name
        : Routes.eventDetailScreen.name;
    final showMembershipControls = isAuthenticated && !isHost && !isHostApp;
    const contentGap = SizedBox(height: CatchLayout.detailScreenContentGap);
    const sectionGap = SizedBox(height: CatchLayout.detailScreenSectionGap);

    return ColoredBox(
      color: t.surface,
      child: CustomScrollView(
        slivers: [
          ClubHeroAppBar(club: club, isHost: isHost),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchLayout.detailScreenHorizontalPadding,
              CatchLayout.detailScreenTopPadding,
              CatchLayout.detailScreenHorizontalPadding,
              0,
            ),
            sliver: SliverList.list(
              children: [
                StatsStrip(club: club, upcomingCount: upcoming.length),
                contentGap,
                _ClubHostSection(
                  club: club,
                  canViewProfile: false,
                  canMessageHost: isAuthenticated && !isHostApp,
                  currentUid: uid,
                ),
                contentGap,
                Text(
                  club.description,
                  style: CatchTextStyles.bodyLead(context, color: t.ink2),
                ),
                if (club.instagramHandle != null ||
                    club.phoneNumber != null ||
                    club.email != null) ...[
                  contentGap,
                  _ClubContactSection(club: club),
                ],
                if (showMembershipControls) ...[
                  contentGap,
                  MembershipButton(
                    clubId: club.id,
                    isMember: isMember,
                    isMutating: isMutating,
                    pushNotificationsEnabled: clubPushNotificationsEnabled,
                    isPushMutating: isClubPushMutating,
                  ),
                ],
                if (!isAuthenticated) ...[contentGap, _GuestPrompt(club: club)],
                sectionGap,
              ],
            ),
          ),
          ClubScheduleSection(
            events: upcoming,
            onEventSelected: (event) => context.pushNamed(
              eventDetailRouteName,
              pathParameters: {'clubId': club.id, 'eventId': event.id},
              extra: event,
            ),
          ),
          if (isAuthenticated)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                CatchLayout.detailScreenHorizontalPadding,
                0,
                CatchLayout.detailScreenHorizontalPadding,
                CatchLayout.detailScreenBottomPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: ClubReviewsSection(reviews: reviews, currentUid: uid),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClubHostSection extends ConsumerWidget {
  const _ClubHostSection({
    required this.club,
    required this.canViewProfile,
    required this.canMessageHost,
    required this.currentUid,
  });

  final Club club;
  final bool canViewProfile;
  final bool canMessageHost;
  final String? currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final hosts = club.displayHostProfiles;
    final messageMutation = ref.watch(
      ClubHostContactController.startConversationMutation,
    );

    void openProfile(String uid) {
      context.pushNamed(
        Routes.publicProfileScreen.name,
        pathParameters: {'uid': uid},
      );
    }

    Future<void> messageHost(ClubHostProfile host) async {
      final matchId = await ClubHostContactController.startConversationMutation
          .run(
            ref,
            (tx) => tx
                .get(clubHostContactControllerProvider.notifier)
                .startConversation(clubId: club.id, hostUid: host.uid),
          );
      if (!context.mounted) return;
      unawaited(
        context.pushNamed(
          Routes.chatScreen.name,
          pathParameters: {'matchId': matchId},
        ),
      );
    }

    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final host in hosts) ...[
            Semantics(
              button: canViewProfile,
              label: canViewProfile ? 'View ${host.displayName} profile' : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: canViewProfile ? () => openProfile(host.uid) : null,
                child: _ClubHostRow(
                  host: host,
                  borderColor: t.primarySoft,
                  showChevron: canViewProfile,
                  onMessage:
                      canMessageHost &&
                          currentUid != null &&
                          currentUid != host.uid &&
                          !messageMutation.isPending
                      ? () => unawaited(messageHost(host))
                      : null,
                ),
              ),
            ),
            if (host != hosts.last) gapH12,
          ],
        ],
      ),
    );
  }
}

class _ClubHostRow extends StatelessWidget {
  const _ClubHostRow({
    required this.host,
    required this.borderColor,
    required this.showChevron,
    required this.onMessage,
  });

  final ClubHostProfile host;
  final Color borderColor;
  final bool showChevron;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Row(
      children: [
        ClubHostAvatar(
          name: host.displayName,
          imageUrl: host.avatarUrl,
          size: 54,
          borderWidth: 2,
          borderColor: borderColor,
        ),
        gapW12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hosted by ${host.displayName}',
                style: CatchTextStyles.sectionTitle(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              gapH6,
              Row(
                children: [
                  ClubHostRoleBadge(role: host.role),
                  gapW8,
                  Expanded(
                    child: Text(
                      showChevron ? 'View profile' : 'Public profile',
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (onMessage != null) ...[
          gapW8,
          IconButton.filledTonal(
            tooltip: 'Message host',
            onPressed: onMessage,
            icon: Icon(
              CatchIcons.chatBubbleOutlineRounded,
              size: CatchIcon.control,
            ),
          ),
        ],
        if (showChevron) ...[
          gapW8,
          Icon(
            CatchIcons.chevronRightRounded,
            size: CatchIcon.lg,
            color: t.ink3,
          ),
        ],
      ],
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
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Contact', heavy: true),
          gapH12,
          if (club.instagramHandle != null)
            _ContactRow(
              icon: CatchIcons.alternateEmailRounded,
              label: club.instagramHandle!,
              onTap: () => unawaited(
                links.openExternal(_instagramUri(club.instagramHandle!)),
              ),
            ),
          if (club.phoneNumber != null)
            _ContactRow(
              icon: CatchIcons.callOutlined,
              label: club.phoneNumber!,
              onTap: () => unawaited(links.open(_phoneUri(club.phoneNumber!))),
            ),
          if (club.email != null)
            _ContactRow(
              icon: CatchIcons.emailOutlined,
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
        padding: CatchInsets.detailInlineRowBottomGap,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CatchRadius.sm),
          child: Padding(
            padding: CatchInsets.controlVerticalTight,
            child: Row(
              children: [
                Icon(icon, size: CatchIcon.md, color: t.primary),
                gapW10,
                Expanded(
                  child: Text(
                    label,
                    style: CatchTextStyles.bodyLead(context, color: t.ink),
                  ),
                ),
                Icon(
                  CatchIcons.openInNewRounded,
                  size: CatchIcon.sm,
                  color: t.ink3,
                ),
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
      padding: CatchInsets.tileContentCompact,
      child: Column(
        children: [
          Text(
            'Sign in to join this club, see member reviews, and connect with the community.',
            style: CatchTextStyles.bodyLead(context, color: t.ink2),
            textAlign: TextAlign.center,
          ),
          gapH12,
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
