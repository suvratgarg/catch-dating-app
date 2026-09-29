part of 'use_cases.dart';

final _attendanceReport = ProgramAttendanceReport(
  programId: _programId,
  serverTime: _now,
  accessExpiresAt: _now.add(const Duration(hours: 8)),
  programGuests: 142,
  programInvitedGuests: 138,
  programAttendingGuests: 117,
  programCheckedInGuests: 96,
  programNoShowGuests: 4,
  functions: [
    ProgramFunctionAttendance(
      functionId: 'fn_sangeet',
      invitedGuests: 80,
      respondedGuests: 74,
      attendingGuests: 66,
      attendingHeads: 92,
      maybeGuests: 5,
      declinedGuests: 3,
      noResponseGuests: 6,
      checkedInGuests: 61,
      checkedInHeads: 84,
      noShowGuests: 2,
      expectedGuests: 63,
      walkInGuests: 1,
      walkInHeads: 1,
      exceptions: const ProgramAttendanceExceptions(
        invitedNoResponseGuestIds: ['g_21', 'g_34', 'g_40'],
        declinedCheckedInGuestIds: ['g_55'],
        noShowGuestIds: ['g_61', 'g_62'],
        walkInGuestIds: ['g_90'],
      ),
    ),
    const ProgramFunctionAttendance(
      functionId: 'fn_reception',
      invitedGuests: 58,
      respondedGuests: 55,
      attendingGuests: 51,
      attendingHeads: 70,
      maybeGuests: 2,
      declinedGuests: 2,
      noResponseGuests: 3,
      checkedInGuests: 35,
      checkedInHeads: 48,
      noShowGuests: 2,
      expectedGuests: 37,
      walkInGuests: 0,
      walkInHeads: 0,
      exceptions: ProgramAttendanceExceptions(
        invitedNoResponseGuestIds: [],
        declinedCheckedInGuestIds: [],
        noShowGuestIds: [],
        walkInGuestIds: [],
      ),
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Screen states',
  type: ProgramAttendanceReportScreen,
  path: '[P1 product surfaces]/Program attendance',
)
Widget programAttendanceReportScreenStates(BuildContext context) {
  return WidgetbookPageCatalogFrame(
    title: 'ProgramAttendanceReportScreen',
    contractId: 'screen.programs.attendance_report',
    children: [
      WidgetbookPageStateCard(
        label: 'report',
        child: WidgetbookUtilityDeviceFrame(
          child: ProviderScope(
            overrides: _programOverrides(),
            child: const ProgramAttendanceReportScreen(programId: _programId),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Row states',
  type: ProgramFunctionAttendanceRow,
  path: '[P1 product surfaces]/Program attendance',
)
Widget programFunctionAttendanceRowStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'ProgramFunctionAttendanceRow',
    catalogId: 'screen.programs.attendance_report',
    children: [
      ProgramFunctionAttendanceRow(
        attendance: _attendanceReport.functions[0],
        functionName: 'Sangeet',
      ),
      ProgramFunctionAttendanceRow(
        attendance: _attendanceReport.functions[1],
        functionName: 'Reception',
      ),
    ],
  );
}
