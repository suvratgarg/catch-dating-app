part of 'catch_field.dart';

/// Exact natural-height title and supporting-copy lane used by
/// [CatchField.content].
class CatchFieldContentRow extends StatelessWidget {
  const CatchFieldContentRow({
    super.key,
    required this.title,
    required this.body,
    this.titleMaxLines = 2,
    this.bodyMaxLines = 3,
    this.isOptional = false,
    this.titleColor,
    this.bodyColor,
  });

  final String title;
  final String body;
  final int titleMaxLines;
  final int bodyMaxLines;
  final bool isOptional;
  final Color? titleColor;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final normalizedBody = body.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchFormFieldLabel.inline(
          label: title.trim(),
          style: _fieldValueTextStyle(
            context,
            color: titleColor ?? t.ink,
            fontWeight: FontWeight.w600,
          ),
          maxLines: titleMaxLines,
          isOptional: isOptional,
        ),
        if (normalizedBody.isNotEmpty) ...[
          const SizedBox(height: CatchFieldTokens.contentBodyTopGap),
          Text(
            normalizedBody,
            key: const ValueKey('catch-field-content-body'),
            maxLines: bodyMaxLines,
            overflow: TextOverflow.ellipsis,
            style:
                CatchTextStyles.supporting(
                  context,
                  color: bodyColor ?? t.ink2,
                ).copyWith(
                  fontSize: CatchFieldTokens.contentBodyFontSize,
                  fontWeight: FontWeight.w400,
                  height: CatchFieldTokens.contentBodyLineHeight,
                ),
          ),
        ],
      ],
    );
  }
}

class CatchFieldRow extends StatelessWidget {
  const CatchFieldRow.standard({
    super.key,
    required this.content,
    this.leading,
    this.trailing,
    this.onTap,
    this.constraints = const BoxConstraints(),
    this.padding = _defaultPadding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.leadingTopPadding = 0,
    this.paddingDuration = Duration.zero,
    this.paddingCurve = Curves.linear,
  }) : leadingGap = leadingSlotGap,
       trailingGap = CatchFieldTokens.trailingGap;

  const CatchFieldRow.add({
    super.key,
    required this.leading,
    required this.content,
    this.onTap,
  }) : trailing = null,
       constraints = const BoxConstraints(),
       padding = const EdgeInsets.symmetric(
         horizontal: CatchFieldTokens.rowHorizontalPadding,
         vertical: CatchFieldTokens.rowVerticalPadding,
       ),
       crossAxisAlignment = CrossAxisAlignment.start,
       leadingTopPadding = 0,
       paddingDuration = Duration.zero,
       paddingCurve = Curves.linear,
       leadingGap = leadingSlotGap,
       trailingGap = CatchFieldTokens.trailingGap;

  /// Render size of icons in the leading slot.
  static const double leadingSlotIconSize = CatchFieldTokens.leadingIconExtent;

  /// Gap between the leading slot and the content lane.
  static const double leadingSlotGap = CatchFieldTokens.leadingGap;

  /// Horizontal distance from the row's padded edge to where the content
  /// lane starts when a leading slot is present. Containers that draw
  /// text-lane-aligned dividers derive their indent from this instead of
  /// hardcoding it, so resizing the leading icon moves the dividers too.
  static const double textLaneInset = CatchLayout.fieldRowTextLaneInset;

  static const _defaultPadding = EdgeInsets.fromLTRB(
    CatchFieldTokens.rowHorizontalPadding,
    CatchFieldTokens.rowVerticalPadding,
    CatchFieldTokens.rowHorizontalPadding,
    CatchFieldTokens.rowVerticalPadding,
  );

