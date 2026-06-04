import 'package:catch_dating_app/clubs/presentation/club_action_keys.dart';
import 'package:catch_dating_app/clubs/presentation/detail/club_membership_controller.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MembershipButton extends ConsumerWidget {
  const MembershipButton({
    super.key,
    required this.clubId,
    required this.isMember,
    required this.isMutating,
    required this.pushNotificationsEnabled,
    required this.isPushMutating,
  });

  final String clubId;
  final bool isMember;
  final bool isMutating;
  final bool pushNotificationsEnabled;
  final bool isPushMutating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMember) {
      return Row(
        children: [
          Expanded(
            child: CatchButton(
              key: ClubActionKeys.leaveButton,
              label: 'Leave club',
              onPressed: () => ClubMembershipController.leaveMutation.run(
                ref,
                (tx) async => tx
                    .get(clubMembershipControllerProvider.notifier)
                    .leave(clubId),
              ),
              variant: CatchButtonVariant.secondary,
              isLoading: isMutating,
              fullWidth: true,
            ),
          ),
          gapW10,
          _ClubBellButton(
            enabled: pushNotificationsEnabled,
            isLoading: isPushMutating,
            onPressed: isMutating
                ? null
                : () => ClubMembershipController.pushNotificationsMutation.run(
                    ref,
                    (tx) async => tx
                        .get(clubMembershipControllerProvider.notifier)
                        .setPushNotifications(
                          clubId: clubId,
                          enabled: !pushNotificationsEnabled,
                        ),
                  ),
          ),
        ],
      );
    }

    return CatchButton(
      key: ClubActionKeys.joinButton,
      label: 'Join club',
      onPressed: () => ClubMembershipController.joinMutation.run(
        ref,
        (tx) async =>
            tx.get(clubMembershipControllerProvider.notifier).join(clubId),
      ),
      isLoading: isMutating,
      fullWidth: true,
    );
  }
}

class _ClubBellButton extends StatelessWidget {
  const _ClubBellButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground = enabled
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    final background = enabled
        ? colorScheme.primary
        : colorScheme.surfaceContainerHighest;

    return Semantics(
      button: true,
      toggled: enabled,
      label: enabled
          ? 'Disable club push notifications'
          : 'Enable club push notifications',
      child: IconBtn(
        size: 52,
        background: background,
        onTap: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox.square(
                dimension: CatchIcon.md,
                child: CatchLoadingIndicator(strokeWidth: 2, color: foreground),
              )
            : Icon(
                enabled
                    ? CatchIcons.notificationsActiveRounded
                    : CatchIcons.notificationsNoneRounded,
                color: foreground,
              ),
      ),
    );
  }
}
