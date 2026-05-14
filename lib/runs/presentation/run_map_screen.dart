import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/run_clubs/presentation/list/run_clubs_list_view_model.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_map_center.dart';
import 'package:catch_dating_app/runs/presentation/run_map_view_model.dart';
import 'package:catch_dating_app/runs/presentation/widgets/map_overlay_controls.dart';
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
    final selectedCityWasUserSelected = ref.watch(
      selectedRunClubCityWasUserSelectedProvider,
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: viewModelAsync.when(
              loading: () => const CatchLoadingIndicator(),
              error: (error, _) => CatchErrorState.fromError(
                error,
                context: AppErrorContext.run,
                onRetry: () => ref.invalidate(runMapViewModelProvider),
              ),
              data: (viewModel) {
                final items = viewModel.effectiveItems;
                final selectedRun = viewModel.selectedRun(_selectedRunId);
                final selectedRunCenter = _startingPointFor(selectedRun);
                final mapCenter = resolveRunMapInitialCenter(
                  deviceLocation: deviceLocation,
                  selectedCity: selectedCity,
                  selectedCityWasUserSelected: selectedCityWasUserSelected,
                );

                return viewModel.isEmpty
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
                              items: items,
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
                              selectedRunCenter: selectedRunCenter,
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
                              items: items,
                              selectedRun: selectedRun,
                              onRunSelected: (run) =>
                                  setState(() => _selectedRunId = run.id),
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),
          const MapOverlayControls(),
        ],
      ),
    );
  }
}

LocationCoordinate? _startingPointFor(Run? run) {
  if (run == null) return null;
  return LocationCoordinate.fromNullable(
    latitude: run.startingPointLat,
    longitude: run.startingPointLng,
  );
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
        message:
            'Join clubs, book runs, or save future runs to see starting points here.',
        surface: false,
      ),
    );
  }
}
