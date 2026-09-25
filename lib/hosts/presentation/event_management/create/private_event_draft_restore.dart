import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:flutter/material.dart';

/// Restores both canonical local dates and older wizard draft dates.
DateTime? restoredPrivateEventDate(
  EventDraft draft, {
  required bool rejectPast,
}) {
  final localDate = draft.eventLocalDate;
  DateTime? date = localDate == null ? null : DateTime.tryParse(localDate);
  final today = DateUtils.dateOnly(DateTime.now());
  if (rejectPast && date != null && date.isBefore(today)) {
    date = null;
  }
  final legacyMillis = draft.selectedDateMillis;
  if (date == null && legacyMillis != null) {
    date = DateTime.fromMillisecondsSinceEpoch(legacyMillis);
  }
  if (date == null) {
    return null;
  }
  final day = DateUtils.dateOnly(date);
  if (rejectPast && day.isBefore(today)) {
    return null;
  }
  return day;
}

/// Canonical HH:mm takes priority; legacy picker fields remain readable.
TimeOfDay? restoredPrivateEventStart(EventDraft draft) {
  final parts = draft.eventLocalStartTime?.split(':');
  if (parts?.length == 2) {
    final hour = int.tryParse(parts![0]);
    final minute = int.tryParse(parts[1]);
    if (hour != null && minute != null &&
        hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
      return TimeOfDay(hour: hour, minute: minute);
    }
  }
  final hour = draft.selectedStartHour;
  final minute = draft.selectedStartMinute;
  if (hour == null || minute == null ||
      hour < 0 || hour >= 24 || minute < 0 || minute >= 60) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}
