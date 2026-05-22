import 'package:catch_dating_app/core/widgets/catch_detail_hero_backdrop.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

class EventPhotoHeader extends StatelessWidget {
  const EventPhotoHeader({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return CatchDetailHeroBackdrop(
      imageUrl: event.photoUrl,
      semanticLabel: '${event.title} photo',
    );
  }
}
