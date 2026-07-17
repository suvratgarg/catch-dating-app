part of 'catch_field.dart';

extension _CatchFieldRowModes on _CatchFieldState {
  Widget _buildAdd(CatchTokens t) {
    return CatchFieldRow.add(
      onTap: widget.onTap,
      leading: Icon(
        widget.icon ?? CatchIcons.add,
        size: CatchIcon.md,
        color: t.primary,
      ),
      content: Text(
        _title ?? '',
        style: _fieldValueTextStyle(
          context,
          color: _toneColor(t, primaryFallback: t.primary),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRow(CatchTokens t) {
    final canFocusTextEntry =
        _isEdit &&
        !widget._explicitSaveInput &&
        widget.enabled &&
        (!widget.readOnly || widget.onTap != null);
    final canToggleRow = _isToggle && widget.onToggle != null && !_isSaving;
    final canExpand =
        _hasControl &&
        widget.enabled &&
        !_isSaving &&
        (widget.open == null || widget.onOpenChanged != null);
    final VoidCallback? rowAction;
    if (widget._explicitSaveInput && widget.enabled && !_isSaving) {
      rowAction = _isOpen
          ? _focusNode.requestFocus
          : () {
              _requestExpansion(true);
              widget.onTap?.call();
            };
    } else if (canFocusTextEntry) {
      rowAction = () {
        if (widget.readOnly && widget.onTap != null) {
          widget.onTap!();
          return;
        }
        _expandAndFocusTextEntry();
        widget.onTap?.call();
      };
    } else if (canExpand) {
      rowAction = () {
        _requestExpansion(!_isOpen);
        widget.onTap?.call();
      };
    } else if (canToggleRow) {
      rowAction = () => widget.onToggle!(!widget.toggled);
    } else if (widget.onTap != null && !_isEdit) {
      rowAction = widget.onTap;
    } else {
      rowAction = null;
    }
    final centerVertically =
        _isToggle ||
        (widget._contentRow && widget.emphasis == CatchFieldEmphasis.title);
    final leadingTopPadding = centerVertically
        ? 0.0
        : widget._contentRow
        ? CatchSpacing.micro2
        : _rowTrailingTopPadding;
    final rawTrailingSlot = _buildTrailingSlot(t);
    final positionsTrailing = _hasControl || _usesPositionedClearTrailing;
    final trailingTopPadding = _rowTrailingTopPadding;
    final trailingSlot = rawTrailingSlot == null
        ? null
        : _usesPositionedClearTrailing || centerVertically
        ? rawTrailingSlot
        : Padding(
            padding: EdgeInsets.only(top: trailingTopPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: CatchFieldTokens.valueLineExtent,
              ),
              child: Align(
                widthFactor: 1,
                heightFactor: 1,
                child: rawTrailingSlot,
              ),
            ),
          );
    final rowContent = CatchFieldRow.standard(
      constraints: _rowConstraints,
      padding: _rowHeaderPadding,
      leading: _buildLeadingSlot(t),
      trailing: positionsTrailing ? null : trailingSlot,
      crossAxisAlignment: centerVertically
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      leadingTopPadding: leadingTopPadding,
      paddingDuration: _hasControl
          ? _expansionMotionDuration(context)
          : Duration.zero,
      paddingCurve: CatchFieldTokens.curve,
      content: _buildBody(t),
    );
    final row = positionsTrailing && trailingSlot != null
        ? Stack(
            children: [
              rowContent,
              PositionedDirectional(
                top: _usesPositionedClearTrailing
                    ? _rowHeaderPadding.top +
                          CatchFieldTokens.captionExtent +
                          (CatchFieldTokens.valueLineExtent - CatchSpacing.s6) /
                              2 +
                          CatchSpacing.micro3
                    : _rowHeaderPadding.top,
                end: _rowHeaderPadding.right,
                child: trailingSlot,
              ),
            ],
          )
        : rowContent;
    final action = rowAction;
    final canInteract = action != null;
    if (!canInteract && !_active && !_hasControl) return row;
    final highlighted = _active || _pressed;
    final decoration = BoxDecoration(
      color: _pressed
          ? CatchFieldTokens.pressedSurface(t)
          : _active
          ? CatchFieldTokens.activeSurface(t)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(CatchFieldTokens.tileRadius),
      border: highlighted ? Border.all(color: t.line) : null,
      boxShadow: _active
          ? CatchElevation.fieldActive(Theme.of(context).brightness)
          : CatchElevation.none,
    );
    final overlayBleed = CatchFieldInsetScope.activeOverlayBleedOf(context);
    final mouseCursor = canInteract
        ? _isEdit
              ? SystemMouseCursors.text
              : SystemMouseCursors.click
        : SystemMouseCursors.basic;
    final tapRegion = _isEdit
        ? TextFieldTapRegion(groupId: _textFieldTapRegionGroup, child: row)
        : row;
    final isToggle = _isToggle;
    final toggleStatusValue = switch (widget.status) {
      CatchFieldStatus.idle => null,
      CatchFieldStatus.saving => context.l10n.coreCatchFieldSemanticSaving,
      CatchFieldStatus.saved => context.l10n.coreCatchFieldSemanticSaved,
    };
    final pointerTarget = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: canInteract ? _handlePointerDown : null,
      onPointerMove: canInteract ? _handlePointerMove : null,
      onPointerUp: canInteract ? _handlePointerEnd : null,
      onPointerCancel: canInteract ? _handlePointerCancel : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: action,
        child: tapRegion,
      ),
    );
    final keyboardTarget = _isEdit || isToggle
        // Editable rows already own one native focus target through TextField.
        // Toggle rows likewise delegate keyboard ownership to their nested
        // switch. A second row Focus node would insert an empty Tab stop.
        ? pointerTarget
        : FocusableActionDetector(
            enabled: canInteract,
            focusNode: _rowFocusNode,
            mouseCursor: mouseCursor,
            onShowFocusHighlight: (focused) {
              if (_rowFocused == focused) return;
              _update(() => _rowFocused = focused);
            },
            actions: <Type, Action<Intent>>{
              if (action != null)
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    if (_rowFocusNode.hasPrimaryFocus) action();
                    return null;
                  },
                ),
            },
            child: pointerTarget,
          );
    final rowPadding = _rowPadding;
    final disclosureStartPadding =
        rowPadding.left + (_hasLeadingSlot ? CatchFieldRow.textLaneInset : 0.0);
    final disclosureControl = widget._explicitSaveInput
        ? CatchFieldExplicitSaveControl(
            supporting: widget._supporting,
            feedback: widget._feedback,
            secondaryAction: widget._secondaryAction,
          )
        : widget.control;
    final actionBar = widget._onSubmit == null
        ? null
        : CatchFieldActionBar(
            revealTargetKey: _actionBarRevealTargetKey,
            loading: _isSaving,
            onCancel: _handleCancel,
            onSubmit: _handleSubmit,
          );
    final rootError = _hasControl ? _displayError?.trim() : null;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        keyboardTarget,
        if (_hasControl)
          CatchFieldDisclosureDrawer(
            open: _isOpen,
            offstage: _disclosureOffstage,
            revealTargetKey: _disclosureRevealTargetKey,
            control: disclosureControl!,
            actionBar: actionBar,
            startPadding: disclosureStartPadding,
            endPadding: rowPadding.right,
            bottomPadding: rowPadding.bottom,
            revealDuration: _expansionMotionDuration(context),
            opacityDuration: _fieldDuration(context, CatchFieldTokens.standard),
            onRevealEnd: _handleExpansionAnimationEnd,
          ),
        if (rootError?.isNotEmpty == true)
          CatchFieldSupportRow(
            key: const ValueKey('catch-field-root-support'),
            text: rootError,
            color: t.danger,
            showErrorIcon: true,
            padding: EdgeInsetsDirectional.only(
              start: disclosureStartPadding,
              end: rowPadding.right,
              bottom: rowPadding.bottom,
            ),
          ),
      ],
    );
    final stack = Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          start: -overlayBleed,
          end: -overlayBleed,
          top: -CatchStroke.hairline,
          bottom: -CatchStroke.hairline,
          child: IgnorePointer(
            child: AnimatedContainer(
              key: const ValueKey('catch-field-active-overlay'),
              duration: _fieldDuration(
                context,
                _pressed
                    ? CatchFieldTokens.pressIn
                    : _active
                    ? CatchFieldTokens.standard
                    : CatchFieldTokens.pressOut,
              ),
              curve: CatchFieldTokens.curve,
              decoration: decoration,
            ),
          ),
        ),
        content,
      ],
    );
    return Semantics(
      container: isToggle,
      excludeSemantics: isToggle,
      label: isToggle ? _title : null,
      button: !isToggle && !_isEdit && canInteract,
      enabled: canInteract,
      expanded: _hasControl ? _isOpen : null,
      toggled: isToggle ? widget.toggled : null,
      value: isToggle ? toggleStatusValue : null,
      onTap: isToggle && canInteract ? action : null,
      child: MouseRegion(
        cursor: mouseCursor,
        onExit: canInteract ? _handlePointerExit : null,
        child: stack,
      ),
    );
  }

  Widget? _buildLeadingSlot(CatchTokens t) {
    if (widget.leading != null) return widget.leading;

    if (widget.icon != null) {
      return Icon(
        widget.icon,
        size: CatchFieldRow.leadingSlotIconSize,
        color:
            widget.iconColor ??
            (_active
                ? t.ink
                : _showsInlineAddAtRest
                ? t.primary
                : _toneColor(t, muted: true)),
      );
    }

    if (_usesRowPrefixIcon) {
      return IconTheme(
        data: IconThemeData(
          color: _hasError
              ? t.danger
              : _active
              ? t.ink
              : _showsInlineAddAtRest
              ? t.primary
              : t.ink2,
          size: CatchFieldRow.leadingSlotIconSize,
        ),
        child: widget.prefixIcon!,
      );
    }

    return null;
  }

  Widget? _buildSelectLeadingSlot(CatchTokens t) {
    if (widget.prefixIcon == null) return null;
    return IconTheme(
      data: IconThemeData(
        color: widget.enabled ? t.ink2 : t.ink3,
        size: CatchFieldRow.leadingSlotIconSize,
      ),
      child: widget.prefixIcon!,
    );
  }

  Widget? _buildTrailingSlot(CatchTokens t) {
    if (_isToggle) {
      return CatchFieldTrailing.toggle(
        value: widget.toggled,
        onChanged: _isSaving ? null : widget.onToggle,
        semanticLabel: _title,
        status: widget.status,
        topPadding: 0,
      );
    }
    if (_isSaving && !_visibleCommitBarOwnsSavingIndicator) {
      return CatchFieldTrailing.saving();
    }
    if (!_isSaving && widget.status == CatchFieldStatus.saved && !_hasError) {
      return CatchFieldTrailing.saved();
    }
    if (!_isSaving && widget.valid && !_hasError) {
      return CatchFieldTrailing.valid(topPadding: 0);
    }

    if (_usesRowTextEntryTrailing) {
      return _buildTextEntryTrailingSlot(t);
    }

    if (_hasControl) {
      return CatchFieldTrailing.rotatingChevron(
        open: _isOpen,
        color: _active ? t.ink : t.ink3,
        topPadding: 0,
      );
    }

    if (_isNavigation) {
      return _buildTrailingGroup(t, includeChevron: _shouldShowChevron);
    }

    return _buildTrailingGroup(t);
  }

  Widget? _buildTextEntryTrailingSlot(CatchTokens t) {
    final fallback = _buildCustomTrailingSlot(t, _action ?? widget.suffixIcon);
    if (!widget.showClearButton) return fallback;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (_, value, _) {
        if (value.text.isEmpty) return fallback ?? const SizedBox.shrink();
        return CatchFieldTrailing.clear(
          tooltip: context.l10n.coreCatchFieldTooltipClearValue1(
            value1: _title ?? context.l10n.coreCatchFieldTooltipField,
          ),
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
          topPadding: 0,
        );
      },
    );
  }

  Widget? _buildTrailingGroup(CatchTokens t, {bool includeChevron = false}) {
    final children = <Widget>[];
    final flexibleIndices = <int>{};
    final valueText = widget.valueText?.trim();
    if (!_stacksTrailingValueText &&
        valueText != null &&
        valueText.isNotEmpty) {
      flexibleIndices.add(children.length);
      children.add(
        CatchFieldTrailing.valueText(
          text: valueText,
          maxLines: widget.valueMaxLines,
          topPadding: 0,
        ),
      );
    }

    final custom = _buildCustomTrailingSlot(t, _action);
    if (custom != null) children.add(custom);

    if (includeChevron) {
      children.add(
        CatchFieldTrailing.fixedChevron(color: t.ink3, topPadding: 0),
      );
    }

    if (children.isEmpty) return null;
    if (children.length == 1) return children.single;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: CatchSpacing.s2),
          if (flexibleIndices.contains(i))
            Flexible(child: children[i])
          else
            children[i],
        ],
      ],
    );
  }

  Widget? _buildCustomTrailingSlot(CatchTokens t, Widget? child) {
    if (child == null) return null;
    return CatchFieldTrailing.custom(
      topPadding: 0,
      color: t.ink3,
      child: child,
    );
  }

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
    return textEntryValueLine || canonicalValueLine ? CatchSpacing.micro18 : 0;
  }

  String _inlineAddSemanticLabel(String addText) => widget.isOptional
      ? context.l10n.coreCatchFormFieldLabelLabelLabelOptional(label: addText)
      : addText;

  TextSpan _inlineAddTextSpan(CatchTokens t) {
    final addText = _emptyEditableValueText ?? _title ?? '';
    final optionalSuffix = widget.isOptional
        ? context.l10n.coreCatchFieldTextOptionalSuffix
        : null;
    return TextSpan(
      children: [
        TextSpan(
          text: addText,
          style: _fieldValueTextStyle(
            context,
            color: t.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (optionalSuffix != null)
          TextSpan(
            text: optionalSuffix,
            style: _fieldValueTextStyle(
              context,
              color: t.ink3,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  Widget _buildBody(CatchTokens t) {
    if (_inlineControlAddAtRest) {
      final addText = _emptyEditableValueText ?? _title ?? '';
      return Semantics(
        label: _inlineAddSemanticLabel(addText),
        excludeSemantics: true,
        child: Text.rich(
          _inlineAddTextSpan(t),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (widget._explicitSaveInput) {
      final error = _displayError?.trim();
      final inlineAddAtRest = error?.isNotEmpty != true && _inlineTextAddAtRest;
      final addText = _emptyEditableValueText;
      final input = IgnorePointer(
        ignoring: !_isOpen,
        child: _buildTextEntryField(
          context,
          showLabelOverride: false,
          variantOverride: CatchFieldVariant.bare,
          valueEmphasis: true,
          canInteractOverride: _isOpen && widget.enabled,
          readOnlyOverride: !_isOpen,
          includeSupport: false,
          inputHintOverride: inlineAddAtRest
              ? null
              : _isOpen
              ? _inputHintText
              : _emptyEditableValueText,
          inputHintWidgetOverride: inlineAddAtRest
              ? Text.rich(
                  _inlineAddTextSpan(t),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          semanticLabelOverride: inlineAddAtRest && addText != null
              ? _inlineAddSemanticLabel(addText)
              : _title,
        ),
      );
      return _buildFieldContent(
        t,
        label: inlineAddAtRest ? null : _title,
        valueWidget: input,
        hasError: error?.isNotEmpty == true,
        labelStyle: _fieldCaptionTextStyle(
          context,
          color: error?.isNotEmpty == true
              ? t.danger
              : _active
              ? t.ink
              : t.ink3,
        ),
      );
    }
    if (_isEdit) return _buildTextEntryBody(t);
    if (widget._contentRow) {
      final hasError = _displayError?.trim().isNotEmpty == true;
      return CatchFieldContentRow(
        title: _title?.trim() ?? '',
        body: _body?.trim() ?? '',
        titleMaxLines: widget.titleMaxLines,
        bodyMaxLines: widget.bodyMaxLines,
        isOptional: widget.isOptional,
        titleColor: hasError ? t.danger : _toneColor(t, primaryFallback: t.ink),
        bodyColor: t.ink2,
      );
    }

    final title = _title?.trim();
    final value = _stacksTrailingValueText
        ? widget.valueText!.trim()
        : _body?.trim().isNotEmpty == true
        ? _body!.trim()
        : widget._onSubmit != null
        ? _emptyEditableValueText
        : _placeholderText?.trim();
    final error = _displayError?.trim();
    final hasValue = value != null && value.isNotEmpty;

    return _buildFieldContent(
      t,
      label: title,
      value: value,
      supportText: _hasControl
          ? error?.isNotEmpty == true
                ? null
                : widget.helperText
          : error?.isNotEmpty == true
          ? error
          : widget.helperText,
      labelEmphasized: widget.emphasis == CatchFieldEmphasis.title || !hasValue,
      valueIsPlaceholder: !_hasValue,
      valueMaxLines: widget.bodyMaxLines,
      hasError: error?.isNotEmpty == true,
    );
  }

  Widget _buildTextEntryBody(CatchTokens t) {
    return _buildTextEntryField(
      context,
      showLabelOverride: false,
      variantOverride: CatchFieldVariant.bare,
      valueEmphasis: true,
      rowBody: true,
    );
  }

  Widget _buildFieldContent(
    CatchTokens t, {
    String? label,
    String? value,
    Widget? valueWidget,
    String? supportText,
    String? counterText,
    bool hasError = false,
    bool labelEmphasized = false,
    bool valueIsPlaceholder = false,
    int valueMaxLines = 1,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    final labelText = label?.trim();
    final valueText = value?.trim();
    final hasLabel = labelText != null && labelText.isNotEmpty;
    final hasValue =
        valueWidget != null || (valueText != null && valueText.isNotEmpty);
    final support = supportText?.trim();
    final counter = counterText?.trim();
    final hasCounter = counter != null && counter.isNotEmpty;
    final hasSupport = (support != null && support.isNotEmpty) || hasCounter;
    final headerTrailingReserve = _hasControl
        ? CatchFieldTokens.trailingGap + CatchFieldTokens.disclosureGlyphExtent
        : _usesPositionedClearTrailing
        ? CatchFieldTokens.trailingGap + CatchSpacing.s6
        : 0.0;

    if (!hasLabel && !hasValue && !hasSupport) {
      return const SizedBox.shrink();
    }

    final baseLabelStyle =
        labelStyle ??
        (labelEmphasized
            ? _fieldValueTextStyle(
                context,
                color: hasError
                    ? t.danger
                    : _toneColor(t, primaryFallback: t.ink),
              )
            : _fieldCaptionTextStyle(
                context,
                color: hasError ? t.danger : t.ink3,
              ));
    final effectiveLabelStyle = baseLabelStyle.copyWith(
      color: _fieldLabelColor(
        t,
        hasError: hasError,
        inactiveColor: baseLabelStyle.color,
      ),
    );
    final effectiveValueStyle =
        valueStyle ??
        (labelEmphasized
            ? _fieldCaptionTextStyle(context, color: t.ink2)
            : _fieldValueTextStyle(
                context,
                color: valueIsPlaceholder
                    ? t.ink3
                    : _toneColor(t, primaryFallback: t.ink),
              ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLabel)
          Padding(
            key: const ValueKey<String>('catch-field-label-content'),
            padding: EdgeInsetsDirectional.only(end: headerTrailingReserve),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: labelEmphasized
                    ? CatchFieldTokens.valueLineExtent
                    : CatchFieldTokens.captionExtent,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: widget.badgeLabel?.trim().isNotEmpty == true
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: CatchFormFieldLabel.inline(
                              label: labelText,
                              style: effectiveLabelStyle,
                              maxLines: widget.titleMaxLines,
                              isOptional: widget.isOptional && widget.showLabel,
                            ),
                          ),
                          const SizedBox(width: CatchSpacing.s2),
                          CatchBadge(
                            label: widget.badgeLabel!.trim(),
                            tone: widget.badgeTone ?? CatchBadgeTone.neutral,
                          ),
                        ],
                      )
                    : CatchFormFieldLabel.inline(
                        label: labelText,
                        style: effectiveLabelStyle,
                        maxLines: widget.titleMaxLines,
                        isOptional: widget.isOptional && widget.showLabel,
                      ),
              ),
            ),
          ),
        if (hasValue) ...[
          Padding(
            key: const ValueKey<String>('catch-field-value-content'),
            padding: EdgeInsetsDirectional.only(end: headerTrailingReserve),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: CatchFieldTokens.valueLineExtent,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child:
                    valueWidget ??
                    Text(
                      valueText!,
                      maxLines: valueMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: effectiveValueStyle,
                    ),
              ),
            ),
          ),
        ],
        if (hasSupport) ...[
          if (hasLabel || hasValue)
            const SizedBox(height: CatchFieldTokens.supportingTopGap),
          CatchFieldSupportRow(
            text: support,
            counter: hasCounter ? counter : null,
            color: hasError ? t.danger : _supportColor(t),
            showErrorIcon: hasError,
          ),
        ],
      ],
    );
  }
}
