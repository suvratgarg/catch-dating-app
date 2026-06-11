import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:flutter/material.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key, this.isOptional = false});

  final String label;
  final bool isOptional;

  @override
  Widget build(BuildContext context) =>
      CatchFormFieldLabel(label: label, isOptional: isOptional, large: true);
}
