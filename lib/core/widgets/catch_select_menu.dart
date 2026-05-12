import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchSelectMenuSize { compact, md }

enum CatchSelectMenuShape { rounded, pill }

class CatchSelectMenu<T> extends StatefulWidget {
  const CatchSelectMenu({
    super.key,
    required this.values,
    required this.itemLabel,
    this.value,
    this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.enabled = true,
    this.hasError = false,
    this.size = CatchSelectMenuSize.md,
    this.shape = CatchSelectMenuShape.rounded,
    this.semanticLabel,
  });

  final List<T> values;
  final String Function(T item) itemLabel;
  final T? value;
  final String? hintText;
  final Widget? prefixIcon;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final bool hasError;
  final CatchSelectMenuSize size;
  final CatchSelectMenuShape shape;
  final String? semanticLabel;

  @override
  State<CatchSelectMenu<T>> createState() => _CatchSelectMenuState<T>();
}

class _CatchSelectMenuState<T> extends State<CatchSelectMenu<T>> {
  final _controller = MenuController();
  late final FocusNode _focusNode;

  bool get _canOpen =>
      widget.enabled && widget.onChanged != null && widget.values.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final triggerBorderRadius = BorderRadius.circular(_triggerRadius);
    final menuBorderRadius = BorderRadius.circular(CatchRadius.sm);

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasBoundedWidth = constraints.hasBoundedWidth;
        final menuWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : null;

        return MenuAnchor(
          controller: _controller,
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(t.surface),
            elevation: const WidgetStatePropertyAll(8),
            shadowColor: WidgetStatePropertyAll(t.overlay),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: menuBorderRadius),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: CatchSpacing.s1),
            ),
          ),
          menuChildren: [
            for (final item in widget.values)
              SizedBox(
                width: menuWidth,
                child: MenuItemButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size(0, _itemHeight)),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
                    ),
                    foregroundColor: WidgetStatePropertyAll(t.ink),
                    backgroundColor: WidgetStatePropertyAll(
                      item == widget.value ? t.primarySoft : Colors.transparent,
                    ),
                    overlayColor: WidgetStatePropertyAll(t.primarySoft),
                    textStyle: WidgetStatePropertyAll(
                      CatchTextStyles.bodyM(context, color: t.ink),
                    ),
                  ),
                  trailingIcon: item == widget.value
                      ? Icon(
                          Icons.check_rounded,
                          color: t.primary,
                          size: CatchIcon.sm,
                        )
                      : null,
                  onPressed: () {
                    widget.onChanged?.call(item);
                    _controller.close();
                  },
                  child: Text(
                    widget.itemLabel(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
          builder: (context, controller, child) {
            return Semantics(
              button: true,
              enabled: _canOpen,
              label: widget.semanticLabel,
              value: _valueLabel,
              child: Focus(
                focusNode: _focusNode,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: triggerBorderRadius,
                  child: InkWell(
                    onTap: _canOpen
                        ? () {
                            _focusNode.requestFocus();
                            controller.isOpen
                                ? controller.close()
                                : controller.open();
                          }
                        : null,
                    borderRadius: triggerBorderRadius,
                    child: AnimatedContainer(
                      duration: CatchMotion.fast,
                      curve: CatchMotion.standardCurve,
                      height: _height,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: widget.enabled ? t.surface : t.raised,
                        borderRadius: triggerBorderRadius,
                        border: Border.all(color: _borderColor(t), width: 1.5),
                        boxShadow: _focusNode.hasFocus && !widget.hasError
                            ? [
                                BoxShadow(
                                  color: t.primarySoft,
                                  blurRadius: 0,
                                  spreadRadius: 3,
                                ),
                              ]
                            : CatchElevation.none,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.prefixIcon != null) ...[
                            IconTheme(
                              data: IconThemeData(
                                color: t.ink3,
                                size: CatchIcon.md,
                              ),
                              child: widget.prefixIcon!,
                            ),
                            const SizedBox(width: CatchSpacing.s2),
                          ],
                          if (hasBoundedWidth)
                            Expanded(child: _triggerLabel(textColor: t.ink))
                          else
                            _triggerLabel(textColor: t.ink),
                          const SizedBox(width: CatchSpacing.s1),
                          Icon(
                            controller.isOpen
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: CatchIcon.md,
                            color: widget.enabled ? t.ink3 : t.ink3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _triggerLabel({required Color textColor}) {
    return Builder(
      builder: (context) {
        final t = CatchTokens.of(context);
        return Text(
          _valueLabel ?? widget.hintText ?? 'Select',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.bodyL(
            context,
            color: _valueLabel == null ? t.ink3 : textColor,
          ),
        );
      },
    );
  }

  String? get _valueLabel {
    final value = widget.value;
    if (value == null) return null;
    return widget.itemLabel(value);
  }

  double get _height {
    return switch (widget.size) {
      CatchSelectMenuSize.compact => 52,
      CatchSelectMenuSize.md => 56,
    };
  }

  double get _itemHeight {
    return switch (widget.size) {
      CatchSelectMenuSize.compact => 44,
      CatchSelectMenuSize.md => 48,
    };
  }

  double get _triggerRadius {
    return switch (widget.shape) {
      CatchSelectMenuShape.rounded => CatchRadius.sm,
      CatchSelectMenuShape.pill => CatchRadius.pill,
    };
  }

  Color _borderColor(CatchTokens t) {
    if (widget.hasError) return t.danger;
    if (!widget.enabled) return t.line;
    if (_focusNode.hasFocus || _controller.isOpen) return t.primary;
    return t.line2;
  }
}
