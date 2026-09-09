import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_content_row.dart';
import 'package:catch_ui/src/components/catch_field_content_row_mode.dart';
import 'package:catch_ui/src/components/catch_field_content_row_status.dart';
import 'package:catch_ui/src/components/catch_field_copy.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope.dart';
import 'package:catch_ui/src/components/catch_field_geometry_scope_mode.dart';
import 'package:catch_ui/src/components/catch_field_row.dart';
import 'package:catch_ui/src/components/catch_field_size.dart';
import 'package:catch_ui/src/components/catch_field_support_row_tone.dart';
import 'package:catch_ui/src/components/catch_field_trailing.dart';
import 'package:catch_ui/src/components/catch_menu.dart';
import 'package:catch_ui/src/components/catch_menu_item.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_control_surface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Field-owned selection menu, validation state, and labelled value row.
///
/// The enclosing field owns the supplied focus and menu controllers. This
/// renderer keeps the selected form value in sync when the caller changes
/// either the value or the available choices.
class CatchFieldSelectControl extends StatefulWidget {
  const CatchFieldSelectControl({
    super.key,
    required this.copy,
    required this.title,
    required this.values,
    required this.itemLabel,
    required this.menuController,
    required this.focusNode,
    this.value,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.showLabel = true,
    this.size = CatchFieldSize.md,
    this.placeholder,
    this.prefixIcon,
    this.error,
    this.helperText,
    this.helperTone = CatchFieldSupportRowTone.neutral,
    this.status = CatchFieldContentRowStatus.idle,
  });

  final CatchFieldCopy copy;
  final String? title;
  final List<Object?> values;
  final String Function(Object? item) itemLabel;
  final MenuController menuController;
  final FocusNode focusNode;
  final Object? value;
  final ValueChanged<Object?>? onChanged;
  final FormFieldValidator<Object?>? validator;
  final bool enabled;
  final bool showLabel;
  final CatchFieldSize size;
  final String? placeholder;
  final Widget? prefixIcon;
  final String? error;
  final String? helperText;
  final CatchFieldSupportRowTone helperTone;
  final CatchFieldContentRowStatus status;

  @override
  State<CatchFieldSelectControl> createState() =>
      _CatchFieldSelectControlState();
}

class _CatchFieldSelectControlState extends State<CatchFieldSelectControl> {
  final _fieldKey = GlobalKey<FormFieldState<Object?>>();