  final Widget content;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final double leadingTopPadding;
  final double leadingGap;
  final double trailingGap;
  final Duration paddingDuration;
  final Curve paddingCurve;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: constraints,
      child: AnimatedPadding(
        duration: paddingDuration,
        curve: paddingCurve,
        padding: padding,
        child: LayoutBuilder(
          builder: (context, rowConstraints) {
            // The trailing slot is intrinsic so trailing affordances pin to
            // the row's trailing edge; the content lane owns all remaining
            // width. Capping the slot at half the row keeps long trailing
            // values from starving the content lane on narrow rows.
            final trailingMaxWidth = rowConstraints.hasBoundedWidth
                ? rowConstraints.maxWidth / 2
                : double.infinity;
            return Row(
              crossAxisAlignment: crossAxisAlignment,
              children: [
                if (leading != null) ...[
                  Padding(
                    padding: EdgeInsets.only(top: leadingTopPadding),
                    child: leading,
                  ),
                  SizedBox(width: leadingGap),
                ],
                Expanded(child: content),
                if (trailing != null) ...[
                  SizedBox(width: trailingGap),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: trailingMaxWidth),
                    child: trailing,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );

    if (onTap == null) return row;
    return CatchRowPressSurface(onTap: onTap, child: row);
  }
}

class CatchFieldTrailing extends StatelessWidget {
  factory CatchFieldTrailing.custom({
    Key? key,
    required Widget child,
    Color? color,
    double topPadding = CatchSpacing.micro2,
  }) {
    return CatchFieldTrailing._(
      key: key,
      topPadding: topPadding,
      builder: (context) {
        final t = CatchTokens.of(context);
        final resolvedColor = color ?? t.ink3;
        return IconTheme(
          data: IconThemeData(color: resolvedColor, size: CatchIcon.md),
          child: DefaultTextStyle.merge(
            style: CatchTextStyles.bodyLead(context, color: resolvedColor),
            child: child,
          ),
        );
      },
    );
  }

  factory CatchFieldTrailing.valueText({
    Key? key,
    required String text,
    int maxLines = 1,
    double topPadding = CatchSpacing.micro2,
  }) {
    return CatchFieldTrailing._(
      key: key,
      topPadding: topPadding,
      builder: (context) {
        final t = CatchTokens.of(context);
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.fieldTrailingValueMaxWidth,
          ),
          child: Text(
            text,
            textAlign: TextAlign.right,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: _fieldValueTextStyle(
              context,
              color: t.ink2,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }

  factory CatchFieldTrailing.fixedChevron({
    Key? key,
    Color? color,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => Icon(
      CatchIcons.chevronRightRounded,
      size: CatchFieldTokens.disclosureGlyphExtent,
      color: color ?? CatchTokens.of(context).ink3,
    ),
  );

  factory CatchFieldTrailing.rotatingChevron({
    Key? key,
    required bool open,
    Color? color,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => AnimatedRotation(
      turns: open ? 0.5 : 0,
      duration: _fieldDuration(context, CatchFieldTokens.reveal),
      curve: CatchFieldTokens.curve,
      child: Icon(
        CatchIcons.expandMoreRounded,
        size: CatchFieldTokens.disclosureGlyphExtent,
        color: color ?? CatchTokens.of(context).ink3,
      ),
    ),
  );

  factory CatchFieldTrailing.toggle({
    Key? key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? semanticLabel,
    CatchFieldStatus status = CatchFieldStatus.idle,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == CatchFieldStatus.saving)
          SizedBox.square(
            dimension: CatchFieldTokens.spinnerExtent,
            child: CatchFieldSpinner(color: CatchTokens.of(context).ink3),
          )
        else if (status == CatchFieldStatus.saved)
          Icon(
            CatchIcons.checkCircleFilled,
            key: const ValueKey('catch-field-saved'),
            size: CatchFieldTokens.disclosureGlyphExtent,
            color: CatchTokens.of(context).success,
          ),
        if (status != CatchFieldStatus.idle)
          const SizedBox(width: CatchFieldTokens.trailingGap),
        CatchFieldToggle(
          value: value,
          semanticLabel: semanticLabel,
          onChanged: onChanged,
        ),
      ],
    ),
  );

  factory CatchFieldTrailing.saving({Key? key, double topPadding = 0}) =>
      CatchFieldTrailing._(
        key: key,
        topPadding: topPadding,
        builder: (context) => Semantics(
          label: context.l10n.coreCatchFieldSemanticSaving,
          liveRegion: true,
          child: ExcludeSemantics(
            child: SizedBox.square(
              dimension: CatchFieldTokens.spinnerExtent,
              child: CatchFieldSpinner(color: CatchTokens.of(context).ink3),
            ),
          ),
        ),
      );

  factory CatchFieldTrailing.saved({Key? key, double topPadding = 0}) =>
      CatchFieldTrailing._(
        key: key,
        topPadding: topPadding,
        builder: (context) => Semantics(
          label: context.l10n.coreCatchFieldSemanticSaved,
          liveRegion: true,
          child: ExcludeSemantics(
            child: Icon(
              CatchIcons.checkCircleFilled,
              key: const ValueKey('catch-field-saved'),
              size: CatchFieldTokens.disclosureGlyphExtent,
              color: CatchTokens.of(context).success,
            ),
          ),
        ),
      );

  factory CatchFieldTrailing.clear({
    Key? key,
    required String tooltip,
    required VoidCallback onPressed,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: CatchControlMetrics.squareConstraints(CatchSpacing.s6),
      style: IconButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(
        CatchIcons.clearCircle,
        size: CatchFieldTokens.largeGlyphExtent,
        color: CatchTokens.of(context).ink3,
      ),
      onPressed: onPressed,
    ),
  );

  factory CatchFieldTrailing.valid({
    Key? key,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => Icon(
      CatchIcons.checkCircle,
      size: CatchIcon.md,
      color: CatchTokens.of(context).success,
    ),
  );

  const CatchFieldTrailing._({
    super.key,
    required this.builder,
    this.topPadding = CatchSpacing.micro2,
  });

  final WidgetBuilder builder;
  final double topPadding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: topPadding),
    child: builder(context),
  );
}

/// Field helper/error and optional counter row.
class CatchFieldSupportRow extends StatelessWidget {
  const CatchFieldSupportRow({
    super.key,
    this.text,
    this.counter,
    required this.color,
    this.showErrorIcon = false,
    this.padding = EdgeInsets.zero,
  });

  final String? text;
  final String? counter;
  final Color color;
  final bool showErrorIcon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final normalizedText = text?.trim();
    final normalizedCounter = counter?.trim();
    final hasText = normalizedText?.isNotEmpty == true;
    final hasCounter = normalizedCounter?.isNotEmpty == true;
    if (!hasText && !hasCounter) return const SizedBox.shrink();

    final label = Text(
      normalizedText ?? '',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.supporting(context, color: color).copyWith(
        fontSize: CatchFieldTokens.captionFontSize,
        fontWeight: FontWeight.w500,
        height: CatchFieldTokens.supportLineHeight,
      ),
    );
    final support = showErrorIcon
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(
                  CatchIcons.fieldWarning,
                  size: CatchFieldTokens.errorGlyphExtent,
                  color: color,
                ),
              ),
              const SizedBox(width: CatchFieldTokens.errorGlyphGap),
              Flexible(child: label),
            ],
          )
        : label;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (hasText) Expanded(child: support) else const Spacer(),
          if (hasCounter) ...[
            if (hasText)
              const SizedBox(width: CatchFieldTokens.supportingCounterGap),
            Text(
              normalizedCounter!,
              style: CatchTextStyles.monoLabel(
                context,
                color: CatchTokens.of(context).ink3,
              ).copyWith(fontSize: CatchFieldTokens.counterFontSize),
            ),
          ],
        ],
      ),
    );
  }
}

