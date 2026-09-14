import 'package:catch_ui/src/components/catch_picker_copy.dart';
import 'package:catch_ui/src/components/catch_wheel_picker_sheet.dart';
import 'package:catch_ui/src/foundations/catch_adaptive_platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showCatchDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  required CatchPickerCopy copy,
  String? title,
}) {
  if (!prefersCupertinoControls()) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }

  final minimumDate = DateUtils.dateOnly(firstDate);
  final maximumDate = DateUtils.dateOnly(lastDate);
  var selectedDate = DateUtils.dateOnly(
    _clampDate(initialDate, minimumDate, maximumDate),
  );

  return showCupertinoModalPopup<DateTime>(
    context: context,
    semanticsDismissible: true,
    builder: (context) => CatchWheelPickerSheet(
      copy: copy,
      title: title ?? copy.title,
      onCancel: () => Navigator.of(context).pop(),
      onDone: () => Navigator.of(context).pop(selectedDate),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: selectedDate,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        onDateTimeChanged: (value) {
          selectedDate = DateUtils.dateOnly(value);
        },
      ),
    ),
  );
}

Future<TimeOfDay?> showCatchTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  required CatchPickerCopy copy,
  String? title,
}) {
  if (!prefersCupertinoControls()) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
  }

  var selectedTime = initialTime;
  final initialDateTime = DateTime(
    2000,
    1,
    1,
    initialTime.hour,
    initialTime.minute,
  );

  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    semanticsDismissible: true,
    builder: (context) => CatchWheelPickerSheet(
      copy: copy,
      title: title ?? copy.title,
      onCancel: () => Navigator.of(context).pop(),
      onDone: () => Navigator.of(context).pop(selectedTime),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: initialDateTime,
        onDateTimeChanged: (value) {
          selectedTime = TimeOfDay.fromDateTime(value);
        },
      ),
    ),
  );
}

DateTime _clampDate(DateTime date, DateTime minimumDate, DateTime maximumDate) {
  final normalizedDate = DateUtils.dateOnly(date);
  if (normalizedDate.isBefore(minimumDate)) return minimumDate;
  if (normalizedDate.isAfter(maximumDate)) return maximumDate;
  return normalizedDate;
}
