import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum HostClubTab { edit, insights, preview }

enum HostClubInsightsRangePreset {
  sevenDays('7 days'),
  thirtyDays('30 days'),
  ninetyDays('90 days'),
  month('This month'),
  custom('Custom');

  const HostClubInsightsRangePreset(this.label);

  final String label;
}

enum HostClubInsightsGranularity {
  day('Day'),
  week('Week'),
  month('Month');

  const HostClubInsightsGranularity(this.label);

  final String label;
}

@immutable
class HostClubsScreenState {
  const HostClubsScreenState._({
    required this.clubs,
    required this.currentUid,
    required this.selectedClubIndex,
    required this.selectedTab,
  });

  factory HostClubsScreenState.resolve({
    required List<Club> clubs,
    required String currentUid,
    int selectedClubIndex = 0,
    String? selectedClubId,
    HostClubTab selectedTab = HostClubTab.edit,
  }) {
    return HostClubsScreenState._(
      clubs: List<Club>.unmodifiable(clubs),
      currentUid: currentUid,
      selectedClubIndex: _resolveSelectedClubIndex(
        clubs: clubs,
        selectedClubIndex: selectedClubIndex,
        selectedClubId: selectedClubId,
      ),
      selectedTab: selectedTab,
    );
  }

  final List<Club> clubs;
  final String currentUid;
  final int selectedClubIndex;
  final HostClubTab selectedTab;

  bool get hasClubs => clubs.isNotEmpty;
  bool get showClubPicker => clubs.length > 1;
  Club? get selectedClub => hasClubs ? clubs[selectedClubIndex] : null;
  String title(AppLocalizations l10n) =>
      selectedClub?.name ?? l10n.hostsHostOperationsScreenStateTitleClubs;
  bool get selectedClubIsOwner => selectedClub?.isOwnedBy(currentUid) ?? false;

  HostClubsScreenState selectClubIndex(int index) {
    return HostClubsScreenState.resolve(
      clubs: clubs,
      currentUid: currentUid,
      selectedClubIndex: index,
      selectedTab: selectedTab,
    );
  }

  HostClubsScreenState selectTab(HostClubTab tab) {
    return HostClubsScreenState.resolve(
      clubs: clubs,
      currentUid: currentUid,
      selectedClubIndex: selectedClubIndex,
      selectedTab: tab,
    );
  }

  static int _resolveSelectedClubIndex({
    required List<Club> clubs,
    required int selectedClubIndex,
    String? selectedClubId,
  }) {
    if (clubs.isEmpty) return 0;
    final selectedId = selectedClubId;
    if (selectedId != null) {
      final index = clubs.indexWhere((club) => club.id == selectedId);
      if (index != -1) return index;
    }
    if (selectedClubIndex < 0) return 0;
    if (selectedClubIndex >= clubs.length) return clubs.length - 1;
    return selectedClubIndex;
  }
}

@immutable
class HostClubInsightsQueryState {
  const HostClubInsightsQueryState({
    required this.clubId,
    required this.eventId,
    required this.rangePreset,
    required this.startDate,
    required this.endDate,
    required this.granularity,
  });

  final String clubId;
  final String? eventId;
  final HostClubInsightsRangePreset rangePreset;
  final DateTime startDate;
  final DateTime endDate;
  final HostClubInsightsGranularity granularity;
}

@immutable
class HostClubInsightsState {
  const HostClubInsightsState._({
    required this.clubId,
    required this.rangePreset,
    required this.granularity,
    required this.selectedEventId,
    required this.customStartDate,
    required this.customEndDate,
  });

  factory HostClubInsightsState.initial({
    required String clubId,
    DateTime? now,
  }) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    return HostClubInsightsState._(
      clubId: clubId,
      rangePreset: HostClubInsightsRangePreset.thirtyDays,
      granularity: HostClubInsightsGranularity.day,
      selectedEventId: null,
      customStartDate: DateTime(today.year, today.month, today.day - 29),
      customEndDate: today,
    );
  }

  final String clubId;
  final HostClubInsightsRangePreset rangePreset;
  final HostClubInsightsGranularity granularity;
  final String? selectedEventId;
  final DateTime customStartDate;
  final DateTime customEndDate;

  HostClubInsightsQueryState get query {
    return HostClubInsightsQueryState(
      clubId: clubId,
      eventId: selectedEventId,
      rangePreset: rangePreset,
      startDate: customStartDate,
      endDate: customEndDate,
      granularity: granularity,
    );
  }

  HostClubInsightsState selectClub(String clubId) {
    if (clubId == this.clubId) return this;
    return _copyWith(clubId: clubId, selectedEventId: null);
  }

  HostClubInsightsState selectRange(HostClubInsightsRangePreset rangePreset) {
    return _copyWith(rangePreset: rangePreset);
  }

  HostClubInsightsState selectGranularity(
    HostClubInsightsGranularity granularity,
  ) {
    return _copyWith(granularity: granularity);
  }

  HostClubInsightsState selectEvent(String eventId) {
    return _copyWith(selectedEventId: eventId);
  }

  HostClubInsightsState clearEvent() {
    if (selectedEventId == null) return this;
    return _copyWith(selectedEventId: null);
  }

  HostClubInsightsState selectCustomStartDate(DateTime date) {
    return _copyWith(
      rangePreset: HostClubInsightsRangePreset.custom,
      customStartDate: DateUtils.dateOnly(date),
    );
  }

  HostClubInsightsState selectCustomEndDate(DateTime date) {
    return _copyWith(
      rangePreset: HostClubInsightsRangePreset.custom,
      customEndDate: DateUtils.dateOnly(date),
    );
  }

  HostClubInsightsState _copyWith({
    String? clubId,
    HostClubInsightsRangePreset? rangePreset,
    HostClubInsightsGranularity? granularity,
    Object? selectedEventId = _unchanged,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    return HostClubInsightsState._(
      clubId: clubId ?? this.clubId,
      rangePreset: rangePreset ?? this.rangePreset,
      granularity: granularity ?? this.granularity,
      selectedEventId: selectedEventId == _unchanged
          ? this.selectedEventId
          : selectedEventId as String?,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
    );
  }
}

const Object _unchanged = Object();
