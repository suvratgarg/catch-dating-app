import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_host_contact_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/catch_club_dock.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_share_card.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ClubDetailScreen extends ConsumerWidget {
  const ClubDetailScreen({super.key, required this.clubId, this.initialClub});

  final String clubId;
  final Club? initialClub;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(clubDetailViewModelProvider(clubId));
    final currentUid = ref.watch(uidProvider).asData?.value;
    final currentUserProfile = ref
        .watch(watchUserProfileProvider)
        .asData
        ?.value;
    final currentMembership = currentUid == null
        ? null
        : ref
              .watch(watchClubMembershipProvider(clubId, currentUid))
              .asData
              ?.value;

    final joinMutation = ref.watch(ClubMembershipController.joinMutation);
    final leaveMutation = ref.watch(ClubMembershipController.leaveMutation);
    final pushMutation = ref.watch(
      ClubMembershipController.pushNotificationsMutation,
    );
    final messageHostMutation = ref.watch(
      ClubHostContactController.startConversationMutation,
    );
    final screenState = HostClubDetailScreenState.fromAsync(
      viewModel: vmAsync,
      initialClub: initialClub,
      currentUid: currentUid,
      currentUserProfile: currentUserProfile,
      currentMembership: currentMembership,
      appRole: AppConfig.appRole,
    );

    Widget wrapMutationListeners(Widget child) => CatchMutationErrorListener(
      mutation: ClubMembershipController.joinMutation,
      child: CatchMutationErrorListener(
        mutation: ClubMembershipController.leaveMutation,
        child: CatchMutationErrorListener(
          mutation: ClubMembershipController.pushNotificationsMutation,
          child: CatchMutationErrorListener(
            mutation: ClubHostContactController.startConversationMutation,
            child: child,
          ),
        ),
      ),
    );

    if (screenState is HostClubDetailContent) {
      return wrapMutationListeners(
        Scaffold(
          body: _buildBody(
            context: context,
            ref: ref,
            club: screenState.club,
            upcomingEvents: screenState.upcomingEvents,
            reviews: screenState.reviews,
            userProfile: screenState.userProfile,
            uid: screenState.uid,
            isHost: screenState.isHost,
            isMember: screenState.isMember,
            isMutating: joinMutation.isPending || leaveMutation.isPending,
            clubPushNotificationsEnabled:
                currentMembership?.pushNotificationsEnabled ?? false,
            isClubPushMutating: pushMutation.isPending,
            isMessageHostPending: messageHostMutation.isPending,
            isAuthenticated: screenState.isAuthenticated,
          ),
          bottomNavigationBar: _buildDock(
            showMembershipDock: screenState.showMembershipDock,
            club: screenState.club,
            isMember: screenState.isMember,
            isAuthenticated: screenState.isAuthenticated,
            isMutating: joinMutation.isPending || leaveMutation.isPending,
            clubPushNotificationsEnabled:
                currentMembership?.pushNotificationsEnabled ?? false,
            isClubPushMutating: pushMutation.isPending,
          ),
        ),
      );
    }

    return Scaffold(
      body: switch (screenState) {
        HostClubDetailLoading() => const ClubDetailLoadingBody(),
        HostClubDetailError(:final error, :final retryIntent) =>
          CatchErrorState.fromError(
            error,
            context: AppErrorContext.club,
            onRetry: () => _retryHostClubDetail(ref, clubId, retryIntent),
          ),
        HostClubDetailNotFound() => CatchErrorState(
          title: 'Club not found',
          message: 'This club is no longer available.',
          icon: CatchIcons.groupsOutlined,
        ),
        HostClubDetailContent() => const SizedBox.shrink(),
      },
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required WidgetRef ref,
    required Club club,
    required List<Event> upcomingEvents,
    required List<Review> reviews,
    required UserProfile? userProfile,
    required String? uid,
    required bool isHost,
    required bool isMember,
    required bool isMutating,
    required bool clubPushNotificationsEnabled,
    required bool isClubPushMutating,
    required bool isMessageHostPending,
    required bool isAuthenticated,
  }) {
    final isHostApp = AppConfig.appRole.isHost;
    final eventDetailRouteName = isHostApp
        ? Routes.hostAppEventDetailScreen.name
        : Routes.eventDetailScreen.name;

    return ClubDetailBody(
      club: club,
      upcoming: upcomingEvents,
      reviews: reviews,
      userProfile: userProfile,
      uid: uid,
      isHost: isHost,
      isMember: isMember,
      isMutating: isMutating,
      clubPushNotificationsEnabled: clubPushNotificationsEnabled,
      isClubPushMutating: isClubPushMutating,
      isAuthenticated: isAuthenticated,
      canMessageHosts: isAuthenticated && !isHostApp,
      isMessageHostPending: isMessageHostPending,
      onShareClub: (buttonContext, club) => showClubShareCardSheet(
        buttonContext,
        club: club,
        share: ref.read(externalShareControllerProvider),
      ),
      onEventSelected: (event) => context.pushNamed(
        eventDetailRouteName,
        pathParameters: {'clubId': club.id, 'eventId': event.id},
        extra: event,
      ),
      onViewHostProfile: (hostUid) => context.pushNamed(
        Routes.publicProfileScreen.name,
        pathParameters: {'uid': hostUid},
      ),
      onMessageHost: (buttonContext, host) =>
          _messageHost(buttonContext, ref, club, host),
      onContactSelected: (action) => _openClubContact(ref, action),
    );
  }

  Future<void> _openClubContact(WidgetRef ref, ClubContactAction action) async {
    final links = ref.read(externalLinkControllerProvider);
    if (action.openExternally) {
      await links.openExternal(action.uri);
    } else {
      await links.open(action.uri);
    }
  }

  Future<void> _messageHost(
    BuildContext context,
    WidgetRef ref,
    Club club,
    ClubHostProfile host,
  ) async {
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

  Widget? _buildDock({
    required bool showMembershipDock,
    required Club club,
    required bool isMember,
    required bool isAuthenticated,
    required bool isMutating,
    required bool clubPushNotificationsEnabled,
    required bool isClubPushMutating,
  }) {
    if (!showMembershipDock) return null;
    return ClubMembershipDock(
      club: club,
      isMember: isMember,
      isAuthenticated: isAuthenticated,
      isMutating: isMutating,
      pushNotificationsEnabled: clubPushNotificationsEnabled,
      isPushMutating: isClubPushMutating,
    );
  }
}

