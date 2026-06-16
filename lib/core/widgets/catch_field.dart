import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CatchFieldMode { edit, read, nav, toggle }

enum CatchFieldEmphasis { value, label }

/// Design-system `Field` (`components/core/Field`): the unified row primitive —
/// input · read · nav · toggle · control, in one component (the convergence of
/// `CatchTextField` / `InfoRow` / settings rows). The caption [label] floats on
/// focus while empty and parks on top once filled; [icon] (+ [iconColor])
/// top-aligns with it; [leadingUnit] is a value-aligned unit (₹/@/+91). Edit
/// mode delegates to a bare [CatchTextField] so validation/keyboard/autofill are
/// preserved. Stack them in a [CatchFieldGroup] for the hairline-divided card.
class CatchField extends StatefulWidget {
  const CatchField({
    super.key,
    this.label,
    this.value,
    this.mode,
    this.emphasis = CatchFieldEmphasis.value,
    this.icon,
    this.iconColor,
    this.leadingUnit,
    this.trailing,
    this.showChevron = false,
    this.placeholder,
    this.toggled = false,
    this.onToggle,
    this.control,
    this.add = false,
    this.error,
    this.valid = false,
    this.divider = false,
    this.tint = true,
    this.onTap,
    // Edit-mode delegation (passed through to the bare CatchTextField).
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
  });

  final String? label;
  final String? value;
  final CatchFieldMode? mode;
  final CatchFieldEmphasis emphasis;
  final IconData? icon;
  final Color? iconColor;
  final String? leadingUnit;
  final Widget? trailing;
  final bool showChevron;
  final String? placeholder;
  final bool toggled;
  final ValueChanged<bool>? onToggle;

  /// A control (Stepper / Chips / OptionCards) revealed on tap; the value shows
  /// as text at rest.
  final Widget? control;
  final bool add;
  final String? error;
  final bool valid;
  final bool divider;
  final bool tint;
  final VoidCallback? onTap;

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;

  @override
  State<CatchField> createState() => _CatchFieldState();
}

class _CatchFieldState extends State<CatchField> {
  bool _focused = false;
  bool _open = false;

  CatchFieldMode get _mode =>
      widget.mode ??
      (widget.onChanged != null || widget.controller != null
          ? CatchFieldMode.edit
          : widget.onToggle != null
          ? CatchFieldMode.toggle
          : (widget.showChevron || widget.onTap != null)
          ? CatchFieldMode.nav
          : CatchFieldMode.read);

  bool get _hasValue => widget.value != null && widget.value!.isNotEmpty;
  bool get _hasControl => widget.control != null;
  bool get _hasError => widget.error != null && widget.error!.isNotEmpty;
  bool get _active => _focused || _open;
  bool get _isEdit => _mode == CatchFieldMode.edit;
  bool get _labelPrimary => widget.emphasis == CatchFieldEmphasis.label;

  /// A value-less read/nav/toggle row — the label IS the primary text (InfoRow).
  bool get _inline =>
      !_isEdit && !_hasControl && !_hasValue && !_open && !_labelPrimary;

