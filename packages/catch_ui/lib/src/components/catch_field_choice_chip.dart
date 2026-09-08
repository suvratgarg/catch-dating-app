import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_chip.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:flutter/material.dart';

class CatchFieldChoiceChip extends StatefulWidget {
  const CatchFieldChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.multi,
    required this.enabled,
    required this.onPressed,
    this.accent,
  });

  final String label;
  final bool selected;
  final bool multi;
  final bool enabled;
  final VoidCallback onPressed;
  final Color? accent;

  @override
  State<CatchFieldChoiceChip> createState() => _CatchFieldChoiceChipState();
}

class _CatchFieldChoiceChipState extends State<CatchFieldChoiceChip> {
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: widget.enabled,
    checked: widget.selected,
    inMutuallyExclusiveGroup: !widget.multi,
    label: widget.label,
    onTap: widget.enabled ? widget.onPressed : null,
    child: ExcludeSemantics(
      child: CatchChip.selectable(
        key: ValueKey('catch-field-choice-${widget.label}'),
        label: widget.label,
        selected: widget.selected,
        enabled: widget.enabled,
        accent: widget.accent,
        leading: widget.multi && widget.selected
            ? Icon(
                CatchIcons.checkRounded,
                size: CatchFieldTokens.chipSelectedGlyphExtent,
              )
            : null,
        semanticsLabel: widget.label,
        onChanged: (_) => widget.onPressed(),
      ),
    ),
  );
}
