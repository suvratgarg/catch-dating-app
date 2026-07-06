import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/clubs/shared/club_action_keys.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_dock.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Membership role the [ClubDetailDock] renders for.
enum ClubDetailDockRole { guest, visitor, member, owner }

@Deprecated('Use ClubDetailDockRole. Kept for one release during C4 migration.')
typedef CatchClubDockState = ClubDetailDockRole;

/// Design-system `ClubDock` (`components/clubs/ClubDock`): the persistent bottom
/// bar of a club detail screen, stateful over membership role — BookingDock's
/// club sibling. `visitor` shows the member count + an **activity-pigmented**
/// Join CTA (the one sanctioned use of the club pigment on an action); `member`
/// shows the count + a notifications bell + a quiet "Joined" control; `owner`
/// shows Manage + a New-event pair; `guest` shows an ink "Sign in to join". The
/// mono [footnote] carries the state's quiet facts.
class ClubDetailDock extends StatelessWidget {
  const ClubDetailDock({
    super.key,
    required this.state,
    required this.activityKind,
    this.members,
    this.membersLabel = 'MEMBERS',
    this.notificationsEnabled = true,
    this.footnote,
    this.joinKey,
    this.manageKey,
    this.isJoinLoading = false,
    this.isBellLoading = false,
    this.onJoin,
    this.onSignIn,
    this.onBell,
    this.onManage,
    this.onCreate,
  });

