import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_location_map_state.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_pins_map.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tile_data.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

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

    return Stack(
      children: [
        Positioned.fill(
          child: EventPinsMap(
            items: [
              EventMapItem(event: state.event, status: EventTileStatus.open),
            ],
            initialCenter: state.startingPoint,
            initialZoom: 15.5,
            selectedEventId: state.event.id,
            enableNetworkTiles: state.enableNetworkTiles,
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
                    label: context
                        .l10n
                        .eventsEventLocationMapBodyScreenLabelGetDirections,
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
