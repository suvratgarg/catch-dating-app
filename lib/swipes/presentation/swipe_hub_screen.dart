import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/attended_run_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SwipeHubScreen extends ConsumerWidget {
  const SwipeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final t = CatchTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Swipe')),
      body: uidAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (uid) {
          if (uid == null) return const SizedBox.shrink();

          // TODO(critical): attendedRunsProvider queries runs.attendedUserIds,
          // but no Cloud Function or client code ever writes attendedUserIds.
          // This provider will ALWAYS return an empty list until a
          // "mark attendance" mechanism is built — see CLAUDE.md item #15.
          final runsAsync = ref.watch(attendedRunsProvider(uid));

          return runsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (runs) {
              if (runs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.directions_run_outlined,
                        size: 64,
                        color: t.line2,
                      ),
                      gapH16,
                      Text('No runs yet', style: CatchTextStyles.displaySm(context)),
                      gapH8,
                      Text(
                        'Attend a run to start meeting people!',
                        style: CatchTextStyles.bodyMd(context, color: t.ink2),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: Sizes.p8),
                itemCount: runs.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) => AttendedRunTile(run: runs[i]),
              );
            },
          );
        },
      ),
    );
  }
}
