import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'who_is_running.g.dart';

@riverpod
Future<Map<String, (String name, String? photoUrl)>> runnerProfiles(
    Ref ref, List<String> uids) async {
  if (uids.isEmpty) return {};
  final profiles =
      await ref.watch(publicProfileRepositoryProvider).fetchPublicProfiles(uids);
  return {
    for (final p in profiles)
      p.uid: (p.name, p.photoUrls.firstOrNull),
  };
}

class WhoIsRunning extends ConsumerWidget {
  const WhoIsRunning({
    super.key,
    required this.run,
    required this.appUser,
  });

  final Run run;
  final AppUser appUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final total = run.signedUpCount;

    final previewIds = run.signedUpUserIds.take(7).toList();
    final profilesAsync = ref.watch(runnerProfilesProvider(previewIds));
    final profiles = profilesAsync.asData?.value ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text("Who's running",
                  style: CatchTextStyles.displaySm(context)),
            ),
            Text('$total/${run.capacityLimit}',
                style: CatchTextStyles.labelMd(context, color: t.ink2)),
          ],
        ),
        const SizedBox(height: 12),
        if (total == 0)
          Text('No one has booked yet — be the first!',
              style: CatchTextStyles.bodySm(context, color: t.ink2))
        else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...previewIds.map((uid) {
                final profile = profiles[uid];
                return PersonAvatar(
                  size: 44,
                  name: profile?.$1 ?? uid,
                  imageUrl: profile?.$2,
                );
              }),
              if (total > 7)
                PersonAvatar.count(count: total - 7, size: 44),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (!run.isUpcoming) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(CatchRadius.card),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite_rounded, size: 16, color: t.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Swiping on fellow runners unlocks after the run finishes.',
                    style: CatchTextStyles.bodySm(context, color: t.primary),
                  ),
                ),
              ],
            ),
          ),
        ] else if (run.isUpcoming) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(CatchRadius.card),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 16, color: t.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Swiping unlocks after the run finishes.',
                    style: CatchTextStyles.bodySm(context, color: t.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
