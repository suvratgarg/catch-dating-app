import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(16, 12, 16, 4),
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return CatchSurface(
      margin: margin,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      backgroundColor: palette.surface,
      borderColor: palette.border,
      radius: CatchRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: CatchTextStyles.labelS(
              context,
              color: palette.textMuted,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
          gapH12,
          child,
        ],
      ),
    );
  }
}