  @override
  void didUpdateWidget(CatchFieldSelectControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value &&
        listEquals(oldWidget.values, widget.values)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final field = _fieldKey.currentState;
      final value = _normalizedValue(widget.value);
      if (field != null && field.value != value) field.didChange(value);
    });
  }

  Object? _normalizedValue(Object? value) =>
      value != null && widget.values.contains(value) ? value : null;

  @override
  Widget build(BuildContext context) {
    final controlSize = switch (widget.size) {
      CatchFieldSize.floating => CatchControlSurfaceSize.floating,
      CatchFieldSize.compact => CatchControlSurfaceSize.compact,
      CatchFieldSize.md => CatchControlSurfaceSize.md,
    };
    final rowConstraints = widget.showLabel
        ? const BoxConstraints()
        : BoxConstraints(minHeight: CatchControlMetrics.minHeight(controlSize));
    final containerOwnsGutter =
        CatchFieldGeometryScope.gutterOwnershipOf(context) ==
        CatchFieldGeometryScopeMode.container;
    final rowPadding = containerOwnsGutter
        ? const EdgeInsets.symmetric(
            vertical: CatchFieldTokens.rowVerticalPadding,
          )
        : const EdgeInsets.fromLTRB(
            CatchFieldTokens.rowHorizontalPadding,
            CatchFieldTokens.rowVerticalPadding,
            CatchFieldTokens.rowHorizontalPadding,
            CatchFieldTokens.rowVerticalPadding,
          );
    return FormField<Object?>(
      key: _fieldKey,
      initialValue: _normalizedValue(widget.value),
      validator: (value) => widget.validator?.call(_normalizedValue(value)),
      enabled: widget.enabled,
      builder: (state) {
        final t = CatchTokens.of(context);
        final value = _normalizedValue(state.value);
        if (state.value != value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final field = _fieldKey.currentState;
            if (field == null) return;
            // A caller update may already have replaced the selection during
            // this frame. Normalize the live value, not the builder snapshot.
            final currentValue = _normalizedValue(field.value);
            if (field.value != currentValue) {
              field.didChange(currentValue);
            }
          });
        }
        final rawError = widget.error ?? state.errorText;
        final error = rawError?.trim().isNotEmpty == true
            ? rawError!.trim()
            : null;
        final hasError = error != null;
        final supportText = error ?? widget.helperText;
        final ValueChanged<Object?>? onChanged =
            widget.enabled && widget.onChanged != null
            ? (next) {
                state.didChange(next);
                widget.onChanged?.call(next);
              }
            : null;
        final values = widget.values;
        final labelOf = widget.itemLabel;
        final label = value == null ? null : labelOf(value);
        final canOpen =
            widget.enabled && onChanged != null && values.isNotEmpty;

        return CatchMenu<Object?>.anchored(
          controller: widget.menuController,
          items: [
            for (final item in values)
              CatchMenuItem<Object?>(
                value: item,
                label: labelOf(item),
                selected: item == value,
                variant: CatchMenuItemVariant.choice,
              ),
          ],
          onSelected: (item, _) {
            onChanged?.call(item);
            widget.menuController.close();
          },
          builder: (context, controller, child) {
            final selectHasLabel =
                widget.showLabel && (widget.title?.trim().isNotEmpty ?? false);
            return Semantics(
              button: true,
              enabled: canOpen,
              label: widget.title,
              value: label,
              child: Focus(
                focusNode: widget.focusNode,
                child: CatchFieldRow.standard(
                  onTap: canOpen
                      ? () {
                          widget.focusNode.requestFocus();
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        }
                      : null,
                  constraints: rowConstraints,
                  padding: rowPadding,
                  leading: widget.prefixIcon == null
                      ? null
                      : IconTheme(
                          data: IconThemeData(
                            color: widget.enabled ? t.ink2 : t.ink3,
                            size: CatchFieldRow.leadingSlotIconSize,
                          ),
                          child: widget.prefixIcon!,
                        ),
                  body: CatchFieldContentRow.value(
                    labelCopy: widget.copy.label,
                    helperTone: widget.helperTone,
                    label: widget.showLabel ? widget.title?.trim() : null,
                    value:
                        label ??
                        widget.placeholder ??
                        widget.copy.selectPlaceholder(widget.title),
                    supportText: supportText,
                    status: hasError
                        ? CatchFieldContentRowStatus.error
                        : widget.status,
                    mode: label == null
                        ? CatchFieldContentRowMode.placeholder
                        : CatchFieldContentRowMode.value,
                    labelStyle: CatchFieldContentRow.captionStyle(
                      context,
                      color: hasError ? t.danger : t.ink2,
                    ),
                    valueStyle: CatchTextStyles.fieldRowValue(
                      context,
                      color: label == null || !widget.enabled ? t.ink3 : t.ink,
                    ),
                  ),
                  trailing: selectHasLabel
                      ? Padding(
                          padding: EdgeInsets.only(
                            top: CatchFieldTokens.captionExtent,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: CatchFieldTokens.valueLineExtent,
                            ),
                            child: Align(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: CatchFieldTrailing.rotatingChevron(
                                open: controller.isOpen,
                                color: t.ink3,
                                topPadding: 0,
                              ),
                            ),
                          ),
                        )
                      : CatchFieldTrailing.rotatingChevron(
                          open: controller.isOpen,
                          color: t.ink3,
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
