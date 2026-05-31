import 'dart:ui';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class PersonAvatarItem {
  const PersonAvatarItem({required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;
}

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
    this.obscured = false,
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
       showStatusDot = false,
       obscured = false;

  final double size;
  final String name;
  final String? imageUrl;
  final double borderWidth;

  /// The ring / stacking border colour. Defaults to transparent when null.
  final Color? borderColor;
  final bool showStatusDot;
  final bool obscured;
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
              style: CatchTextStyles.avatarCount(
                context,
                size: innerSize * 0.30,
                color: t.surface,
              ),
            ),
          ),
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = _shell(
        size: innerSize,
        child: _obscureIfNeeded(
          child: Image.network(
            imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) =>
                _GradientPlaceholder(name: name, size: innerSize),
          ),
        ),
      );
    } else {
      avatar = _shell(
        size: innerSize,
        child: _obscureIfNeeded(
          child: _GradientPlaceholder(name: name, size: innerSize),
        ),
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
              width: CatchLayout.avatarStatusDotExtent,
              height: CatchLayout.avatarStatusDotExtent,
              decoration: BoxDecoration(
                color: t.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.surface,
                  width: CatchStroke.underline,
                ),
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

  Widget _obscureIfNeeded({required Widget child}) {
    if (!obscured) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: Transform.scale(scale: 1.16, child: child),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: CatchTokens.editorialDark.withValues(
              alpha: CatchOpacity.avatarPhotoScrim,
            ),
          ),
        ),
      ],
    );
  }
}

class PersonAvatarStack extends StatelessWidget {
  const PersonAvatarStack({
    super.key,
    required this.items,
    this.totalCount,
    this.size = 32,
    this.overlap = 9,
    this.borderWidth = 2,
    this.borderColor,
    this.limit = 4,
    this.obscured = false,
    this.showOverflowCount = true,
  });

  final List<PersonAvatarItem> items;
  final int? totalCount;
  final double size;
  final double overlap;
  final double borderWidth;
  final Color? borderColor;
  final int limit;
  final bool obscured;
  final bool showOverflowCount;

  @override
  Widget build(BuildContext context) {
    final shown = items.take(limit).toList();
    final count = totalCount ?? items.length;
    final overflow = count - shown.length;
    final avatars = <Widget>[
      for (final item in shown)
        PersonAvatar(
          size: size,
          name: item.name,
          imageUrl: item.imageUrl,
          borderWidth: borderWidth,
          borderColor: borderColor ?? CatchTokens.of(context).surface,
          obscured: obscured,
        ),
      if (showOverflowCount && overflow > 0)
        PersonAvatar.count(
          size: size,
          count: overflow,
          borderWidth: borderWidth,
          borderColor: borderColor ?? CatchTokens.of(context).surface,
        ),
    ];
    if (avatars.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: size,
      width: size + (avatars.length - 1) * (size - overlap),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < avatars.length; i++)
            Positioned(left: i * (size - overlap), child: avatars[i]),
        ],
      ),
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

  static final _palettes = () {
    final kinds = ActivityKind.values;
    final palette = ActivityPalette.light;
    return List.generate(12, (i) {
      final a = palette.forKind(kinds[i % kinds.length]);
      final b = palette.forKind(kinds[(i + 5) % kinds.length]);
      return [a.accent, b.accent];
    });
  }();

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
