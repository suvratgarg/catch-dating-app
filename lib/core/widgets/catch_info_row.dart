import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:flutter/material.dart';

enum CatchInfoRowTrailing { none, chevron, toggle }

/// Handoff `CatchInfoRow`: on-surface inline or stacked list row.
class CatchInfoRow extends StatelessWidget {
  const CatchInfoRow({
    super.key,
    this.icon,
    required this.label,
    this.caption,
    this.value,
    this.trailing = CatchInfoRowTrailing.none,
    this.toggleValue = false,
    this.onToggleChanged,
    this.add = false,
    this.danger = false,
    this.divider = false,
    this.onTap,
  });

  final IconData? icon;
  final String label;
  final String? caption;
  final String? value;
  final CatchInfoRowTrailing trailing;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final bool add;
  final bool danger;
  final bool divider;
  final VoidCallback? onTap;

  CatchInfoRow copyWith({bool? divider}) {
    return CatchInfoRow(
      key: key,
      icon: icon,
      label: label,
      caption: caption,
      value: value,
      trailing: trailing,
      toggleValue: toggleValue,
      onToggleChanged: onToggleChanged,
      add: add,
      danger: danger,
      divider: divider ?? this.divider,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final stacked = caption != null && caption!.trim().isNotEmpty;
    final labelColor = danger
        ? t.danger
        : add
        ? t.primary
        : t.ink;
    final row = Stack(
      children: [
        if (divider)
          Positioned(
            top: 0,
            left: icon != null ? CatchIcon.control + CatchSpacing.s3 : 0,
            right: 0,
            child: ColoredBox(
              color: t.line.withValues(alpha: CatchOpacity.infoRowDivider),
              child: const SizedBox(height: CatchStroke.hairline),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: CatchLayout.infoRowVerticalPadding,
          ),
          child: Row(
            crossAxisAlignment: stacked
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: EdgeInsets.only(
                    top: stacked ? CatchStroke.hairline : 0,
                  ),
                  child: Icon(
                    icon,
                    size: CatchIcon.control,
                    color: danger ? t.danger : t.ink2,
                  ),
                ),
                gapW12,
              ],
              Expanded(
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            caption!,
                            style: CatchTextStyles.fieldLabel(
                              context,
                              color: t.ink3,
                            ),
                          ),
                          gapH2,
                          Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.infoRowTitle(
                              context,
                              color: labelColor,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        add ? '+ $label' : label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.infoRowTitle(
                          context,
                          color: labelColor,
                        ),
                      ),
              ),
              if (value != null && value!.trim().isNotEmpty) ...[
                gapW12,
                Flexible(
                  child: Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: CatchTextStyles.mono(context, color: t.ink),
                  ),
                ),
              ],
              if (trailing == CatchInfoRowTrailing.toggle) ...[
                gapW12,
                CatchToggle(
                  value: toggleValue,
                  onChanged: onToggleChanged,
                  semanticLabel: label,
                ),
              ] else if (trailing == CatchInfoRowTrailing.chevron) ...[
                gapW6,
                Padding(
                  padding: EdgeInsets.only(top: stacked ? CatchSpacing.s1 : 0),
                  child: Icon(
                    CatchIcons.chevronRightRounded,
                    size: CatchIcon.control,
                    color: t.ink3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
