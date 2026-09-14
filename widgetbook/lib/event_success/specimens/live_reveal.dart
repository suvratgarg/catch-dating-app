import 'package:catch_dating_app/event_success/presentation/event_success_live_reveal_card.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'preview.dart';

@widgetbook.UseCase(
  name: "AssignmentUnlockedShell",
  type: AssignmentUnlockedShell,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictAssignmentUnlockedShell(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "AssignmentUnlockedShell",
  );
}

@widgetbook.UseCase(
  name: "AttendeeCountdown",
  type: AttendeeCountdown,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictAttendeeCountdown(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "AttendeeCountdown",
  );
}

@widgetbook.UseCase(
  name: "CountdownBeatRail",
  type: CountdownBeatRail,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictCountdownBeatRail(BuildContext context) {
  const items = [
    (label: "Hold", icon: Icons.pan_tool_alt_outlined),
    (label: "Watch", icon: Icons.visibility_outlined),
    (label: "Move", icon: Icons.bolt_rounded),
  ];
  return StrictCoverageScaffold(
    componentName: "CountdownBeatRail",
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CountdownBeatRail(items: items, currentIndex: 0),
        gapH16,
        CountdownBeatRail(items: items, currentIndex: 1),
        gapH16,
        CountdownBeatRail(items: items, currentIndex: 2),
      ],
    ),
  );
}

@widgetbook.UseCase(
  name: "CountdownCuePill",
  type: CountdownCuePill,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictCountdownCuePill(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "CountdownCuePill",
  );
}

@widgetbook.UseCase(
  name: "CountdownCueStack",
  type: CountdownCueStack,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictCountdownCueStack(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "CountdownCueStack",
  );
}

@widgetbook.UseCase(
  name: "CountdownNumber",
  type: CountdownNumber,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictCountdownNumber(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "CountdownNumber",
  );
}

@widgetbook.UseCase(
  name: "CountdownStageDial",
  type: CountdownStageDial,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictCountdownStageDial(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "CountdownStageDial",
  );
}

@widgetbook.UseCase(
  name: "EventSuccessLiveRevealAttendeeCard",
  type: EventSuccessLiveRevealAttendeeCard,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictEventSuccessLiveRevealAttendeeCard(
  BuildContext context,
) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "EventSuccessLiveRevealAttendeeCard",
  );
}

@widgetbook.UseCase(
  name: "EventSuccessLiveRevealHostCard",
  type: EventSuccessLiveRevealHostCard,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictEventSuccessLiveRevealHostCard(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "EventSuccessLiveRevealHostCard",
  );
}

@widgetbook.UseCase(
  name: "HostRevealActions",
  type: HostRevealActions,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictHostRevealActions(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "HostRevealActions",
  );
}

@widgetbook.UseCase(
  name: "RevealGroupSlotRow",
  type: RevealGroupSlotRow,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictRevealGroupSlotRow(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "RevealGroupSlotRow",
  );
}

@widgetbook.UseCase(
  name: "RevealHostCopy",
  type: RevealHostCopy,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictRevealHostCopy(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "RevealHostCopy",
  );
}

@widgetbook.UseCase(
  name: "RevealProgressBar",
  type: RevealProgressBar,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictRevealProgressBar(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "RevealProgressBar",
  );
}

@widgetbook.UseCase(
  name: "RevealRoundList",
  type: RevealRoundList,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictRevealRoundList(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "RevealRoundList",
  );
}

@widgetbook.UseCase(
  name: "RevealRoundRail",
  type: RevealRoundRail,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictRevealRoundRail(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "RevealRoundRail",
  );
}

@widgetbook.UseCase(
  name: "RevealRoundRow",
  type: RevealRoundRow,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictRevealRoundRow(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "RevealRoundRow",
  );
}

@widgetbook.UseCase(
  name: "RevealSlotRow",
  type: RevealSlotRow,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictRevealSlotRow(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "RevealSlotRow",
  );
}

@widgetbook.UseCase(
  name: "RevealTicker",
  type: RevealTicker,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictRevealTicker(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "RevealTicker",
  );
}

@widgetbook.UseCase(
  name: "VisibleGroupRotationSlots",
  type: VisibleGroupRotationSlots,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictVisibleGroupRotationSlots(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "VisibleGroupRotationSlots",
  );
}

@widgetbook.UseCase(
  name: "VisiblePodAssignment",
  type: VisiblePodAssignment,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictVisiblePodAssignment(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "VisiblePodAssignment",
  );
}

@widgetbook.UseCase(
  name: "VisibleRotationSlots",
  type: VisibleRotationSlots,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictVisibleRotationSlots(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "VisibleRotationSlots",
  );
}

@widgetbook.UseCase(
  name: "WaitingRevealCue",
  type: WaitingRevealCue,
  path:
      "[P1 product surfaces]/Event Success strict coverage/Live reveal folded states",
)
Widget eventSuccessStrictWaitingRevealCue(BuildContext context) {
  return eventSuccessStrictPreview(
    context,
    surface: EventSuccessStrictSurface.liveReveal,
    componentName: "WaitingRevealCue",
  );
}
