import 'package:catch_dating_app/run_clubs/presentation/detail/run_club_detail_controller.dart';
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
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isMutating
              ? null
              : () => RunClubDetailController.leaveMutation.run(
                  ref,
                  (tx) async => tx
                      .get(runClubDetailControllerProvider.notifier)
                      .leave(clubId),
                ),
          child: isMutating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Leave club'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isMutating
            ? null
            : () => RunClubDetailController.joinMutation.run(
                ref,
                (tx) async => tx
                    .get(runClubDetailControllerProvider.notifier)
                    .join(clubId),
              ),
        child: isMutating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Join club'),
      ),
    );
  }
}
