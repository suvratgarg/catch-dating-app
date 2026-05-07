import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_select_menu.dart';
import 'package:flutter/material.dart';

/// Canonical Catch single-select dropdown field for labelled enum-like values.
class CatchDropdownField<T extends Labelled> extends StatefulWidget {
  const CatchDropdownField({
    super.key,
    required this.values,
    required this.label,
    this.isOptional = false,
    this.value,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final List<T> values;
  final String label;
  final bool isOptional;
  final T? value;
  final String? hintText;
  final Widget? prefixIcon;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  State<CatchDropdownField<T>> createState() => _CatchDropdownFieldState<T>();
}

class _CatchDropdownFieldState<T extends Labelled>
    extends State<CatchDropdownField<T>> {
  final _fieldKey = GlobalKey<FormFieldState<T>>();

  @override
  void didUpdateWidget(covariant CatchDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final field = _fieldKey.currentState;
        if (field != null && field.value != widget.value) {
          field.didChange(widget.value);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: _fieldKey,
      initialValue: widget.value,
      validator: widget.validator,
      enabled: widget.enabled,
      builder: (field) {
        final t = CatchTokens.of(context);
        final value = _normalizedValue(field.value);
        final hasError = field.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CatchFormFieldLabel(
              label: widget.label,
              isOptional: widget.isOptional,
              hasError: hasError,
            ),
            const SizedBox(height: CatchSpacing.s2),
            CatchSelectMenu<T>(
              values: widget.values,
              value: value,
              itemLabel: (item) => item.label,
              hintText:
                  widget.hintText ?? 'Select ${widget.label.toLowerCase()}',
              prefixIcon: widget.prefixIcon,
              enabled: widget.enabled,
              hasError: hasError,
              semanticLabel: widget.label,
              onChanged: widget.enabled
                  ? (next) {
                      field.didChange(next);
                      widget.onChanged?.call(next);
                    }
                  : null,
            ),
            if (hasError) ...[
              const SizedBox(height: CatchSpacing.s1),
              Text(
                field.errorText!,
                style: CatchTextStyles.bodyS(context, color: t.danger),
              ),
            ],
          ],
        );
      },
    );
  }

  T? _normalizedValue(T? value) {
    if (value == null) return null;
    return widget.values.contains(value) ? value : null;
  }
}
