import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Date and time wheels',
  type: CatchPickerSheet,
  path: '[Core primitives]/Sheets',
)
Widget pickerSheetStates(BuildContext context) {
  const CatchPickerCopy copy = CatchPickerCopy(
    title: 'Select date',
    cancelLabel: 'Cancel',
    doneLabel: 'Done',
  );
  return WidgetbookCatalogFrame(
    title: 'Native picker sheets',
    catalogId: 'catch.sheet.picker',
    children: [
      for (final mode in [
        CupertinoDatePickerMode.date,
        CupertinoDatePickerMode.time,
      ])
        Align(
          child: SizedBox(
            width: 390,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: EdgeInsets.only(
                  bottom: mode == CupertinoDatePickerMode.time ? 34 : 0,
                ),
              ),
              child: CatchPickerSheet(
                title: mode == CupertinoDatePickerMode.date
                    ? copy.title
                    : 'Select time',
                copy: copy,
                onCancel: () {},
                onDone: () {},
                child: CupertinoDatePicker(
                  mode: mode,
                  initialDateTime: DateTime(2026, 5, 12, 7, 30),
                  minimumDate: mode == CupertinoDatePickerMode.date
                      ? DateTime(2026, 5)
                      : null,
                  maximumDate: mode == CupertinoDatePickerMode.date
                      ? DateTime(2026, 5, 31)
                      : null,
                  onDateTimeChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
