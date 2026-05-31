import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:flutter/material.dart';

class PickerTile extends StatelessWidget {
  const PickerTile({
    super.key,
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  final IconData icon;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchControlShell(
      onTap: onTap,
      tone: CatchControlTone.raised,
      padding: CatchControlMetrics.contentPadding(CatchControlSize.md),
      semanticButton: true,
      child: Row(
        children: [
          Icon(icon, size: CatchIcon.control, color: t.ink2),
          gapW12,
          Expanded(
            child: Text(
              value ?? placeholder,
              style: value != null
                  ? CatchTextStyles.bodyLead(context)
                  : CatchTextStyles.bodyLead(context, color: t.ink3),
            ),
          ),
          Icon(
            CatchIcons.chevronRightRounded,
            size: CatchIcon.md,
            color: t.ink3,
          ),
        ],
      ),
    );
  }
}
