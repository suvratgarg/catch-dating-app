import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_map_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventMapSheet extends StatelessWidget {
  const EventMapSheet({
    super.key,
    required this.items,
    required this.selectedEvent,
    required this.onEventSelected,
  });

  final List<EventMapItem> items;
  final Event? selectedEvent;
  final ValueChanged<Event> onEventSelected;

  @override
  Widget build(BuildContext context) {
    final highlightedItem =
        _selectedItem(items, selectedEvent?.id) ?? items.first;
    final highlightedEvent = highlightedItem.event;

    return CatchSurface(
      padding: const EdgeInsets.all(Sizes.p14),
      elevation: CatchSurfaceElevation.overlay,
      borderColor: CatchTokens.of(context).line,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nearby events',
                  style: CatchTextStyles.labelM(context),
                ),
              ),
              Text(
                '${items.length}',
                style: CatchTextStyles.labelM(
                  context,
                  color: CatchTokens.of(context).primary,
                ),
              ),
            ],
          ),
          gapH10,
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth * 0.58)
                  .clamp(190.0, 260.0)
                  .toDouble();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < items.length; index += 1) ...[
                      if (index > 0) gapW10,
                      EventMapTile(
                        data: items[index].tileData,
                        selected: items[index].event.id == highlightedEvent.id,
                        width: cardWidth,
                        onTap: () => onEventSelected(items[index].event),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          gapH12,
          CatchButton(
            label: 'View event',
            onPressed: () => context.pushNamed(
              Routes.eventDetailScreen.name,
              pathParameters: {
                'clubId': highlightedEvent.clubId,
                'eventId': highlightedEvent.id,
              },
              extra: highlightedEvent,
            ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

EventMapItem? _selectedItem(List<EventMapItem> items, String? selectedEventId) {
  if (selectedEventId == null) return null;
  for (final item in items) {
    if (item.event.id == selectedEventId) return item;
  }
  return null;
}
