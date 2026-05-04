import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/scrollable_profile.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/swipe_stamp.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    this.horizontalOffsetPercentage = 0,
  });

  final PublicProfile profile;

  /// Horizontal drag progress from CardSwiper (-100 to 100).
  /// Positive = dragging right (like), negative = dragging left (nope).
  final int horizontalOffsetPercentage;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final likeOpacity = (horizontalOffsetPercentage / 40.0).clamp(0.0, 1.0);
    final nopeOpacity = (-horizontalOffsetPercentage / 40.0).clamp(0.0, 1.0);

    return Semantics(
      label: 'Profile of ${profile.name}, ${profile.age}',
      hint: 'Swipe left to pass, right to like. Tap to view full profile.',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            ScrollableProfile(
              profile: profile,
              cardHeight: constraints.maxHeight,
            ),
            Positioned(
              top: 48,
              left: 20,
              child: IgnorePointer(
                child: Opacity(
                  opacity: likeOpacity,
                  child: SwipeStamp(kind: SwipeStampKind.like, color: t.like),
                ),
              ),
            ),
            Positioned(
              top: 48,
              right: 20,
              child: IgnorePointer(
                child: Opacity(
                  opacity: nopeOpacity,
                  child: SwipeStamp(kind: SwipeStampKind.nope, color: t.pass),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
