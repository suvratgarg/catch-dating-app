import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:flutter/material.dart';

class ProfileInfoChip extends StatelessWidget {
  const ProfileInfoChip({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.chipFill,
        borderRadius: BorderRadius.circular(CatchRadius.pill),
        border: Border.all(color: palette.chipBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 260),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: palette.textSecondary, size: 14),
              gapW6,
              Flexible(
                child: Text(
                  text,
                  style: CatchTextStyles.labelL(
                    context,
                    color: palette.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
