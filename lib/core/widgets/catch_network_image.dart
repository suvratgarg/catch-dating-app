import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Canonical network-image primitive — the single seam every remote image in
/// the app renders through.
///
/// Drop-in for [Image.network] (same positional URL + `fit`/`width`/`height`/
/// `errorBuilder`/`loadingBuilder`), but it additionally:
/// - **decode-sizes**: derives `cacheWidth`/`cacheHeight` from the explicit
///   size or, failing that, caps decode at the screen width, so large source
///   images are not decoded at full resolution (memory + jank win);
/// - **fails gracefully**: supplies a neutral branded fallback when no
///   `errorBuilder` is given;
/// - keeps Flutter's in-memory [ImageCache] keyed by URL + decode size.
///
/// Callers that need circular/rounded framing keep wrapping this in their
/// existing `ClipRRect`/`ClipOval` — this widget only owns image loading.
class CatchNetworkImage extends StatelessWidget {
  const CatchNetworkImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
    this.loadingBuilder,
    this.cacheWidth,
    this.cacheHeight,
    this.semanticLabel,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final ImageErrorWidgetBuilder? errorBuilder;
  final ImageLoadingBuilder? loadingBuilder;
  final String? semanticLabel;

  /// Explicit decode-width override (logical px before DPR scaling).
  final int? cacheWidth;

  /// Explicit decode-height override (logical px before DPR scaling).
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    if (_isBundledAsset(url)) {
      return Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
        errorBuilder:
            errorBuilder ??
            (context, error, stack) => const CatchNetworkImageFallback(),
      );
    }

    final media = MediaQuery.maybeOf(context);
    final dpr = media?.devicePixelRatio ?? 1.0;
    final screenWidth = media?.size.width;

    int? scaled(double? logical) =>
        (logical != null && logical.isFinite && logical > 0)
        ? (logical * dpr).round()
        : null;

    // Prefer an explicit override, then the laid-out size, then a screen-width
    // cap so a full-bleed image never decodes beyond what can be shown.
    final decodeWidth = cacheWidth ?? scaled(width) ?? scaled(screenWidth);

    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: decodeWidth,
      cacheHeight: cacheHeight ?? scaled(height),
      semanticLabel: semanticLabel,
      errorBuilder:
          errorBuilder ??
          (context, error, stack) => const CatchNetworkImageFallback(),
      loadingBuilder: loadingBuilder,
    );
  }

  static bool _isBundledAsset(String url) {
    final trimmed = url.trim();
    return trimmed.startsWith('assets/') || trimmed.startsWith('packages/');
  }
}

class CatchNetworkImageFallback extends StatelessWidget {
  const CatchNetworkImageFallback({
    super.key,
    this.backgroundColor,
    this.iconColor,
    this.icon,
    this.iconSize = CatchIcon.md,
  });

  final Color? backgroundColor;
  final Color? iconColor;
  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ColoredBox(
      color: backgroundColor ?? t.surface,
      child: Center(
        child: Icon(
          icon ?? CatchIcons.imageOutlined,
          color: iconColor ?? t.ink3,
          size: iconSize,
        ),
      ),
    );
  }
}
