import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_map_view_model.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_map_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Map view'),
      body: viewModelAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (error, _) => CatchErrorText(error),
        data: (viewModel) {
          final runs = viewModel.runs;
          final selectedRun = viewModel.selectedRun(_selectedRunId);

          return Column(
            children: [
              Expanded(
                child: viewModel.isEmpty
                    ? const _MapEmptyState()
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: _RunsMap(
                              runs: viewModel.pinnedRuns,
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

class _RunsMap extends ConsumerWidget {
  const _RunsMap({
    required this.runs,
    required this.selectedRunId,
    required this.enableNetworkTiles,
    required this.onRunSelected,
  });

  static const _mumbai = LatLng(19.0760, 72.8777);

  final List<Run> runs;
  final String? selectedRunId;
  final bool enableNetworkTiles;
  final ValueChanged<Run> onRunSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceLocation = ref.watch(deviceLocationProvider).asData?.value;
    final center = runs.isEmpty
        ? (deviceLocation ?? _mumbai)
        : LatLng(runs.first.startingPointLat!, runs.first.startingPointLng!);
    final t = CatchTokens.of(context);

    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 12.5),
      children: [
        if (enableNetworkTiles)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.catchdating.app',
          )
        else
          ColoredBox(color: t.primarySoft),
        MarkerLayer(
          markers: [
            for (final run in runs)
              Marker(
                point: LatLng(run.startingPointLat!, run.startingPointLng!),
                width: 52,
                height: 52,
                child: Semantics(
                  button: true,
                  selected: selectedRunId == run.id,
                  label: 'Select ${run.title}',
                  child: GestureDetector(
                    onTap: () => onRunSelected(run),
                    child: AnimatedScale(
                      scale: selectedRunId == run.id ? 1.14 : 1,
                      duration: const Duration(milliseconds: 160),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: selectedRunId == run.id ? t.primary : t.ink,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.directions_run_rounded,
                          color: selectedRunId == run.id
                              ? t.primaryInk
                              : t.surface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
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
