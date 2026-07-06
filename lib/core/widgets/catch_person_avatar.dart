// ignore_for_file: prefer_initializing_formals

import 'dart:math' as math;
import 'dart:ui';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:flutter/material.dart';

class CatchPersonAvatarItem {
  const CatchPersonAvatarItem({
    required this.name,
    this.imageUrl,
    this.initials,
  });

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
    this.activityKind,
    this.activityDim = false,
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
       shape = CatchPersonAvatarShape.circle,
       activityKind = null,
       activityDim = false;

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
  final ActivityKind? activityKind;
  final bool activityDim;
  final int? _count;

  static String initialsOf(String value) => _initialsOf(value);

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final innerSize = size - borderWidth * 2;

    Widget avatar;

    if (_count != null) {
      // Overflow bubble — quiet raised fill with secondary ink.
      avatar = CatchPersonAvatarShell(
        size: innerSize,
        shape: shape,
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
      final image = CatchNetworkImage(
        imageUrl!,
        errorBuilder: (context, _, _) => CatchInitialsAvatarPlaceholder(
          name: name,
          initials: initials,
          size: innerSize,
        ),
      );
      avatar = CatchPersonAvatarShell(
        size: innerSize,
        shape: shape,
        child: obscured ? CatchObscuredAvatarContent(child: image) : image,
      );
    } else if (activityKind != null) {
      avatar = CatchPersonAvatarShell(
        size: innerSize,
        shape: shape,
        child: CatchActivityInitialsPlaceholder(
          kind: activityKind!,
          initials: initials ?? _initialsOf(name),
          size: innerSize,
          dim: activityDim,
        ),
      );
    } else {
      final placeholder = CatchInitialsAvatarPlaceholder(
        name: name,
        initials: initials,
        size: innerSize,
      );
      avatar = CatchPersonAvatarShell(
        size: innerSize,
        shape: shape,
        child: obscured
            ? CatchObscuredAvatarContent(child: placeholder)
            : placeholder,
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
}

class CatchPersonAvatarShell extends StatelessWidget {
  const CatchPersonAvatarShell({
    super.key,
    required this.size,
    required this.child,
    this.shape = CatchPersonAvatarShape.circle,
  });

  final double size;
  final Widget child;
  final CatchPersonAvatarShape shape;

  @override
  Widget build(BuildContext context) {
    final sized = SizedBox.square(dimension: size, child: child);
    return switch (shape) {
      CatchPersonAvatarShape.circle => ClipOval(child: sized),
      CatchPersonAvatarShape.square => ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.md),
        child: sized,
      ),
    };
  }
}

class CatchObscuredAvatarContent extends StatelessWidget {
  const CatchObscuredAvatarContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
          child: Transform.scale(scale: 1.16, child: child),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: CatchTokens.editorialBlack.withValues(
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
        CatchVeiledPersonAvatar(
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

class CatchVeiledPersonAvatar extends StatelessWidget {
  const CatchVeiledPersonAvatar({
    super.key,
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

class CatchActivityInitialsPlaceholder extends StatelessWidget {
  const CatchActivityInitialsPlaceholder({
    super.key,
    required this.kind,
    required this.initials,
    required this.size,
    this.dim = false,
  });

  final ActivityKind kind;
  final String initials;
  final double size;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, kind);
    final initialsSize = size * CatchLayout.activityAvatarInitialsScale;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: const GradientRotation(150 * math.pi / 180),
              colors: [activity.accent, activity.deep],
            ),
            border: Border.all(
              color: CatchTokens.editorialWhite.withValues(
                alpha: CatchOpacity.activityAvatarInnerRule,
              ),
            ),
          ),
        ),
        CustomPaint(painter: _ActivityAvatarTexturePainter()),
        if (initials.isNotEmpty)
          Center(
            child: Text(
              initials,
              style: CatchFonts.mono(
                fontSize: initialsSize,
                height: 1,
                fontWeight: FontWeight.w700,
                letterSpacing: initialsSize * 0.02,
                color: CatchTokens.editorialWhite,
              ),
            ),
          ),
        if (dim)
          ColoredBox(
            color: CatchTokens.editorialBlack.withValues(
              alpha: CatchOpacity.activityAvatarDim,
            ),
          ),
      ],
    );
  }
}

class _ActivityAvatarTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.activityAvatarPrint,
      )
      ..strokeWidth = CatchLayout.activityAvatarTextureStrokeWidth;
    final stride = CatchLayout.activityAvatarTextureStride;
    for (
      double offset = -size.height;
      offset < size.width + size.height;
      offset += stride
    ) {
      canvas.drawLine(
        Offset(offset, size.height),
        Offset(offset + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ActivityAvatarTexturePainter oldDelegate) =>
      false;
}

class CatchInitialsAvatarPlaceholder extends StatelessWidget {
  const CatchInitialsAvatarPlaceholder({
    super.key,
    required this.name,
    required this.size,
    this.initials,
  });

  final String name;
  final double size;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final label = initials ?? _initialsOf(name);

    // People are paper and ink, never activity pigment.
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: t.primarySoft),
        if (label.isNotEmpty)
          Center(
            child: Text(
              label,
              style: CatchFonts.mono(
                fontSize: size * 0.34,
                height: 1,
                fontWeight: FontWeight.w700,
                color: t.ink2,
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
