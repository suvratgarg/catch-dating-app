import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_text.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final profileAsync = ref.watch(watchUserProfileProvider);
    final t = CatchTokens.of(context);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Map view'),
      body: profileAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (error, _) => CatchErrorText(error),
        data: (user) {
          if (user == null) return const SizedBox.shrink();

          final signedUpAsync = ref.watch(watchSignedUpRunsProvider(user.uid));
          final recommendedAsync = ref.watch(
            recommendedRunsProvider(user.joinedRunClubIds),
          );
          final isLoading =
              signedUpAsync.isLoading || recommendedAsync.isLoading;
          final error = signedUpAsync.error ?? recommendedAsync.error;
          final runs = _mergeRuns(
            signedUpAsync.asData?.value ?? const <Run>[],
            recommendedAsync.asData?.value ?? const <Run>[],
          );
          final pinnedRuns = runs.where(_hasPin).toList();
          final selectedRun = runs
              .where((run) => run.id == _selectedRunId)
              .firstOrNull;

          return Column(
            children: [
              Expanded(
                child: isLoading
                    ? const CatchLoadingIndicator()
                    : error != null
                    ? CatchErrorText(error)
                    : runs.isEmpty
                    ? _MapEmptyState(tokens: t)
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: _RunsMap(
                              runs: pinnedRuns,
                              selectedRunId: _selectedRunId,
                              enableNetworkTiles: widget.enableNetworkTiles,
                              onRunSelected: (run) =>
                                  setState(() => _selectedRunId = run.id),
                            ),
                          ),
                          Positioned(
                            left: CatchSpacing.s5,
                            right: CatchSpacing.s5,
                            bottom: Sizes.p20,
                            child: _MapRunSheet(
                              runs: runs,
                              selectedRun: selectedRun,
                              tokens: t,
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

  static bool _hasPin(Run run) =>
      run.startingPointLat != null && run.startingPointLng != null;

  static List<Run> _mergeRuns(List<Run> signedUp, List<Run> recommended) {
    final byId = <String, Run>{};
    for (final run in [...signedUp, ...recommended]) {
      byId[run.id] = run;
    }
    final runs = byId.values.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return runs;
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
          ],
        ),
      ],
    );
  }
}

class _MapRunSheet extends StatelessWidget {
  const _MapRunSheet({
    required this.runs,
    required this.selectedRun,
    required this.tokens,
    required this.onRunSelected,
  });

  final List<Run> runs;
  final Run? selectedRun;
  final CatchTokens tokens;
  final ValueChanged<Run> onRunSelected;

  @override
  Widget build(BuildContext context) {
    final highlightedRun = selectedRun ?? runs.first;

    return Container(
      padding: const EdgeInsets.all(Sizes.p14),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        border: Border.all(color: tokens.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nearby runs', style: CatchTextStyles.labelM(context)),
          gapH10,
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: runs.length,
              separatorBuilder: (_, _) => gapW10,
              itemBuilder: (context, index) {
                final run = runs[index];
                final selected = run.id == highlightedRun.id;
                return _RunMapChip(
                  run: run,
                  selected: selected,
                  onTap: () => onRunSelected(run),
                );
              },
            ),
          ),
          gapH12,
          CatchButton(
            label: 'View run',
            onPressed: () => context.pushNamed(
              Routes.runDetailScreen.name,
              pathParameters: {
                'runClubId': highlightedRun.runClubId,
                'runId': highlightedRun.id,
              },
            ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _RunMapChip extends StatelessWidget {
  const _RunMapChip({
    required this.run,
    required this.selected,
    required this.onTap,
  });

  final Run run;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CatchRadius.md),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(Sizes.p12),
        decoration: BoxDecoration(
          color: selected ? t.primarySoft : t.raised,
          borderRadius: BorderRadius.circular(CatchRadius.md),
          border: Border.all(color: selected ? t.primary : t.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              run.meetingPoint,
              style: CatchTextStyles.labelL(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            gapH6,
            Text(
              '${run.shortDateLabel} · ${run.compactTimeRangeLabel}',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
            gapH4,
            Text(
              '${RunFormatters.distanceKm(run.distanceKm)} · ${run.pace.label}',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
            if (run.startingPointLat == null || run.startingPointLng == null)
              Text(
                'No exact pin',
                style: CatchTextStyles.bodyS(context, color: t.primary),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapEmptyState extends StatelessWidget {
  const _MapEmptyState({required this.tokens});

  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s5),
        child: Text(
          'Join clubs or book runs to see mapped starting points here.',
          style: CatchTextStyles.bodyM(context, color: tokens.ink2),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
