import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart'
    show CatchContractConstraints, CatchContractFieldConstraints;

/// Design-system `OptionCard` (`components/core/OptionCard`): a selectable choice
/// card with a leading check/circle, a [title], and a one-line [description].
/// Selected = ink border + faint ink wash + filled check. The descriptive
/// counterpart to `Chip` / `SelectChip` — for mutually-exclusive choices that
/// each need a sentence (admission presets, cancellation policy). Stack in a
/// column.
class CatchOptionCard extends StatefulWidget {
  const CatchOptionCard({
    super.key,
    required this.title,
    this.contract,
    this.contractValue,
    this.contractExemption,
    this.description,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final CatchContractFieldConstraints? contract;
  final String? contractValue;
  final String? contractExemption;
  final String? description;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<CatchOptionCard> createState() => _CatchOptionCardState();
}

class _CatchOptionCardState extends State<CatchOptionCard> {
  bool _focused = false;

  @override
  void didUpdateWidget(CatchOptionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onTap == null) _focused = false;
  }

  @override
  Widget build(BuildContext context) {
    final allowedContractValues = widget.contract?.enumValues;
    assert(
      widget.contract == null ||
          widget.contractValue == null ||
          allowedContractValues == null ||
          allowedContractValues.contains(widget.contractValue),
      'CatchOptionCard value must be allowed by its contract.',
    );
    final t = CatchTokens.of(context);

    return CatchSurface(
      onTap: widget.onTap,
      onFocusChange: (focused) {
        if (_focused != focused) setState(() => _focused = focused);
      },
      tone: CatchSurfaceTone.transparent,
      backgroundColor: widget.selected
          ? Color.alphaBlend(
              t.ink.withValues(alpha: CatchOpacity.controlOverlayHover),
              t.surface,
            )
          : t.surface,
      borderSpec: _focused
          ? CatchBorder.resolve(t, CatchBorderRole.focus)
          : widget.selected
          ? CatchBorder.resolve(t, CatchBorderRole.selected)
          : CatchBorder.interactive(t, CatchInteractiveBorderState.resting),
      radius: CatchRadius.md,
      padding: CatchInsets.tileContentCompact,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: CatchStroke.hairline),
            child: Icon(
              widget.selected ? CatchIcons.checkCircle : CatchIcons.circle,
              size: CatchIcon.lg,
              color: widget.selected ? t.ink : t.ink3,
            ),
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: CatchTextStyles.labelL(context)),
                if (widget.description != null &&
                    widget.description!.isNotEmpty) ...[
                  const SizedBox(height: CatchSpacing.micro3),
                  Text(
                    widget.description!,
                    style: CatchTextStyles.supporting(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
