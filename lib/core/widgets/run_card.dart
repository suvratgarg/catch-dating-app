import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/core/widgets/status_chip.dart';
import 'package:catch_dating_app/core/widgets/vibe_tag.dart';
import 'package:flutter/material.dart';

// ── Data model ────────────────────────────────────────────────────────────────

/// View-model passed to [RunCard]. Widgets never compute state — the caller
/// builds this from a Firestore [Run] + [RunEligibility].
class RunCardData {
  const RunCardData({
    required this.clubName,
    required this.location,
    required this.dateTime,
    required this.distanceLabel,
    required this.paceLabel,
    required this.attendeeCount,
    required this.capacity,
    required this.price,
    this.spotsLeft,
    this.isFeatured = false,
    this.vibes = const [],
    this.attendeeAvatarUrls = const [],
    this.status = RunStatus.open,
    this.mapWidget,
    this.heroImageUrl,
  });

  final String clubName;
  final String location;

  /// Pre-formatted, e.g. "Today · 6:00 AM" or "Mon 22 Apr · 6:00 AM"
  final String dateTime;
  final String distanceLabel; // "7K"
  final String paceLabel; // "5:30 /km"

  /// Formatted price string: "₹299" or "Free"
  final String price;

  final int attendeeCount;
  final int capacity;

  /// If non-null a flame badge shows "N SPOTS LEFT"
  final int? spotsLeft;

  final bool isFeatured;
  final List<String> vibes;

  /// Up to 4 photo URLs for the stacked avatar row. Falls back to initials.
  final List<String> attendeeAvatarUrls;

  final RunStatus status;

  /// Optional map widget rendered in the photo area (e.g. flutter_map tile).
  /// If null and [heroImageUrl] is also null, a [_MapPlaceholder] is shown.
  final Widget? mapWidget;
  final String? heroImageUrl;
}

// ── Density enum ─────────────────────────────────────────────────────────────

enum RunCardDensity {
  /// Small row inside a club detail page — no photo, just distance badge + when/price.
  compact,

  /// Standard vertical card — map/photo header, roster strip, Join CTA.
  standard,

  /// Full-bleed hero card — large photo area, big title, all detail.
  hero,
}

// ── RunCard ───────────────────────────────────────────────────────────────────

/// Versatile run card rendered at three densities across the app.
///
/// - **compact** — used in [ScreenClubDetail] upcoming list
/// - **standard** — home feed list (default)
/// - **hero** — dashboard next-run hero card
///
/// The card itself is non-interactive; wrap with [GestureDetector] or
/// [InkWell] at the call-site to handle taps.
///
/// Usage:
/// ```dart
/// RunCard(data: runCardData)
/// RunCard(data: runCardData, density: RunCardDensity.compact)
/// RunCard(data: runCardData, density: RunCardDensity.hero, showRoster: true)
/// ```
class RunCard extends StatelessWidget {
  const RunCard({
    super.key,
    required this.data,
    this.density = RunCardDensity.standard,
    this.showPrice = true,
    this.showRoster = true,
    this.onTap,
  });

  final RunCardData data;
  final RunCardDensity density;
  final bool showPrice;
  final bool showRoster;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return switch (density) {
      RunCardDensity.compact => _CompactCard(
        data: data,
        showPrice: showPrice,
        onTap: onTap,
      ),
      RunCardDensity.standard => _StandardCard(
        data: data,
        showPrice: showPrice,
        showRoster: showRoster,
        onTap: onTap,
      ),
      RunCardDensity.hero => _HeroCard(
        data: data,
        showPrice: showPrice,
        showRoster: showRoster,
        onTap: onTap,
      ),
    };
  }
}

// ── Compact variant ───────────────────────────────────────────────────────────

class _CompactCard extends StatelessWidget {
  const _CompactCard({required this.data, required this.showPrice, this.onTap});