  bool get _floated => !_isEdit || _hasValue || _active;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final background = widget.tint && _active
        ? Color.alphaBlend(
            t.ink.withValues(alpha: CatchOpacity.controlOverlayHover),
            t.surface,
          )
        : Colors.transparent;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(CatchRadius.interactiveTile),
        boxShadow: widget.tint && _active ? CatchElevation.card : null,
      ),
      child: Stack(
        children: [
          if (widget.divider && !_active)
            Positioned(
              top: 0,
              left: CatchSpacing.s4,
              right: CatchSpacing.s4,
              child: ColoredBox(
                color: t.line,
                child: const SizedBox(height: CatchStroke.hairline),
              ),
            ),
          widget.add ? _buildAdd(t) : _buildRow(t),
          if (_hasError)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  CatchSpacing.s12,
                  0,
                  CatchSpacing.s4,
                  CatchSpacing.micro10,
                ),
                child: Row(
                  children: [
                    Icon(
                      CatchIcons.errorOutlineRounded,
                      size: CatchIcon.xs,
                      color: t.danger,
                    ),
                    const SizedBox(width: CatchSpacing.micro6),
                    Expanded(
                      child: Text(
                        widget.error!,
                        style: CatchTextStyles.fieldLabel(
                          context,
                          color: t.danger,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAdd(CatchTokens t) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(CatchRadius.interactiveTile),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s4,
          vertical: CatchSpacing.micro14,
        ),
        child: Row(
          children: [
            Icon(widget.icon ?? CatchIcons.add, size: CatchIcon.md, color: t.primary),
            const SizedBox(width: CatchSpacing.s3),
            Text(
              widget.label ?? '',
              style: CatchTextStyles.titleS(context, color: t.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(CatchTokens t) {
    final clickable = _hasControl || (widget.onTap != null && !_isEdit);
    final bottomPadding = _hasError ? CatchSpacing.s8 : CatchSpacing.micro14;

    return InkWell(
      onTap: clickable
          ? () {
              if (_hasControl) setState(() => _open = !_open);
              widget.onTap?.call();
            }
          : null,
      borderRadius: BorderRadius.circular(CatchRadius.interactiveTile),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          CatchSpacing.s4,
          CatchSpacing.micro14,
          CatchSpacing.s4,
          bottomPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.icon != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: CatchSpacing.micro2),
                child: Icon(
                  widget.icon,
                  size: CatchIcon.md,
                  color: widget.iconColor ?? (_focused ? t.ink : t.ink2),
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
            ],
            Expanded(child: _buildBody(t)),
            ..._buildTrailing(t),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CatchTokens t) {
    final labelInPlace = _inline || _labelPrimary;
    return Padding(
      padding: EdgeInsets.only(top: labelInPlace ? 0 : CatchSpacing.s4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.label != null && widget.label!.isNotEmpty)
            labelInPlace
                ? Text(
                    widget.label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _labelPrimary
                        ? CatchTextStyles.infoRowTitle(
                            context,
                            color: _hasError ? t.danger : t.ink,
                          )
                        : CatchTextStyles.bodyM(
                            context,
                            color: _hasError ? t.danger : t.ink,
                          ),
                  )
                : AnimatedPositioned(
                    duration: CatchMotion.fast,
                    curve: CatchMotion.standardCurve,
                    left: 0,
                    top: _floated ? 0 : CatchSpacing.s4,
                    child: Text(
                      widget.label!,
                      style: _floated
                          ? CatchTextStyles.fieldLabel(
                              context,
                              color: _hasError
                                  ? t.danger
                                  : _focused
                                  ? t.ink
                                  : t.ink3,
                            )
                          : CatchTextStyles.bodyM(context, color: t.ink3),
                    ),
                  ),
          _buildContent(t),
        ],
      ),
    );
  }

  Widget _buildContent(CatchTokens t) {
    if (_isEdit) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (widget.leadingUnit != null) ...[
            Text(
              widget.leadingUnit!,
              style: CatchTextStyles.titleS(context, color: t.ink2),
            ),
            const SizedBox(width: CatchSpacing.s1),
          ],
          Expanded(
            child: CatchTextField(
              label: widget.label ?? '',
              showLabel: false,
              variant: CatchTextFieldVariant.bare,
              controller: widget.controller,
              initialValue: widget.initialValue,
              hintText: widget.placeholder,
              onChanged: widget.onChanged,
              onFocusChanged: (f) => setState(() => _focused = f),
              validator: widget.validator,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              inputFormatters: widget.inputFormatters,
              autofillHints: widget.autofillHints,
              obscureText: widget.obscureText,
              readOnly: widget.readOnly,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
            ),
          ),
        ],
      );
    }

    if (_open && _hasControl) {
      return Padding(
        padding: const EdgeInsets.only(top: CatchSpacing.s1),
        child: widget.control,
      );
    }

    if (_labelPrimary) {
      return _hasValue
          ? Padding(
              padding: const EdgeInsets.only(top: CatchSpacing.micro2),
              child: Text(
                widget.value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.fieldLabel(context),
              ),
            )
          : const SizedBox.shrink();
    }

    if (_inline) return const SizedBox.shrink();

    return Text(
      _hasValue ? widget.value! : (widget.placeholder ?? ''),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _hasValue
          ? CatchTextStyles.infoRowTitle(context)
          : CatchTextStyles.bodyM(context, color: t.ink3),
    );
  }

  List<Widget> _buildTrailing(CatchTokens t) {
    final top = const SizedBox(width: CatchSpacing.s2);
    if (widget.valid && !_hasError) {
      return [
        top,
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro3),
          child: Icon(
            CatchIcons.checkCircle,
            size: CatchIcon.md,
            color: t.success,
          ),
        ),
      ];
    }
    if (_mode == CatchFieldMode.toggle) {
      return [
        top,
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro2),
          child: CatchToggle(value: widget.toggled, onChanged: widget.onToggle),
        ),
      ];
    }
    if (_hasControl) {
      return [
        top,
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro3),
          child: AnimatedRotation(
            turns: _open ? 0.5 : 0,
            duration: CatchMotion.fast,
            child: Icon(
              CatchIcons.expandMoreRounded,
              size: CatchIcon.control,
              color: _active ? t.ink : t.ink3,
            ),
          ),
        ),
      ];
    }
    if (_mode == CatchFieldMode.nav) {
      return [
        top,
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro3),
          child: Icon(
            CatchIcons.chevronRightRounded,
            size: CatchIcon.control,
            color: t.ink3,
          ),
        ),
      ];
    }
    if (widget.trailing != null) {
      return [
        top,
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro2),
          child: widget.trailing!,
        ),
      ];
    }
    return const [];
  }
}

/// Design-system `FieldGroup`: stacks [CatchField]s into a hairline-divided
/// surface card (the on-surface row group). Injects an inset top divider on each
/// field after the first.
class CatchFieldGroup extends StatelessWidget {
  const CatchFieldGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line2,
      radius: CatchRadius.md,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++)
            if (i == 0)
              children[i]
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: t.line)),
                ),
                child: children[i],
              ),
        ],
      ),
    );
  }
}
