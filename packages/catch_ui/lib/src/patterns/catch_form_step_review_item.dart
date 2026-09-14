import 'package:catch_ui/src/patterns/catch_form_step_row_list_status.dart';
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
  final CatchFormStepRowListStatus status;

  bool get blocksCompletion =>
      status == CatchFormStepRowListStatus.needsInformation;
}
