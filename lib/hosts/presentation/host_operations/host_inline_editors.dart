part of '../host_operations_screen.dart';

mixin _HostInlineClubSaveState<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  bool _ownsClubMutation = false;

  bool get isSaving =>
      ref.read(HostClubEditController.updateClubMutation).isPending;

  bool get ownsClubMutation => _ownsClubMutation;

  void clearClubMutationOwnership() {
    _ownsClubMutation = false;
  }

  Future<bool> saveClubPatch({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {
    if (isSaving) return false;
    if (patch.isEmpty) return true;

    _ownsClubMutation = true;
    try {
      await HostClubEditController.updateClubMutation.run(
        ref,
        (tx) => tx
            .get(hostClubEditControllerProvider)
            .updateClub(clubId: clubId, patch: patch),
      );
      _ownsClubMutation = false;
      return true;
    } catch (_) {
      return false;
    }
  }
}

class HostInlineTextEntryEditor extends ConsumerStatefulWidget {
  const HostInlineTextEntryEditor({
    super.key,
    required this.clubId,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.currentFieldValue,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    required this.patchForValue,
    this.placeholder,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.normalizeInput,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.validator,
    this.toFieldValue,
  });

  final String clubId;
  final IconData icon;
  final String label;
  final String value;
  final String currentValue;
  final Object? currentFieldValue;
  final String fieldName;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final UpdateClubPatch Function(Object? value) patchForValue;
  final String? placeholder;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final String Function(String value)? normalizeInput;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;

  @override
  ConsumerState<HostInlineTextEntryEditor> createState() =>
      _HostInlineTextEntryEditorState();
}

class _HostInlineTextEntryEditorState
    extends ConsumerState<HostInlineTextEntryEditor>
    with _HostInlineClubSaveState<HostInlineTextEntryEditor> {
  late final TextEditingController _controller;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _controller.addListener(_clearValidationError);
  }

  @override
  void didUpdateWidget(covariant HostInlineTextEntryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _controller.text = widget.currentValue;
      clearClubMutationOwnership();
    }
    if (oldWidget.isExpanded && !widget.isExpanded) {
      clearClubMutationOwnership();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_clearValidationError);
    _controller.dispose();
    super.dispose();
  }

  void _clearValidationError() {
    if (_validationError == null && !ownsClubMutation) return;
    setState(() {
      _validationError = null;
      clearClubMutationOwnership();
    });
  }

  void _cancel() {
    _controller.text = widget.currentValue;
    clearClubMutationOwnership();
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final normalizedText =
        widget.normalizeInput?.call(_controller.text) ?? _controller.text;
    if (normalizedText != _controller.text) {
      _controller.text = normalizedText;
    }

    final validationError = widget.validator?.call(normalizedText);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    final rawValue = normalizedText.trim();
    final fieldValue = widget.toFieldValue != null
        ? widget.toFieldValue!(rawValue)
        : rawValue;
    if (_isUnchanged(fieldValue)) {
      _cancel();
      return;
    }

    final saved = await saveClubPatch(
      clubId: widget.clubId,
      patch: widget.patchForValue(fieldValue),
    );
    if (saved && mounted) widget.onSaved();
  }

  bool _isUnchanged(Object? fieldValue) {
    final currentFieldValue = widget.currentFieldValue;
    return fieldValue == currentFieldValue ||
        (fieldValue == null &&
            (currentFieldValue == null || widget.currentValue.trim().isEmpty));
  }

  @override
  Widget build(BuildContext context) {
    final saveMutation = ref.watch(HostClubEditController.updateClubMutation);
    final saving = saveMutation.isPending;
    final inputFormatters = <TextInputFormatter>[
      if (widget.maxLines != 1) const _HostStackedBlankLinesFormatter(),
      if (widget.maxLength != null)
        LengthLimitingTextInputFormatter(widget.maxLength),
    ];
    return CatchField.inputActions(
      icon: widget.icon,
      title: widget.label,
      controller: _controller,
      placeholder: widget.placeholder ?? widget.value,
      open: widget.isExpanded,
      onOpenChanged: (expanded) {
        if (expanded != widget.isExpanded) widget.onTap();
      },
      isLoading: saving,
      enabled: !saving,
      error:
          _validationError ??
          (ownsClubMutation
              ? mutationErrorMessage(
                  saveMutation,
                  l10n: context.l10n,
                  context: AppErrorContext.club,
                )
              : null),
      keyboardType: widget.keyboardType,
      textInputAction: widget.maxLines == 1
          ? TextInputAction.done
          : TextInputAction.newline,
      textCapitalization: widget.textCapitalization,
      inputFormatters: inputFormatters.isEmpty ? null : inputFormatters,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      supporting: widget.showCounter && widget.maxLength != null
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Text(
                context.l10n.hostsHostInlineEditorsTextLengthMaxlength(
                  length: _controller.text.length,
                  maxLength: widget.maxLength!,
                ),
                style: CatchTextStyles.labelM(context),
              ),
            )
          : null,
      onSubmitted: (_) => _submit(),
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }
}