void _retryHostClubDetail(
  WidgetRef ref,
  String clubId,
  HostClubDetailRetryIntent intent,
) {
  switch (intent) {
    case HostClubDetailRetryIntent.reloadDetail:
      ref.invalidate(clubDetailViewModelProvider(clubId));
  }
}

enum HostClubDetailRetryIntent { reloadDetail }

sealed class HostClubDetailScreenState {
  const HostClubDetailScreenState();

  factory HostClubDetailScreenState.fromAsync({
    required AsyncValue<ClubDetailViewModel?> viewModel,
    required Club? initialClub,
    required String? currentUid,
    required UserProfile? currentUserProfile,
    required ClubMembership? currentMembership,
    required AppRole appRole,
  }) {
    final liveViewModel = viewModel.asData?.value;
    if (liveViewModel != null) {
      return HostClubDetailContent.fromViewModel(
        liveViewModel,
        appRole: appRole,
      );
    }

    if (viewModel.isLoading && initialClub != null) {
      final isAuthenticated = currentUid != null;
      return HostClubDetailContent(
        club: initialClub,
        upcomingEvents: const [],
        reviews: const [],
        userProfile: currentUserProfile,
        uid: currentUid,
        isHost:
            appRole.isHost &&
            isAuthenticated &&
            initialClub.isHostedBy(currentUid),
        isMember:
            isAuthenticated &&
            currentMembership?.status == ClubMembershipStatus.active,
        isAuthenticated: isAuthenticated,
        isInitialFallback: true,
        publicPreviewMode: appRole.isHost,
        showMembershipDock: !appRole.isHost,
      );
    }

    return switch (viewModel) {
      AsyncError(:final error) => HostClubDetailError(error: error),
      AsyncLoading() => const HostClubDetailLoading(),
      AsyncData() => const HostClubDetailNotFound(),
    };
  }
}

final class HostClubDetailLoading extends HostClubDetailScreenState {
  const HostClubDetailLoading();
}

final class HostClubDetailError extends HostClubDetailScreenState {
  const HostClubDetailError({
    required this.error,
    this.retryIntent = HostClubDetailRetryIntent.reloadDetail,
  });

  final Object error;
  final HostClubDetailRetryIntent retryIntent;
}

final class HostClubDetailNotFound extends HostClubDetailScreenState {
  const HostClubDetailNotFound();
}

final class HostClubDetailContent extends HostClubDetailScreenState {
  const HostClubDetailContent({
    required this.club,
    required this.upcomingEvents,
    required this.reviews,
    required this.userProfile,
    required this.uid,
    required this.isHost,
    required this.isMember,
    required this.isAuthenticated,
    required this.isInitialFallback,
    required this.publicPreviewMode,
    required this.showMembershipDock,
  });

  factory HostClubDetailContent.fromViewModel(
    ClubDetailViewModel viewModel, {
    required AppRole appRole,
  }) {
    return HostClubDetailContent(
      club: viewModel.club,
      upcomingEvents: viewModel.upcomingEvents,
      reviews: viewModel.reviews,
      userProfile: viewModel.userProfile,
      uid: viewModel.uid,
      isHost: viewModel.isHost,
      isMember: viewModel.isMember,
      isAuthenticated: viewModel.isAuthenticated,
      isInitialFallback: false,
      publicPreviewMode: appRole.isHost,
      showMembershipDock: !appRole.isHost,
    );
  }

