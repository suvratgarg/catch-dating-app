import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/schedule_day_header.dart';
import 'package:catch_dating_app/runs/presentation/widgets/schedule_run_card.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

typedef _RunCellInfo = ({Run run, int mergeRow, int mergeSpan});

class RunScheduleGrid extends StatelessWidget {
  const RunScheduleGrid({
    super.key,
    required this.runs,
    this.selectedRunId,
    this.onRunSelected,
  });

  final List<Run> runs;
  final String? selectedRunId;
  final ValueChanged<Run>? onRunSelected;

  static const _startHour = 6;
  static const _endHour = 22;
  static const _numDays = 7;
  static const _slotMinutes = 30;
  static const _totalSlots = (_endHour - _startHour) * 60 ~/ _slotMinutes;
  static const _rowCount = 1 + _totalSlots;
  static const _columnCount = 1 + _numDays;

  static const _headerRowHeight = 52.0;
  static const _slotRowHeight = 32.0;
  static const _timeColumnWidth = 52.0;
  static const _dayColumnWidth = 110.0;

  List<DateTime> get _days {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    return List.generate(_numDays, (i) => start.add(Duration(days: i)));
  }

  Map<(int, int), _RunCellInfo> _buildRunMap(
    List<Run> runs,
    List<DateTime> days,
  ) {
    final map = <(int, int), _RunCellInfo>{};
    for (final run in runs) {
      final colIdx =
          days.indexWhere((d) => DateUtils.isSameDay(d, run.startTime));
      if (colIdx < 0) continue;
      final col = colIdx + 1;

      final startMinuteOfDay = run.startTime.hour * 60 + run.startTime.minute;
      final startSlot =
          (startMinuteOfDay - _startHour * 60) ~/ _slotMinutes;
      final durationMinutes =
          run.endTime.difference(run.startTime).inMinutes;
      final mergeSpan =
          (durationMinutes + _slotMinutes - 1) ~/ _slotMinutes;
      final mergeRow = startSlot + 1;

      for (int r = mergeRow; r < mergeRow + mergeSpan; r++) {
        if (r >= 1 && r < _rowCount) {
          map[(r, col)] = (run: run, mergeRow: mergeRow, mergeSpan: mergeSpan);
        }
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final days = _days;
    final runMap = _buildRunMap(runs, days);

    return TableView.builder(
      pinnedRowCount: 1,
      pinnedColumnCount: 1,
      rowCount: _rowCount,
      columnCount: _columnCount,
      rowBuilder: (index) => TableSpan(
        extent: FixedTableSpanExtent(
          index == 0 ? _headerRowHeight : _slotRowHeight,
        ),
        backgroundDecoration:
            index == 0 ? TableSpanDecoration(color: t.raised) : null,
        foregroundDecoration: TableSpanDecoration(
          border: TableSpanBorder(
            trailing: BorderSide(color: t.line, width: 0.5),
          ),
        ),
      ),
      columnBuilder: (index) => TableSpan(
        extent: FixedTableSpanExtent(
          index == 0 ? _timeColumnWidth : _dayColumnWidth,
        ),
        backgroundDecoration:
            index == 0 ? TableSpanDecoration(color: t.raised) : null,
        foregroundDecoration: TableSpanDecoration(
          border: TableSpanBorder(
            trailing: BorderSide(color: t.line, width: 0.5),
          ),
        ),
      ),
      cellBuilder: (context, vicinity) {
        final row = vicinity.row;
        final col = vicinity.column;

        if (row == 0 && col == 0) {
          return const TableViewCell(child: SizedBox.shrink());
        }

        if (row == 0) {
          return TableViewCell(child: ScheduleDayHeader(day: days[col - 1]));
        }

        if (col == 0) {
          final slotIndex = row - 1;
          if (slotIndex % (60 ~/ _slotMinutes) == 0) {
            final hour = _startHour + slotIndex ~/ (60 ~/ _slotMinutes);
            return TableViewCell(
              child: Padding(
                padding: const EdgeInsets.only(right: 6, top: 4),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  style: CatchTextStyles.labelSm(context, color: t.ink2),
                  textAlign: TextAlign.right,
                ),
              ),
            );
          }
          return const TableViewCell(child: SizedBox.shrink());
        }

        final runInfo = runMap[(row, col)];
        if (runInfo != null) {
          final isSelected = selectedRunId == runInfo.run.id;
          return TableViewCell(
            rowMergeStart: runInfo.mergeRow,
            rowMergeSpan: runInfo.mergeSpan,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ScheduleRunCard(
                run: runInfo.run,
                isSelected: isSelected,
                onTap: () => onRunSelected?.call(runInfo.run),
              ),
            ),
          );
        }

        return const TableViewCell(child: SizedBox.shrink());
      },
    );
  }
}
