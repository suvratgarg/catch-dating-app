import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/locations/shared/catch_google_map.dart';
import 'package:flutter/material.dart';

/// A read-only, attribution-safe Google Maps viewport for compact previews.
///
/// The preview deliberately owns all gesture and map-control configuration so
/// feature call sites cannot accidentally turn a compact map into a second
/// interactive map screen. [enableNetworkTiles] is an explicit deterministic
/// seam for Widgetbook, golden tests, and offline captures.
class CatchMapPreview extends StatelessWidget {
  const CatchMapPreview({
    super.key,
    required this.coordinate,
    required this.fallbackLabel,
    this.markerHue = CatchMapMarkerHue.orange,
    this.enableNetworkTiles = true,
    this.zoom = 15.5,
  });

  final LocationCoordinate? coordinate;
  final String fallbackLabel;
  final CatchMapMarkerHue markerHue;
  final bool enableNetworkTiles;
  final double zoom;

  bool get showsGoogleMap => coordinate != null && enableNetworkTiles;

  @override
  Widget build(BuildContext context) {
    final coordinate = this.coordinate;
    if (coordinate == null || !enableNetworkTiles) {
      final t = CatchTokens.of(context);
      return ColoredBox(
        color: t.bg,
        child: Center(
          child: Padding(
            padding: CatchInsets.content,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CatchIcons.mapOutlined, color: t.ink3, size: CatchIcon.lg),
                if (fallbackLabel.trim().isNotEmpty) ...[
                  gapH6,
                  Text(
                    fallbackLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: CatchTextStyles.supporting(context, color: t.ink3),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      image: true,
      label: fallbackLabel,
      child: IgnorePointer(
        child: CatchGoogleMap(
          initialCenter: coordinate,
          initialZoom: zoom,
          markers: {
            CatchMapMarker(
              id: 'catch-map-preview-location',
              position: coordinate,
              hue: markerHue,
            ),
          },
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: false,
          zoomGesturesEnabled: false,
          tiltGesturesEnabled: false,
          liteModeEnabled: Theme.of(context).platform == TargetPlatform.android,
          // Keep Google's attribution clear of the preview caption, which is
          // rendered outside this viewport by the owning surface.
          padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
        ),
      ),
    );
  }
}
