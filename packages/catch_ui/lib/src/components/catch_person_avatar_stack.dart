import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_avatar_colors.dart';
import 'package:catch_ui/src/components/catch_person_avatar.dart';
import 'package:catch_ui/src/components/catch_person_avatar_item.dart';
import 'package:catch_ui/src/components/catch_veiled_person_avatar.dart';
import 'package:flutter/material.dart';

class CatchPersonAvatarStack extends StatelessWidget {
  const CatchPersonAvatarStack({
    super.key,
    required this.items,
    required this.countLabelBuilder,
    this.totalCount,
    this.size = 32,
    this.overlap = 9,
    this.borderWidth = 2,
    this.borderColor,
    this.limit = 4,
    this.obscured = false,
    this.showOverflowCount = true,
    this.veiledCount = 0,
    this.veiledColors,
  }) : assert(
         veiledCount <= 0 || veiledColors != null,
         'Veiled avatar slots require caller-resolved colors.',
       );

  final List<CatchPersonAvatarItem> items;
  final String Function(int) countLabelBuilder;
  final int? totalCount;
  final double size;
  final double overlap;
  final double borderWidth;
  final Color? borderColor;
  final int limit;
  final bool obscured;
  final bool showOverflowCount;
  final int veiledCount;
  final CatchAvatarColors? veiledColors;

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
          colors: veiledColors!,
          borderWidth: borderWidth,
          borderColor: borderColor ?? CatchTokens.of(context).surface,
        ),
      if (showOverflowCount && overflow > 0)
        CatchPersonAvatar.count(
          size: size,
          count: overflow,
          countLabelBuilder: countLabelBuilder,
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
