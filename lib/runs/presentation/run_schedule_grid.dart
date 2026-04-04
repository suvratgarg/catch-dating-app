import 'package:catch_dating_app/runs/domain/run.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final days = _days;
    final runMap = _buildRunMap(runs, days);
    final lineColor = colorScheme.outlineVariant;
    final stickyBg = colorScheme.surfaceContainerHighest;

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
            index == 0 ? TableSpanDecoration(color: stickyBg) : null,
        foregroundDecoration: TableSpanDecoration(
          border: TableSpanBorder(
            trailing: BorderSide(color: lineColor, width: 0.5),
          ),
        ),
      ),
      columnBuilder: (index) => TableSpan(
        extent: FixedTableSpanExtent(
          index == 0 ? _timeColumnWidth : _dayColumnWidth,
        ),
        backgroundDecoration:
            index == 0 ? TableSpanDecoration(color: stickyBg) : null,
        foregroundDecoration: TableSpanDecoration(
          border: TableSpanBorder(
            trailing: BorderSide(color: lineColor, width: 0.5),
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
          return TableViewCell(child: _DayHeader(day: days[col - 1]));
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
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
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
              child: _RunCard(
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

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _weekdays[day.weekday - 1],
          style: TextStyle(
            fontSize: 11,
            color:
                isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 2),
        CircleAvatar(
          radius: 13,
          backgroundColor:
              isToday ? colorScheme.primary : Colors.transparent,
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              color: isToday ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({
    required this.run,
    required this.isSelected,
    this.onTap,
  });

  final Run run;
  final bool isSelected;
  final VoidCallback? onTap;

  static Color _bgColor(PaceLevel pace) => switch (pace) {
    PaceLevel.easy => Colors.green.shade100,
    PaceLevel.moderate => Colors.blue.shade100,
    PaceLevel.fast => Colors.orange.shade100,
    PaceLevel.competitive => Colors.red.shade100,
  };

  static Color _fgColor(PaceLevel pace) => switch (pace) {
    PaceLevel.easy => Colors.green.shade800,
    PaceLevel.moderate => Colors.blue.shade800,
    PaceLevel.fast => Colors.orange.shade800,
    PaceLevel.competitive => Colors.red.shade800,
  };

  static String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  static String _formatDistance(double km) => km == km.roundToDouble()
      ? '${km.round()}km'
      : '${km.toStringAsFixed(1)}km';

  @override
  Widget build(BuildContext context) {
    final bg = _bgColor(run.pace);
    final fg = _fgColor(run.pace);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? fg : fg.withAlpha(80),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: fg.withAlpha(60), blurRadius: 6)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_formatDistance(run.distanceKm)} · ${run.pace.label}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_formatTime(run.startTime)}–${_formatTime(run.endTime)}',
              style: TextStyle(fontSize: 10, color: fg),
              maxLines: 1,
            ),
            if (run.signedUpCount > 0)
              Text(
                '${run.signedUpCount}/${run.capacityLimit}',
                style: TextStyle(fontSize: 10, color: fg),
              ),
          ],
        ),
      ),
    );
  }
}
