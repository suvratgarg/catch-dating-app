import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_view_model.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_detail_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunDetailScreen extends ConsumerWidget {
  const RunDetailScreen({
    super.key,
    required this.runClubId,
    required this.runId,
  });

  final String runClubId;
  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(runDetailViewModelProvider(runId));

    return Scaffold(
      body: vmAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (e, _) => CatchErrorText(e),
        data: (vm) {
          if (vm == null) {
            return const Center(child: Text('Run not found.'));
          }
          return RunDetailBody(
            run: vm.run,
            userProfile: vm.userProfile,
            runClubId: runClubId,
            reviews: vm.reviews,
            isAuthenticated: vm.isAuthenticated,
          );
        },
      ),
    );
  }
}
