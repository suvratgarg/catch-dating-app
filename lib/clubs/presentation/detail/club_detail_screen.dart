import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_detail_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_host_contact_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/catch_club_dock.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final vm = vmAsync.asData?.value;

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

    if (vm != null) {
      return wrapMutationListeners(
        Scaffold(
          body: _buildBody(
            club: vm.club,
            upcomingEvents: vm.upcomingEvents,
            reviews: vm.reviews,
            userProfile: vm.userProfile,
            uid: vm.uid,
            isHost: vm.isHost,
            isMember: vm.isMember,
            isMutating: joinMutation.isPending || leaveMutation.isPending,
            clubPushNotificationsEnabled:
                currentMembership?.pushNotificationsEnabled ?? false,
            isClubPushMutating: pushMutation.isPending,
            isAuthenticated: vm.isAuthenticated,
          ),
          bottomNavigationBar: _buildDock(
            club: vm.club,
            isMember: vm.isMember,
            isAuthenticated: vm.isAuthenticated,
            isMutating: joinMutation.isPending || leaveMutation.isPending,
            clubPushNotificationsEnabled:
                currentMembership?.pushNotificationsEnabled ?? false,
            isClubPushMutating: pushMutation.isPending,
          ),
        ),
      );
    }

    if (vmAsync.isLoading && initialClub != null) {
      final placeholderAuth = currentUid != null;
      return wrapMutationListeners(
        Scaffold(
          body: _buildBody(
            club: initialClub!,
            upcomingEvents: const [],
            reviews: const [],
            userProfile: currentUserProfile,
            uid: currentUid,
            isHost:
                AppConfig.appRole.isHost &&
                placeholderAuth &&
                initialClub!.isHostedBy(currentUid),
            isMember:
                placeholderAuth &&
                currentMembership?.status == ClubMembershipStatus.active,
            isMutating: joinMutation.isPending || leaveMutation.isPending,
            clubPushNotificationsEnabled:
                currentMembership?.pushNotificationsEnabled ?? false,
            isClubPushMutating: pushMutation.isPending,
            isAuthenticated: placeholderAuth,
          ),
          bottomNavigationBar: _buildDock(
            club: initialClub!,
            isMember:
                placeholderAuth &&
                currentMembership?.status == ClubMembershipStatus.active,
            isAuthenticated: placeholderAuth,
            isMutating: joinMutation.isPending || leaveMutation.isPending,
            clubPushNotificationsEnabled:
                currentMembership?.pushNotificationsEnabled ?? false,
            isClubPushMutating: pushMutation.isPending,
          ),
        ),
      );
    }

    return Scaffold(
      body: vmAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (error, _) => CatchErrorState.fromError(
          error,
          context: AppErrorContext.club,
          onRetry: () => ref.invalidate(clubDetailViewModelProvider(clubId)),
        ),
        data: (_) => CatchErrorState(
          title: 'Club not found',
          message: 'This club is no longer available.',
          icon: CatchIcons.groupsOutlined,
        ),
      ),
    );
  }

  Widget _buildBody({
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
    required bool isAuthenticated,
  }) {
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
    );
  }

  Widget? _buildDock({
    required Club club,
    required bool isMember,
    required bool isAuthenticated,
    required bool isMutating,
    required bool clubPushNotificationsEnabled,
    required bool isClubPushMutating,
  }) {
    // Host app uses its own club chrome; the membership dock is consumer-only.
    if (AppConfig.appRole.isHost) return null;
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
