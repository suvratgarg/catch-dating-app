import 'package:catch_dating_app/events/shared/event_tiles/event_date_tile.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/contract_preview.dart';
import 'fixtures.dart';

@widgetbook.UseCase(
  name: 'Date marker states',
  type: EventDateTile,
  path: '[Events]/Calendar',
)
Widget eventDateMarkerStates(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EventDateTile(
        date: widgetbookEvent.startTime,
        active: true,
        hasEvent: true,
        today: true,
        onTap: widgetbookNoop,
      ),
      gapW12,
      EventDateTile(
        date: widgetbookEvent.startTime.add(const Duration(days: 1)),
        active: false,
        hasEvent: true,
        layout: EventDateTileVariant.monthGrid,
        onTap: widgetbookNoop,
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Week marker states',
  type: WeekDayTile,
  path: '[Events]/Calendar',
)
Widget eventWeekMarkerStates(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      WeekDayTile(
        date: widgetbookEvent.startTime,
        active: true,
        hasEvent: true,
        onTap: widgetbookNoop,
      ),
      gapW12,
      WeekDayTile(
        date: widgetbookEvent.startTime.add(const Duration(days: 1)),
        active: false,
        hasEvent: true,
        onTap: widgetbookNoop,
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Month marker states',
  type: MonthDayTile,
  path: '[Events]/Calendar',
)
Widget eventMonthMarkerStates(BuildContext context) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      MonthDayTile(
        date: widgetbookEvent.startTime,
        active: true,
        today: true,
        hasEvent: true,
        enabled: true,
        onTap: widgetbookNoop,
      ),
      gapW12,
      MonthDayTile(
        date: widgetbookEvent.startTime.add(const Duration(days: 1)),
        active: false,
        today: false,
        hasEvent: true,
        enabled: true,
        onTap: widgetbookNoop,
      ),
      gapW12,
      MonthDayTile(
        date: widgetbookEvent.startTime.add(const Duration(days: 2)),
        active: false,
        today: false,
        hasEvent: false,
        enabled: false,
        onTap: widgetbookNoop,
      ),
    ],
  );
}