  final ClubDetailDockRole state;
  final ActivityKind activityKind;
  final int? members;
  final String membersLabel;
  final bool notificationsEnabled;
  final String? footnote;
  final Key? joinKey;
  final Key? manageKey;
  final bool isJoinLoading;
  final bool isBellLoading;
  final VoidCallback? onJoin;
  final VoidCallback? onSignIn;
  final VoidCallback? onBell;
  final VoidCallback? onManage;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, activityKind);
    final t = CatchTokens.of(context);
    final showCount = members != null && state != ClubDetailDockRole.owner;

    return CatchBottomDock(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.micro18,
        CatchSpacing.micro14,
        CatchSpacing.micro18,
        CatchSpacing.micro18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showCount) ...[
                DockCount(members: members!, label: membersLabel),
                const SizedBox(width: CatchSpacing.s3),
              ],
              ..._controls(activity),
            ],
          ),
          if (footnote != null && footnote!.isNotEmpty) ...[
            const SizedBox(height: CatchSpacing.micro10),
            Text(
              footnote!,
              textAlign: TextAlign.center,
              style: CatchTextStyles.monoLabel(
                context,
                color: t.ink3,
              ).copyWith(fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _controls(CatchActivity activity) {
    switch (state) {
      case ClubDetailDockRole.guest:
        return [
          Expanded(
            child: CatchButton(
              label: 'Sign in to join',
              icon: Icon(CatchIcons.lockOutlineRounded),
              onPressed: onSignIn,
              fullWidth: true,
            ),
          ),
        ];
      case ClubDetailDockRole.visitor:
        return [
          Expanded(
            child: CatchButton(
              key: joinKey,
              label: 'Join club',
              icon: Icon(CatchIcons.add),
              accentColor: activity.accent,
              isLoading: isJoinLoading,
              onPressed: onJoin,
              fullWidth: true,
            ),
          ),
        ];
      case ClubDetailDockRole.member:
        return [
          DockBell(
            active: notificationsEnabled,
            accent: activity.accent,
            isLoading: isBellLoading,
            onPressed: onBell,
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: CatchButton(
              key: manageKey,
              label: 'Joined',
              icon: Icon(CatchIcons.checkCircle),
              variant: CatchButtonVariant.secondary,
              isLoading: isJoinLoading,
              onPressed: onManage,
              fullWidth: true,
            ),
          ),
        ];
      case ClubDetailDockRole.owner:
        return [
          Expanded(
            child: CatchButton(
              label: 'Manage',
              icon: Icon(CatchIcons.settingsOutlined),
              variant: CatchButtonVariant.secondary,
              onPressed: onManage,
              fullWidth: true,
            ),
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            flex: 2,
            child: CatchButton(
              label: 'New event',
              icon: Icon(CatchIcons.add),
              accentColor: activity.accent,
              onPressed: onCreate,
              fullWidth: true,
            ),
          ),
        ];
    }
  }
}

@Deprecated('Use ClubDetailDock. Kept for one release during C4 migration.')
typedef CatchClubDock = ClubDetailDock;

class DockCount extends StatelessWidget {
  const DockCount({super.key, required this.members, required this.label});

  final int members;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$members',
          style: CatchTextStyles.numericLarge(
            context,
          ).copyWith(fontSize: 17, height: 1),
        ),
        const SizedBox(height: CatchSpacing.micro6),
        Text(
          label,
          style: CatchTextStyles.monoLabel(
            context,
            color: t.ink2,
          ).copyWith(fontSize: 9, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Member notifications bell — the active state fills with the club's activity
/// accent (not the raw Material color scheme).
class DockBell extends StatelessWidget {
  const DockBell({
    super.key,
    required this.active,
    required this.accent,
    required this.isLoading,
    required this.onPressed,
  });

  final bool active;
  final Color accent;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final foreground = active ? CatchTokens.editorialWhite : t.ink2;

    return Semantics(
      button: true,
      toggled: active,
      label: active
          ? 'Disable club push notifications'
          : 'Enable club push notifications',
      child: CatchIconButton(
        size: CatchSpacing.s12,
        background: active ? accent : t.raised,
        onTap: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox.square(
                dimension: CatchIcon.md,
                child: CatchLoadingIndicator(strokeWidth: 2, color: foreground),
              )
            : Icon(
                active
                    ? CatchIcons.notificationsActiveRounded
                    : CatchIcons.notificationsNoneRounded,
                color: foreground,
              ),
      ),
    );
  }
}

/// Provider-backed [ClubDetailDock] for the consumer club-detail screen. Computes
/// the membership state and wires Join / Leave / notification mutations and the
/// guest sign-in route. (Owner state is host-app territory and not rendered
/// here.)
class ClubMembershipDock extends ConsumerWidget {
  const ClubMembershipDock({
    super.key,
    required this.club,
    required this.isMember,
    required this.isAuthenticated,
    required this.isMutating,
    required this.pushNotificationsEnabled,
    required this.isPushMutating,
  });

  final Club club;
  final bool isMember;
  final bool isAuthenticated;
  final bool isMutating;
  final bool pushNotificationsEnabled;
  final bool isPushMutating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return ClubDetailDock(
      state: state,
      activityKind: club.hostDefaults.primaryActivityKind,
      members: club.memberCount,
      footnote: footnote,
      joinKey: ClubActionKeys.joinButton,
      manageKey: ClubActionKeys.leaveButton,
      notificationsEnabled: pushNotificationsEnabled,
      isJoinLoading: isMutating,
      isBellLoading: isPushMutating,
      onSignIn: () => context.go(
        Uri(
          path: Routes.authScreen.path,
          queryParameters: {'from': '/clubs/${club.id}'},
        ).toString(),
      ),
      onJoin: () => ClubMembershipController.joinMutation.run(
        ref,
        (tx) async =>
            tx.get(clubMembershipControllerProvider.notifier).join(club.id),
      ),
      onManage: () => ClubMembershipController.leaveMutation.run(
        ref,
        (tx) async =>
            tx.get(clubMembershipControllerProvider.notifier).leave(club.id),
      ),
      onBell: isMutating
          ? null
          : () => ClubMembershipController.pushNotificationsMutation.run(
              ref,
              (tx) async => tx
                  .get(clubMembershipControllerProvider.notifier)
                  .setPushNotifications(
                    clubId: club.id,
                    enabled: !pushNotificationsEnabled,
                  ),
            ),
    );
  }
}
