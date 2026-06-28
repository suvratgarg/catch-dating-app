import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class DashboardSectionStateCard extends StatelessWidget {
  const DashboardSectionStateCard({
    super.key,
    required this.message,
    this.isLoading = false,
  });

  final String message;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: Row(
        children: [
          if (isLoading)
            CatchSkeleton.box(
              width: CatchIcon.md,
              height: CatchIcon.md,
              radius: CatchRadius.sm,
            )
          else
            Icon(
              CatchIcons.errorOutlineRounded,
              color: t.primary,
              size: CatchIcon.md,
            ),
          gapW10,
          Expanded(
            child: Text(
              message,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
