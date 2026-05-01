import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class MapPinTile extends StatelessWidget {
  const MapPinTile({
    super.key,
    required this.startingPoint,
    required this.onTap,
  });

  final LatLng? startingPoint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final hasPin = startingPoint != null;
    return CatchSurface(
      onTap: onTap,
      tone: hasPin ? CatchSurfaceTone.primarySoft : CatchSurfaceTone.raised,
      radius: CatchRadius.md,
      borderColor: hasPin ? t.primary : t.line,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Icon(
            hasPin ? Icons.edit_location_alt_outlined : Icons.map_outlined,
            size: 20,
            color: hasPin ? t.primary : t.ink2,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasPin
                  ? '${startingPoint!.latitude.toStringAsFixed(5)}, '
                        '${startingPoint!.longitude.toStringAsFixed(5)}'
                  : 'Pin exact starting point on map',
              style: hasPin
                  ? CatchTextStyles.bodyM(context, color: t.primary)
                  : CatchTextStyles.bodyM(context, color: t.ink3),
            ),
          ),
          Icon(
            hasPin ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
            size: 18,
            color: hasPin ? t.primary : t.ink3,
          ),
        ],
      ),
    );
  }
}
