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
