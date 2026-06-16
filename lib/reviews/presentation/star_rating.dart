import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Read-only star row. [rating] is 1-5 (integers for filled stars).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final clampedRating = rating.clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < clampedRating
              ? CatchIcons.starRounded
              : CatchIcons.starOutlineRounded,
          size: size,
          // Ratings are ink data — pigment never touches stars: filled ink,
          // empty line2.
          color: i < clampedRating ? t.ink : t.line2,
        ),
      ),
    );
  }
}

/// Tappable star row for picking a rating.
class StarRatingPicker extends StatelessWidget {
  const StarRatingPicker({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 40,
    this.keyBuilder,
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final double size;
  final Key Function(int rating)? keyBuilder;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final clampedRating = rating.clamp(0, 5);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final value = i + 1;
        return Tooltip(
          message: '$value star${value == 1 ? '' : 's'}',
          child: Semantics(
            button: true,
            label: 'Rate $value star${value == 1 ? '' : 's'}',
            selected: clampedRating == value,
            child: GestureDetector(
              key: keyBuilder?.call(value),
              onTap: () => onChanged(value),
              child: Padding(
                padding: CatchInsets.inlineHorizontalTight,
                child: Icon(
                  i < clampedRating
                      ? CatchIcons.starRounded
                      : CatchIcons.starOutlineRounded,
                  size: size,
                  color: i < clampedRating ? t.ink : t.line2,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
