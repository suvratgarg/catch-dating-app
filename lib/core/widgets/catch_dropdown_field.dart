import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Canonical Catch single-select dropdown field for labelled enum-like values.
class CatchDropdownField<T extends Labelled> extends StatefulWidget {
  const CatchDropdownField({
    super.key,
    required this.values,
    required this.label,
    this.value,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  final List<T> values;
  final String label;
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
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() => setState(() {});

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
        final borderColor = _borderColor(t, hasError);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: CatchTextStyles.labelM(
                context,
                color: hasError ? t.danger : t.ink2,
              ),
            ),
            const SizedBox(height: CatchSpacing.s2),
            AnimatedContainer(
              duration: CatchMotion.fast,
              curve: CatchMotion.standardCurve,
              decoration: BoxDecoration(
                color: widget.enabled ? t.surface : t.raised,
                borderRadius: BorderRadius.circular(CatchRadius.sm),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: _focusNode.hasFocus && !hasError
                    ? [
                        BoxShadow(
                          color: t.primarySoft,
                          blurRadius: 0,
                          spreadRadius: 3,
                        ),
                      ]
                    : CatchElevation.none,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                  value: value,
                  focusNode: _focusNode,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(CatchRadius.md),
                  dropdownColor: t.surface,
                  icon: Padding(
                    padding: const EdgeInsets.only(right: CatchSpacing.s3),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.enabled ? t.ink2 : t.ink3,
                      size: CatchIcon.md,
                    ),
                  ),
                  hint: Text(
                    widget.hintText ?? 'Select ${widget.label.toLowerCase()}',
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.bodyL(context, color: t.ink3),
                  ),
                  style: CatchTextStyles.bodyL(
                    context,
                    color: widget.enabled ? t.ink : t.ink3,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  items: widget.values
                      .map(
                        (item) => DropdownMenuItem<T>(
                          value: item,
                          child: Row(
                            children: [
                              if (widget.prefixIcon != null) ...[
                                IconTheme(
                                  data: IconThemeData(
                                    color: t.ink3,
                                    size: CatchIcon.md,
                                  ),
                                  child: widget.prefixIcon!,
                                ),
                                const SizedBox(width: CatchSpacing.s2),
                              ],
                              Expanded(
                                child: Text(
                                  item.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: widget.enabled
                      ? (next) {
                          field.didChange(next);
                          widget.onChanged?.call(next);
                        }
                      : null,
                ),
              ),
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

  Color _borderColor(CatchTokens t, bool hasError) {
    if (hasError) return t.danger;
    if (!widget.enabled) return t.line;
    if (_focusNode.hasFocus) return t.primary;
    return t.line2;
  }
}
