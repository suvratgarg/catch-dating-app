import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart'
    show CatchContractConstraints, CatchContractFieldConstraints;

/// Visual emphasis for an activity chip.
enum CatchChipEmphasis { soft, solid }

enum _CatchChipVariant { tag, selectable, activity, removable }

/// Canonical compact-label primitive for facts, choices, activities, and
/// removable values.
///
/// Choose the constructor that matches the chip's interaction contract:
///
/// - [CatchChip.tag] is passive metadata.
/// - [CatchChip.selectable] is a parent-owned binary choice.
/// - [CatchChip.activity] carries registry-backed activity identity.
/// - [CatchChip.removable] exposes one removal action across the whole chip.
class CatchChip extends StatefulWidget {
  const CatchChip.tag({
    Key? key,
    required String label,
    Widget? leading,
    Color? tintColor,
    Color? inkColor,
    String? semanticsLabel,
  }) : this._(
         key: key,
         variant: _CatchChipVariant.tag,
         label: label,
         leading: leading,
         tintColor: tintColor,
         inkColor: inkColor,
         semanticsLabel: semanticsLabel,
       );

  const CatchChip.selectable({
    Key? key,
    required String label,
    required bool selected,
    required ValueChanged<bool> onChanged,
    CatchContractFieldConstraints? contract,
    String? contractValue,
    String? contractExemption,
    bool enabled = true,
    Widget? leading,
    Color? accent,
    String? semanticsLabel,
  }) : this._(
         key: key,
         variant: _CatchChipVariant.selectable,
         label: label,
         leading: leading,
         selected: selected,
         onChanged: onChanged,
         contract: contract,
         contractValue: contractValue,
         contractExemption: contractExemption,
         enabled: enabled,
         accent: accent,
         semanticsLabel: semanticsLabel,
       );

  const CatchChip.activity({
    Key? key,
    required ActivityKind activityKind,
    CatchChipEmphasis emphasis = CatchChipEmphasis.soft,
    String? label,
    VoidCallback? onTap,
    bool enabled = true,
    String? semanticsLabel,
  }) : this._(
         key: key,
         variant: _CatchChipVariant.activity,
         activityKind: activityKind,
         emphasis: emphasis,
         label: label,
         onTap: onTap,
         enabled: enabled,
         semanticsLabel: semanticsLabel,
       );

  const CatchChip.removable({
    Key? key,
    required String label,
    required VoidCallback onRemove,
    bool enabled = true,
    Widget? leading,
    Color? tintColor,
    Color? inkColor,
    String? semanticsLabel,
  }) : this._(
         key: key,
         variant: _CatchChipVariant.removable,
         label: label,
         leading: leading,
         onRemove: onRemove,
         enabled: enabled,
         tintColor: tintColor,
         inkColor: inkColor,
         semanticsLabel: semanticsLabel,
       );

  const CatchChip._({
    super.key,
    required this._variant,
    this._label,
    this._leading,
    this._selected = false,
    this._enabled = true,
    this._accent,
    this._tintColor,
    this._inkColor,
    this._activityKind,
    this._emphasis = CatchChipEmphasis.soft,
    this._onChanged,
    this._onTap,
    this._onRemove,
    this._semanticsLabel,
    this._contract,
    this._contractValue,
    this._contractExemption,
  });

  final _CatchChipVariant _variant;
  final String? _label;
  final Widget? _leading;
  final bool _selected;
  final bool _enabled;
  final Color? _accent;
  final Color? _tintColor;
  final Color? _inkColor;
  final ActivityKind? _activityKind;
  final CatchChipEmphasis _emphasis;
  final ValueChanged<bool>? _onChanged;
  final VoidCallback? _onTap;
  final VoidCallback? _onRemove;
  final String? _semanticsLabel;
  final CatchContractFieldConstraints? _contract;
  final String? _contractValue;
  final String? _contractExemption;

  /// Visible label for tag, selectable, and removable chips, or the optional
  /// label override for an activity chip.
  String? get label => _label;

  Widget? get leading => _leading;

  /// Parent-owned selection state. This is meaningful only for
  /// [CatchChip.selectable].
  bool get selected => _selected;

  bool get enabled => _enabled;
  Color? get accent => _accent;
  Color? get tintColor => _tintColor;
  Color? get inkColor => _inkColor;
  ActivityKind? get activityKind => _activityKind;
  CatchChipEmphasis get emphasis => _emphasis;
  ValueChanged<bool>? get onChanged => _onChanged;
  VoidCallback? get onTap => _onTap;
  VoidCallback? get onRemove => _onRemove;
  String? get semanticsLabel => _semanticsLabel;
  String? get contractExemption => _contractExemption;

  @override
  State<CatchChip> createState() => _CatchChipState();
}

class _CatchChipState extends State<CatchChip> {
  static const double _pressedScale = 0.97;

  bool _pressed = false;

  bool get _hasControlRole => switch (widget._variant) {
    _CatchChipVariant.selectable || _CatchChipVariant.removable => true,
    _CatchChipVariant.activity => widget._onTap != null,
    _CatchChipVariant.tag => false,
  };

  bool get _interactive => _hasControlRole && widget._enabled;

  VoidCallback? get _onPressed {
    if (!_interactive) return null;
    return switch (widget._variant) {
      _CatchChipVariant.selectable => () => widget._onChanged!(
        !widget._selected,
      ),
      _CatchChipVariant.activity => widget._onTap,
      _CatchChipVariant.removable => widget._onRemove,
      _CatchChipVariant.tag => null,
    };
  }

