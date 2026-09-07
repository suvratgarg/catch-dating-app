import 'package:flutter/material.dart';

/// Caller-resolved pigment and tints for avatar fallbacks and veils.
/// The shared renderer never interprets an activity or another feature model.
@immutable
class CatchAvatarColors {
  const CatchAvatarColors({
    required this.accent,
    required this.deep,
    required this.soft,
  });
  final Color accent;
  final Color deep;
  final Color soft;
}