  final RunCardData data;
  final bool showPrice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      onTap: onTap,
      radius: CatchRadius.md,
      borderColor: t.line,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Distance badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              data.distanceLabel,
              style: CatchTextStyles.titleL(context, color: t.primary),
            ),
          ),
          const SizedBox(width: 12),
          // When + location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.dateTime, style: CatchTextStyles.titleM(context)),
                const SizedBox(height: 2),
                Text(data.location, style: CatchTextStyles.bodyS(context)),
              ],
            ),
          ),
          if (showPrice)
            Text(
              data.price,
              style: CatchTextStyles.titleM(
                context,
                color: data.price == 'Free' ? t.accent : t.ink,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Standard variant ──────────────────────────────────────────────────────────

class _StandardCard extends StatelessWidget {
  const _StandardCard({
    required this.data,
    required this.showPrice,
    required this.showRoster,
    this.onTap,
  });

  final RunCardData data;
  final bool showPrice;
  final bool showRoster;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      onTap: onTap,
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Photo / map header ──────────────────────────────────────────
          _PhotoHeader(data: data, height: 160),
          // ── Info body ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(CatchSpacing.s4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.clubName,
                        style: CatchTextStyles.titleL(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showPrice) ...[
                      const SizedBox(width: 8),
                      Text(
                        data.price,
                        style: CatchTextStyles.titleM(
                          context,
                          color: data.price == 'Free' ? t.accent : t.ink,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                // Location + time row
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: t.ink2),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        data.location,
                        style: CatchTextStyles.bodyS(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time_rounded, size: 13, color: t.ink2),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        data.dateTime,
                        style: CatchTextStyles.bodyS(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (showRoster) ...[
                  const SizedBox(height: 14),
                  _RosterRow(data: data),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero variant ──────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.data,
    required this.showPrice,
    required this.showRoster,
    this.onTap,
  });

  final RunCardData data;
  final bool showPrice;
  final bool showRoster;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      onTap: onTap,
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhotoHeader(data: data, height: 220),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              16,
              CatchSpacing.s4,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Club + vibe tags
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.clubName,
                        style: CatchTextStyles.displayM(context),
                        maxLines: 2,
                      ),
                    ),
                    if (showPrice) ...[
                      const SizedBox(width: 8),
                      Text(
                        data.price,
                        style: CatchTextStyles.titleL(
                          context,
                          color: data.price == 'Free' ? t.accent : t.ink,
                        ),
                      ),
                    ],
                  ],
                ),
                if (data.vibes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: data.vibes.map((v) => VibeTag(label: v)).toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: t.ink2),
                    const SizedBox(width: 3),
                    Text(
                      data.location,
                      style: CatchTextStyles.bodyM(context, color: t.ink2),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time_rounded, size: 14, color: t.ink2),
                    const SizedBox(width: 3),
                    Text(
                      data.dateTime,
                      style: CatchTextStyles.bodyM(context, color: t.ink2),
                    ),
                  ],
                ),
                if (showRoster) ...[
                  const SizedBox(height: 16),
                  _RosterRow(data: data),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

/// Map/photo header shared by standard + hero cards.
class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.data, required this.height});

  final RunCardData data;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background: custom widget > hero image > map placeholder
          if (data.mapWidget != null)
            data.mapWidget!
          else if (data.heroImageUrl != null)
            Image.network(data.heroImageUrl!, fit: BoxFit.cover)
          else
            _MapPlaceholder(
              dark: Theme.of(context).brightness == Brightness.dark,
            ),

          // Hot badge + dist/pace pill
          Positioned(
            top: 12,
            left: 12,
            child: Wrap(
              spacing: 6,
              children: [
                if (data.spotsLeft != null)
                  CatchBadge(
                    label: '🔥 ${data.spotsLeft} SPOTS LEFT',
                    tone: CatchBadgeTone.solid,
                  ),
                CatchBadge(
                  label: '${data.distanceLabel} · ${data.paceLabel}',
                  tone: CatchBadgeTone.neutral,
                ),
              ],
            ),
          ),

          // Status chip (top-right)
          if (data.status != RunStatus.open)
            Positioned(
              top: 12,
              right: 12,
              child: StatusChip(status: data.status),
            ),

          // Stacked avatars (bottom-right)
          Positioned(
            right: 12,
            bottom: 12,
            child: _StackedAvatars(
              urls: data.attendeeAvatarUrls,
              count: data.attendeeCount,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stacked circular avatars with overflow count — matches the design.
class _StackedAvatars extends StatelessWidget {
  const _StackedAvatars({required this.urls, required this.count});

  final List<String> urls;
  final int count;

  @override
  Widget build(BuildContext context) {
    const size = 30.0;
    const border = 2.0;
    const overlap = 10.0;

    final shown = urls.take(4).toList();
    final overflow = count - shown.length;

    final avatars = <Widget>[
      for (final url in shown)
        PersonAvatar(
          size: size,
          imageUrl: url,
          borderWidth: border,
          borderColor: Colors.white,
        ),
      if (overflow > 0)
        PersonAvatar.count(
          size: size,
          count: overflow,
          borderWidth: border,
          borderColor: Colors.white,
        ),
    ];

    // Stack avatars with negative left margin via Row + SizedBox trick
    return SizedBox(
      height: size,
      width: size + (avatars.length - 1) * (size - overlap),
      child: Stack(
        children: [
          for (var i = 0; i < avatars.length; i++)
            Positioned(left: i * (size - overlap), child: avatars[i]),
        ],
      ),
    );
  }
}

/// Roster strip shown at the bottom of standard + hero cards.
class _RosterRow extends StatelessWidget {
  const _RosterRow({required this.data});
  final RunCardData data;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: CatchTextStyles.bodyS(context),
              children: [
                TextSpan(
                  text: '${data.attendeeCount}/${data.capacity} runners',
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: t.primary,
            borderRadius: BorderRadius.circular(CatchRadius.pill),
          ),
          child: Text(
            'Join →',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: t.primaryInk,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Map placeholder ───────────────────────────────────────────────────────────

/// Stylised static map used when no real map widget or photo is available.
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final landBg = dark ? const Color(0xFF1A2E2A) : const Color(0xFFE8EDE5);
    final water = dark ? const Color(0xFF0F1E2B) : const Color(0xFFCDDDE6);
    final road = dark ? const Color(0xFF2F2A24) : const Color(0xFFFFFFFF);
    final block = dark ? const Color(0xFF2A423D) : const Color(0xFFD5DCC8);
    final t = CatchTokens.of(context);

    return CustomPaint(
      painter: _MapPainter(
        landBg: landBg,
        water: water,
        road: road,
        block: block,
        routeColor: t.primary,
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({
    required this.landBg,
    required this.water,
    required this.road,
    required this.block,
    required this.routeColor,
  });

  final Color landBg, water, road, block, routeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // Land background
    paint.color = landBg;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);

    // Water
    paint.color = water;
    final waterPath = Path()
      ..moveTo(0, h * 0.69)
      ..cubicTo(w * 0.2, h * 0.63, w * 0.4, h * 0.81, w * 0.67, h * 0.75)
      ..lineTo(w, h * 0.81)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(waterPath, paint);

    // Roads
    paint
      ..color = road
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(-10, h * 0.25), Offset(w + 10, h * 0.375), paint);
    paint.strokeWidth = 3;
    canvas.drawLine(Offset(w * 0.27, -10), Offset(w * 0.33, h + 10), paint);
    canvas.drawLine(Offset(w * 0.67, -10), Offset(w * 0.73, h + 10), paint);
    paint.strokeWidth = 2;
    canvas.drawLine(Offset(-10, h * 0.56), Offset(w + 10, h * 0.625), paint);

    // City blocks
    paint
      ..color = block.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    for (final r in [
      Rect.fromLTWH(w * 0.07, h * 0.06, w * 0.17, h * 0.15),
      Rect.fromLTWH(w * 0.40, h * 0.06, w * 0.23, h * 0.25),
      Rect.fromLTWH(w * 0.77, h * 0.06, w * 0.20, h * 0.275),
      Rect.fromLTWH(w * 0.07, h * 0.41, w * 0.17, h * 0.11),
      Rect.fromLTWH(w * 0.77, h * 0.41, w * 0.20, h * 0.14),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(2)),
        paint,
      );
    }

    // Park (green block)
    paint.color = (dark ? const Color(0xFF25413A) : const Color(0xFFCFDCB8))
        .withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.40, h * 0.375, w * 0.23, h * 0.22),
        const Radius.circular(2),
      ),
      paint,
    );

    // Route overlay
    paint
      ..color = routeColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final route = Path()
      ..moveTo(w * 0.13, h * 0.81)
      ..quadraticBezierTo(w * 0.30, h * 0.56, w * 0.47, h * 0.50)
      ..quadraticBezierTo(w * 0.64, h * 0.44, w * 0.83, h * 0.31);
    canvas.drawPath(route, paint);

    // Route endpoints
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.13, h * 0.81), 5, paint);
    paint.color = block;
    canvas.drawCircle(Offset(w * 0.83, h * 0.31), 5, paint);
    paint.color = Colors.white;
    canvas.drawCircle(Offset(w * 0.83, h * 0.31), 3, paint);
  }

  bool get dark => landBg == const Color(0xFF1A2E2A);

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.routeColor != routeColor || old.landBg != landBg;
}
