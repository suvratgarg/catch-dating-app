import 'package:catch_dating_app/core/labelled.dart';
import 'package:flutter/material.dart';

/// Bare dropdown — use this when you need a dropdown outside a [Form],
/// e.g. in an [AppBar] title.
class EnumDropdown<T extends Labelled> extends StatelessWidget {
  const EnumDropdown({
    super.key,
    required this.values,
    required this.value,
    required this.onChanged,
  });

  final List<T> values;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        items: _items(values),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

/// Form-field dropdown — use inside a [Form] to get decoration, validation,
/// and [FormState.save] support.
class EnumDropdownField<T extends Labelled> extends StatelessWidget {
  const EnumDropdownField({
    super.key,
    required this.values,
    required this.label,
    this.prefixIcon,
    this.initialValue,
    this.onChanged,
    this.validator,
  });

  final List<T> values;
  final String label;
  final Widget? prefixIcon;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefixIcon,
      ),
      items: _items(values),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

List<DropdownMenuItem<T>> _items<T extends Labelled>(List<T> values) =>
    values
        .map((v) => DropdownMenuItem(value: v, child: Text(v.label)))
        .toList();
