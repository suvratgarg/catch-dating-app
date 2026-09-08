import 'package:catch_ui/src/patterns/catch_form_step_status.dart';
import 'package:flutter/foundation.dart';

@immutable
class CatchFormStepReviewItem {
  const CatchFormStepReviewItem({
    required this.index,
    required this.title,
    required this.status,
  });

  final int index;
  final String title;
  final CatchFormStepStatus status;

  bool get blocksCompletion => status == CatchFormStepStatus.needsInformation;
}
