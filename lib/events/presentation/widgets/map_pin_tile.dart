import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:flutter/material.dart';

class MapPinTile extends StatelessWidget {
  const MapPinTile({
    super.key,
    required this.startingPoint,
    required this.onTap,
    this.selectedLabel,
    this.enabled = true,
  });

  final LocationCoordinate? startingPoint;
  final VoidCallback onTap;
  final String? selectedLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasPin = startingPoint != null;
    final label = _trimToNull(selectedLabel);
    final title = hasPin ? label ?? 'Pinned location' : 'Choose on map';
    final foregroundColor = enabled
        ? hasPin
              ? t.primary
              : t.ink2
        : t.ink3;

    return CatchControlShell(
      onTap: enabled ? onTap : null,
      tone: hasPin ? CatchControlTone.surface : CatchControlTone.raised,
      enabled: enabled,
      focused: hasPin,
      padding: CatchControlMetrics.contentPadding(CatchControlSize.md),
      semanticButton: true,
      child: Row(
        children: [
          Icon(
            hasPin ? Icons.edit_location_alt_outlined : Icons.map_outlined,
            size: 20,
            color: foregroundColor,
          ),
          gapW12,
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.bodyLead(context, color: foregroundColor),
            ),
          ),
          Icon(
            hasPin ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
            size: 18,
            color: foregroundColor,
          ),
        ],
      ),
    );
  }
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
