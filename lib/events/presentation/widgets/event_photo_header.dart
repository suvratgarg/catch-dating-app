import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:flutter/material.dart';

/// Hero visual for the event detail screen.
///
/// Wraps [CatchEventThumbnail] with activity artwork preferred so the detail
/// header stays color-coded by the same mutable visual schema as Explore cards.
class EventPhotoHeader extends StatelessWidget {
  const EventPhotoHeader({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: eventPhotoHeroTag(event.id),
      transitionOnUserGestures: true,
      child: CatchEventThumbnail(
        photoUrl: event.photoUrl,
        pace: event.pace,
        activityKind: event.activityKind,
        scrim: CatchEventThumbnailScrim.bottom,
        preferActivityArtwork: true,
      ),
    );
  }
}
