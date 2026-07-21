import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_body_screen.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_state.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_overlay_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

export 'package:catch_dating_app/events/presentation/event_location_map_body_screen.dart';

class EventLocationMapRouteScreen extends ConsumerWidget {
  const EventLocationMapRouteScreen({
    super.key,
    required this.eventId,
    this.enableNetworkTiles = true,
  });

  final String eventId;
  final bool enableNetworkTiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vmAsync = ref.watch(eventDetailViewModelProvider(eventId));

    return CatchAsyncValueView<EventDetailViewModel?>(
      value: vmAsync,
      onRetry: () => ref.invalidate(eventDetailViewModelProvider(eventId)),
      loadingBuilder: (_) =>
          const ChromelessMapScaffold(child: EventLocationMapLoadingBody()),
      errorBuilder: (_, error, _) => ChromelessMapScaffold(
        child: CatchErrorState.fromError(
          error,
          context: AppErrorContext.event,
          onRetry: () => ref.invalidate(eventDetailViewModelProvider(eventId)),
        ),
      ),
      builder: (context, vm) {
        final event = vm?.event;
        if (event == null) {
          return ChromelessMapScaffold(
            child: CatchErrorState(
              title:
                  context.l10n.eventsEventLocationMapScreenTitleEventNotFound,
              message:
                  context.l10n.eventsEventLocationMapScreenMessageThisEventIsNo,
            ),
          );
        }
        final state = EventLocationMapState.fromEvent(
          event,
          enableNetworkTiles: enableNetworkTiles,
        );

        return ChromelessMapScaffold(
          safeArea: false,
          child: EventLocationMapScreen(
            state: state,
            onGetDirections: () => unawaited(
              ref
                  .read(externalLinkControllerProvider)
                  .openExternal(state.directionsUri),
            ),
          ),
        );
      },
    );
  }
}

class EventLocationMapLoadingBody extends StatelessWidget {
  const EventLocationMapLoadingBody({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Stack(
      children: [
        const Positioned.fill(child: EventMapLoadingBody()),
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
              padding: CatchInsets.content,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CatchSkeleton.box(
                        width: CatchLayout.eventInfoTileExtent,
                        height: CatchLayout.eventInfoTileExtent,
                        radius: CatchRadius.interactiveTile,
                        borderColor: t.line,
                      ),
                      gapW12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CatchSkeleton.text(
                              width: CatchLayout.skeletonTextTitleWidth,
                            ),
                            gapH6,
                            CatchSkeleton.text(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  gapH12,
                  CatchSkeleton.box(
                    width: double.infinity,
                    height: CatchLayout.buttonLgHeight,
                    radius: CatchRadius.pill,
                    borderColor: t.line,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChromelessMapScaffold extends StatelessWidget {
  const ChromelessMapScaffold({
    super.key,
    required this.child,
    this.safeArea = true,
  });

  final Widget child;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      body: Stack(
        children: [
          Positioned.fill(child: safeArea ? SafeArea(child: child) : child),
          const MapOverlayControls(),
        ],
      ),
    );
  }
}
