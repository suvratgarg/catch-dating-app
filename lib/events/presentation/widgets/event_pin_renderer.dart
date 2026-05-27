import 'dart:async';
import 'dart:ui' as ui;

import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tile_data.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

/// Custom map pin spec. Encapsulates everything needed to render a single
/// chip pin: a short time label, the relationship status that drives the
/// tint, and whether the pin is currently selected.
@immutable
class EventPinSpec {
  const EventPinSpec({
    required this.timeLabel,
    required this.status,
    required this.selected,
  });

  final String timeLabel;
  final EventTileStatus status;
  final bool selected;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventPinSpec &&
          other.timeLabel == timeLabel &&
          other.status == status &&
          other.selected == selected;

  @override
  int get hashCode => Object.hash(timeLabel, status, selected);
}

class _PinPalette {
  const _PinPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

/// Time-chip map pin renderer.
///
/// Renders a small rounded-rect chip with the event start time inside, plus
/// a triangular anchor tail pointing at the pin coordinate. Tinted by
/// relationship status (joined event = filled brand, discoverable =
/// surface with brand border, saved = solid ink, etc.) so the user can read
/// the map at a glance.
///
/// Rendering happens off the UI thread via `Picture.toImage`. Bitmap results
/// are cached on a static map keyed by [(EventPinSpec, devicePixelRatio)]
/// so the same pin is never rasterised twice. Caches are bounded — entries
/// are evicted in insertion order when the cache exceeds [_maxCacheEntries].
class EventPinRenderer {
  EventPinRenderer._();

  static const int _maxCacheEntries = 256;
  static final Map<_CacheKey, gmaps.BitmapDescriptor> _cache =
      <_CacheKey, gmaps.BitmapDescriptor>{};
  static final Map<_CacheKey, Future<gmaps.BitmapDescriptor>> _inflight =
      <_CacheKey, Future<gmaps.BitmapDescriptor>>{};
  static final Map<_ClusterCacheKey, gmaps.BitmapDescriptor> _clusterCache =
      <_ClusterCacheKey, gmaps.BitmapDescriptor>{};
  static final Map<_ClusterCacheKey, Future<gmaps.BitmapDescriptor>>
  _clusterInflight = <_ClusterCacheKey, Future<gmaps.BitmapDescriptor>>{};

  static Future<gmaps.BitmapDescriptor> render({
    required EventPinSpec spec,
    required double devicePixelRatio,
  }) {
    final key = _CacheKey(spec, devicePixelRatio);
    final cached = _cache[key];
    if (cached != null) return Future.value(cached);
    final inflight = _inflight[key];
    if (inflight != null) return inflight;

    final future = _renderRaw(spec: spec, devicePixelRatio: devicePixelRatio);
    _inflight[key] = future;
    future
        .then((descriptor) {
          if (_cache.length >= _maxCacheEntries) {
            _cache.remove(_cache.keys.first);
          }
          _cache[key] = descriptor;
        })
        .whenComplete(() => _inflight.remove(key));
    return future;
  }

  /// Anchor for [gmaps.Marker.anchor] given the chip pin shape — bottom-
  /// centre of the pin lines up with the geographic point.
  static const Offset anchor = Offset(0.5, 1.0);
  static const Offset clusterAnchor = Offset(0.5, 0.5);

  static Future<gmaps.BitmapDescriptor> renderCluster({
    required int count,
    required double devicePixelRatio,
  }) {
    final key = _ClusterCacheKey(count, devicePixelRatio);
    final cached = _clusterCache[key];
    if (cached != null) return Future.value(cached);
    final inflight = _clusterInflight[key];
    if (inflight != null) return inflight;

    final future = _renderClusterRaw(
      count: count,
      devicePixelRatio: devicePixelRatio,
    );
    _clusterInflight[key] = future;
    future
        .then((descriptor) {
          if (_clusterCache.length >= _maxCacheEntries) {
            _clusterCache.remove(_clusterCache.keys.first);
          }
          _clusterCache[key] = descriptor;
        })
        .whenComplete(() => _clusterInflight.remove(key));
    return future;
  }

