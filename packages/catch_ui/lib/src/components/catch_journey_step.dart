import 'package:catch_ui/src/components/catch_journey_steps.dart';

/// One step in a [CatchJourneySteps] sequence.
class CatchJourneyStep {
  const CatchJourneyStep({required this.title, this.body});

  final String title;
  final String? body;
}
