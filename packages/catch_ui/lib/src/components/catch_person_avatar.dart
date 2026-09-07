// ignore_for_file: prefer_initializing_formals

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_activity_initials_placeholder.dart';
import 'package:catch_ui/src/components/catch_avatar_colors.dart';
import 'package:catch_ui/src/components/catch_avatar_initials.dart';
import 'package:catch_ui/src/components/catch_initials_avatar_placeholder.dart';
import 'package:catch_ui/src/components/catch_obscured_avatar_content.dart';
import 'package:catch_ui/src/components/catch_person_avatar_shape.dart';
import 'package:catch_ui/src/components/catch_person_avatar_shell.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:catch_ui/src/primitives/catch_network_image.dart';
import 'package:flutter/material.dart';

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
/// a caller-labelled count bubble instead of a photo (end of a stacked avatar row).
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
/// CatchPersonAvatar.count(size: 32, count: 19, countLabelBuilder: countLabelBuilder)
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
    this.colors,
    this.dim = false,
  }) : _count = null,
       countLabelBuilder = null;

  /// Overflow avatar — formats [count] with caller-owned copy instead of a photo.
  const CatchPersonAvatar.count({
    super.key,
    required this.size,
    // Keep the public argument as `count`; `this._count` would expose a
    // private-looking parameter name to callers.
    required int count,
    required String Function(int) this.countLabelBuilder,
    this.borderWidth = 0,
    this.borderColor,
  }) : _count = count,
       name = '',
       imageUrl = null,
       initials = null,
       showStatusDot = false,
       obscured = false,
       shape = CatchPersonAvatarShape.circle,
       colors = null,
       dim = false;

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
  final CatchAvatarColors? colors;
  final bool dim;
  final String Function(int)? countLabelBuilder;
  final int? _count;

  static String initialsOf(String value) => catchAvatarInitialsOf(value);

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
              countLabelBuilder!(_count),
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
        errorBuilder: (context, _, _) => colors == null
            ? CatchInitialsAvatarPlaceholder(
                name: name,
                initials: initials,
                size: innerSize,
              )
            : CatchActivityInitialsPlaceholder(
                colors: colors!,
                initials: initials ?? catchAvatarInitialsOf(name),
                size: innerSize,
                dim: dim,
              ),
      );
      avatar = CatchPersonAvatarShell(
        size: innerSize,
        shape: shape,
        child: obscured ? CatchObscuredAvatarContent(child: image) : image,
      );
    } else if (colors != null) {
      avatar = CatchPersonAvatarShell(
        size: innerSize,
        shape: shape,
        child: CatchActivityInitialsPlaceholder(
          colors: colors!,
          initials: initials ?? catchAvatarInitialsOf(name),
          size: innerSize,
          dim: dim,
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
