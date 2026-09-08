import 'package:catch_ui/src/patterns/catch_form_step_review_item.dart';
import 'package:flutter/foundation.dart';

@immutable
class CatchFormReviewState {
  const CatchFormReviewState(this.items);

  final List<CatchFormStepReviewItem> items;

  bool get canSubmit => !items.any((item) => item.blocksCompletion);

  int? get firstIncompleteStep {
    for (final item in items) {
      if (item.blocksCompletion) return item.index;
    }
    return null;
  }
}
