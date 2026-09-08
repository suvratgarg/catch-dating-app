import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar_colors.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:flutter/material.dart';

class CatchVeiledPersonAvatar extends StatelessWidget {
  const CatchVeiledPersonAvatar({
    super.key,
    required this.size,
    required this.colors,
    required this.borderWidth,
    required this.borderColor,
  });

  final double size;
  final CatchAvatarColors colors;
  final double borderWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final innerSize = size - borderWidth * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor),
      padding: EdgeInsets.all(borderWidth),
      child: ClipOval(
        child: ColoredBox(
          color: colors.soft,
          child: Center(
            child: Icon(
              CatchIcons.personOutlined,
              size: innerSize * 0.38,
              color: colors.deep.withValues(
                alpha: CatchOpacity.avatarFallbackGlyph,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
