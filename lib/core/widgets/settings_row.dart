import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Settings-style row with icon, label, optional value, trailing widget, and
/// danger mode — used 13+ times in the settings screen and reusable for any
/// settings or action-list surface.
///
/// Usage:
/// ```dart
/// SettingsRow(
///   label: 'Phone', value: '+91 9876543210',
///   icon: CatchIcons.phoneOutlined, onTap: () {...},
/// )
/// SettingsRow(
///   label: 'Delete account', icon: CatchIcons.deleteOutline,
///   danger: true, onTap: _confirmDelete,
/// )
/// SettingsRow(
///   label: 'Show me on map', icon: CatchIcons.mapOutlined,
///   trailing: Switch(...),
/// )
/// ```
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  final String label;
  final IconData icon;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = danger ? t.primary : t.ink;

    final child = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.micro14,
        vertical: CatchLayout.settingsRowVerticalPadding,
      ),
      child: Row(
        children: [
          Icon(icon, color: danger ? t.primary : t.ink2, size: CatchIcon.row),
          gapW12,
          Expanded(
            child: Text(
              label,
              style: CatchTextStyles.bodyLead(
                context,
                color: color,
              ).copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null)
            trailing!
          else ...[
            if (value != null) ...[
              gapW12,
              Expanded(
                child: Text(
                  value!,
                  textAlign: TextAlign.right,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            if (onTap != null) ...[
              gapW6,
              Icon(CatchIcons.chevronRightRounded, color: t.ink3),
            ],
          ],
        ],
      ),
    );

    return Material(
      color: t.surface.withValues(alpha: CatchOpacity.none),
      child: InkWell(onTap: onTap, child: child),
    );
  }
}
