part of 'catch_field.dart';

extension _CatchFieldControl on _CatchFieldState {
  void _dismiss() {
    if (_isSaving) return;
    if (_isOpen) {
      _handleCancel();
    }
    if (_focusNode.hasFocus) _focusNode.unfocus();
    if (_menuController.isOpen) _menuController.close();
  }

  void _handleCancel() {
    if (_isSaving) return;
    _requestExpansion(false);
    widget._onCancel?.call();
  }

  void _handleSubmit() {
    if (_isSaving) return;
    widget._onSubmit?.call();
    // The handoff closes locally-owned disclosures after Done. Controlled
    // editors remain parent-owned so async validation/save state can decide
    // when their card collapses.
    if (mounted &&
        widget._closeLocallyOnSubmit &&
        widget.open == null &&
        !_isSaving) {
      _requestExpansion(false);
    }
  }
}

/// Exact wrapping chip control used by [CatchField.choices].
class CatchFieldChoiceControl<T> extends StatelessWidget {
  const CatchFieldChoiceControl({
    super.key,
    required this.values,
    required this.itemLabel,
    required this.selected,
    required this.multi,
    required this.onSelectionChanged,
    this.allowEmptySelection = false,
    this.autoClose = false,
    this.enabled = true,
    this.itemAccent,
  });

  final List<T> values;
  final String Function(T value) itemLabel;
  final Set<T> selected;
  final bool multi;
  final bool allowEmptySelection;
  final bool autoClose;
  final bool enabled;
  final Color? Function(T value)? itemAccent;
  final ValueChanged<Set<T>>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: CatchFieldTokens.chipHorizontalGap,
        runSpacing: CatchFieldTokens.chipRunSpacing,
        children: [
          for (final value in values)
            CatchFieldChoiceChip(
              label: itemLabel(value),
              selected: selected.contains(value),
              multi: multi,
              enabled: enabled && onSelectionChanged != null,
              accent: itemAccent?.call(value),
              onPressed: () {
                final next = Set<T>.from(selected);
                if (multi) {
                  if (next.contains(value)) {
                    if (!allowEmptySelection && next.length == 1) return;
                    next.remove(value);
                  } else {
                    next.add(value);
                  }
                } else {
                  final wasSelected = next.contains(value);
                  next.clear();
                  if (!wasSelected || !allowEmptySelection) {
                    next.add(value);
                  }
                }
                onSelectionChanged?.call(next);
                if (!multi && autoClose && onSelectionChanged != null) {
                  const _CatchFieldChoicePickedNotification(
                    autoClose: true,
                  ).dispatch(context);
                }
              },
            ),
        ],
      ),
    );
  }
}

/// Field-owned vertical single-select control for explanatory choices.
///
/// Each option remains one complete clickable [CatchOptionCard]; the field
/// owns disclosure, collapsed summary, and auto-close behavior.
class CatchFieldOptionCardControl<T> extends StatelessWidget {
  const CatchFieldOptionCardControl({
    super.key,
    required this.values,
    required this.itemTitle,
    required this.itemDescription,
    required this.selected,
    required this.onChanged,
    this.autoClose = false,
    this.enabled = true,
  });

  final List<T> values;
  final String Function(T value) itemTitle;
  final String Function(T value) itemDescription;
  final T selected;
  final ValueChanged<T>? onChanged;
  final bool autoClose;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < values.length; index++) ...[
          if (index > 0) const SizedBox(height: CatchSpacing.s2),
          Builder(
            builder: (context) {
              final value = values[index];
              final title = itemTitle(value);
              final isSelected = value == selected;
              return Semantics(
                selected: isSelected,
                inMutuallyExclusiveGroup: true,
                child: CatchOptionCard(
                  key: ValueKey('catch-field-option-card-$title'),
                  title: title,
                  description: itemDescription(value),
                  selected: isSelected,
                  onTap: enabled && onChanged != null
                      ? () {
                          onChanged?.call(value);
                          if (autoClose) {
                            const _CatchFieldChoicePickedNotification(
                              autoClose: true,
                            ).dispatch(context);
                          }
                        }
                      : null,
                ),
              );
            },
          ),
        ],
      ],
    );
  }
}

class CatchFieldChoiceChip extends StatefulWidget {
  const CatchFieldChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.multi,
    required this.enabled,
    required this.onPressed,
    this.accent,
  });

  final String label;
  final bool selected;
  final bool multi;
  final bool enabled;
  final VoidCallback onPressed;
  final Color? accent;

  @override
  State<CatchFieldChoiceChip> createState() => _CatchFieldChoiceChipState();
}

class _CatchFieldChoiceChipState extends State<CatchFieldChoiceChip> {
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: widget.enabled,
    checked: widget.selected,
    inMutuallyExclusiveGroup: !widget.multi,
    label: widget.label,
    onTap: widget.enabled ? widget.onPressed : null,
    child: ExcludeSemantics(
      child: CatchChip.selectable(
        key: ValueKey('catch-field-choice-${widget.label}'),
        label: widget.label,
        selected: widget.selected,
        enabled: widget.enabled,
        accent: widget.accent,
        leading: widget.multi && widget.selected
            ? Icon(
                CatchIcons.checkRounded,
                size: CatchFieldTokens.chipSelectedGlyphExtent,
              )
            : null,
        semanticsLabel: widget.label,
        onChanged: (_) => widget.onPressed(),
      ),
    ),
  );
}
