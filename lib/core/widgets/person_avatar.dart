import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Circular avatar used across roster lists, chat threads, swipe cards, and
/// the match modal.
///
/// **Photo state**: if [imageUrl] is supplied it is loaded via [Image.network];
/// otherwise a deterministic gradient placeholder is rendered from [name].
///
/// **Border ring**: set [borderWidth] > 0 and [borderColor] to render a
/// coloured ring — white (2 px) for stacked rows, orange for match state.
///
/// **Status dot**: pass [showStatusDot] = true to render a 9 px green dot at
/// the bottom-right (online indicator).
///
/// **Overflow bubble**: use the named constructor [PersonAvatar.count] to show
/// a "+N" bubble instead of a photo (end of a stacked avatar row).
///
/// Usage:
/// ```dart
/// // Ordinary avatar
/// PersonAvatar(size: 40, name: 'Riya', imageUrl: user.photoUrl)
///
/// // Stacked (white border)
/// PersonAvatar(size: 32, name: 'Riya', borderWidth: 2, borderColor: Colors.white)
///
/// // Match ring
/// PersonAvatar(size: 72, name: 'Riya', borderWidth: 3, borderColor: t.primary)
///
/// // Overflow
/// PersonAvatar.count(size: 32, count: 19, borderWidth: 2, borderColor: Colors.white)
/// ```
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.size,
    this.name = '',
    this.imageUrl,
    this.borderWidth = 0,
    this.borderColor,
    this.showStatusDot = false,
  }) : _count = null;

  /// Overflow avatar — shows "+[count]" instead of a photo.
  const PersonAvatar.count({
    super.key,
    required this.size,
    required int count,
    this.borderWidth = 0,
    this.borderColor,
  }) : _count = count,
       name = '',
       imageUrl = null,
       showStatusDot = false;

  final double size;
  final String name;
  final String? imageUrl;
  final double borderWidth;

  /// The ring / stacking border colour. Defaults to transparent when null.
  final Color? borderColor;
  final bool showStatusDot;
  final int? _count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final innerSize = size - borderWidth * 2;

    Widget avatar;

    if (_count != null) {
      // Overflow bubble — dark fill, white text
      avatar = _shell(
        size: innerSize,
        child: ColoredBox(
          color: t.ink,
          child: Center(
            child: Text(
              '+$_count',
              style: TextStyle(
                fontSize: innerSize * 0.30,
                fontWeight: FontWeight.w700,
                color: t.surface,
                height: 1,
              ),
            ),
          ),
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = _shell(
        size: innerSize,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              _GradientPlaceholder(name: name, size: innerSize),
        ),
      );
    } else {
      avatar = _shell(
        size: innerSize,
        child: _GradientPlaceholder(name: name, size: innerSize),
      );
    }

    // Wrap with border ring if requested
    if (borderWidth > 0) {
      avatar = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: borderColor ?? Colors.transparent,
        ),
        padding: EdgeInsets.all(borderWidth),
        child: avatar,
      );
    }

    if (!showStatusDot) return avatar;

    // Online status dot (bottom-right)
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                shape: BoxShape.circle,
                border: Border.all(color: t.surface, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clips the child into a circle at [size].
  Widget _shell({required double size, required Widget child}) {
    return ClipOval(
      child: SizedBox.square(dimension: size, child: child),
    );
  }
}

// ── Gradient placeholder ──────────────────────────────────────────────────────

/// Deterministic gradient placeholder derived from [name] — matches the
/// `avatarGrad()` logic in primitives.jsx.
class _GradientPlaceholder extends StatelessWidget {
  const _GradientPlaceholder({required this.name, required this.size});

  final String name;
  final double size;

  static const _palettes = [
    [Color(0xFFFF8A5B), Color(0xFFFF3E6F)],
    [Color(0xFF6B8CFF), Color(0xFFA3E4FF)],
    [Color(0xFFFFCE54), Color(0xFFFF7846)],
    [Color(0xFF2E8F6B), Color(0xFF9AD469)],
    [Color(0xFFA86BFF), Color(0xFFFF6BC7)],
    [Color(0xFF1F3A4D), Color(0xFF6B9BB8)],
    [Color(0xFFE74F3B), Color(0xFFFFA26E)],
    [Color(0xFF4B3A2E), Color(0xFFB68A5F)],
    [Color(0xFF0F2F2F), Color(0xFF3EA89B)],
    [Color(0xFFC24B2C), Color(0xFFF2B06E)],
    [Color(0xFF2C3E50), Color(0xFF7FAFCE)],
    [Color(0xFFD48A2D), Color(0xFFF6D27A)],
  ];

  int _hash() {
    int h = 0;
    for (final c in name.codeUnits) {
      h = (h * 31 + c) & 0xFFFFFFFF;
    }
    return h;
  }

  // Gradient begin/end pairs, one per palette entry for variety.
  static const _begins = [
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.centerLeft,
    Alignment.topLeft,
    Alignment.bottomLeft,
    Alignment.topRight,
    Alignment.topLeft,
    Alignment.topCenter,
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.centerLeft,
  ];

  @override
  Widget build(BuildContext context) {
    final h = _hash();
    final idx = h % _palettes.length;
    final pair = _palettes[idx];
    final begin = _begins[idx];
    final end = begin == Alignment.topLeft
        ? Alignment.bottomRight
        : begin == Alignment.topRight
        ? Alignment.bottomLeft
        : Alignment.bottomCenter;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: begin, end: end, colors: pair),
      ),
    );
  }
}
