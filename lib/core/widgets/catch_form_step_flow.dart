import 'package:flutter/material.dart';

@immutable
class CatchFormStepSpec {
  const CatchFormStepSpec({
    required this.title,
    this.formKey,
    this.optional = false,
  });

  final String title;
  final GlobalKey<FormState>? formKey;
  final bool optional;
}

enum CatchFormStepStatus { complete, needsInformation, optional }

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

GlobalKey<FormState>? formKeyForStep(List<CatchFormStepSpec> steps, int index) {
  if (index < 0 || index >= steps.length) return null;
  return steps[index].formKey;
}

String formTitleForStep(List<CatchFormStepSpec> steps, int index) {
  if (index < 0 || index >= steps.length) {
    throw RangeError.range(index, 0, steps.length - 1, 'index');
  }
  return steps[index].title;
}
