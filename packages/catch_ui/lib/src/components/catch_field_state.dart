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
  bool _hovered = false;
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

  void _update(VoidCallback callback) {
    setState(callback);
    _notifyRowActivity();
  }

  void _notifyRowActivity() {
    if (!mounted) return;
    CatchFieldActivityNotification(
      _active || _hovered || _pressed,
    ).dispatch(context);
  }

  @override
  void initState() {
    super.initState();
    _initializeField();
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyRowActivity());
  }

  @override
  void didUpdateWidget(covariant CatchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateFieldConfiguration(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifyRowActivity());
  }

  @override
  void dispose() {
    _disposeField();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _renderField(context);
}