  @override
  void didUpdateWidget(CatchChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_interactive) _pressed = false;
  }

  void _setPressed(bool value) {
    if (!_interactive || value == _pressed) return;
    setState(() => _pressed = value);
  }

  Color _inkForFill(CatchTokens tokens, Color fill) {
    if (fill == tokens.primary) return tokens.primaryInk;
    return ThemeData.estimateBrightnessForColor(fill) == Brightness.dark
        ? CatchTokens.editorialWhite
        : CatchTokens.editorialBlack;
  }

  @override
  Widget build(BuildContext context) {
    final allowedContractValues =
        widget._contract?.enumValues ?? widget._contract?.itemEnumValues;
    assert(
      widget._contract == null ||
          widget._contractValue == null ||
          allowedContractValues == null ||
          allowedContractValues.contains(widget._contractValue),
      'CatchChip.selectable value must be allowed by its contract.',
    );
    final t = CatchTokens.of(context);
    final activityKind = widget._activityKind;
    final activity = activityKind == null
        ? null
        : ActivityPalette.resolve(context, activityKind);
    final label = widget._label ?? activity!.label;
    final radius = BorderRadius.circular(CatchRadius.pill);
    final duration = MediaQuery.maybeOf(context)?.disableAnimations == true
        ? Duration.zero
        : CatchMotion.fast;

    late final Color background;
    late final Color foreground;
    late final Color border;
    late final List<BoxShadow> shadow;
    late final Widget? leading;
    late final TextStyle textStyle;
    late final EdgeInsetsGeometry padding;

    switch (widget._variant) {
      case _CatchChipVariant.tag:
      case _CatchChipVariant.removable:
        final hasTint = widget._tintColor != null;
        background = widget._tintColor ?? t.surface;
        foreground = widget._inkColor ?? t.ink;
        border = hasTint ? Colors.transparent : t.line2;
        shadow = CatchElevation.none;
        leading = widget._leading;
        textStyle = CatchTextStyles.labelL(context, color: foreground);
        padding = const EdgeInsets.symmetric(
          horizontal: CatchSpacing.micro14,
          vertical: CatchSpacing.s2,
        );
        break;
      case _CatchChipVariant.selectable:
        final accent = widget._accent ?? t.primary;
        background = widget._selected ? accent : t.surface;
        foreground = widget._selected ? _inkForFill(t, accent) : t.ink;
        border = widget._selected ? Colors.transparent : t.line2;
        shadow = widget._selected
            ? CatchElevation.segmentedSelected(t)
            : CatchElevation.none;
        leading = widget._leading;
        textStyle = CatchTextStyles.labelL(context, color: foreground);
        padding = const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s4,
          vertical: CatchSpacing.micro10,
        );
        break;
      case _CatchChipVariant.activity:
        final solid = widget._emphasis == CatchChipEmphasis.solid;
        background = solid ? activity!.accent : activity!.soft;
        foreground = solid
            ? _inkForFill(t, activity.accent)
            : Theme.of(context).brightness == Brightness.dark
            ? activity.accent
            : activity.deep;
        border = Colors.transparent;
        shadow = CatchElevation.none;
        leading = Icon(activity.glyph);
        textStyle = CatchTextStyles.fieldRowTitle(
          context,
          color: foreground,
        ).copyWith(height: 1);
        padding = const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s4,
          vertical: CatchSpacing.micro10,
        );
        break;
    }

    final trailing = widget._variant == _CatchChipVariant.removable
        ? Icon(CatchIcons.closeRounded, color: foreground, size: CatchIcon.sm)
        : null;
    final iconSize = widget._variant == _CatchChipVariant.activity
        ? CatchLayout.activityChipIconSize
        : CatchIcon.sm;
    final iconGap = widget._variant == _CatchChipVariant.activity
        ? CatchLayout.activityChipIconGap
        : CatchSpacing.s2;

    final content = Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            IconTheme(
              data: IconThemeData(color: foreground, size: iconSize),
              child: leading,
            ),
            SizedBox(width: iconGap),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: CatchSpacing.s2),
            trailing,
          ],
        ],
      ),
    );

    final surface = AnimatedContainer(
      duration: duration,
      curve: CatchMotion.standardCurve,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(color: border),
        boxShadow: shadow,
      ),
      child: _hasControlRole
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                excludeFromSemantics: true,
                onTap: _onPressed,
                onHighlightChanged: _setPressed,
                borderRadius: radius,
                hoverColor: foreground.withValues(
                  alpha: CatchOpacity.controlOverlayHover,
                ),
                focusColor: foreground.withValues(
                  alpha: CatchOpacity.controlOverlayHover,
                ),
                splashColor: foreground.withValues(
                  alpha: CatchOpacity.controlOverlayPressed,
                ),
                highlightColor: foreground.withValues(
                  alpha: CatchOpacity.controlOverlayPressed,
                ),
                child: content,
              ),
            )
          : content,
    );

    final chip = AnimatedScale(
      scale: _interactive && _pressed ? _pressedScale : 1,
      duration: duration,
      curve: CatchMotion.standardCurve,
      child: AnimatedOpacity(
        opacity: _hasControlRole && !widget._enabled
            ? CatchOpacity.disabledControl
            : CatchOpacity.visible,
        duration: duration,
        curve: CatchMotion.standardCurve,
        child: surface,
      ),
    );

    final defaultSemanticsLabel = widget._variant == _CatchChipVariant.removable
        ? '${MaterialLocalizations.of(context).deleteButtonTooltip}: $label'
        : label;

    return Semantics(
      container: true,
      excludeSemantics: true,
      button: _hasControlRole ? true : null,
      selected: widget._variant == _CatchChipVariant.selectable
          ? widget._selected
          : null,
      enabled: _hasControlRole ? widget._enabled : null,
      label: widget._semanticsLabel ?? defaultSemanticsLabel,
      onTap: _onPressed,
      child: chip,
    );
  }
}
