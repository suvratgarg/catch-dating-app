import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_membership_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MembershipButton extends ConsumerWidget {
  const MembershipButton({
    super.key,
    required this.clubId,
    required this.isMember,
    required this.isMutating,
  });

  final String clubId;
  final bool isMember;
  final bool isMutating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMember) {
      return CatchButton(
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
