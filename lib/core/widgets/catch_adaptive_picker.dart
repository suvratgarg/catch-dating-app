import 'package:catch_dating_app/core/platform/adaptive_platform.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showCatchDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String title = 'Select date',
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
    builder: (context) => _CupertinoPickerSheet(
      title: title,
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
  String title = 'Select time',
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
    builder: (context) => _CupertinoPickerSheet(
      title: title,
      onCancel: () => Navigator.of(context).pop(),
      onDone: () => Navigator.of(context).pop(selectedTime),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        initialDateTime: initialDateTime,
        use24hFormat: false,
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

class _CupertinoPickerSheet extends StatelessWidget {
  const _CupertinoPickerSheet({
    required this.title,
    required this.child,
    required this.onCancel,
    required this.onDone,
  });

  static const _pickerHeight = CatchLayout.iosPickerHeight;
  static const _toolbarHeight = CatchLayout.iosPickerToolbarHeight;

  final String title;
  final Widget child;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CupertinoPopupSurface(
      child: ColoredBox(
        color: t.surface,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _toolbarHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CatchSpacing.s4,
                        ),
                        onPressed: onCancel,
                        child: Text(
                          'Cancel',
                          style: CatchTextStyles.labelL(context, color: t.ink2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CatchLayout.iosPickerTitleSidePadding,
                      ),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: CatchTextStyles.labelL(context, color: t.ink),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CatchSpacing.s4,
                        ),
                        onPressed: onDone,
                        child: Text(
                          'Done',
                          style: CatchTextStyles.labelL(
                            context,
                            color: t.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: t.line),
              SizedBox(height: _pickerHeight, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
