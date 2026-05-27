import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:flutter/material.dart';

/// Presentation-only data for the Explore concept lab.
///
/// These models intentionally do not mirror Firestore or production domain
/// objects. They describe the mixed feed shapes the visual exploration wants
/// to prove before we decide how to adapt real Event/Club data into them.
class ExploreConceptEventData {
  const ExploreConceptEventData({
    required this.title,
    required this.clubName,
    required this.venue,
    required this.timeLabel,
    required this.countdownLabel,
    required this.priceLabel,
    required this.capacityLabel,
    required this.activityLabel,
    required this.statusLabel,
    required this.activityKind,
    this.clockTime,
    this.supportingLabel,
  });

  final String title;
  final String clubName;
  final String venue;
  final String timeLabel;
  final String countdownLabel;
  final String priceLabel;
  final String capacityLabel;
  final String activityLabel;
  final String statusLabel;
  final ActivityKind activityKind;
  final TimeOfDay? clockTime;
  final String? supportingLabel;
}

class ExploreConceptClubData {
  const ExploreConceptClubData({
    required this.kicker,
    required this.name,
    required this.tagline,
    required this.hostLabel,
    required this.memberCountLabel,
    required this.tags,
    required this.scheduleLabel,
    required this.actionLabel,
    required this.accentColor,
    required this.secondaryAccentColor,
    this.hasCoverPhoto = false,
    this.coverCaption,
  });

  final String kicker;
  final String name;
  final String tagline;
  final String hostLabel;
  final String memberCountLabel;
  final List<String> tags;
  final String scheduleLabel;
  final String actionLabel;
  final Color accentColor;
  final Color secondaryAccentColor;
  final bool hasCoverPhoto;
  final String? coverCaption;
}

class ExploreConceptCategoryData {
  const ExploreConceptCategoryData({
    required this.label,
    required this.countLabel,
    required this.activityKind,
  });

  final String label;
  final String countLabel;
  final ActivityKind activityKind;
}

sealed class ExploreConceptThisWeekItemData {
  const ExploreConceptThisWeekItemData();
}

class ExploreConceptThisWeekEventData extends ExploreConceptThisWeekItemData {
  const ExploreConceptThisWeekEventData({
    required this.weekdayLabel,
    required this.dayLabel,
    required this.title,
    required this.clubName,
    required this.timeLabel,
    required this.priceLabel,
    required this.goingLabel,
    required this.leftLabel,
    required this.progress,
    required this.activityKind,
    this.clockTime,
    this.leftIsUrgent = false,
  });

  final String weekdayLabel;
  final String dayLabel;
  final String title;
  final String clubName;
  final String timeLabel;
  final String priceLabel;
  final String goingLabel;
  final String leftLabel;
  final double progress;
  final ActivityKind activityKind;
  final TimeOfDay? clockTime;
  final bool leftIsUrgent;
}

class ExploreConceptThisWeekClubData extends ExploreConceptThisWeekItemData {
  const ExploreConceptThisWeekClubData({
    required this.club,
    required this.kicker,
    required this.supportingLabel,
    required this.activityKind,
  });

  final ExploreConceptClubData club;
  final String kicker;
  final String supportingLabel;
  final ActivityKind activityKind;
}
