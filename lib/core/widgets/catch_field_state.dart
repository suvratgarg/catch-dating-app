part of 'catch_field.dart';

class _CatchFieldDismissIntent extends Intent {
  const _CatchFieldDismissIntent();
}

class _CatchFieldChoicePickedNotification extends Notification {
  const _CatchFieldChoicePickedNotification({required this.autoClose});

  final bool autoClose;
}

class _CatchFieldState extends State<CatchField>
    with SingleTickerProviderStateMixin {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  final _selectFieldKey = GlobalKey<FormFieldState<Object?>>();
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
  late bool _inputWasEmpty;
  bool _textEntryHasValidationError = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  void _update(VoidCallback callback) => setState(callback);

  @override
  void initState() {
    super.initState();
    _expandedContentRevealController = AnimationController(vsync: this)
      ..addListener(_handleExpandedContentRevealTick)
      ..addStatusListener(_handleExpandedContentRevealStatus);
    _open = widget.open ?? (widget.initiallyOpen && widget.control != null);
    _disclosureOffstage = !_isOpen;
    _attachFocusNode(widget.focusNode);
    _internalController = TextEditingController(
      text: widget.controller == null ? widget.initialValue : null,
    );
    _inputWasEmpty = _controller.text.isEmpty;
    _attachControllerListener(_controller);
    if (widget._explicitSaveInput && _isOpen) {
      _pendingExpansionFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _requestPendingExpansionFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant CatchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode();
      _attachFocusNode(widget.focusNode);
    }
    final wasOpen = oldWidget.open ?? _open;
    if (oldWidget.control != widget.control &&
        widget.control == null &&
        !widget._explicitSaveInput) {
      _open = false;
    } else if (widget.open != null) {
      _open = widget.open!;
    } else if (oldWidget.open != null) {
      _open = oldWidget.open!;
    } else if (oldWidget.initiallyOpen != widget.initiallyOpen) {
      _open = widget.initiallyOpen && widget.control != null;
    }
    final isOpen = _isOpen;
    if (!wasOpen && isOpen) {
      _disclosureOffstage = false;
      _scheduleExpandedContentReveal();
    } else if (wasOpen && !isOpen) {
      _cancelExpandedContentReveal();
    }
    if (widget._explicitSaveInput && !wasOpen && isOpen) {
      _pendingExpansionFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _requestPendingExpansionFocus();
      });
    } else if (wasOpen && !isOpen) {
      _pendingExpansionFocus = false;
      _focusNode.unfocus();
    }
    if (oldWidget._selectValue != widget._selectValue ||
        !listEquals(oldWidget._selectValues, widget._selectValues)) {
      _scheduleSelectFieldSync();
    }

    final oldController = oldWidget.controller ?? _internalController;
    if (oldController != _controller) {
      _attachControllerListener(_controller);
      _syncFieldValue();
    }
    if (widget.controller == null &&
        oldWidget.controller == null &&
        widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _internalController.text) {
      _internalController.value = TextEditingValue(
        text: widget.initialValue ?? '',
      );
      _syncFieldValue();
    }
  }

  @override
  void dispose() {
    _activeExpandedContentRevealPosition = null;
    _expandedContentRevealController.dispose();
    _singleChoiceCloseTimer?.cancel();
    _listenedController?.removeListener(_syncFieldValue);
    _detachFocusNode();
    _rowFocusNode.dispose();
    _internalController.dispose();
    super.dispose();
  }

  void _attachFocusNode(FocusNode? supplied) {
    _focusNode = supplied ?? FocusNode();
    _ownsFocusNode = supplied == null;
    _focused = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChanged);
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
  }

  void _handleFocusChanged() {
    final focused = _focusNode.hasFocus;
    if (_focused == focused) return;
    _focused = focused;
    widget.onFocusChanged?.call(_focused);
    if (!focused) widget.onBlur?.call(_controller.text);
    setState(() {});
  }

  void _attachControllerListener(TextEditingController controller) {
    _listenedController?.removeListener(_syncFieldValue);
    _listenedController = controller..addListener(_syncFieldValue);
  }

  void _syncFieldValue() {
    final text = _controller.text;
    final field = _fieldKey.currentState;
    if (field != null && field.value != text) {
      field.didChange(text);
    }
    final isEmpty = text.isEmpty;
    final needsParentRebuild = isEmpty != _inputWasEmpty;
    _inputWasEmpty = isEmpty;
    if (mounted && needsParentRebuild) setState(() {});
  }

  void _scheduleSelectFieldSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final field = _selectFieldKey.currentState;
      final value = _normalizedSelectValue(widget._selectValue);
      if (field != null && field.value != value) {
        field.didChange(value);
      }
    });
  }

  void _setTextEntryValidationError(bool hasError) {
    if (_textEntryHasValidationError == hasError) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _textEntryHasValidationError == hasError) return;
      setState(() => _textEntryHasValidationError = hasError);
    });
  }

  void _expandAndFocusTextEntry() {
    // Let EditableText own subsequent taps so it can position the native
    // insertion cursor. Re-requesting focus in a post-frame callback would
    // collapse every tap to the existing selection and make editing feel like
    // a two-step interaction.
    if (_focusNode.hasFocus) return;
    setState(() {
      if (!_focused) {
        _focused = true;
        widget.onFocusChanged?.call(true);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  void _requestExpansion(bool expanded) {
    if (_isOpen == expanded) return;
    if (!expanded) {
      _singleChoiceCloseTimer?.cancel();
      _cancelExpandedContentReveal();
    }
    if (widget.open == null) {
      setState(() {
        _open = expanded;
        if (expanded) _disclosureOffstage = false;
      });
      if (expanded) _scheduleExpandedContentReveal();
    }
    widget.onOpenChanged?.call(expanded);
  }

  void _cancelExpandedContentReveal() {
    _expandedContentRevealController.stop();
    _activeExpandedContentRevealPosition = null;
  }

  void _startExpandedContentReveal({
    required ScrollPosition position,
    required double destination,
    required Duration duration,
  }) {
    _expandedContentRevealController.stop();
    _activeExpandedContentRevealPosition = position;
    _expandedContentRevealStart = position.pixels;
    _expandedContentRevealDestination = destination;
    _expandedContentRevealController
      ..duration = duration
      ..value = 0
      ..forward();
  }

  void _handleExpandedContentRevealTick() {
    final position = _activeExpandedContentRevealPosition;
    if (!_isOpen || position == null || !position.hasPixels) {
      _expandedContentRevealController.stop();
      _activeExpandedContentRevealPosition = null;
      return;
    }
    if (position.isScrollingNotifier.value) {
      // A direct user drag always wins over the automatic field reveal.
      _expandedContentRevealController.stop();
      _activeExpandedContentRevealPosition = null;
      return;
    }

    final progress = CatchFieldTokens.curve.transform(
      _expandedContentRevealController.value,
    );
    final requested =
        _expandedContentRevealStart +
        (_expandedContentRevealDestination - _expandedContentRevealStart) *
            progress;
    final available = requested
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (available > position.pixels) position.jumpTo(available);
  }

  void _handleExpandedContentRevealStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _activeExpandedContentRevealPosition = null;
    }
  }

  ScrollableState? _expandedContentRevealScrollable() {
    BuildContext searchContext = context;
    ScrollableState? nearestVertical;
    final visited = <ScrollableState>{};
    while (true) {
      final candidate = Scrollable.maybeOf(searchContext);
      if (candidate == null || !visited.add(candidate)) break;
      final position = candidate.position;
      if (position.axis == Axis.vertical) {
        nearestVertical ??= candidate;
        if (position.hasContentDimensions &&
            position.maxScrollExtent > position.minScrollExtent) {
          return candidate;
        }
      }
      // A Scrollable's own context sits outside its private inherited scope,
      // so the next lookup walks to the next enclosing scroll owner.
      searchContext = candidate.context;
    }
    return nearestVertical;
  }

  void _scheduleExpandedContentReveal({Duration? duration}) {
    if (_expandedContentRevealScheduled) return;
    _expandedContentRevealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _expandedContentRevealScheduled = false;
      if (!mounted || !_isOpen) return;

      final targetContext =
          _actionBarRevealTargetKey.currentContext ??
          _disclosureRevealTargetKey.currentContext;
      final target = targetContext?.findRenderObject();
      if (target is! RenderBox || !target.attached || !target.hasSize) return;

      final visibility = CatchFieldVisibilityScope.maybeOf(context);
      final bottomClearance =
          (visibility?.bottomObstruction ?? 0) +
          (visibility?.revealPadding ?? CatchSpacing.s2);
      final prioritizesActionBar =
          _actionBarRevealTargetKey.currentContext != null;
      final targetTop = prioritizesActionBar
          ? 0.0
          : target.size.height > 1
          ? target.size.height - 1
          : 0.0;
      final targetHeight = prioritizesActionBar ? target.size.height : 1.0;
      final revealDuration = duration ?? _expansionMotionDuration(context);
      final scrollable = _expandedContentRevealScrollable();
      final scrollPosition = scrollable?.position;
      final scrollViewport = scrollable?.context.findRenderObject();
      if (scrollPosition != null &&
          scrollPosition.axis == Axis.vertical &&
          scrollViewport is RenderBox &&
          scrollViewport.attached &&
          scrollViewport.hasSize) {
        final targetBottom = target
            .localToGlobal(Offset(0, targetTop + targetHeight))
            .dy;
        final viewportBottom = scrollViewport
            .localToGlobal(Offset(0, scrollViewport.size.height))
            .dy;
        final scrollDelta = targetBottom + bottomClearance - viewportBottom;
        if (scrollDelta > 0) {
          final destination = scrollPosition.pixels + scrollDelta;
          if (revealDuration == Duration.zero) {
            _expandedContentRevealController.stop();
            _activeExpandedContentRevealPosition = null;
            final available = destination
                .clamp(
                  scrollPosition.minScrollExtent,
                  scrollPosition.maxScrollExtent,
                )
                .toDouble();
            if (available > scrollPosition.pixels) {
              scrollPosition.jumpTo(available);
              return;
            }
          } else {
            // The field and viewport share one motion curve. Driving the
            // offset frame-by-frame lets the scroll extent grow with the
            // disclosure instead of clamping an animateTo target to the
            // collapsed card and snapping at the end.
            _startExpandedContentReveal(
              position: scrollPosition,
              destination: destination,
              duration: revealDuration,
            );
            return;
          }
        }
      }

      target.showOnScreen(
        rect: Rect.fromLTWH(
          0,
          targetTop,
          target.size.width,
          targetHeight + bottomClearance,
        ),
        duration: revealDuration,
        curve: CatchFieldTokens.curve,
      );
    });
  }

  void _handleExpansionAnimationEnd() {
    if (!_isOpen && !_disclosureOffstage) {
      setState(() => _disclosureOffstage = true);
    } else if (_isOpen) {
      // The Align height factor reaches its final scroll extent only at the
      // end of the reveal. Correct any earlier clamp without introducing a
      // second visible animation.
      _scheduleExpandedContentReveal(duration: Duration.zero);
    }
    _requestPendingExpansionFocus();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pressedPointer != null || event.buttons & kPrimaryButton == 0) return;
    _pressedPointer = event.pointer;
    _pressedDownPosition = event.position;
    if (!_pressed) setState(() => _pressed = true);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_pressedPointer != event.pointer) return;
    final origin = _pressedDownPosition;
    if (origin == null || (event.position - origin).distance <= kTouchSlop) {
      return;
    }
    _clearPressedPointer(event.pointer);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (_pressedPointer != event.pointer) return;
    _pressedPointer = null;
    _pressedDownPosition = null;
    // Keep the contact outline alive through GestureDetector's onTap. The tap
    // may activate focus/disclosure in the same frame, so deferring this reset
    // prevents a transparent frame between pressed and focused chrome.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pressedPointer == null && _pressed) {
        setState(() => _pressed = false);
      }
    });
  }

  void _handlePointerCancel(PointerEvent event) {
    _clearPressedPointer(event.pointer);
  }

  void _handlePointerExit(PointerExitEvent event) {
    _clearPressedPointer(event.pointer);
  }

  void _clearPressedPointer(int pointer) {
    if (_pressedPointer != pointer) return;
    _pressedPointer = null;
    _pressedDownPosition = null;
    if (_pressed && mounted) setState(() => _pressed = false);
  }

  void _handleOutsidePointerDown(PointerDownEvent event) {
    _outsidePointer = event.pointer;
    _outsideDownPosition = event.position;
  }

  void _handleOutsidePointerUp(PointerUpEvent event) {
    if (_outsidePointer != event.pointer) return;
    final downPosition = _outsideDownPosition;
    _outsidePointer = null;
    _outsideDownPosition = null;
    if (downPosition != null &&
        (event.position - downPosition).distance <= kTouchSlop) {
      _dismiss();
    }
  }

  void _clearOutsidePointer(PointerEvent event) {
    if (_outsidePointer != event.pointer) return;
    _outsidePointer = null;
    _outsideDownPosition = null;
  }

  void _requestPendingExpansionFocus() {
    if (!_pendingExpansionFocus ||
        !widget._explicitSaveInput ||
        !_isOpen ||
        !widget.enabled) {
      return;
    }
    _pendingExpansionFocus = false;
    _focusNode.requestFocus();
  }

  bool _handleChoicePicked(_CatchFieldChoicePickedNotification notification) {
    if (!notification.autoClose || _isSaving) return true;
    _singleChoiceCloseTimer?.cancel();
    _singleChoiceCloseTimer = Timer(
      CatchFieldTokens.singleChoiceCloseDelay,
      () {
        if (mounted && !_isSaving) _requestExpansion(false);
      },
    );
    return true;
  }

  CatchFieldMode get _mode => _hasSelect
      ? CatchFieldMode.select
      : widget.mode ??
            (_hasTextEntryConfiguration
                ? CatchFieldMode.edit
                : widget.onToggle != null
                ? CatchFieldMode.toggle
                : (widget.showChevron == true || widget.onTap != null)
                ? CatchFieldMode.nav
                : CatchFieldMode.read);

  bool get _hasValue => _body != null && _body!.isNotEmpty;
  bool get _inlineControlAddAtRest => widget.addable && !_hasValue && !_isOpen;
  bool get _hasControl => widget.control != null || widget._explicitSaveInput;
  Object get _textFieldTapRegionGroup =>
      widget._explicitSaveInput ? _tapRegionGroup : EditableText;
  bool get _hasSelect =>
      widget._selectValues != null && widget._selectItemLabel != null;
  bool get _hasFieldValidationError => _textEntryHasValidationError;
  bool get _hasError =>
      (_displayError != null && _displayError!.isNotEmpty) ||
      _hasFieldValidationError;
  bool get _isOpen => widget.open ?? _open;
  bool get _isSaving =>
      widget._isLoading || widget.status == CatchFieldStatus.saving;
  // Keep progress in the commit bar through its close animation. Once the
  // drawer is actually offstage, the header becomes the only visible owner.
  bool get _visibleCommitBarOwnsSavingIndicator =>
      _isSaving && !_disclosureOffstage && widget._onSubmit != null;
  bool get _active => _focused || _rowFocused || widget.focused || _isOpen;
  bool get _isEdit => _mode == CatchFieldMode.edit;
  bool get _hasInputValue => !_inputWasEmpty;
  bool get _hasTextEntryConfiguration =>
      widget.controller != null ||
      widget.initialValue != null ||
      widget.onChanged != null ||
      widget.onSubmitted != null ||
      widget.onFocusChanged != null ||
      widget.validator != null ||
      widget.keyboardType != null ||
      widget.textInputAction != null ||
      widget.inputFormatters != null ||
      widget.autofillHints != null ||
      widget.obscureText ||
      widget.maxLines != 1 ||
      widget.minLines != null ||
      widget.maxLength != null ||
      widget.readOnly ||
      widget.autofocus ||
      widget.prefixIcon != null ||
      widget.prefixText != null ||
      widget.suffixIcon != null ||
      widget.suffixText != null ||
      widget.showClearButton;
  bool get _usesUnderlineChrome =>
      _isEdit && widget.variant == CatchFieldVariant.underline;
  bool get _usesRowPrefixIcon =>
      _isEdit &&
      !_usesUnderlineChrome &&
      !_compactTextEntry &&
      widget.showLabel &&
      widget.prefixIcon != null;
  bool get _usesRowTextEntryTrailing =>
      _isEdit &&
      !_usesUnderlineChrome &&
      !_compactTextEntry &&
      (widget.showClearButton || widget.suffixIcon != null || _action != null);
  bool get _usesPositionedClearTrailing =>
      _usesRowTextEntryTrailing &&
      widget.showClearButton &&
      widget.showLabel &&
      (_title?.isNotEmpty ?? false) &&
      _hasInputValue &&
      !_isSaving &&
      widget.status == CatchFieldStatus.idle &&
      !(widget.valid && !_hasError);
  bool get _hasLeadingSlot =>
      widget.leading != null || widget.icon != null || _usesRowPrefixIcon;
  String? get _title => widget.title;
  String? get _body => widget.body;
  Widget? get _action => widget.action;
  String? get _displayError => widget.errorText ?? widget.error;
  String? get _placeholderText => widget.placeholder;
  String? get _inputHintText {
    final hint = (widget.inputHint ?? widget.placeholder)?.trim();
    if (hint == null || hint.isEmpty) return null;

    final label = _title?.trim();
    if (widget.showLabel &&
        label != null &&
        label.toLowerCase() == hint.toLowerCase()) {
      return null;
    }
    return hint;
  }

  String? get _emptyEditableValueText {
    final label = _title?.trim();
    final isEditableRow =
        (_isEdit && !widget.readOnly) ||
        widget._onSubmit != null ||
        widget.addable;
    if (!isEditableRow || label == null || label.isEmpty) return null;
    return CatchField.resolveEmptyValueText(
      context,
      title: label,
      emptyValueText: widget.emptyValueText,
    );
  }

  bool get _shouldShowChevron =>
      widget.showChevron ??
      (_mode == CatchFieldMode.nav &&
          (widget.mode == CatchFieldMode.nav || _action == null) &&
          widget.onTap != null &&
          widget.tone != CatchFieldTone.danger);

  bool get _textEntryCanCollapse =>
      _isEdit && widget.showLabel && (_title?.isNotEmpty ?? false);
  bool get _textEntryExpanded =>
      !_textEntryCanCollapse ||
      _hasInputValue ||
      _active ||
      _hasError ||
      widget.autofocus;
  bool _textEntryExpandedWith({required bool hasError}) =>
      !_textEntryCanCollapse ||
      _hasInputValue ||
      _active ||
      hasError ||
      widget.autofocus;
  bool _inlineTextAddAtRestWith({required bool hasError}) =>
      _isEdit &&
      !widget.readOnly &&
      _textEntryCanCollapse &&
      !_hasInputValue &&
      !_active &&
      !hasError &&
      !widget.autofocus &&
      _emptyEditableValueText != null;
  bool get _inlineTextAddAtRest =>
      _inlineTextAddAtRestWith(hasError: _hasError);
  bool get _showsInlineAddAtRest =>
      _inlineControlAddAtRest || _inlineTextAddAtRest;
  bool get _textEntryCollapsed => _textEntryCanCollapse && !_textEntryExpanded;
  bool get _compactTextEntry =>
      _isEdit && widget.size == CatchFieldSize.floating && !widget.showLabel;

  @override
  Widget build(BuildContext context) {
    late final Widget field;
    if (_mode == CatchFieldMode.select) {
      field = _buildSelectField(context);
    } else if (_usesUnderlineChrome) {
      field = _buildTextEntryField(context);
    } else {
      final t = CatchTokens.of(context);
      final rowStack = Stack(
        children: [
          if (widget.divider)
            Positioned(
              top: 0,
              left:
                  _rowPadding.left +
                  (_hasLeadingSlot ? CatchFieldRow.textLaneInset : 0),
              right: _rowPadding.right,
              child: ColoredBox(
                color: CatchDivider.colorFor(t, CatchDividerRole.fieldRow),
                child: const SizedBox(height: CatchStroke.hairline),
              ),
            ),
          widget.add ? _buildAdd(t) : _buildRow(t),
        ],
      );
      if (!_isEdit && !_hasControl) {
        field = rowStack;
      } else {
        field = Shortcuts(
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
    }
    final listeningField =
        NotificationListener<_CatchFieldChoicePickedNotification>(
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
