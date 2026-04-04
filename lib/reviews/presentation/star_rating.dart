import 'package:flutter/material.dart';

/// Read-only star row. [rating] is 1–5 (integers for filled stars).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16});

  final int rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: Colors.amber,
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
  });

  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (i) => GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: Colors.amber,
            ),
          ),
        ),
      ),
    );
  }
}
