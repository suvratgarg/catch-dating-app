// ignore_for_file: prefer_initializing_formals

import 'dart:ui';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:flutter/material.dart';

class CatchPersonAvatarItem {
  const CatchPersonAvatarItem({required this.name, this.imageUrl, this.initials});

  final String name;
  final String? imageUrl;
  final String? initials;
}

enum CatchPersonAvatarShape { circle, square }

/// Circular avatar used across roster lists, chat threads, swipe cards, and
/// the match modal.
///
/// **Photo state**: if [imageUrl] is supplied it is loaded via
/// [CatchNetworkImage]; otherwise a deterministic gradient placeholder is
/// rendered from [name].
///
/// **Border ring**: set [borderWidth] > 0 and [borderColor] to render a
/// coloured ring — white (2 px) for stacked rows, orange for match state.
///
/// **Status dot**: pass [showStatusDot] = true to render a 9 px green dot at
/// the bottom-right (online indicator).
///
/// **Overflow bubble**: use the named constructor [CatchPersonAvatar.count] to show
/// a "+N" bubble instead of a photo (end of a stacked avatar row).
///
/// Usage:
/// ```dart
/// // Ordinary avatar
/// CatchPersonAvatar(size: 40, name: 'Riya', imageUrl: user.photoUrl)
///
/// // Stacked (white border)
/// CatchPersonAvatar(size: 32, name: 'Riya', borderWidth: 2, borderColor: Colors.white)
///
/// // Match ring
/// CatchPersonAvatar(size: 72, name: 'Riya', borderWidth: 3, borderColor: t.primary)
///
/// // Overflow
/// CatchPersonAvatar.count(size: 32, count: 19, borderWidth: 2, borderColor: Colors.white)
/// ```
class CatchPersonAvatar extends StatelessWidget {
  const CatchPersonAvatar({
    super.key,
    required this.size,
    this.name = '',
    this.imageUrl,
    this.initials,
    this.borderWidth = 0,
    this.borderColor,
    this.showStatusDot = false,
    this.obscured = false,
    this.shape = CatchPersonAvatarShape.circle,
  }) : _count = null;

  /// Overflow avatar — shows "+[count]" instead of a photo.
  const CatchPersonAvatar.count({
    super.key,
    required this.size,
    // Keep the public argument as `count`; `this._count` would expose a
    // private-looking parameter name to callers.
    required int count,
    this.borderWidth = 0,
    this.borderColor,
  }) : _count = count,
       name = '',
       imageUrl = null,
       initials = null,
       showStatusDot = false,
       obscured = false,
       shape = CatchPersonAvatarShape.circle;

  final double size;
  final String name;
  final String? imageUrl;
  final String? initials;
  final double borderWidth;

  /// The ring / stacking border colour. Defaults to transparent when null.
  final Color? borderColor;
  final bool showStatusDot;
  final bool obscured;
  final CatchPersonAvatarShape shape;
  final int? _count;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final innerSize = size - borderWidth * 2;

    Widget avatar;

    if (_count != null) {
      // Overflow bubble — quiet raised fill with secondary ink.
      avatar = _shell(
        size: innerSize,
        child: ColoredBox(
          color: t.raised,
          child: Center(
            child: Text(
              '+$_count',
              style: CatchTextStyles.avatarCount(
                context,
                size: innerSize * 0.30,
                color: t.ink2,
              ),
            ),
          ),
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = _shell(
        size: innerSize,
        child: _obscureIfNeeded(
          child: CatchNetworkImage(
            imageUrl!,
            errorBuilder: (_, _, _) =>
                _GradientPlaceholder(name: name, size: innerSize),
          ),
        ),
      );
    } else {
      avatar = _shell(
        size: innerSize,
        child: _obscureIfNeeded(
          child: _InitialsPlaceholder(
            name: name,
            initials: initials,
            size: innerSize,
          ),
        ),
      );
    }

    // Wrap with border ring if requested
    if (borderWidth > 0) {
      avatar = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: shape == CatchPersonAvatarShape.circle
              ? BoxShape.circle
              : BoxShape.rectangle,
          borderRadius: shape == CatchPersonAvatarShape.square
              ? BorderRadius.circular(CatchRadius.md)
              : null,
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
    final sized = SizedBox.square(dimension: size, child: child);
    return switch (shape) {
      CatchPersonAvatarShape.circle => ClipOval(child: sized),
      CatchPersonAvatarShape.square => ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.md),
        child: sized,
      ),
    };
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

class CatchPersonAvatarStack extends StatelessWidget {
  const CatchPersonAvatarStack({
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
    this.veiledCount = 0,
    this.activityKind = ActivityKind.openActivity,
  });

  final List<CatchPersonAvatarItem> items;
  final int? totalCount;
  final double size;
  final double overlap;
  final double borderWidth;
  final Color? borderColor;
  final int limit;
  final bool obscured;
  final bool showOverflowCount;
  final int veiledCount;
  final ActivityKind activityKind;

  @override
  Widget build(BuildContext context) {
    final shown = items.take(limit).toList();
    final count = totalCount ?? items.length;
    final remainingSlots = (limit - shown.length).clamp(0, limit).toInt();
    final shownVeiledCount = veiledCount.clamp(0, remainingSlots).toInt();
    final visibleCount = shown.length + shownVeiledCount;
    final overflow = count - visibleCount;
    final avatars = <Widget>[
      for (final item in shown)
        CatchPersonAvatar(
          size: size,
          name: item.name,
          imageUrl: item.imageUrl,
          initials: item.initials,
          borderWidth: borderWidth,
          borderColor: borderColor ?? CatchTokens.of(context).surface,
          obscured: obscured,
        ),
      for (var i = 0; i < shownVeiledCount; i++)
        _VeiledPersonAvatar(
          size: size,
          activityKind: activityKind,
          borderWidth: borderWidth,
          borderColor: borderColor ?? CatchTokens.of(context).surface,
        ),
      if (showOverflowCount && overflow > 0)
        CatchPersonAvatar.count(
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

class _VeiledPersonAvatar extends StatelessWidget {
  const _VeiledPersonAvatar({
    required this.size,
    required this.activityKind,
    required this.borderWidth,
    required this.borderColor,
  });

  final double size;
  final ActivityKind activityKind;
  final double borderWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, activityKind);
    final innerSize = size - borderWidth * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor),
      padding: EdgeInsets.all(borderWidth),
      child: ClipOval(
        child: ColoredBox(
          color: activity.soft,
          child: Center(
            child: Icon(
              CatchIcons.personOutlined,
              size: innerSize * 0.38,
              color: activity.deep.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }
}

class _InitialsPlaceholder extends StatelessWidget {
  const _InitialsPlaceholder({
    required this.name,
    required this.initials,
    required this.size,
  });

  final String name;
  final String? initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final label = initials ?? _initialsOf(name);

    return Stack(
      fit: StackFit.expand,
      children: [
        _GradientPlaceholder(name: name, size: size),
        if (label.isNotEmpty)
          Center(
            child: Text(
              label,
              style: CatchTextStyles.avatarCount(
                context,
                size: size * 0.29,
                color: CatchTokens.editorialLight,
              ),
            ),
          ),
      ],
    );
  }
}

String _initialsOf(String value) {
  final parts = value
      .trim()
      .split(RegExp(r'[\s\-_]+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) {
    final word = parts.first;
    return word.characters.take(2).toString().toUpperCase();
  }
  return parts
      .take(2)
      .map((part) => part.characters.first)
      .join()
      .toUpperCase();
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
