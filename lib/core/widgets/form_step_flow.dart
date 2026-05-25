import 'package:flutter/material.dart';

@immutable
class FormStepSpec {
  const FormStepSpec({required this.title, this.formKey});

  final String title;
  final GlobalKey<FormState>? formKey;
}

GlobalKey<FormState>? formKeyForStep(List<FormStepSpec> steps, int index) {
  if (index < 0 || index >= steps.length) return null;
  return steps[index].formKey;
}

String formTitleForStep(List<FormStepSpec> steps, int index) {
  if (index < 0 || index >= steps.length) {
    throw RangeError.range(index, 0, steps.length - 1, 'index');
  }
  return steps[index].title;
}
