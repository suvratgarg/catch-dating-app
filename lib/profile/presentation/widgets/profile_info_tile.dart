import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    final row = Row(
      children: [
        Icon(icon, color: t.ink2),
        gapW16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: CatchTextStyles.bodyS(context)),
              Text(value, style: CatchTextStyles.bodyL(context)),
            ],
          ),
        ),
        if (onTap != null)
          Icon(Icons.chevron_right, color: t.ink3, size: 20),
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.p10),
        child: row,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CatchRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Sizes.p10),
        child: row,
      ),
    );
  }
}
