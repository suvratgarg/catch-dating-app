import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_membership_controller.dart';
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
              label: 'Leave club',
              onPressed: () => RunClubMembershipController.leaveMutation.run(
                ref,
                (tx) async => tx
                    .get(runClubMembershipControllerProvider.notifier)
                    .leave(clubId),
              ),
              variant: CatchButtonVariant.secondary,
              isLoading: isMutating,
              fullWidth: true,
            ),
          ),
          const SizedBox(width: 10),
          _ClubBellButton(
            enabled: pushNotificationsEnabled,
            isLoading: isPushMutating,
            onPressed: isMutating
                ? null
                : () =>
                      RunClubMembershipController.pushNotificationsMutation.run(
                        ref,
                        (tx) async => tx
                            .get(runClubMembershipControllerProvider.notifier)
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
      label: 'Join club',
      onPressed: () => RunClubMembershipController.joinMutation.run(
        ref,
        (tx) async =>
            tx.get(runClubMembershipControllerProvider.notifier).join(clubId),
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
      child: SizedBox.square(
        dimension: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: isLoading ? null : onPressed,
              child: Center(
                child: isLoading
                    ? SizedBox.square(
                        dimension: 18,
                        child: CatchLoadingIndicator(
                          strokeWidth: 2,
                          color: foreground,
                        ),
                      )
                    : Icon(
                        enabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        color: foreground,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
