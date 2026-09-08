part of 'catch_field.dart';

/// Placement of a field's native input inside its existing row or underline.
enum CatchFieldTextEntryMode { standalone, row, explicitSave }

/// Native input, validation, and text-entry chrome owned by a CatchField.
///
/// The owner supplies immutable configuration and keeps controller, focus,
/// dismissal and save orchestration. Product callers use CatchField's named
/// constructors; this member moves with that facade into the shared package.
class CatchFieldTextEntry extends StatelessWidget {
  const CatchFieldTextEntry({
    super.key,
    required this.field,
    required this.formFieldKey,
    required this.controller,
    required this.focusNode,
    required this.tapRegionGroupId,
    required this.onValidationErrorChanged,
    required this.onSubmitted,
    required this.mode,
    required this.states,
    required this.emptyValueText,
    required this.inputHintText,
    required this.addTextSpan,
    required this.headerTrailingReserve,
    this.expanded = false,
    this.inlineAddAtRest = false,
  });

  final CatchField field;
  final GlobalKey<FormFieldState<String>> formFieldKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Object tapRegionGroupId;
  final ValueChanged<bool> onValidationErrorChanged;
  final ValueChanged<String> onSubmitted;
  final CatchFieldTextEntryMode mode;
  final Set<WidgetState> states;
  final String? emptyValueText;
  final String? inputHintText;
  final TextSpan addTextSpan;
  final double headerTrailingReserve;
  final bool expanded;
  final bool inlineAddAtRest;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final rowBody = mode == CatchFieldTextEntryMode.row;
    final explicitSave = mode == CatchFieldTextEntryMode.explicitSave;
    final valueEmphasis = mode != CatchFieldTextEntryMode.standalone;
    final effectiveVariant = valueEmphasis
        ? CatchFieldVariant.bare
        : field.variant;
    final effectiveShowLabel = valueEmphasis ? false : field.showLabel;
    final canInteractOverride = explicitSave ? expanded && field.enabled : null;
    final readOnlyOverride = explicitSave ? !expanded : null;
    final includeSupport = !explicitSave;
    final inputHintOverride = explicitSave && !inlineAddAtRest
        ? expanded
              ? inputHintText
              : emptyValueText
        : null;
    final inputHintWidgetOverride = explicitSave && inlineAddAtRest
        ? Text.rich(
            addTextSpan,
            style: CatchTextStyles.fieldRowValue(
              context,
              color: t.ink3,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : null;
    final addSemanticLabel = emptyValueText == null
        ? null
        : field.isOptional
        ? field.copy.label.optionalSemantics(emptyValueText!)
        : emptyValueText;
    final semanticLabelOverride = explicitSave && inlineAddAtRest
        ? addSemanticLabel ?? field.title
        : field.title;

    return FormField<String>(
      key: formFieldKey,
      initialValue: controller.text,
      validator: (value) => CatchContractFieldPolicy.validateText(
        copy: field.copy.validation,
        label: field.title ?? '',
        value: value ?? '',
        contract: field.contract,
        explicitValidator: field.validator,
      ),
      enabled: field.enabled,
      builder: (state) {
        final t = CatchTokens.of(context);
        final rawError = field.errorText ?? field.error ?? state.errorText;
        final error = rawError?.trim().isNotEmpty == true
            ? rawError!.trim()
            : null;
        final hasError = error != null;
        onValidationErrorChanged(state.hasError);
        final supportText = includeSupport ? error ?? field.helperText : null;

        final inlineAddAtRest =
            rowBody && _inlineTextAddAtRestWith(hasError: hasError);
        final addText = rowBody ? emptyValueText : null;
        final effectiveInputHint = !rowBody
            ? inputHintOverride
            : inlineAddAtRest
            ? null
            : _textEntryExpandedWith(hasError: hasError)
            ? inputHintOverride
            : emptyValueText;
        final effectiveHintWidget = !rowBody
            ? inputHintWidgetOverride
            : inlineAddAtRest
            ? Text.rich(
                addTextSpan,
                style: CatchTextStyles.fieldRowValue(
                  context,
                  color: t.ink3,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null;
        final effectiveSemanticLabel = !rowBody
            ? semanticLabelOverride
            : inlineAddAtRest && addText != null
            ? addSemanticLabel!
            : _title;

        final canInteract =
            canInteractOverride ?? (!field.readOnly || field.onTap != null);
        final readOnly = readOnlyOverride ?? field.readOnly;
        final effectiveFocused = focusNode.hasFocus || field.focused;
        final inlineAddHint = effectiveHintWidget != null;
        final multiline =
            !inlineAddHint &&
            !field.obscureText &&
            (field.maxLines != 1 || (field.minLines ?? 1) > 1);
        final multilineValueStyle = CatchTextStyles.fieldRowValue(
          context,
          color: field.enabled ? t.ink : t.ink3,
        ).copyWith(height: CatchFieldTokens.multilineValueLineHeight);
        final multilineHintStyle = CatchTextStyles.fieldRowValue(
          context,
          color: t.ink2,
        ).copyWith(height: CatchFieldTokens.multilineValueLineHeight);
        final inputStyle = valueEmphasis
            ? multiline
                  ? multilineValueStyle
                  : CatchTextStyles.fieldRowValue(
                      context,
                      color: field.enabled ? t.ink : t.ink3,
                    )
            : _textStyle(context, color: field.enabled ? t.ink : t.ink3);
        final hintStyle = valueEmphasis
            ? multiline
                  ? multilineHintStyle
                  : CatchTextStyles.fieldRowValue(context, color: t.ink2)
            : field.size == CatchFieldSize.floating
            ? CatchTextStyles.bodyL(context, color: t.ink2)
            : _textStyle(context, color: t.ink2);
        final resolvedHintText = effectiveHintWidget == null
            ? effectiveInputHint ?? inputHintText
            : null;
        final visualOnlyHint = !effectiveShowLabel && resolvedHintText != null;
        final textField = CatchTextInput(
          inputKey: const ValueKey<String>('catch-field-text-entry'),
          groupId: tapRegionGroupId,
          controller: controller,
          focusNode: focusNode,
          enabled: field.enabled,
          mode: !canInteract
              ? CatchTextInputMode.inactive
              : readOnly
              ? CatchTextInputMode.readOnly
              : CatchTextInputMode.editable,
          enableInteractiveSelection: canInteract,
          autofocus: field.autofocus,
          keyboardType: field.keyboardType,
          textInputAction: field.textInputAction ?? TextInputAction.done,
          textCapitalization: field.textCapitalization,
          inputFormatters: CatchContractFieldPolicy.effectiveInputFormatters(
            field.contract,
            field.inputFormatters,
            explicitMaxLength: field._editConfig?.maxLength,
          ),
          autofillHints: field.autofillHints,
          variant: field.obscureText
              ? CatchTextInputVariant.obscured
              : CatchTextInputVariant.plain,
          maxLines: field.obscureText || inlineAddHint ? 1 : field.maxLines,
          minLines: inlineAddHint ? null : field.minLines,
          maxLength: field.maxLength,
          textAlign: field.textAlign,
          textAlignVertical: inlineAddHint
              ? TextAlignVertical.center
              : _textAlignVertical,
          onTap: field.onTap,
          onTapOutside: field._explicitSaveInput
              ? null
              : (_) => focusNode.unfocus(),
          onChanged: (value) {
            state.didChange(value);
            field.onChanged?.call(value);
          },
          onEditingComplete: field.retainFocusOnSubmitted ? () {} : null,
          onSubmitted: onSubmitted,
          style: inputStyle,
          cursorColor: t.primary,
          decoration: InputDecoration(
            counterText: '',
            isDense: true,
            isCollapsed: effectiveVariant == CatchFieldVariant.bare,
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: _contentPadding(effectiveVariant),
            labelText: _useFloatingLabel(effectiveVariant, effectiveShowLabel)
                ? _title
                : null,
            labelStyle: _useFloatingLabel(effectiveVariant, effectiveShowLabel)
                ? CatchTextStyles.bodyL(
                    context,
                    color: _fieldLabelColor(t, hasError: hasError),
                  )
                : null,
            floatingLabelStyle:
                _useFloatingLabel(effectiveVariant, effectiveShowLabel)
                ? CatchFieldValueContent.captionStyle(
                    context,
                    color: _fieldLabelColor(t, hasError: hasError),
                  )
                : null,
            floatingLabelBehavior:
                _useFloatingLabel(effectiveVariant, effectiveShowLabel)
                ? FloatingLabelBehavior.auto
                : FloatingLabelBehavior.never,
            hint: effectiveHintWidget != null
                ? ExcludeSemantics(child: effectiveHintWidget)
                : visualOnlyHint
                ? ExcludeSemantics(child: Text(resolvedHintText))
                : null,
            hintText: effectiveHintWidget != null || visualOnlyHint
                ? null
                : resolvedHintText,
            hintStyle: hintStyle,
            prefixText: field.prefixText,
            prefixStyle: _textStyle(context, color: t.ink2),
            suffixText: field.suffixText,
            suffixStyle: CatchTextStyles.bodyLead(context, color: t.ink2),
            prefixIconConstraints: _iconConstraints,
            prefixIcon: _usesRowPrefixIcon || field.prefixIcon == null
                ? null
                : IconTheme(
                    data: IconThemeData(color: t.ink3, size: CatchIcon.md),
                    child: field.prefixIcon!,
                  ),
            suffixIconConstraints: _suffixIconConstraints,
            suffixIcon:
                _usesRowTextEntryTrailing ||
                    (!field.showClearButton &&
                        field.action == null &&
                        field.suffixIcon == null)
                ? null
                : CatchFieldTrailing.inputSuffix(
                    controller: controller,
                    clearTooltip: field.copy.clearTooltip(_title),
                    action: field.action,
                    suffixIcon: field.suffixIcon,
                    showClearButton: field.showClearButton,
                    onChanged: field.onChanged,
                  ),
          ),
        );
        final Widget inputShell;
        if (effectiveVariant == CatchFieldVariant.bare ||
            effectiveVariant == CatchFieldVariant.row) {
          inputShell = textField;
        } else {
          final active = effectiveFocused || hasError;
          final baselineColor = hasError
              ? t.danger
              : field.enabled
              ? t.line2
              : t.line;
          final sweepColor = hasError ? t.danger : t.ink;
          inputShell = ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: CatchControlMetrics.minHeight(_controlSize),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                DecoratedBox(
                  key: const ValueKey('catch-field-underline-baseline'),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: baselineColor)),
                  ),
                  child: textField,
                ),
                PositionedDirectional(
                  start: 0,
                  end: 0,
                  bottom: -CatchFieldTokens.underlineSweepBottomOffset,
                  height: CatchStroke.underline,
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        TweenAnimationBuilder<double>(
                          key: const ValueKey('catch-field-underline-sweep'),
                          duration: catchFieldMotionDuration(
                            context,
                            CatchFieldTokens.reveal,
                          ),
                          curve: CatchFieldTokens.curve,
                          tween: Tween<double>(end: active ? 1 : 0),
                          builder: (context, progress, _) => Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: SizedBox(
                              key: const ValueKey(
                                'catch-field-underline-sweep-bar',
                              ),
                              width: constraints.maxWidth * progress,
                              height: CatchStroke.underline,
                              child: ColoredBox(color: sweepColor),
                            ),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          );
        }
        final singleLineControlHeight = _singleLineControlHeight(
          effectiveVariant,
        );
        final sizedInputShell = singleLineControlHeight == null
            ? inputShell
            : SizedBox(height: singleLineControlHeight, child: inputShell);

        final input = effectiveShowLabel
            ? sizedInputShell
            : MergeSemantics(
                child: Semantics(
                  label: effectiveSemanticLabel ?? _title,
                  child: sizedInputShell,
                ),
              );

        if (rowBody) {
          final body = CatchFieldValueContent(
            labelCopy: field.copy.label,
            titleMaxLines: field.titleMaxLines,
            isOptional: field.isOptional && field.showLabel,
            badgeLabel: field.badgeLabel,
            badgeTone: field.badgeTone,
            tone: field.tone,
            helperTone: field.helperTone,
            headerTrailingReserve: headerTrailingReserve,
            label: field.showLabel && !inlineAddAtRest ? _title : null,
            supportText: supportText,
            counterText:
                field.maxLength != null &&
                    (_focused || field.focused || hasError)
                ? '${controller.text.characters.length} / ${field.maxLength}'
                : null,
            status: hasError
                ? CatchFieldValueContentStatus.error
                : _active
                ? CatchFieldValueContentStatus.active
                : CatchFieldValueContentStatus.idle,
            labelStyle: CatchFieldValueContent.captionStyle(
              context,
              color: hasError
                  ? t.danger
                  : _active
                  ? t.ink
                  : t.ink2,
            ),
            valueWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (!inlineAddAtRest && field.leadingUnit != null) ...[
                  Text(
                    field.leadingUnit!,
                    style: CatchTextStyles.fieldRowValue(
                      context,
                      color: t.ink2,
                    ),
                  ),
                  const SizedBox(width: CatchSpacing.s1),
                ],
                Expanded(
                  key: const ValueKey<String>('catch-field-text-input'),
                  child: input,
                ),
              ],
            ),
          );

          if (MediaQuery.maybeOf(context)?.disableAnimations == true) {
            return body;
          }
          return AnimatedSize(
            duration: catchFieldMotionDuration(context, CatchMotion.base),
            curve: CatchMotion.standardCurve,
            alignment: Alignment.topCenter,
            child: body,
          );
        }

        final counterText =
            effectiveVariant == CatchFieldVariant.underline &&
                field.maxLength != null &&
                (_focused || field.focused)
            ? '${controller.text.characters.length} / ${field.maxLength}'
            : null;
        final hasMeta = supportText != null || counterText != null;

        if (!effectiveShowLabel && !hasMeta) {
          return input;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (effectiveShowLabel &&
                !_useFloatingLabel(effectiveVariant, effectiveShowLabel)) ...[
              CatchFormFieldLabel.inline(
                copy: field.copy.label,
                label: _title ?? '',
                style: CatchFieldValueContent.captionStyle(
                  context,
                  color: _fieldLabelColor(t, hasError: hasError),
                ),
                isOptional: field.isOptional && field.showLabel,
              ),
              const SizedBox(height: CatchSpacing.s2),
            ],
            input,
            if (hasMeta) ...[
              const SizedBox(height: CatchFieldTokens.supportingTopGap),
              CatchFieldSupportRow(
                text: supportText,
                counter: counterText,
                color: hasError ? t.danger : _supportColor(t),
                showErrorIcon:
                    hasError && effectiveVariant != CatchFieldVariant.underline,
              ),
            ],
          ],
        );
      },
    );
  }

  bool get _active => states.contains(WidgetState.selected);
  bool get _focused => states.contains(WidgetState.focused);
  String? get _title => field.title;
  bool get _hasInputValue => controller.text.isNotEmpty;
  bool get _textEntryCanCollapse =>
      field.showLabel && (_title?.isNotEmpty ?? false);
  bool _textEntryExpandedWith({required bool hasError}) =>
      !_textEntryCanCollapse ||
      _hasInputValue ||
      _active ||
      hasError ||
      field.autofocus;
  bool _inlineTextAddAtRestWith({required bool hasError}) =>
      !field.readOnly &&
      _textEntryCanCollapse &&
      !_hasInputValue &&
      !_active &&
      !hasError &&
      !field.autofocus &&
      emptyValueText != null;
  bool get _compactTextEntry =>
      field.size == CatchFieldSize.floating && !field.showLabel;
  bool get _usesRowPrefixIcon =>
      field.variant != CatchFieldVariant.underline &&
      !_compactTextEntry &&
      field.showLabel &&
      field.prefixIcon != null;
  bool get _usesRowTextEntryTrailing =>
      field.variant != CatchFieldVariant.underline &&
      !_compactTextEntry &&
      (field.showClearButton ||
          field.suffixIcon != null ||
          field.action != null);
  Color _fieldLabelColor(CatchTokens t, {required bool hasError}) => hasError
      ? t.danger
      : _active
      ? t.ink
      : t.ink2;
  Color _supportColor(CatchTokens t) => switch (field.helperTone) {
    CatchFieldSupportTone.neutral => t.ink2,
    CatchFieldSupportTone.brand => t.primary,
    CatchFieldSupportTone.success => t.success,
  };

  bool _useFloatingLabel(CatchFieldVariant variant, bool showLabel) {
    return field.floatingLabel &&
        showLabel &&
        !field.isOptional &&
        variant == CatchFieldVariant.underline;
  }

  EdgeInsets _contentPadding(CatchFieldVariant variant) {
    if (variant == CatchFieldVariant.bare || variant == CatchFieldVariant.row) {
      return EdgeInsets.zero;
    }
    if (variant == CatchFieldVariant.underline) {
      return const EdgeInsets.fromLTRB(
        0,
        CatchSpacing.micro2,
        0,
        CatchSpacing.s2,
      );
    }
    return CatchControlMetrics.textFieldContentPadding(_controlSize);
  }

  TextStyle _textStyle(BuildContext context, {required Color color}) {
    final style = field.size == CatchFieldSize.floating
        ? CatchTextStyles.bodyLead(context, color: color)
        : CatchTextStyles.bodyL(context, color: color);

    if (!field.mono) return style;

    return style.copyWith(
      fontFeatures: [
        ...?style.fontFeatures,
        const FontFeature.tabularFigures(),
      ],
    );
  }

  BoxConstraints? get _iconConstraints {
    if (field.maxLines != 1 || field.minLines != null) return null;

    final extent = CatchControlMetrics.iconExtent(_controlSize);
    return CatchControlMetrics.squareConstraints(extent);
  }

  BoxConstraints? get _suffixIconConstraints {
    if (field.action == null) return _iconConstraints;
    return const BoxConstraints();
  }

  CatchControlSurfaceSize get _controlSize {
    return switch (field.size) {
      CatchFieldSize.floating => CatchControlSurfaceSize.floating,
      CatchFieldSize.compact => CatchControlSurfaceSize.compact,
      CatchFieldSize.md => CatchControlSurfaceSize.md,
    };
  }

  TextAlignVertical? get _textAlignVertical {
    if (field.maxLines != 1 || field.minLines != null) return null;
    return TextAlignVertical.center;
  }

  double? _singleLineControlHeight(CatchFieldVariant variant) {
    if (variant == CatchFieldVariant.bare || variant == CatchFieldVariant.row) {
      return null;
    }
    if (field.maxLines != 1 || field.minLines != null) return null;
    return CatchControlMetrics.minHeight(_controlSize);
  }
}
