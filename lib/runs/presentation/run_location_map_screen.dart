import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_detail_view_model.dart';
import 'package:catch_dating_app/runs/presentation/run_location_links.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_pins_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RunLocationMapRouteScreen extends ConsumerWidget {
  const RunLocationMapRouteScreen({
    super.key,
    required this.runId,
    this.enableNetworkTiles = true,
  });

  final String runId;
  final bool enableNetworkTiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(runDetailViewModelProvider(runId));

    return vmAsync.when(
      loading: () => const Scaffold(body: CatchLoadingIndicator()),
      error: (error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.run,
        onRetry: () => ref.invalidate(runDetailViewModelProvider(runId)),
      ),
      data: (vm) {
        final run = vm?.run;
        if (run == null) {
          return const CatchErrorScaffold(
            title: 'Run not found',
            message: 'This run is no longer available.',
          );
        }
        return RunLocationMapScreen(
          run: run,
          enableNetworkTiles: enableNetworkTiles,
        );
      },
    );
  }
}

class RunLocationMapScreen extends ConsumerWidget {
  const RunLocationMapScreen({
    super.key,
    required this.run,
    this.enableNetworkTiles = true,
  });

  final Run run;
  final bool enableNetworkTiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);

    if (!run.hasExactStartingPoint) {
      return CatchErrorScaffold(
        title: 'Location unavailable',
        message: 'This run does not have an exact pinned starting point yet.',
        backgroundColor: t.bg,
      );
    }

    final point = LocationCoordinate(
      run.startingPointLat!,
      run.startingPointLng!,
    );

    return Scaffold(
      backgroundColor: t.bg,
      appBar: const CatchTopBar(title: 'Run location'),
      body: Stack(
        children: [
          Positioned.fill(
            child: RunPinsMap(
              runs: [run],
              initialCenter: point,
              initialZoom: 15.5,
              selectedRunId: run.id,
              enableNetworkTiles: enableNetworkTiles,
              markerIcon: Icons.location_on_rounded,
            ),
          ),
          Positioned(
            left: CatchSpacing.s5,
            right: CatchSpacing.s5,
            bottom: CatchSpacing.s5,
            child: SafeArea(
              top: false,
              child: CatchSurface(
                tone: CatchSurfaceTone.raised,
                elevation: CatchSurfaceElevation.overlay,
                borderColor: t.line,
                padding: const EdgeInsets.all(CatchSpacing.s4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: t.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: t.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: CatchSpacing.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                run.meetingPoint,
                                style: CatchTextStyles.titleM(context),
                              ),
                              if (run.locationDetails != null &&
                                  run.locationDetails!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  run.locationDetails!,
                                  style: CatchTextStyles.bodyS(
                                    context,
                                    color: t.ink2,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: CatchSpacing.s3),
                    CatchButton(
                      label: 'Get directions',
                      icon: const Icon(Icons.directions_outlined, size: 18),
                      fullWidth: true,
                      onPressed: () => unawaited(
                        ref
                            .read(externalLinkControllerProvider)
                            .openExternal(directionsUriForRun(run)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