class HostInlineOption<T> {
  const HostInlineOption({
    required this.value,
    required this.label,
    this.accentColor,
  });

  final T value;
  final String label;
  final Color? accentColor;
}

class HostInlineOptionEditor<T> extends ConsumerStatefulWidget {
  const HostInlineOptionEditor({
    super.key,
    required this.clubId,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.fieldName,
    required this.isExpanded,
    required this.options,
    required this.patchForValue,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.helperText,
  });

  final String clubId;
  final IconData icon;
  final String label;
  final String value;
  final T currentValue;
  final String fieldName;
  final bool isExpanded;
  final List<HostInlineOption<T>> options;
  final UpdateClubPatch Function(T value) patchForValue;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;
  final String? helperText;

  @override
  ConsumerState<HostInlineOptionEditor<T>> createState() =>
      _HostInlineOptionEditorState<T>();
}

class _HostInlineOptionEditorState<T>
    extends ConsumerState<HostInlineOptionEditor<T>>
    with _HostInlineClubSaveState<HostInlineOptionEditor<T>> {
  late T _selected = widget.currentValue;

  @override
  void didUpdateWidget(covariant HostInlineOptionEditor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _selected = widget.currentValue;
      clearClubMutationOwnership();
    }
    if (oldWidget.isExpanded && !widget.isExpanded) {
      clearClubMutationOwnership();
    }
  }

  void _cancel() {
    setState(() {
      _selected = widget.currentValue;
      clearClubMutationOwnership();
    });
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected == widget.currentValue) {
      _cancel();
      return;
    }

    final saved = await saveClubPatch(
      clubId: widget.clubId,
      patch: widget.patchForValue(_selected),
    );
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final saveMutation = ref.watch(HostClubEditController.updateClubMutation);
    final saving = saveMutation.isPending;
    final displayValue = widget.isExpanded
        ? _labelFor(_selected)
        : widget.value;
    // TODO(edit-spec-p3): Migrate this staged editor to CatchField.choices
    // once the Host option save model becomes immediate-commit.
    return CatchField.control(
      icon: widget.icon,
      title: widget.label,
      body: displayValue,
      open: widget.isExpanded,
      onOpenChanged: (expanded) {
        if (expanded != widget.isExpanded) widget.onTap();
      },
      isLoading: saving,
      error: ownsClubMutation
          ? mutationErrorMessage(
              saveMutation,
              l10n: context.l10n,
              context: AppErrorContext.club,
            )
          : null,
      control: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.helperText != null) ...[
            Text(
              widget.helperText!,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH12,
          ],
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final option in widget.options)
                CatchChip.selectable(
                  label: option.label,
                  selected: _selected == option.value,
                  accent: option.accentColor,
                  enabled: !saving,
                  onChanged: (_) => setState(() {
                    _selected = option.value;
                    clearClubMutationOwnership();
                  }),
                ),
            ],
          ),
        ],
      ),
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }

  String _labelFor(T value) {
    for (final option in widget.options) {
      if (option.value == value) return option.label;
    }
    return widget.value;
  }
}

class HostInlineAgeRangeEditor extends ConsumerStatefulWidget {
  const HostInlineAgeRangeEditor({
    super.key,
    required this.clubId,
    required this.icon,
    required this.label,
    required this.value,
    required this.fieldName,
    required this.hostDefaults,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
  });

  final String clubId;
  final IconData icon;
  final String label;
  final String value;
  final String fieldName;
  final ClubHostDefaults hostDefaults;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<HostInlineAgeRangeEditor> createState() =>
      _HostInlineAgeRangeEditorState();
}

