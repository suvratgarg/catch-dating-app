import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_state.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_overlay_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          return const ChromelessMapScaffold(
            child: CatchErrorState(
              title: 'Event not found',
              message: 'This event is no longer available.',
            ),
          );
        }
        final state = EventLocationMapState.fromEvent(
          event,
          enableNetworkTiles: enableNetworkTiles,
        );

        if (!state.hasExactStartingPoint) {
          return const ChromelessMapScaffold(
            child: CatchErrorState(
              title: 'Location unavailable',
              message:
                  'This event does not have an exact pinned starting point yet.',
            ),
          );
        }

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

class EventLocationMapScreen extends StatelessWidget {
  const EventLocationMapScreen({
    super.key,
    required this.state,
    required this.onGetDirections,
  });

  final EventLocationMapState state;
  final VoidCallback onGetDirections;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    if (!state.hasExactStartingPoint) {
      final error = const CatchErrorState(
        title: 'Location unavailable',
        message: 'This event does not have an exact pinned starting point yet.',
      );
      return SafeArea(child: error);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: EventPinsMap(
            items: [
              EventMapItem(event: state.event, status: EventTileStatus.open),
            ],
            initialCenter: state.startingPoint!,
            initialZoom: 15.5,
            selectedEventId: state.event.id,
            enableNetworkTiles: state.enableNetworkTiles,
            markerIcon: CatchIcons.locationOnRounded,
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
              padding: CatchInsets.content,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CatchSurface(
                        width: CatchLayout.eventInfoTileExtent,
                        height: CatchLayout.eventInfoTileExtent,
                        backgroundColor: t.primarySoft,
                        radius: CatchRadius.interactiveTile,
                        borderWidth: 0,
                        child: Icon(
                          CatchIcons.locationOnOutlined,
                          color: t.primary,
                          size: CatchIcon.row,
                        ),
                      ),
                      const SizedBox(width: CatchSpacing.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.locationName,
                              style: CatchTextStyles.sectionTitle(context),
                            ),
                            if (state.locationNotes != null) ...[
                              gapH2,
                              Text(
                                state.locationNotes!,
                                style: CatchTextStyles.supporting(
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
                    icon: Icon(
                      CatchIcons.directionsOutlined,
                      size: CatchIcon.md,
                    ),
                    fullWidth: true,
                    onPressed: onGetDirections,
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
