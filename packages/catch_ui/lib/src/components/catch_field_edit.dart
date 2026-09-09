part of 'catch_field.dart';

extension _CatchFieldEdit on _CatchFieldState {
  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    if (!widget.retainFocusOnSubmitted) _focusNode.unfocus();
  }

  EdgeInsets get _rowPadding {
    final containerOwnsGutter =
        CatchFieldGeometryScope.gutterOwnershipOf(context) ==
        CatchFieldGeometryScopeMode.container;
    if (_compactTextEntry) {
      return containerOwnsGutter
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: CatchSpacing.s1);
    }
    if (containerOwnsGutter) {
      return const EdgeInsets.symmetric(
        vertical: CatchFieldTokens.rowVerticalPadding,
      );
    }
    return const EdgeInsets.fromLTRB(
      CatchFieldTokens.rowHorizontalPadding,
      CatchFieldTokens.rowVerticalPadding,
      CatchFieldTokens.rowHorizontalPadding,
      CatchFieldTokens.rowVerticalPadding,
    );
  }

  EdgeInsets get _rowHeaderPadding {
    final padding = _rowPadding;
    if (!_hasControl) return padding;
    return EdgeInsets.fromLTRB(
      padding.left,
      padding.top,
      padding.right,
      _isOpen ? 0 : padding.bottom,
    );
  }

  BoxConstraints get _rowConstraints {
    if (_compactTextEntry) {
      return const BoxConstraints(
        minHeight: CatchControlMetrics.floatingMinHeight,
      );
    }
    return const BoxConstraints();
  }
}

Duration _expansionMotionDuration(BuildContext context) {
  return catchFieldMotionDuration(context, CatchMotion.base);
}