class _HostInlineAgeRangeEditorState
    extends ConsumerState<HostInlineAgeRangeEditor>
    with _HostInlineClubSaveState<HostInlineAgeRangeEditor> {
  late final TextEditingController _minAgeController;
  late final TextEditingController _maxAgeController;
  String? _validationError;

  EventPolicyDefaults get _policy => widget.hostDefaults.eventPolicy;

  @override
  void initState() {
    super.initState();
    _minAgeController = TextEditingController(
      text: _optionalMinAgeText(_policy.minAge),
    );
    _maxAgeController = TextEditingController(
      text: _optionalMaxAgeText(_policy.maxAge),
    );
    _minAgeController.addListener(_clearValidationError);
    _maxAgeController.addListener(_clearValidationError);
  }

  @override
  void didUpdateWidget(covariant HostInlineAgeRangeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.hostDefaults.eventPolicy.minAge != _policy.minAge ||
        oldWidget.hostDefaults.eventPolicy.maxAge != _policy.maxAge) {
      _minAgeController.text = _optionalMinAgeText(_policy.minAge);
      _maxAgeController.text = _optionalMaxAgeText(_policy.maxAge);
      clearClubMutationOwnership();
    }
    if (oldWidget.isExpanded && !widget.isExpanded) {
      clearClubMutationOwnership();
    }
  }

  @override
  void dispose() {
    _minAgeController.removeListener(_clearValidationError);
    _maxAgeController.removeListener(_clearValidationError);
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _clearValidationError() {
    if (_validationError == null && !ownsClubMutation) return;
    setState(() {
      _validationError = null;
      clearClubMutationOwnership();
    });
  }

  void _cancel() {
    _minAgeController.text = _optionalMinAgeText(_policy.minAge);
    _maxAgeController.text = _optionalMaxAgeText(_policy.maxAge);
    clearClubMutationOwnership();
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final parsed = _parseAgeRange(
      minText: _minAgeController.text,
      maxText: _maxAgeController.text,
    );
    if (parsed.error != null) {
      setState(() => _validationError = parsed.error);
      return;
    }

    final minAge = parsed.minAge!;
    final maxAge = parsed.maxAge!;
    if (minAge == _policy.minAge && maxAge == _policy.maxAge) {
      _cancel();
      return;
    }

    final saved = await saveClubPatch(
      clubId: widget.clubId,
      patch: UpdateClubPatch(
        hostDefaults: widget.hostDefaults.copyWith(
          eventPolicy: _policy.copyWith(minAge: minAge, maxAge: maxAge),
        ),
      ),
    );
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final saveMutation = ref.watch(HostClubEditController.updateClubMutation);
    final saving = saveMutation.isPending;
    final displayValue = widget.isExpanded ? _draftValue : widget.value;
    // Composite exception: two coordinated inputs commit one age-range patch.
    return CatchField.control(
      icon: widget.icon,
      title: widget.label,
      body: displayValue,
      open: widget.isExpanded,
      onOpenChanged: (expanded) {
        if (expanded != widget.isExpanded) widget.onTap();
      },
      isLoading: saving,
      error:
          _validationError ??
          (ownsClubMutation
              ? mutationErrorMessage(
                  saveMutation,
                  l10n: context.l10n,
                  context: AppErrorContext.club,
                )
              : null),
      control: Row(
        children: [
          Expanded(
            child: CatchField.input(
              title: context.l10n.hostsHostInlineEditorsTitleMinAge,
              isOptional: true,
              controller: _minAgeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !saving,
            ),
          ),
          gapW12,
          Expanded(
            child: CatchField.input(
              title: context.l10n.hostsHostInlineEditorsTitleMaxAge,
              isOptional: true,
              controller: _maxAgeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              enabled: !saving,
            ),
          ),
        ],
      ),
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }

  String get _draftValue {
    final minAge = int.tryParse(_minAgeController.text.trim()) ?? 0;
    final maxAge = int.tryParse(_maxAgeController.text.trim()) ?? 99;
    return context.l10n.hostsHostInlineEditorsVisiblecopyMinageMaxage(
      minAge: minAge,
      maxAge: maxAge,
    );
  }
}

class _HostStackedBlankLinesFormatter extends TextInputFormatter {
  const _HostStackedBlankLinesFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final collapsed = _collapseHostStackedBlankLines(newValue.text);
    if (collapsed == newValue.text) return newValue;

    final selectionEnd = newValue.selection.end;
    final normalizedOffset = selectionEnd < 0
        ? collapsed.length
        : _collapseHostStackedBlankLines(
            newValue.text.substring(0, selectionEnd),
          ).length;
    final offset = normalizedOffset.clamp(0, collapsed.length);
    return TextEditingValue(
      text: collapsed,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

String _collapseHostStackedBlankLines(String value) {
  return value
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(RegExp(r'\n[ \t]*\n(?:[ \t]*\n)+'), '\n\n');
}
