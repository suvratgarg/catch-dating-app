import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_club_name_lookup.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_agenda_list.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SavedRunsScreen extends ConsumerWidget {
  const SavedRunsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final uid = ref.watch(uidProvider).asData?.value;
    final savedRunsAsync = uid == null
        ? const AsyncData(<Run>[])
        : ref.watch(watchSavedRunDetailsForUserProvider(uid));

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Saved runs'),
      body: SafeArea(
        child: savedRunsAsync.when(
          loading: () => const CatchLoadingIndicator(),
          error: (_, _) => const _SavedRunsMessage(
            title: 'Saved runs unavailable',
            message: 'Your saved runs could not be loaded.',
          ),
          data: (runs) {
            if (runs.isEmpty) {
              return const _SavedRunsMessage(
                title: 'No saved runs yet',
                message: 'Save runs you want to revisit before booking.',
              );
            }

            final now = DateTime.now();
            final orderedRuns = _orderSavedRuns(runs, now: now);
            final clubNamesAsync = ref.watch(
              runClubNameLookupProvider(
                RunClubNameLookupQuery(orderedRuns.map((run) => run.runClubId)),
              ),
            );
            final clubNames = clubNamesAsync.asData?.value;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.s5,
                    CatchSpacing.s2,
                    CatchSpacing.s5,
                    CatchSpacing.s3,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Runs you saved',
                      style: CatchTextStyles.displayM(context),
                    ),
                  ),
                ),
                if (clubNames == null)
                  SliverFillRemaining(
                    child: clubNamesAsync.hasError
                        ? const _SavedRunsMessage(
                            title: 'Saved runs unavailable',
                            message: 'Run club names could not be loaded.',
                          )
                        : const CatchLoadingIndicator(),
                  )
                else
                  RunAgendaSliverList(
                    runs: orderedRuns,
                    showClubName: true,
                    clubNameBuilder: (run) => clubNames[run.runClubId],
                    today: DateUtils.dateOnly(now),
                    preserveInputOrder: true,
                    badgeLabelBuilder: (run) =>
                        run.startTime.isAfter(now) ? 'SAVED' : 'PAST',
                    statusBuilder: (run) => run.startTime.isAfter(now)
                        ? RunTileStatus.saved
                        : RunTileStatus.past,
                    onRunSelected: (run) => _openRunDetail(context, run),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openRunDetail(BuildContext context, Run run) {
    final runClubId = Uri.encodeComponent(run.runClubId);
    final runId = Uri.encodeComponent(run.id);
    context.push('/saved-runs/run-clubs/$runClubId/runs/$runId');
  }
}

class _SavedRunsMessage extends StatelessWidget {
  const _SavedRunsMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CatchEmptyState(
        icon: Icons.bookmark_border_rounded,
        title: title,
        message: message,
        surface: false,
        iconStyle: CatchEmptyStateIconStyle.plain,
        iconSize: 44,
        padding: const EdgeInsets.all(CatchSpacing.s6),
        titleStyle: CatchTextStyles.titleL(context),
      ),
    );
  }
}

List<Run> _orderSavedRuns(List<Run> runs, {required DateTime now}) {
  final upcoming = <Run>[];
  final past = <Run>[];
  for (final run in runs) {
    if (run.startTime.isBefore(now)) {
      past.add(run);
    } else {
      upcoming.add(run);
    }
  }

  upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));
  past.sort((a, b) => b.startTime.compareTo(a.startTime));
  return [...upcoming, ...past];
}