/// Supporting metadata shown inside an explicit-save disclosure before its
/// commit bar. Validation remains a root-level [CatchFieldSupportRow].
class CatchFieldExplicitSaveControl extends StatelessWidget {
  const CatchFieldExplicitSaveControl({
    super.key,
    this.supporting,
    this.feedback,
    this.secondaryAction,
  });

  final Widget? supporting;
  final Widget? feedback;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    void addChild(Widget child) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: CatchSpacing.s2));
      }
      children.add(child);
    }

    if (supporting case final supporting?) {
      addChild(Align(alignment: Alignment.centerRight, child: supporting));
    }
    if (feedback case final feedback?) addChild(feedback);
    if (secondaryAction case final secondaryAction?) {
      addChild(secondaryAction);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// Trailing Cancel/Done group used by explicit-save field drawers.
class CatchFieldActionBar extends StatelessWidget {
  const CatchFieldActionBar({
    super.key,
    required this.onCancel,
    required this.onSubmit,
    this.loading = false,
    this.actionLeading,
    this.revealTargetKey,
  });

  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool loading;
  final Widget? actionLeading;
  final Key? revealTargetKey;

  @override
  Widget build(BuildContext context) {
    final cancelButton = CatchFieldCommitButton(
      key: const ValueKey('catch-field-cancel'),
      label: context.l10n.coreCatchFieldLabelCancel,
      onPressed: loading ? null : onCancel,
    );
    final doneButton = CatchFieldCommitButton(
      key: const ValueKey('catch-field-done'),
      label: loading
          ? context.l10n.coreCatchFieldLabelSaving
          : context.l10n.coreCatchFieldLabelDone,
      primary: true,
      loading: loading,
      onPressed: loading ? null : onSubmit,
    );

    return KeyedSubtree(
      key: revealTargetKey,
      child: SizedBox(
        key: const ValueKey('catch-field-action-bar'),
        width: double.infinity,
        child: Row(
          children: [
            if (actionLeading != null)
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: actionLeading,
                ),
              )
            else
              const Spacer(),
            cancelButton,
            const SizedBox(width: CatchFieldTokens.actionButtonGap),
            doneButton,
          ],
        ),
      ),
    );
  }
}

