import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/runs/presentation/run_map_center.dart';
import 'package:catch_dating_app/runs/presentation/run_map_view_model.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_map_sheet.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_pins_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunMapScreen extends ConsumerStatefulWidget {
  const RunMapScreen({super.key, this.enableNetworkTiles = true});

  final bool enableNetworkTiles;

  @override
  ConsumerState<RunMapScreen> createState() => _RunMapScreenState();
}

class _RunMapScreenState extends ConsumerState<RunMapScreen> {
  String? _selectedRunId;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final viewModelAsync = ref.watch(runMapViewModelProvider);
    final deviceLocation = ref.watch(deviceLocationProvider).asData?.value;
    final selectedCity = ref.watch(selectedRunClubCityProvider);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Map view'),
      body: viewModelAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (error, _) => CatchErrorState.fromError(
          error,
          context: AppErrorContext.run,
          onRetry: () => ref.invalidate(runMapViewModelProvider),
        ),
        data: (viewModel) {
          final runs = viewModel.runs;
          final selectedRun = viewModel.selectedRun(_selectedRunId);
          final mapCenter = resolveRunMapInitialCenter(
            deviceLocation: deviceLocation,
            selectedCity: selectedCity,
            pinnedRuns: viewModel.pinnedRuns,
          );

          return Column(
            children: [
              Expanded(
                child: viewModel.isEmpty
                    ? const _MapEmptyState()
                    : !viewModel.hasPinnedRuns
                    ? Stack(
                        children: [
                          const Positioned.fill(child: _NoPinnedRunsState()),
                          Positioned(
                            left: CatchSpacing.s5,
                            right: CatchSpacing.s5,
                            bottom: CatchSpacing.s5,
                            child: RunMapSheet(
                              runs: runs,
                              selectedRun: selectedRun,
                              onRunSelected: (run) =>
                                  setState(() => _selectedRunId = run.id),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: RunPinsMap(
                              runs: viewModel.pinnedRuns,
                              initialCenter: mapCenter,
                              selectedRunId: _selectedRunId,
                              enableNetworkTiles: widget.enableNetworkTiles,
                              onRunSelected: (run) =>
                                  setState(() => _selectedRunId = run.id),
                            ),
                          ),
                          Positioned(
                            left: CatchSpacing.s5,
                            right: CatchSpacing.s5,
                            bottom: CatchSpacing.s5,
                            child: RunMapSheet(
                              runs: runs,
                              selectedRun: selectedRun,
                              onRunSelected: (run) =>
                                  setState(() => _selectedRunId = run.id),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NoPinnedRunsState extends StatelessWidget {
  const _NoPinnedRunsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CatchEmptyState(
        icon: Icons.add_location_alt_outlined,
        title: 'No exact pins yet',
        message:
            'These runs are visible, but none have pinned starting points.',
        surface: false,
      ),
    );
  }
}

class _MapEmptyState extends StatelessWidget {
  const _MapEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CatchEmptyState(
        icon: Icons.map_outlined,
        title: 'No mapped runs yet',
        message: 'Join clubs or book runs to see mapped starting points here.',
        surface: false,
      ),
    );
  }
}
