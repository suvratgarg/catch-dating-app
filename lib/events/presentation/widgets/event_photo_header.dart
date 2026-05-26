import 'package:catch_dating_app/core/widgets/catch_event_thumbnail.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

/// Hero photo for the event detail screen.
///
/// Wraps [CatchEventThumbnail] so the fallback (when `Event.photoUrl` is
/// null or fails to load) is a pace-themed gradient with the activity glyph
/// rather than a generic backdrop — matches the look of the redesigned
/// Explore cards.
class EventPhotoHeader extends StatelessWidget {
  const EventPhotoHeader({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return CatchEventThumbnail(
      photoUrl: event.photoUrl,
      pace: event.pace,
      activityKind: event.activityKind,
      scrim: CatchEventThumbnailScrim.bottom,
    );
  }
}
