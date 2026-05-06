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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: palette.textSecondary, size: 15),
            gapW6,
            Text(
              text,
              style: CatchTextStyles.labelL(
                context,
                color: palette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
