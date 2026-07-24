import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart'
    show CatchContractConstraints, CatchContractFieldConstraints;

/// Design-system `OptionCard` (`components/core/OptionCard`): a selectable choice
/// card with a leading check/circle, a [title], and a one-line [description].
/// Selected = ink border + faint ink wash + filled check. The descriptive
/// counterpart to `Chip` / `SelectChip` — for mutually-exclusive choices that
/// each need a sentence (admission presets, cancellation policy). Stack in a
/// column.
class CatchOptionCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final allowedContractValues = contract?.enumValues;
    assert(
      contract == null ||
          contractValue == null ||
          allowedContractValues == null ||
          allowedContractValues.contains(contractValue),
      'CatchOptionCard value must be allowed by its contract.',
    );
    final t = CatchTokens.of(context);

    return CatchSurface(
      onTap: onTap,
      tone: CatchSurfaceTone.transparent,
      backgroundColor: selected
          ? Color.alphaBlend(
              t.ink.withValues(alpha: CatchOpacity.controlOverlayHover),
              t.surface,
            )
          : t.surface,
      borderColor: selected ? t.ink : t.line2,
      borderWidth: CatchStroke.underline,
      radius: CatchRadius.md,
      padding: CatchInsets.tileContentCompact,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: CatchStroke.hairline),
            child: Icon(
              selected ? CatchIcons.checkCircle : CatchIcons.circle,
              size: CatchIcon.lg,
              color: selected ? t.ink : t.ink3,
            ),
          ),
          const SizedBox(width: CatchSpacing.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CatchTextStyles.labelL(context)),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: CatchSpacing.micro3),
                  Text(
                    description!,
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
