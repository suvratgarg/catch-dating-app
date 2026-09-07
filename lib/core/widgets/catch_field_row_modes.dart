part of 'catch_field.dart';

extension _CatchFieldRowModes on _CatchFieldState {
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
    final hasInlineMetadata = widget.inlineMetadata?.trim().isNotEmpty == true;
    final centerVertically =
        _showsInlineAddAtRest ||
        _isToggle ||
        hasInlineMetadata ||
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
              constraints: BoxConstraints(
                minHeight: CatchFieldTokens.valueLineExtent,
              ),
              child: Align(
                widthFactor: 1,
                heightFactor: 1,
                child: rawTrailingSlot,
              ),
            ),
          );
    final Widget? leadingSlot;
    if (widget.leading != null) {
      final extent = widget.leadingExtent;
      leadingSlot = extent == null
          ? widget.leading
          : SizedBox(width: extent, child: widget.leading);
    } else if (widget.icon != null) {
      leadingSlot = Icon(
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
    } else if (_usesRowPrefixIcon) {
      leadingSlot = IconTheme(
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
    } else {
      leadingSlot = null;
    }
    final rowContent = CatchFieldRow.standard(
      constraints: _usesPositionedClearTrailing
          ? _rowConstraints.enforce(
              BoxConstraints(
                minHeight: CatchFieldTrailing.clearTargetConstraints.minHeight,
              ),
            )
          : _rowConstraints,
      padding: _rowHeaderPadding,
      leading: leadingSlot,
      trailing: positionsTrailing ? null : trailingSlot,
      crossAxisAlignment: centerVertically
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      leadingTopPadding: leadingTopPadding,
      paddingDuration: _hasControl
          ? _expansionMotionDuration(context)
          : Duration.zero,
      paddingCurve: CatchMotion.standardCurve,
      content: _buildBody(t),
    );
    final row = positionsTrailing && trailingSlot != null
        ? Stack(
            children: [
              rowContent,
              if (_usesPositionedClearTrailing)
                PositionedDirectional(
                  top: 0,
                  bottom: 0,
                  end: _rowHeaderPadding.right,
                  width: CatchFieldTrailing.clearTargetConstraints.maxWidth,
                  child: LayoutBuilder(
                    builder: (context, available) {
                      final extent =
                          CatchFieldTrailing.clearTargetConstraints.maxHeight;
                      final scaler = MediaQuery.textScalerOf(context);
                      final desiredTop =
                          _rowHeaderPadding.top +
                          scaler.scale(CatchFieldTokens.captionExtent) +
                          (scaler.scale(CatchFieldTokens.valueLineExtent) -
                                  extent) /
                              2 +
                          CatchSpacing.micro3;
                      // Keep the value-line alignment when it fits, while
                      // preserving the complete target inside compact rows.
                      final top = desiredTop.clamp(
                        0.0,
                        available.maxHeight - extent,
                      );
                      return Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: top),
                          child: trailingSlot,
                        ),
                      );
                    },
                  ),
                )
              else
                PositionedDirectional(
                  top: _rowHeaderPadding.top,
                  end: _rowHeaderPadding.right,
                  child: trailingSlot,
                ),
            ],
          )
        : rowContent;
    final action = rowAction;
    final canInteract = action != null;
    if (!canInteract && !_active && !_hasControl) return row;
    final interactionShape = CatchFieldGeometryScope.interactionShapeOf(
      context,
    );
    final interactionBorderRadius = switch (interactionShape) {
      CatchFieldInteractionShape.roundedTile => BorderRadius.circular(
        CatchFieldTokens.tileRadius,
      ),
      CatchFieldInteractionShape.sectionClipped ||
      CatchFieldInteractionShape.fullBleedBand => BorderRadius.zero,
    };
    final interactionBorder = CatchBorder.resolve(
      t,
      CatchBorderRole.boundary,
    ).all;
    final fullBleedFocusBorder = CatchBorder.resolve(
      t,
      CatchBorderRole.focus,
    ).all;
    final fullBleedFocused =
        interactionShape == CatchFieldInteractionShape.fullBleedBand &&
        _rowFocused &&
        !_pressed;
    final activeDecoration = BoxDecoration(
      color: _active && !_pressed
          ? CatchFieldTokens.activeSurface(t)
          : Colors.transparent,
      borderRadius: interactionBorderRadius,
      // The active and pressed layers hand one stroke between them. This
      // prevents their animated decorations from ever stacking two outlines.
      border: fullBleedFocused
          ? fullBleedFocusBorder
          : _active &&
                !_pressed &&
                interactionShape != CatchFieldInteractionShape.fullBleedBand
          ? interactionBorder
          : null,
      boxShadow:
          _active && interactionShape == CatchFieldInteractionShape.roundedTile
          ? CatchElevation.fieldActive(Theme.of(context).brightness)
          : CatchElevation.none,
    );
    final pressDecoration = BoxDecoration(
      color: _pressed ? CatchFieldTokens.pressedSurface(t) : Colors.transparent,
      borderRadius: interactionBorderRadius,
      // A divided or standalone row owns its complete pressed silhouette.
      // A contained row inherits the section perimeter and stays a tint-only
      // internal band. A rounded row temporarily owns the one shared stroke
      // while pressed, whether or not it was already active.
      border:
          _pressed && interactionShape == CatchFieldInteractionShape.roundedTile
          ? interactionBorder
          : null,
    );
    final overlayOutsets = CatchFieldGeometryScope.interactionOutsetsOf(
      context,
    );
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
      CatchFieldStatus.saving => widget.copy.savingSemanticLabel,
      CatchFieldStatus.saved => widget.copy.savedSemanticLabel,
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
        rowPadding.left + (_hasLeadingSlot ? _leadingTextLaneInset : 0.0);
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
            cancelLabel: widget.copy.cancelLabel,
            doneLabel: widget.copy.doneLabel,
            savingLabel: widget.copy.savingLabel,

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
            opacityDuration: catchFieldMotionDuration(
              context,
              CatchMotion.base,
            ),
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
        Positioned(
          left: -overlayOutsets.left,
          right: -overlayOutsets.right,
          top: -CatchStroke.hairline,
          bottom: -CatchStroke.hairline,
          child: IgnorePointer(
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  key: CatchField.pressOverlayKey,
                  duration: catchFieldMotionDuration(
                    context,
                    _pressed
                        ? CatchFieldTokens.pressIn
                        : CatchFieldTokens.pressOut,
                  ),
                  curve: CatchFieldTokens.curve,
                  decoration: pressDecoration,
                ),
                AnimatedContainer(
                  key: const ValueKey('catch-field-active-overlay'),
                  duration: catchFieldMotionDuration(
                    context,
                    _active
                        ? CatchFieldTokens.standard
                        : CatchFieldTokens.pressOut,
                  ),
                  curve: CatchFieldTokens.curve,
                  decoration: activeDecoration,
                ),
              ],
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

  Widget? _buildTrailingSlot(CatchTokens t) {
    if (_isToggle) {
      return CatchFieldTrailing.toggle(
        copy: widget.copy,
        value: widget.toggled,
        onChanged: _isSaving ? null : widget.onToggle,
        contract: widget.contract,
        contractExemption: widget.toggleContractExemption,
        semanticLabel: _title,
        status: _effectiveStatus,
        topPadding: 0,
      );
    }
    if (_statusLaneActive &&
        !_visibleCommitBarOwnsSavingIndicator &&
        !_hasError) {
      return CatchFieldTrailing.status(
        copy: widget.copy,
        status: _effectiveStatus,
      );
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
    final fallbackContent = widget.action ?? widget.suffixIcon;
    final fallback = fallbackContent == null
        ? null
        : CatchFieldTrailing.custom(
            topPadding: 0,
            color: t.ink3,
            child: fallbackContent,
          );
    if (!widget.showClearButton) return fallback;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (_, value, _) {
        if (value.text.isEmpty) return fallback ?? const SizedBox.shrink();
        return CatchFieldTrailing.clear(
          tooltip: widget.copy.clearTooltip(_title),
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
    final valueText = widget.valueText?.trim();
    if (!_stacksTrailingValueText &&
        valueText != null &&
        valueText.isNotEmpty) {
      children.add(
        CatchFieldTrailing.valueText(
          text: valueText,
          maxLines: widget.valueMaxLines,
          topPadding: 0,
        ),
      );
    }

    final custom = widget.action == null
        ? null
        : CatchFieldTrailing.custom(
            topPadding: 0,
            color: t.ink3,
            child: widget.action!,
          );
    if (custom != null) children.add(custom);

    if (children.isEmpty) {
      return includeChevron
          ? CatchFieldTrailing.fixedChevron(color: t.ink3, topPadding: 0)
          : null;
    }

    // Value and custom metadata share the lane without starving either of width.
    final group = children.length == 1
        ? children.single
        : Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s1,
            children: children,
          );
    if (!includeChevron) return group;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: group),
        const SizedBox(width: CatchSpacing.s2),
        CatchFieldTrailing.fixedChevron(color: t.ink3, topPadding: 0),
      ],
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

  Widget _buildBody(CatchTokens t) {
    if (_inlineControlAddAtRest) {
      final addText = _emptyEditableValueText ?? _title ?? '';
      return Semantics(
        label: _inlineAddSemanticLabel(addText),
        excludeSemantics: true,
        child: Text.rich(
          _inlineAddTextSpan(t),
          style: CatchTextStyles.fieldRowValue(
            context,
            color: t.ink3,
            fontWeight: FontWeight.w500,
          ),
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
                  style: CatchTextStyles.fieldRowValue(
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
      );
      return CatchFieldValueContent(
        labelCopy: widget.copy.label,
        titleMaxLines: widget.titleMaxLines,
        isOptional: widget.isOptional && widget.showLabel,
        badgeLabel: widget.badgeLabel,
        badgeTone: widget.badgeTone,
        tone: widget.tone,
        helperTone: widget.helperTone,
        headerTrailingReserve: _contentTrailingReserve,
        label: inlineAddAtRest ? null : _title,
        valueWidget: input,
        status: error?.isNotEmpty == true
            ? CatchFieldValueContentStatus.error
            : _active
            ? CatchFieldValueContentStatus.active
            : CatchFieldValueContentStatus.idle,
        labelStyle: CatchFieldValueContent.captionStyle(
          context,
          color: error?.isNotEmpty == true
              ? t.danger
              : _active
              ? t.ink
              : t.ink2,
        ),
      );
    }
    if (_isEdit) {
      return _buildTextEntryField(
        context,
        showLabelOverride: false,
        variantOverride: CatchFieldVariant.bare,
        valueEmphasis: true,
        rowBody: true,
      );
    }
    final inlineMetadata = widget.inlineMetadata?.trim();
    if (inlineMetadata?.isNotEmpty == true) {
      final title = _title?.trim() ?? '';
      return Semantics(
        label: '$title, $inlineMetadata',
        excludeSemantics: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: CatchTextStyles.recordTitle(
                context,
                color: _toneColor(t, primaryFallback: t.ink),
              ),
            ),
            const SizedBox(height: CatchRecordTokens.titleGap),
            Text(
              inlineMetadata!,
              style: CatchTextStyles.recordContext(context),
            ),
          ],
        ),
      );
    }
    if (widget._contentRow) {
      final hasError = _displayError?.trim().isNotEmpty == true;
      return CatchFieldContentRow(
        labelCopy: widget.copy.label,

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

    return CatchFieldValueContent(
      labelCopy: widget.copy.label,
      titleMaxLines: widget.titleMaxLines,
      isOptional: widget.isOptional && widget.showLabel,
      badgeLabel: widget.badgeLabel,
      badgeTone: widget.badgeTone,
      tone: widget.tone,
      helperTone: widget.helperTone,
      headerTrailingReserve: _contentTrailingReserve,
      label: title,
      value: value,
      supportText: _hasControl
          ? error?.isNotEmpty == true
                ? null
                : widget.helperText
          : error?.isNotEmpty == true
          ? error
          : widget.helperText,
      emphasis: widget.emphasis == CatchFieldEmphasis.title || !hasValue
          ? CatchFieldEmphasis.title
          : CatchFieldEmphasis.body,
      mode: !_hasValue
          ? CatchFieldValueContentMode.placeholder
          : CatchFieldValueContentMode.value,
      valueMaxLines: widget.bodyMaxLines,
      status: error?.isNotEmpty == true
          ? CatchFieldValueContentStatus.error
          : _active
          ? CatchFieldValueContentStatus.active
          : CatchFieldValueContentStatus.idle,
    );
  }
}
