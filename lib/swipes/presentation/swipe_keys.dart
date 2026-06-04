import 'package:flutter/foundation.dart';

abstract final class SwipeKeys {
  static const passButton = ValueKey('catches.profile.pass');
  static const applyFiltersButton = ValueKey('swipes.filters.apply');
  static const resetFiltersButton = ValueKey('swipes.filters.reset');
  static const ageRangeSlider = ValueKey('swipes.filters.age_range');
  static const activeCatchWindowCard = ValueKey('swipes.hub.activeWindow.card');
  static const openCatchesDeckButton = ValueKey('swipes.recap.open_deck');

  static ValueKey<String> genderFilterChip(String genderName) =>
      ValueKey('swipes.filters.gender.$genderName');

  static ValueKey<String> vibeTile(String uid) =>
      ValueKey('swipes.recap.vibe_tile.$uid');
}