  final Club club;
  final List<Event> upcomingEvents;
  final List<Review> reviews;
  final UserProfile? userProfile;
  final String? uid;
  final bool isHost;
  final bool isMember;
  final bool isAuthenticated;
  final bool isInitialFallback;
  final bool publicPreviewMode;
  final bool showMembershipDock;
}

class ClubDetailLoadingBody extends StatelessWidget {
  const ClubDetailLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.surface,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildClubHeroLoadingSkeleton()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              CatchLayout.detailScreenHorizontalPadding,
              CatchLayout.detailScreenTopPadding,
              CatchLayout.detailScreenHorizontalPadding,
              CatchLayout.detailScreenBottomPadding,
            ),
            sliver: SliverList.list(
              children: [
                _buildClubStatsLoadingSkeleton(),
                CatchSectionStack(
                  padding: const EdgeInsets.only(top: CatchSpacing.screenPt),
                  children: [
                    CatchSection(
                      title: 'Your hosts',
                      first: true,
                      child: _buildClubHostLoadingSkeleton(),
                    ),
                    CatchSection(
                      title: 'About',
                      child: _buildClubTextLoadingSkeleton(lines: 3),
                    ),
                    CatchSection(
                      title: 'What we do',
                      child: _buildClubTagLoadingSkeleton(),
                    ),
                    CatchSection(
                      title: 'Upcoming',
                      child: _buildClubScheduleLoadingSkeleton(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildClubHeroLoadingSkeleton() {
  return Stack(
    children: [
      CatchSkeleton.box(
        width: double.infinity,
        height: CatchLayout.clubDetailHeroNoCoverPhoneHeight,
        borderRadius: BorderRadius.zero,
      ),
      Positioned(
        left: CatchLayout.detailScreenHorizontalPadding,
        right: CatchLayout.detailScreenHorizontalPadding,
        bottom: CatchSpacing.s5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
            gapH10,
            CatchSkeleton.text(width: CatchSpacing.s16 * 3),
            gapH8,
            FractionallySizedBox(
              widthFactor: 0.58,
              alignment: Alignment.centerLeft,
              child: CatchSkeleton.text(),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildClubStatsLoadingSkeleton() {
  return Builder(
    builder: (context) {
      final t = CatchTokens.of(context);

      return CatchSurface(
        borderColor: t.line,
        padding: CatchInsets.tileContentCompact,
        child: Row(
          children: [
            Expanded(child: _buildClubStatLoadingSkeleton()),
            _buildClubStatsDividerSkeleton(),
            Expanded(child: _buildClubStatLoadingSkeleton()),
            _buildClubStatsDividerSkeleton(),
            Expanded(child: _buildClubStatLoadingSkeleton()),
          ],
        ),
      );
    },
  );
}

Widget _buildClubStatLoadingSkeleton() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
      gapH8,
      CatchSkeleton.text(width: CatchSpacing.s10),
    ],
  );
}

Widget _buildClubStatsDividerSkeleton() {
  return Builder(
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
        child: SizedBox(
          width: CatchStroke.hairline,
          height: CatchSpacing.s11,
          child: ColoredBox(color: CatchTokens.of(context).line),
        ),
      );
    },
  );
}

Widget _buildClubHostLoadingSkeleton() {
  return Builder(
    builder: (context) {
      final t = CatchTokens.of(context);

      return CatchSurface(
        borderColor: t.line,
        padding: CatchInsets.tileContentCompact,
        child: Row(
          children: [
            CatchSkeleton.circle(size: CatchSpacing.s10),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
                  gapH6,
                  CatchSkeleton.text(width: CatchSpacing.s16 * 2),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildClubTextLoadingSkeleton({required int lines}) {
  return CatchSkeleton.textBlock(lines: lines);
}

Widget _buildClubTagLoadingSkeleton() {
  return Wrap(
    spacing: CatchSpacing.s2,
    runSpacing: CatchSpacing.s2,
    children: [
      CatchSkeleton.box(
        width: CatchSpacing.s16 + CatchSpacing.s6,
        height: CatchSpacing.s8,
        radius: CatchRadius.pill,
      ),
      CatchSkeleton.box(
        width: CatchSpacing.s16 + CatchSpacing.s10,
        height: CatchSpacing.s8,
        radius: CatchRadius.pill,
      ),
      CatchSkeleton.box(
        width: CatchSpacing.s16 + CatchSpacing.s4,
        height: CatchSpacing.s8,
        radius: CatchRadius.pill,
      ),
    ],
  );
}

Widget _buildClubScheduleLoadingSkeleton() {
  return Column(
    children: [
      CatchSkeleton.card(height: CatchLayout.skeletonCardCompactHeight),
      gapH10,
      CatchSkeleton.card(height: CatchLayout.skeletonCardCompactHeight),
    ],
  );
}
