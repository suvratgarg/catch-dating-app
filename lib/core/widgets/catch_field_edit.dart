part of 'catch_field.dart';

extension _CatchFieldEdit on _CatchFieldState {
  Widget _buildTextEntryField(
    BuildContext context, {
    bool? showLabelOverride,
    CatchFieldVariant? variantOverride,
    bool valueEmphasis = false,
    bool rowBody = false,
    bool? canInteractOverride,
    bool? readOnlyOverride,
    bool includeSupport = true,
    String? inputHintOverride,
    Widget? inputHintWidgetOverride,
    String? semanticLabelOverride,
  }) {
    final effectiveVariant = variantOverride ?? widget.variant;
    final effectiveShowLabel = showLabelOverride ?? widget.showLabel;

    return FormField<String>(
      key: _fieldKey,
      initialValue: _controller.text,
      validator: widget.validator,
      enabled: widget.enabled,
      builder: (state) {
        final t = CatchTokens.of(context);
        final rawError = widget.errorText ?? widget.error ?? state.errorText;
        final error = rawError?.trim().isNotEmpty == true
            ? rawError!.trim()
            : null;
        final hasError = error != null;
        _setTextEntryValidationError(state.hasError);
        final supportText = includeSupport ? error ?? widget.helperText : null;

        if (rowBody) {
          final expanded = _textEntryExpandedWith(hasError: hasError);
          final inlineAddAtRest = _inlineTextAddAtRestWith(hasError: hasError);
          final addText = _emptyEditableValueText;
          final body = _buildFieldContent(
            t,
            label: widget.showLabel && !inlineAddAtRest ? _title : null,
            supportText: supportText,
            counterText:
                widget.maxLength != null &&
                    (_focused || widget.focused || hasError)
                ? '${_controller.text.characters.length} / ${widget.maxLength}'
                : null,
            hasError: hasError,
            labelStyle: _fieldCaptionTextStyle(
              context,
              color: hasError
                  ? t.danger
                  : _active
                  ? t.ink
                  : t.ink3,
            ),
            valueWidget: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                if (!inlineAddAtRest && widget.leadingUnit != null) ...[
                  Text(
                    widget.leadingUnit!,
                    style: _fieldValueTextStyle(context, color: t.ink2),
                  ),
                  const SizedBox(width: CatchSpacing.s1),
                ],
                Expanded(
                  key: const ValueKey<String>('catch-field-text-input'),
                  child: _buildTextEntryInput(
                    context,
                    state,
                    variant: effectiveVariant,
                    showLabel: effectiveShowLabel,
                    valueEmphasis: valueEmphasis,
                    hasError: hasError,
                    canInteractOverride: canInteractOverride,
                    readOnlyOverride: readOnlyOverride,
                    inputHintOverride: inlineAddAtRest
                        ? null
                        : expanded
                        ? inputHintOverride
                        : _emptyEditableValueText,
                    inputHintWidgetOverride: inlineAddAtRest
                        ? Text.rich(
                            _inlineAddTextSpan(t),
                            style: _fieldValueTextStyle(
                              context,
                              color: t.ink3,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    semanticLabelOverride: inlineAddAtRest && addText != null
                        ? _inlineAddSemanticLabel(addText)
                        : _title,
                  ),
                ),
              ],
            ),
          );

          return _buildTextEntryMotion(context, child: body);
        }

        final field = _buildTextEntryInput(
          context,
          state,
          variant: effectiveVariant,
          showLabel: effectiveShowLabel,
          valueEmphasis: valueEmphasis,
          hasError: hasError,
          canInteractOverride: canInteractOverride,
          readOnlyOverride: readOnlyOverride,
          inputHintOverride: inputHintOverride,
          inputHintWidgetOverride: inputHintWidgetOverride,
          semanticLabelOverride: semanticLabelOverride,
        );

        final counterText =
            effectiveVariant == CatchFieldVariant.underline &&
                widget.maxLength != null &&
                (_focused || widget.focused)
            ? '${_controller.text.characters.length} / ${widget.maxLength}'
            : null;
        final hasMeta = supportText != null || counterText != null;

        if (!effectiveShowLabel && !hasMeta) {
          return field;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (effectiveShowLabel &&
                !_useFloatingLabel(effectiveVariant, effectiveShowLabel)) ...[
              CatchFormFieldLabel.inline(
                label: _title ?? '',
                style: _fieldCaptionTextStyle(
                  context,
                  color: _fieldLabelColor(t, hasError: hasError),
                ),
                isOptional: widget.isOptional && widget.showLabel,
              ),
              const SizedBox(height: CatchSpacing.s2),
            ],
            field,
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

  Widget _buildTextEntryInput(
    BuildContext context,
    FormFieldState<String> state, {
    required CatchFieldVariant variant,
    required bool showLabel,
    required bool valueEmphasis,
    required bool hasError,
    bool? canInteractOverride,
    bool? readOnlyOverride,
    String? inputHintOverride,
    Widget? inputHintWidgetOverride,
    String? semanticLabelOverride,
  }) {
    final t = CatchTokens.of(context);
    final canInteract =
        canInteractOverride ?? (!widget.readOnly || widget.onTap != null);
    final readOnly = readOnlyOverride ?? widget.readOnly;
    final effectiveFocused = _focusNode.hasFocus || widget.focused;
    final inlineAddHint = inputHintWidgetOverride != null;
    final multiline =
        !inlineAddHint &&
        !widget.obscureText &&
        (widget.maxLines != 1 || (widget.minLines ?? 1) > 1);
    final multilineValueStyle = _fieldValueTextStyle(
      context,
      color: widget.enabled ? t.ink : t.ink3,
      fontWeight: FontWeight.w500,
    ).copyWith(height: CatchFieldTokens.multilineValueLineHeight);
    final multilineHintStyle = _fieldValueTextStyle(
      context,
      color: t.ink2,
      fontWeight: FontWeight.w500,
    ).copyWith(height: CatchFieldTokens.multilineValueLineHeight);
    final inputStyle = valueEmphasis
        ? multiline
              ? multilineValueStyle
              : _fieldValueTextStyle(
                  context,
                  color: widget.enabled ? t.ink : t.ink3,
                )
        : _textStyle(context, color: widget.enabled ? t.ink : t.ink3);
    final hintStyle = valueEmphasis
        ? multiline
              ? multilineHintStyle
              : _fieldValueTextStyle(context, color: t.ink2)
        : widget.size == CatchFieldSize.floating
        ? CatchTextStyles.bodyL(context, color: t.ink2)
        : _textStyle(context, color: t.ink2);
    final resolvedHintText = inputHintWidgetOverride == null
        ? inputHintOverride ?? _inputHintText
        : null;
    final visualOnlyHint = !showLabel && resolvedHintText != null;
    final textField = TextField(
      key: const ValueKey<String>('catch-field-text-entry'),
      groupId: _textFieldTapRegionGroup,
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: readOnly,
      canRequestFocus: canInteract,
      enableInteractiveSelection: canInteract,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      obscureText: widget.obscureText,
      maxLines: widget.obscureText || inlineAddHint ? 1 : widget.maxLines,
      minLines: inlineAddHint ? null : widget.minLines,
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      textAlignVertical: inlineAddHint
          ? TextAlignVertical.center
          : _textAlignVertical,
      onTap: widget.onTap,
      onTapOutside: widget._explicitSaveInput
          ? null
          : (_) => _focusNode.unfocus(),
      onChanged: (value) {
        state.didChange(value);
        widget.onChanged?.call(value);
      },
      onEditingComplete: widget.retainFocusOnSubmitted ? () {} : null,
      onSubmitted: _handleSubmitted,
      style: inputStyle,
      cursorColor: t.primary,
      decoration: InputDecoration(
        counterText: '',
        isDense: true,
        isCollapsed: variant == CatchFieldVariant.bare,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: _contentPadding(variant),
        labelText: _useFloatingLabel(variant, showLabel) ? _title : null,
        labelStyle: _useFloatingLabel(variant, showLabel)
            ? CatchTextStyles.bodyL(
                context,
                color: _fieldLabelColor(t, hasError: hasError),
              )
            : null,
        floatingLabelStyle: _useFloatingLabel(variant, showLabel)
            ? _fieldCaptionTextStyle(
                context,
                color: _fieldLabelColor(t, hasError: hasError),
              )
            : null,
        floatingLabelBehavior: _useFloatingLabel(variant, showLabel)
            ? FloatingLabelBehavior.auto
            : FloatingLabelBehavior.never,
        hint: inputHintWidgetOverride != null
            ? ExcludeSemantics(child: inputHintWidgetOverride)
            : visualOnlyHint
            ? ExcludeSemantics(child: Text(resolvedHintText))
            : null,
        hintText: inputHintWidgetOverride != null || visualOnlyHint
            ? null
            : resolvedHintText,
        hintStyle: hintStyle,
        prefixText: widget.prefixText,
        prefixStyle: _textStyle(context, color: t.ink2),
        suffixText: widget.suffixText,
        suffixStyle: CatchTextStyles.bodyLead(context, color: t.ink2),
        prefixIconConstraints: _iconConstraints,
        prefixIcon: _usesRowPrefixIcon || widget.prefixIcon == null
            ? null
            : IconTheme(
                data: IconThemeData(color: t.ink3, size: CatchIcon.md),
                child: widget.prefixIcon!,
              ),
        suffixIconConstraints: _suffixIconConstraints,
        suffixIcon: _usesRowTextEntryTrailing ? null : _buildSuffixIcon(t),
      ),
    );
    final inputShell = _buildFieldChrome(
      context: context,
      tokens: t,
      hasError: hasError,
      focused: effectiveFocused,
      variant: variant,
      child: textField,
    );
    final singleLineControlHeight = _singleLineControlHeight(variant);
    final sizedInputShell = singleLineControlHeight == null
        ? inputShell
        : SizedBox(height: singleLineControlHeight, child: inputShell);

    if (showLabel) return sizedInputShell;
    return MergeSemantics(
      child: Semantics(
        label: semanticLabelOverride ?? _title,
        child: sizedInputShell,
      ),
    );
  }

  Widget _buildTextEntryMotion(BuildContext context, {required Widget child}) {
    return AnimatedSize(
      duration: _motionDuration(context),
      curve: CatchMotion.standardCurve,
      alignment: Alignment.topCenter,
      child: child,
    );
  }

  Duration _motionDuration(BuildContext context) {
    return _catchFieldMotionDuration(context);
  }

  Widget _buildSelectField(BuildContext context) {
    return FormField<Object?>(
      key: _selectFieldKey,
      initialValue: _normalizedSelectValue(widget._selectValue),
      validator: (value) =>
          widget._selectValidator?.call(_normalizedSelectValue(value)),
      enabled: widget.enabled,
      builder: (state) {
        final t = CatchTokens.of(context);
        final value = _normalizedSelectValue(state.value);
        if (state.value != value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final field = _selectFieldKey.currentState;
            if (field != null && field.value != value) {
              field.didChange(value);
            }
          });
        }
        final rawError = widget.errorText ?? widget.error ?? state.errorText;
        final error = rawError?.trim().isNotEmpty == true
            ? rawError!.trim()
            : null;
        final hasError = error != null;
        final supportText = error ?? widget.helperText;
        return _buildSelectTrigger(
          context: context,
          tokens: t,
          value: value,
          hasError: hasError,
          supportText: supportText,
          onChanged: widget.enabled && widget._onSelectChanged != null
              ? (next) {
                  state.didChange(next);
                  widget._onSelectChanged?.call(next);
                }
              : null,
        );
      },
    );
  }

  Widget _buildSelectTrigger({
    required BuildContext context,
    required CatchTokens tokens,
    required Object? value,
    required bool hasError,
    required String? supportText,
    required ValueChanged<Object?>? onChanged,
  }) {
    final values = widget._selectValues ?? const <Object?>[];
    final labelOf = widget._selectItemLabel!;
    final label = value == null ? null : labelOf(value);
    final canOpen = widget.enabled && onChanged != null && values.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : null;
        return MenuAnchor(
          controller: _menuController,
          // The panel itself is the shared CatchMenu surface; the anchor
          // chrome stays transparent (same contract as CatchActionMenu).
          style: const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            elevation: WidgetStatePropertyAll(0),
            shadowColor: WidgetStatePropertyAll(Colors.transparent),
            surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
          ),
          menuChildren: [
            CatchMenu<Object?>(
              width: menuWidth,
              items: [
                for (final item in values)
                  CatchMenuItem<Object?>(
                    value: item,
                    label: labelOf(item),
                    selected: item == value,
                  ),
              ],
              onSelected: (item, _) {
                onChanged?.call(item);
                _menuController.close();
              },
            ),
          ],
          builder: (context, controller, child) {
            final selectHasLabel =
                widget.showLabel && (_title?.trim().isNotEmpty ?? false);
            return Semantics(
              button: true,
              enabled: canOpen,
              label: _title,
              value: label,
              child: Focus(
                focusNode: _focusNode,
                child: CatchFieldRow.standard(
                  onTap: canOpen
                      ? () {
                          _focusNode.requestFocus();
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        }
                      : null,
                  constraints: _rowConstraints,
                  padding: _rowPadding,
                  leading: _buildSelectLeadingSlot(tokens),
                  content: _buildFieldContent(
                    tokens,
                    label: widget.showLabel ? _title?.trim() : null,
                    value:
                        label ??
                        widget.placeholder ??
                        _selectPlaceholder(context.l10n, _title),
                    supportText: supportText,
                    hasError: hasError,
                    valueIsPlaceholder: label == null,
                    labelStyle: _fieldCaptionTextStyle(
                      context,
                      color: hasError ? tokens.danger : tokens.ink3,
                    ),
                    valueStyle: _fieldValueTextStyle(
                      context,
                      color: label == null || !widget.enabled
                          ? tokens.ink3
                          : tokens.ink,
                    ),
                  ),
                  trailing: selectHasLabel
                      ? Padding(
                          padding: const EdgeInsets.only(
                            top: CatchFieldTokens.captionExtent,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: CatchFieldTokens.valueLineExtent,
                            ),
                            child: Align(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: CatchFieldTrailing.rotatingChevron(
                                open: controller.isOpen,
                                color: tokens.ink3,
                                topPadding: 0,
                              ),
                            ),
                          ),
                        )
                      : CatchFieldTrailing.rotatingChevron(
                          open: controller.isOpen,
                          color: tokens.ink3,
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFieldChrome({
    required BuildContext context,
    required CatchTokens tokens,
    required bool hasError,
    required bool focused,
    required CatchFieldVariant variant,
    required Widget child,
  }) {
    if (variant == CatchFieldVariant.bare || variant == CatchFieldVariant.row) {
      return child;
    }

    final active = focused || hasError;
    final baselineColor = hasError
        ? tokens.danger
        : widget.enabled
        ? tokens.line2
        : tokens.line;
    final sweepColor = hasError ? tokens.danger : tokens.ink;
    return ConstrainedBox(
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
            child: child,
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: -CatchFieldTokens.underlineSweepBottomOffset,
            height: CatchStroke.underline,
            child: LayoutBuilder(
              builder: (context, constraints) => TweenAnimationBuilder<double>(
                key: const ValueKey('catch-field-underline-sweep'),
                duration: _fieldDuration(context, CatchFieldTokens.reveal),
                curve: CatchFieldTokens.curve,
                tween: Tween<double>(end: active ? 1 : 0),
                builder: (context, progress, _) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(
                    key: const ValueKey('catch-field-underline-sweep-bar'),
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

  Widget? _buildSuffixIcon(CatchTokens t) {
    final action = _action;

    if (widget.showClearButton) {
      return ValueListenableBuilder(
        valueListenable: _controller,
        builder: (_, TextEditingValue value, _) {
          if (value.text.isEmpty) {
            return _quietSuffix(
                  t,
                  action ?? widget.suffixIcon,
                  padded: action != null,
                ) ??
                const SizedBox.shrink();
          }
          return IconButton(
            tooltip: context.l10n.coreCatchFieldTooltipClearValue1(
              value1: _title ?? context.l10n.coreCatchFieldTooltipField,
            ),
            icon: Icon(CatchIcons.closeRounded, size: CatchIcon.xs),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
            },
          );
        },
      );
    }

    return _quietSuffix(t, action ?? widget.suffixIcon, padded: action != null);
  }

  Widget? _quietSuffix(CatchTokens t, Widget? child, {required bool padded}) {
    if (child == null) return null;
    final styledChild = IconTheme(
      data: IconThemeData(color: t.ink3, size: CatchIcon.md),
      child: DefaultTextStyle.merge(
        style: CatchTextStyles.bodyLead(context, color: t.ink3),
        child: child,
      ),
    );
    if (!padded) return styledChild;
    return Padding(
      padding: const EdgeInsets.only(left: CatchSpacing.s2),
      child: styledChild,
    );
  }

  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    if (!widget.retainFocusOnSubmitted) _focusNode.unfocus();
  }

  bool _useFloatingLabel(CatchFieldVariant variant, bool showLabel) {
    return widget.floatingLabel &&
        showLabel &&
        !widget.isOptional &&
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
    final style = widget.size == CatchFieldSize.floating
        ? CatchTextStyles.bodyLead(context, color: color)
        : CatchTextStyles.bodyL(context, color: color);

    if (!widget.mono) return style;

    return style.copyWith(
      fontFeatures: [
        ...?style.fontFeatures,
        const FontFeature.tabularFigures(),
      ],
    );
  }

  Color _supportColor(CatchTokens t) {
    return switch (widget.helperTone) {
      CatchFieldSupportTone.neutral => t.ink3,
      CatchFieldSupportTone.brand => t.primary,
      CatchFieldSupportTone.success => t.success,
    };
  }

  Color _fieldLabelColor(
    CatchTokens t, {
    required bool hasError,
    Color? inactiveColor,
  }) {
    if (hasError) return t.danger;
    return _active ? t.ink : inactiveColor ?? t.ink3;
  }

  BoxConstraints? get _iconConstraints {
    if (widget.maxLines != 1 || widget.minLines != null) return null;

    final extent = CatchControlMetrics.iconExtent(_controlSize);
    return CatchControlMetrics.squareConstraints(extent);
  }

  BoxConstraints? get _suffixIconConstraints {
    if (_action == null) return _iconConstraints;
    return const BoxConstraints();
  }

  CatchControlSize get _controlSize {
    return switch (widget.size) {
      CatchFieldSize.floating => CatchControlSize.floating,
      CatchFieldSize.compact => CatchControlSize.compact,
      CatchFieldSize.md => CatchControlSize.md,
    };
  }

  Object? _normalizedSelectValue(Object? value) {
    if (value == null) return null;
    final values = widget._selectValues;
    if (values == null || !values.contains(value)) return null;
    return value;
  }

  TextAlignVertical? get _textAlignVertical {
    if (widget.maxLines != 1 || widget.minLines != null) return null;
    return TextAlignVertical.center;
  }

  double? _singleLineControlHeight(CatchFieldVariant variant) {
    if (variant == CatchFieldVariant.bare || variant == CatchFieldVariant.row) {
      return null;
    }
    if (widget.maxLines != 1 || widget.minLines != null) return null;
    return CatchControlMetrics.minHeight(_controlSize);
  }

  Color _toneColor(
    CatchTokens t, {
    bool muted = false,
    Color? primaryFallback,
  }) {
    return switch (widget.tone) {
      CatchFieldTone.primary => t.primary,
      CatchFieldTone.danger => t.danger,
      _ => primaryFallback ?? (muted ? t.ink2 : t.ink),
    };
  }

  EdgeInsets get _rowPadding {
    final flush = CatchFieldInsetScope.flushOf(context);
    if (_compactTextEntry) {
      return flush
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: CatchSpacing.s1);
    }
    if (flush) {
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
    if (_isSelect && !widget.showLabel) {
      return BoxConstraints(
        minHeight: CatchControlMetrics.minHeight(_controlSize),
      );
    }
    return const BoxConstraints();
  }
}

String _selectPlaceholder(AppLocalizations l10n, String? title) {
  final normalizedTitle = title?.trim();
  if (normalizedTitle == null || normalizedTitle.isEmpty) {
    return l10n.coreCatchFieldVisiblecopySelect;
  }
  return l10n.coreCatchFieldVisiblecopySelectTolowercase(
    toLowerCase: normalizedTitle.toLowerCase(),
  );
}

Duration _catchFieldMotionDuration(BuildContext context) {
  return _fieldDuration(context, CatchMotion.base);
}

Duration _expansionMotionDuration(BuildContext context) {
  return _fieldDuration(context, CatchMotion.base);
}

Duration _fieldDuration(BuildContext context, Duration duration) {
  final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
  return disableAnimations == true ? Duration.zero : duration;
}

TextStyle _fieldValueTextStyle(
  BuildContext context, {
  required Color color,
  FontWeight fontWeight = FontWeight.w700,
}) => CatchTextStyles.fieldRowTitle(context, color: color).copyWith(
  fontSize: CatchFieldTokens.valueFontSize,
  fontWeight: fontWeight,
  height: CatchFieldTokens.valueLineHeight,
);

TextStyle _fieldCaptionTextStyle(
  BuildContext context, {
  required Color color,
}) => CatchTextStyles.fieldLabel(context, color: color).copyWith(
  fontSize: CatchFieldTokens.captionFontSize,
  fontWeight: FontWeight.w500,
  height: CatchFieldTokens.supportLineHeight,
);