/// Full-row disclosure sibling below a [CatchField] header.
class CatchFieldDisclosureDrawer extends StatelessWidget {
  const CatchFieldDisclosureDrawer({
    super.key,
    required this.open,
    required this.offstage,
    required this.control,
    required this.startPadding,
    required this.endPadding,
    required this.bottomPadding,
    required this.revealDuration,
    required this.opacityDuration,
    required this.onRevealEnd,
    this.actionBar,
    this.revealTargetKey,
  });

  final bool open;
  final bool offstage;
  final Widget control;
  final Widget? actionBar;
  final double startPadding;
  final double endPadding;
  final double bottomPadding;
  final Duration revealDuration;
  final Duration opacityDuration;
  final VoidCallback onRevealEnd;
  final Key? revealTargetKey;

  @override
  Widget build(BuildContext context) {
    final revealedContent = KeyedSubtree(
      key: revealTargetKey,
      child: GestureDetector(
        key: const ValueKey('catch-field-control-tap-barrier'),
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: startPadding,
            end: endPadding,
            top: CatchFieldTokens.controlTopGap,
            bottom: bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              control,
              if (actionBar != null) ...[
                const SizedBox(height: CatchFieldTokens.actionBarTopGap),
                actionBar!,
              ],
            ],
          ),
        ),
      ),
    );

    return ExcludeSemantics(
      excluding: !open,
      child: ExcludeFocus(
        excluding: !open,
        child: IgnorePointer(
          ignoring: !open,
          child: TweenAnimationBuilder<double>(
            key: const ValueKey('catch-field-expansion'),
            duration: revealDuration,
            curve: CatchFieldTokens.curve,
            tween: Tween<double>(end: open ? 1 : 0),
            onEnd: onRevealEnd,
            child: revealedContent,
            builder: (context, reveal, child) => Offstage(
              offstage: offstage || (!open && reveal == 0),
              child: ClipRect(
                clipper: const _CatchFieldDisclosureClipper(),
                child: AnimatedOpacity(
                  key: const ValueKey('catch-field-control-opacity'),
                  duration: opacityDuration,
                  curve: CatchFieldTokens.curve,
                  opacity: open ? 1 : 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: reveal,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fixed-cadence Phosphor spinner from the Field handoff.
class CatchFieldSpinner extends StatefulWidget {
  const CatchFieldSpinner({
    super.key,
    this.size = CatchFieldTokens.spinnerExtent,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  State<CatchFieldSpinner> createState() => _CatchFieldSpinnerState();
}

class _CatchFieldSpinnerState extends State<CatchFieldSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: CatchFieldTokens.spinnerPeriod,
  )..repeat();

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      key: const ValueKey('catch-field-spinner'),
      turns: _rotation,
      child: Icon(
        CatchIcons.fieldSpinner,
        size: widget.size,
        color: widget.color,
      ),
    );
  }
}

/// Exact Cancel/Done action used by a disclosed [CatchField] editor.
class CatchFieldCommitButton extends StatefulWidget {
  const CatchFieldCommitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;

  @override
  State<CatchFieldCommitButton> createState() => _CatchFieldCommitButtonState();
}

class _CatchFieldCommitButtonState extends State<CatchFieldCommitButton> {
  late final FocusNode _focusNode = FocusNode(
    debugLabel: widget.primary
        ? 'CatchField Done button'
        : 'CatchField Cancel button',
  );
  bool _showFocusHighlight = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_updateFocusHighlight);
    FocusManager.instance.addHighlightModeListener(_updateFocusHighlight);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_updateFocusHighlight)
      ..dispose();
    FocusManager.instance.removeHighlightModeListener(_updateFocusHighlight);
    super.dispose();
  }

  void _updateFocusHighlight([FocusHighlightMode? _]) {
    final show =
        _focusNode.hasFocus &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    if (show != _showFocusHighlight && mounted) {
      setState(() => _showFocusHighlight = show);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final background = widget.primary ? t.ink : t.surface;
    final foreground = widget.primary ? t.primaryInk : t.ink;
    final button = CatchTextButton(
      label: widget.label,
      onPressed: widget.onPressed,
      foregroundColor: foreground,
      backgroundColor: background,
      disabledForegroundColor: foreground,
      disabledBackgroundColor: background,
      focusNode: _focusNode,
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchFieldTokens.actionButtonHorizontalPadding,
        vertical: CatchFieldTokens.actionButtonVerticalPadding,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: widget.primary ? Colors.transparent : t.line2),
      shape: const StadiumBorder(),
      textStyle: CatchTextStyles.fieldRowTitle(context).copyWith(
        fontSize: CatchFieldTokens.actionButtonFontSize,
        fontWeight: FontWeight.w600,
        height: 1,
      ),
      leading: widget.loading
          ? ExcludeSemantics(
              child: SizedBox.square(
                dimension: CatchFieldTokens.actionSpinnerExtent,
                child: CatchFieldSpinner(
                  size: CatchFieldTokens.actionSpinnerExtent,
                  color: foreground,
                ),
              ),
            )
          : null,
      leadingGap: CatchFieldTokens.actionButtonSpinnerGap,
    );
    return Semantics(
      liveRegion: widget.loading,
      child: AnimatedOpacity(
        duration: _fieldDuration(context, CatchFieldTokens.fast),
        curve: CatchFieldTokens.curve,
        opacity: widget.onPressed == null && !widget.primary
            ? CatchFieldTokens.savingCancelOpacity
            : 1,
        child: CatchFieldFocusOutline(
          debugKey: ValueKey(
            widget.primary
                ? 'catch-field-done-focus-outline'
                : 'catch-field-cancel-focus-outline',
          ),
          show: _showFocusHighlight,
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          child: button,
        ),
      ),
    );
  }
}

/// Exact 44x26 switch used by [CatchField.toggle].
class CatchFieldToggle extends StatelessWidget {
  const CatchFieldToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CatchToggle.field(
      value: value,
      onChanged: onChanged,
      semanticLabel: semanticLabel,
    );
  }
}
