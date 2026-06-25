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
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_location_links.dart';
import 'package:catch_dating_app/events/presentation/event_map_screen.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/events/presentation/widgets/map_overlay_controls.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
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
          const _ChromelessMapScaffold(child: EventLocationMapLoadingBody()),
      errorBuilder: (_, error, _) => _ChromelessMapScaffold(
        child: CatchErrorState.fromError(
          error,
          context: AppErrorContext.event,
          onRetry: () => ref.invalidate(eventDetailViewModelProvider(eventId)),
        ),
      ),
      builder: (context, vm) {
        final event = vm?.event;
        if (event == null) {
          return const _ChromelessMapScaffold(
            child: CatchErrorState(
              title: 'Event not found',
              message: 'This event is no longer available.',
            ),
          );
        }
        return EventLocationMapScreen(
          event: event,
          enableNetworkTiles: enableNetworkTiles,
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

class EventLocationMapScreen extends ConsumerWidget {
  const EventLocationMapScreen({
    super.key,
    required this.event,
    this.enableNetworkTiles = true,
  });

  final Event event;
  final bool enableNetworkTiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);

    if (!event.hasExactStartingPoint) {
      return const _ChromelessMapScaffold(
        child: CatchErrorState(
          title: 'Location unavailable',
          message:
              'This event does not have an exact pinned starting point yet.',
        ),
      );
    }

    final point = LocationCoordinate(
      event.effectiveStartingPointLat!,
      event.effectiveStartingPointLng!,
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: EventPinsMap(
              items: [EventMapItem(event: event, status: EventTileStatus.open)],
              initialCenter: point,
              initialZoom: 15.5,
              selectedEventId: event.id,
              enableNetworkTiles: enableNetworkTiles,
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
                                event.locationName,
                                style: CatchTextStyles.sectionTitle(context),
                              ),
                              if (event.locationNotes != null &&
                                  event.locationNotes!.isNotEmpty) ...[
                                gapH2,
                                Text(
                                  event.locationNotes!,
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
                      onPressed: () => unawaited(
                        ref
                            .read(externalLinkControllerProvider)
                            .openExternal(directionsUriForEvent(event)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const MapOverlayControls(),
        ],
      ),
    );
  }
}

class _ChromelessMapScaffold extends StatelessWidget {
  const _ChromelessMapScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      body: Stack(
        children: [
          Positioned.fill(child: SafeArea(child: child)),
          const MapOverlayControls(),
        ],
      ),
    );
  }
}
