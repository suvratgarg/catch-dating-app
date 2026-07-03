import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:flutter/material.dart';

/// Shared host event picker row for date/time/location-style selections.
class HostPickerTile extends StatelessWidget {
  const HostPickerTile({
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
    final displayValue = value;
    final hasValue = displayValue != null && displayValue.isNotEmpty;
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
              hasValue ? displayValue : placeholder,
              style: hasValue
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
