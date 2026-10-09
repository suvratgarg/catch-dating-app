import 'package:catch_dating_app/hosts/presentation/event_management/create/host_event_offer_preferences_screen.dart';
import 'package:flutter/widgets.dart';

/// Public route boundary for the shared offer settings editor.
class HostResponseOfferPreferencesRouteScreen extends StatelessWidget {
  const HostResponseOfferPreferencesRouteScreen({
    super.key,
    required this.organizerId,
    required this.eventId,
    required this.onBack,
  });

  final String organizerId;
  final String eventId;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => HostEventOfferPreferencesScreen(
    organizerId: organizerId,
    eventId: eventId,
    onBack: onBack,
  );
}
