import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar_initials.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

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
    final label = initials ?? catchAvatarInitialsOf(name);
    final tone = name.runes.fold<int>(0, (value, rune) => value + rune) % 3;
    final background = Color.lerp(
      t.primarySoft,
      t.ink2,
      tone * CatchOpacity.calloutFill,
    )!;

    // People are paper and ink, never activity pigment.
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: background),
        if (label.isNotEmpty)
          Center(
            child: Text(
              label,
              style: CatchTextStyles.avatarInitials(
                context,
                size: size * 0.34,
                color: t.ink2,
              ),
            ),
          ),
      ],
    );
  }
}
