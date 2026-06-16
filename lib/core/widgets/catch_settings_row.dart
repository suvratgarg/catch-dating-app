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
/// CatchSettingsRow(
///   label: 'Phone', value: '+91 9876543210',
///   icon: CatchIcons.phoneOutlined, onTap: () {...},
/// )
/// CatchSettingsRow(
///   label: 'Delete account', icon: CatchIcons.deleteOutline,
///   danger: true, onTap: _confirmDelete,
/// )
/// CatchSettingsRow(
///   label: 'Show me on map', icon: CatchIcons.mapOutlined,
///   trailing: Switch(...),
/// )
/// ```
class CatchSettingsRow extends StatelessWidget {
  const CatchSettingsRow({
    super.key,
    required this.label,
    required this.icon,
    this.value,
    this.trailing,
    this.onTap,
    this.danger = false,
    this.divider = false,
    this.showChevron,
    this.valueMaxLines = 1,
  });

  final String label;
  final IconData icon;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  final bool divider;
  final bool? showChevron;
  final int valueMaxLines;

  CatchSettingsRow copyWith({bool? divider}) {
    return CatchSettingsRow(
      key: key,
      label: label,
      icon: icon,
      value: value,
      trailing: trailing,
      onTap: onTap,
      danger: danger,
      divider: divider ?? this.divider,
      showChevron: showChevron,
      valueMaxLines: valueMaxLines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = danger ? t.danger : t.ink;
    final shouldShowChevron =
        showChevron ?? (onTap != null && trailing == null && !danger);

    final child = Stack(
      children: [
        if (divider)
          Positioned(
            top: 0,
            left: CatchIcon.row + CatchSpacing.s3,
            right: 0,
            child: ColoredBox(
              color: t.line.withValues(alpha: CatchOpacity.profileInfoDivider),
              child: const SizedBox(height: CatchStroke.hairline),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Icon(
                icon,
                color: danger ? t.danger : t.ink2,
                size: CatchIcon.row,
              ),
              gapW12,
              Expanded(
                child: Text(
                  label,
                  style: CatchTextStyles.infoRowTitle(context, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (value != null && value!.isNotEmpty) ...[
                gapW12,
                Flexible(
                  child: Text(
                    value!,
                    textAlign: TextAlign.right,
                    style: CatchTextStyles.mono(context, color: t.ink),
                    maxLines: valueMaxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (trailing != null) ...[gapW12, trailing!],
              if (shouldShowChevron) ...[
                gapW6,
                Icon(CatchIcons.chevronRightRounded, color: t.ink3, size: 16),
              ],
            ],
          ),
        ),
      ],
    );

    return Material(
      color: t.surface.withValues(alpha: CatchOpacity.none),
      child: InkWell(onTap: onTap, child: child),
    );
  }
}
