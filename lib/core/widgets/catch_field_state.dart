part of 'catch_field.dart';

class _CatchFieldDismissIntent extends Intent {
  const _CatchFieldDismissIntent();
}

class _CatchFieldState extends State<CatchField>
    with SingleTickerProviderStateMixin {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  final _disclosureRevealTargetKey = GlobalKey();
  final _actionBarRevealTargetKey = GlobalKey();
  final _menuController = MenuController();
  final Object _tapRegionGroup = Object();
  final FocusNode _rowFocusNode = FocusNode(debugLabel: 'CatchField row');
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late final TextEditingController _internalController;
  TextEditingController? _listenedController;

  bool _focused = false;
  bool _rowFocused = false;
  bool _pressed = false;
  int? _pressedPointer;
  Offset? _pressedDownPosition;
  int? _outsidePointer;
  Offset? _outsideDownPosition;
  late bool _open;
  late bool _disclosureOffstage;
  bool _pendingExpansionFocus = false;
  bool _expandedContentRevealScheduled = false;
  late final AnimationController _expandedContentRevealController;
  ScrollPosition? _activeExpandedContentRevealPosition;
  double _expandedContentRevealStart = 0;
  double _expandedContentRevealDestination = 0;
  Timer? _singleChoiceCloseTimer;
  Timer? _statusLaneDismissTimer;
  late bool _inputWasEmpty;
  bool _textEntryHasValidationError = false;
  late bool _statusLaneActive;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  void _update(VoidCallback callback) => setState(callback);

  @override
  void initState() {
    super.initState();
    _initializeField();
  }

  @override
  void didUpdateWidget(covariant CatchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateFieldConfiguration(oldWidget);
  }

  @override
  void dispose() {
    _disposeField();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textEntry = !_isEdit
        ? null
        : CatchFieldTextEntry(
            field: widget,
            formFieldKey: _fieldKey,
            controller: _controller,
            focusNode: _focusNode,
            tapRegionGroupId: _textFieldTapRegionGroup,
            onValidationErrorChanged: _setTextEntryValidationError,
            onSubmitted: _handleSubmitted,
            mode: _usesUnderlineChrome
                ? CatchFieldTextEntryMode.standalone
                : widget._explicitSaveInput
                ? CatchFieldTextEntryMode.explicitSave
                : CatchFieldTextEntryMode.row,
            states: {
              if (_active) WidgetState.selected,
              if (_focused) WidgetState.focused,
            },
            emptyValueText: _emptyEditableValueText,
            inputHintText: _inputHintText,
            addTextSpan: _inlineAddTextSpan(CatchTokens.of(context)),
            headerTrailingReserve: _contentTrailingReserve,
            expanded: _isOpen,
            inlineAddAtRest: _inlineTextAddAtRest,
          );
    final Widget field;
    switch (widget._config) {
      case _SelectConfig():
        field = CatchFieldSelectControl(
          copy: widget.copy,
          title: _title,
          values: widget._selectValues!,
          itemLabel: widget._selectItemLabel!,
          value: widget._selectValue,
          onChanged: widget._onSelectChanged,
          validator: widget._selectValidator,
          menuController: _menuController,
          focusNode: _focusNode,
          enabled: widget.enabled,
          showLabel: widget.showLabel,
          size: widget.size,
          placeholder: widget.placeholder,
          prefixIcon: widget.prefixIcon,
          error: _displayError,
          helperText: widget.helperText,
          helperTone: widget.helperTone,
          status: _active
              ? CatchFieldValueContentStatus.active
              : CatchFieldValueContentStatus.idle,
        );
      case _EditConfig() when _usesUnderlineChrome:
        field = textEntry!;
      case _EditConfig() || _RowConfig() || _ToggleConfig() || _ControlConfig():
        final t = CatchTokens.of(context);
        final Widget configuredRow;
        if (widget.add) {
          configuredRow = CatchFieldRow.add(
            onTap: widget.onTap,
            leading: Icon(
              widget.icon ?? CatchIcons.add,
              size: CatchIcon.md,
              color: t.primary,
            ),
            content: Text(
              _title ?? '',
              style: CatchTextStyles.fieldRowValue(
                context,
                color: _toneColor(t, primaryFallback: t.primary),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        } else {
          final canFocusTextEntry =
              _isEdit &&
              !widget._explicitSaveInput &&
              widget.enabled &&
              (!widget.readOnly || widget.onTap != null);
          final canToggleRow =
              _isToggle && widget.onToggle != null && !_isSaving;
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
          final hasInlineMetadata =
              widget.inlineMetadata?.trim().isNotEmpty == true;
          final centerVertically =
              _showsInlineAddAtRest ||
              _isToggle ||
              hasInlineMetadata ||
              (widget._contentRow &&
                  widget.emphasis == CatchFieldEmphasis.title);
          final leadingTopPadding = centerVertically
              ? 0.0
              : widget._contentRow
              ? CatchSpacing.micro2
              : _rowTrailingTopPadding;
          final Widget? rawTrailingSlot;
          if (_isToggle) {
            rawTrailingSlot = CatchFieldTrailing.toggle(
              copy: widget.copy,
              value: widget.toggled,
              onChanged: _isSaving ? null : widget.onToggle,
              contract: widget.contract,
              contractExemption: widget.toggleContractExemption,
              semanticLabel: _title,
              status: _effectiveStatus,
              topPadding: 0,
            );
          } else if (_statusLaneActive &&
              !_visibleCommitBarOwnsSavingIndicator &&
              !_hasError) {
            rawTrailingSlot = CatchFieldTrailing.status(
              copy: widget.copy,
              status: _effectiveStatus,
            );
          } else if (!_isSaving && widget.valid && !_hasError) {
            rawTrailingSlot = CatchFieldTrailing.valid(topPadding: 0);
          } else if (_usesRowTextEntryTrailing) {
            final fallbackContent = widget.action ?? widget.suffixIcon;
            final fallback = fallbackContent == null
                ? null
                : CatchFieldTrailing.custom(
                    topPadding: 0,
                    color: t.ink3,
                    child: fallbackContent,
                  );
            if (!widget.showClearButton) {
              rawTrailingSlot = fallback;
            } else {
              rawTrailingSlot = ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (_, value, _) {
                  if (value.text.isEmpty) {
                    return fallback ?? const SizedBox.shrink();
                  }
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
          } else if (_hasControl) {
            rawTrailingSlot = CatchFieldTrailing.rotatingChevron(
              open: _isOpen,
              color: _active ? t.ink : t.ink3,
              topPadding: 0,
            );
          } else {
            final includeChevron = _isNavigation && _shouldShowChevron;
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
              rawTrailingSlot = includeChevron
                  ? CatchFieldTrailing.fixedChevron(
                      color: t.ink3,
                      topPadding: 0,
                    )
                  : null;
            } else {
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
              rawTrailingSlot = !includeChevron
                  ? group
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(child: group),
                        const SizedBox(width: CatchSpacing.s2),
                        CatchFieldTrailing.fixedChevron(
                          color: t.ink3,
                          topPadding: 0,
                        ),
                      ],
                    );
            }
          }
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
          final Widget rowBody;
          final inlineMetadata = widget.inlineMetadata?.trim();
          if (_inlineControlAddAtRest) {
            final addText = _emptyEditableValueText ?? _title ?? '';
            rowBody = Semantics(
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
          } else if (widget._explicitSaveInput) {
            final error = _displayError?.trim();
            final inlineAddAtRest =
                error?.isNotEmpty != true && _inlineTextAddAtRest;
            final input = IgnorePointer(ignoring: !_isOpen, child: textEntry);
            rowBody = CatchFieldValueContent(
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
          } else if (_isEdit) {
            rowBody = textEntry!;
          } else if (inlineMetadata?.isNotEmpty == true) {
            final title = _title?.trim() ?? '';
            rowBody = Semantics(
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
          } else if (widget._contentRow) {
            final hasError = _displayError?.trim().isNotEmpty == true;
            rowBody = CatchFieldContentRow(
              labelCopy: widget.copy.label,

              title: _title?.trim() ?? '',
              body: _body?.trim() ?? '',
              titleMaxLines: widget.titleMaxLines,
              bodyMaxLines: widget.bodyMaxLines,
              isOptional: widget.isOptional,
              titleColor: hasError
                  ? t.danger
                  : _toneColor(t, primaryFallback: t.ink),
              bodyColor: t.ink2,
            );
          } else {
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

            rowBody = CatchFieldValueContent(
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
          final rowContent = CatchFieldRow.standard(
            constraints: _usesPositionedClearTrailing
                ? _rowConstraints.enforce(
                    BoxConstraints(
                      minHeight:
                          CatchFieldTrailing.clearTargetConstraints.minHeight,
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
            content: rowBody,
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
                        width:
                            CatchFieldTrailing.clearTargetConstraints.maxWidth,
                        child: LayoutBuilder(
                          builder: (context, available) {
                            final extent = CatchFieldTrailing
                                .clearTargetConstraints
                                .maxHeight;
                            final scaler = MediaQuery.textScalerOf(context);
                            final desiredTop =
                                _rowHeaderPadding.top +
                                scaler.scale(CatchFieldTokens.captionExtent) +
                                (scaler.scale(
                                          CatchFieldTokens.valueLineExtent,
                                        ) -
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
          if (!canInteract && !_active && !_hasControl) {
            configuredRow = row;
          } else {
            final mouseCursor = canInteract
                ? _isEdit
                      ? SystemMouseCursors.text
                      : SystemMouseCursors.click
                : SystemMouseCursors.basic;
            final tapRegion = _isEdit
                ? TextFieldTapRegion(
                    groupId: _textFieldTapRegionGroup,
                    child: row,
                  )
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
                rowPadding.left +
                (_hasLeadingSlot ? _leadingTextLaneInset : 0.0);
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
            final stack = CatchFieldSurface(
              pressedOverlayKey: CatchField.pressOverlayKey,
              states: {
                if (_active) WidgetState.selected,
                if (_rowFocused) WidgetState.focused,
                if (_pressed) WidgetState.pressed,
              },
              child: content,
            );
            configuredRow = Semantics(
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
        }
        final rowStack = Stack(children: [configuredRow]);
        field = !_isEdit && !_hasControl
            ? rowStack
            : Shortcuts(
                shortcuts: const <ShortcutActivator, Intent>{
                  SingleActivator(LogicalKeyboardKey.escape):
                      _CatchFieldDismissIntent(),
                },
                child: Actions(
                  actions: <Type, Action<Intent>>{
                    _CatchFieldDismissIntent:
                        CallbackAction<_CatchFieldDismissIntent>(
                          onInvoke: (_) {
                            _dismiss();
                            return null;
                          },
                        ),
                  },
                  child: _isEdit
                      ? TextFieldTapRegion(
                          groupId: _textFieldTapRegionGroup,
                          onTapOutside: _handleOutsidePointerDown,
                          onTapUpOutside: _handleOutsidePointerUp,
                          onTapInside: _clearOutsidePointer,
                          onTapUpInside: _clearOutsidePointer,
                          child: rowStack,
                        )
                      : TapRegion(
                          groupId: _tapRegionGroup,
                          onTapOutside: _handleOutsidePointerDown,
                          onTapUpOutside: _handleOutsidePointerUp,
                          onTapInside: _clearOutsidePointer,
                          onTapUpInside: _clearOutsidePointer,
                          child: rowStack,
                        ),
                ),
              );
    }
    final listeningField =
        NotificationListener<CatchFieldChoicePickedNotification>(
          onNotification: _handleChoicePicked,
          child: field,
        );
    if (widget.enabled) return listeningField;
    return IgnorePointer(
      child: Opacity(
        opacity: CatchFieldTokens.disabledOpacity,
        child: listeningField,
      ),
    );
  }
}