  static Future<gmaps.BitmapDescriptor> _renderRaw({
    required EventPinSpec spec,
    required double devicePixelRatio,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final palette = _paletteFor(spec.status);
    final scale = devicePixelRatio;

    // Layout text first so the chip width follows the label.
    final textPainter = TextPainter(
      text: TextSpan(
        text: spec.timeLabel,
        style: TextStyle(
          color: palette.foreground,
          fontSize: 13 * scale,
          fontWeight: FontWeight.w700,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 200 * scale);
    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    final hPad = 12.0 * scale;
    final vPad = 7.0 * scale;
    final tailHeight = 8.0 * scale;
    final tailHalfWidth = 6.0 * scale;
    final selectionScale = spec.selected ? 1.12 : 1.0;
    final width = (textWidth + hPad * 2) * selectionScale;
    final height = (textHeight + vPad * 2) * selectionScale;
    final totalHeight = height + tailHeight;

    if (spec.selected) {
      final shadowPaint = ui.Paint()
        ..color = const Color.fromRGBO(26, 20, 16, 0.18)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 5 * scale);
      canvas.drawRRect(
        ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(0, 2 * scale, width, height),
          ui.Radius.circular(height / 2),
        ),
        shadowPaint,
      );
    }

    final chipPath = ui.Path()
      ..addRRect(
        ui.RRect.fromRectAndRadius(
          ui.Rect.fromLTWH(0, 0, width, height),
          ui.Radius.circular(height / 2),
        ),
      )
      ..moveTo(width / 2 - tailHalfWidth, height)
      ..lineTo(width / 2, height + tailHeight)
      ..lineTo(width / 2 + tailHalfWidth, height)
      ..close();

    final bgPaint = ui.Paint()
      ..color = palette.background
      ..style = ui.PaintingStyle.fill;
    canvas.drawPath(chipPath, bgPaint);

    final borderPaint = ui.Paint()
      ..color = palette.border
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = spec.selected ? 2.5 * scale : 1.5 * scale;
    canvas.drawPath(chipPath, borderPaint);

    textPainter.paint(
      canvas,
      ui.Offset(
        (width - textPainter.width) / 2,
        (height - textPainter.height) / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.ceil(), totalHeight.ceil());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    textPainter.dispose();
    image.dispose();
    picture.dispose();
    if (byteData == null) {
      return gmaps.BitmapDescriptor.defaultMarker;
    }
    return gmaps.BitmapDescriptor.bytes(
      byteData.buffer.asUint8List(),
      width: width / scale,
      height: totalHeight / scale,
    );
  }

  static Future<gmaps.BitmapDescriptor> _renderClusterRaw({
    required int count,
    required double devicePixelRatio,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final scale = devicePixelRatio;
    final size = 42.0 * scale;
    final radius = size / 2;
    final label = count > 99 ? '99+' : count.toString();

    final shadowPaint = ui.Paint()
      ..color = const Color.fromRGBO(26, 20, 16, 0.18)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 5 * scale);
    canvas.drawCircle(
      ui.Offset(radius, radius + 2 * scale),
      radius,
      shadowPaint,
    );

    final bgPaint = ui.Paint()
      ..color = const Color(0xFFFF4E1F)
      ..style = ui.PaintingStyle.fill;
    canvas.drawCircle(ui.Offset(radius, radius), radius, bgPaint);

    final ringPaint = ui.Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.5 * scale;
    canvas.drawCircle(ui.Offset(radius, radius), radius - scale, ringPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: const Color(0xFFFFFFFF),
          fontSize: 14 * scale,
          fontWeight: FontWeight.w800,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size);
    textPainter.paint(canvas, ui.Offset(0, (size - textPainter.height) / 2));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.ceil(), size.ceil());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    textPainter.dispose();
    image.dispose();
    picture.dispose();
    if (byteData == null) {
      return gmaps.BitmapDescriptor.defaultMarker;
    }
    return gmaps.BitmapDescriptor.bytes(
      byteData.buffer.asUint8List(),
      width: size / scale,
      height: size / scale,
    );
  }

  static _PinPalette _paletteFor(EventTileStatus status) {
    return switch (status) {
      // Joined / hosted — bold filled brand pill.
      EventTileStatus.joined || EventTileStatus.hosted => const _PinPalette(
        background: Color(0xFFFF4E1F),
        foreground: Color(0xFFFFFFFF),
        border: Color(0xFFB8350F),
      ),
      // Saved — dark filled chip with light text.
      EventTileStatus.saved => const _PinPalette(
        background: Color(0xFF1A1410),
        foreground: Color(0xFFFFFFFF),
        border: Color(0xFF1A1410),
      ),
      // Waitlisted / full — warning tint.
      EventTileStatus.waitlisted || EventTileStatus.full => const _PinPalette(
        background: Color(0xFFFFE2D4),
        foreground: Color(0xFFB8350F),
        border: Color(0xFFB8350F),
      ),
      // Past / ineligible / cancelled — muted (rarely shown on map but
      // covered for completeness).
      EventTileStatus.past ||
      EventTileStatus.ineligible ||
      EventTileStatus.cancelled => const _PinPalette(
        background: Color(0xFFEFE7DD),
        foreground: Color(0xFF7C6B5A),
        border: Color(0xFF7C6B5A),
      ),
      EventTileStatus.attended => const _PinPalette(
        background: Color(0xFF2F7D45),
        foreground: Color(0xFFFFFFFF),
        border: Color(0xFF205A30),
      ),
      // Default — surface chip with brand outline. Recommended and open use
      // the same map treatment intentionally: pins signal geography, not
      // curation.
      EventTileStatus.recommended || EventTileStatus.open => const _PinPalette(
        background: Color(0xFFFFFFFF),
        foreground: Color(0xFFFF4E1F),
        border: Color(0xFFFF4E1F),
      ),
    };
  }
}

@immutable
class _CacheKey {
  const _CacheKey(this.spec, this.devicePixelRatio);
  final EventPinSpec spec;
  final double devicePixelRatio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CacheKey &&
          other.spec == spec &&
          other.devicePixelRatio == devicePixelRatio;

  @override
  int get hashCode => Object.hash(spec, devicePixelRatio);
}

@immutable
class _ClusterCacheKey {
  const _ClusterCacheKey(this.count, this.devicePixelRatio);

  final int count;
  final double devicePixelRatio;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ClusterCacheKey &&
          other.count == count &&
          other.devicePixelRatio == devicePixelRatio;

  @override
  int get hashCode => Object.hash(count, devicePixelRatio);
}
