part of 'catch_field.dart';

extension _CatchFieldRowModes on _CatchFieldState {
  double get _rowTrailingTopPadding {
    if (widget._contentRow) return 0;
    if (!_isEdit && widget.emphasis == CatchFieldEmphasis.title) {
      return 0;
    }
    if (_showsInlineAddAtRest) return 0;

    final textEntryValueLine =
        _isEdit &&
        widget.showLabel &&
        (_title?.isNotEmpty ?? false) &&
        !_textEntryCollapsed;
    final canonicalValueLine =
        !_isEdit &&
        ((_body?.trim().isNotEmpty ?? false) ||
            (_placeholderText?.trim().isNotEmpty ?? false));
    return textEntryValueLine || canonicalValueLine
        ? CatchFieldTokens.captionExtent
        : 0;
  }

  String _inlineAddSemanticLabel(String addText) => widget.isOptional
      ? widget.copy.label.optionalSemantics(addText)
      : addText;

  TextSpan _inlineAddTextSpan(CatchTokens t) {
    final addText = _emptyEditableValueText ?? _title ?? '';
    final optionalSuffix = widget.isOptional
        ? widget.copy.label.optionalSuffix
        : null;
    return TextSpan(
      children: [
        TextSpan(
          text: addText,
          style: CatchTextStyles.fieldRowValue(
            context,
            color: t.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (optionalSuffix != null)
          TextSpan(
            text: optionalSuffix,
            style: CatchTextStyles.fieldRowValue(
              context,
              color: t.ink3,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}
