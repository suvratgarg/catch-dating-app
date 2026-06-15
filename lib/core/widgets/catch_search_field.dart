import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:flutter/material.dart';

/// Handoff `SearchField`: raised pill input with search glyph and quiet clear
/// target.
class CatchSearchField extends StatefulWidget {
  const CatchSearchField({
    super.key,
    this.value = '',
    this.placeholder = 'Search',
    this.onChanged,
    this.autofocus = false,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.onFocusChanged,
    this.semanticLabel,
    this.emptyTrailingIcon,
    this.emptyTrailingTooltip,
    this.onEmptyTrailingPressed,
  });

  final String value;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;
  final String? semanticLabel;
  final IconData? emptyTrailingIcon;
  final String? emptyTrailingTooltip;
  final VoidCallback? onEmptyTrailingPressed;

  @override
  State<CatchSearchField> createState() => _CatchSearchFieldState();
}

class _CatchSearchFieldState extends State<CatchSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant CatchSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
    setState(() {});
  }

  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    _focusNode.unfocus();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      label: widget.semanticLabel ?? widget.placeholder,
      textField: true,
      child: CatchControlShell(
        size: CatchControlSize.compact,
        shape: CatchControlShape.pill,
        tone: CatchControlTone.raised,
        enabled: widget.enabled,
        focused: _focusNode.hasFocus,
        padding: const EdgeInsets.only(
          left: CatchSpacing.s4,
          right: CatchSpacing.s2,
        ),
        child: Row(
          children: [
            Icon(
              CatchIcons.search,
              size: CatchLayout.searchFieldIconSize,
              color: t.ink3,
            ),
            const SizedBox(width: CatchLayout.searchFieldIconGap),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                onSubmitted: _handleSubmitted,
                onTapOutside: (_) => _focusNode.unfocus(),
                style: CatchTextStyles.bodyM(
                  context,
                  color: widget.enabled ? t.ink : t.ink3,
                ),
                cursorColor: t.primary,
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.placeholder,
                  hintStyle: CatchTextStyles.bodyM(context, color: t.ink3),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) {
                  if (widget.emptyTrailingIcon != null &&
                      widget.onEmptyTrailingPressed != null) {
                    return SizedBox.square(
                      dimension: CatchLayout.searchFieldClearSize,
                      child: IconButton(
                        tooltip:
                            widget.emptyTrailingTooltip ?? widget.placeholder,
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(
                          widget.emptyTrailingIcon,
                          size: CatchLayout.searchFieldClearIconSize,
                          color: t.ink3,
                        ),
                        onPressed: widget.enabled
                            ? widget.onEmptyTrailingPressed
                            : null,
                      ),
                    );
                  }

                  return const SizedBox(
                    width: CatchLayout.searchFieldClearSize,
                  );
                }

                return SizedBox.square(
                  dimension: CatchLayout.searchFieldClearSize,
                  child: IconButton(
                    tooltip: 'Clear ${widget.placeholder}',
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      CatchIcons.clearCircle,
                      size: CatchLayout.searchFieldClearIconSize,
                      color: t.ink3,
                    ),
                    onPressed: widget.enabled ? _clear : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
