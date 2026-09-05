import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_choice.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

enum EventRehearsalStartChoice { upcomingEvent, custom }

/// Chooses the rehearsal starting point before the configurable setup screen.
class EventRehearsalStartSheet extends StatelessWidget {
  const EventRehearsalStartSheet({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    key: const ValueKey<String>('event-rehearsal-start-sheet'),
    title: context.l10n.hostRehearsalStartTitle,
    subtitle: context.l10n.hostRehearsalStartSubtitle,
    scrollable: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EventRehearsalChoice(
          key: const ValueKey<String>('rehearsal-start-upcoming'),
          title: context.l10n.hostRehearsalStartUpcoming(title: event.title),
          description: context.l10n.hostRehearsalStartUpcomingDescription(
            count: event.signedUpCount,
          ),
          icon: CatchIcons.calendarTodayOutlined,
          onTap: () => Navigator.of(
            context,
          ).pop(EventRehearsalStartChoice.upcomingEvent),
        ),
        const CatchDivider.section(),
        EventRehearsalChoice(
          key: const ValueKey<String>('rehearsal-start-custom'),
          title: context.l10n.hostRehearsalStartCustom,
          description: context.l10n.hostRehearsalStartCustomDescription,
          icon: CatchIcons.tuneRounded,
          onTap: () =>
              Navigator.of(context).pop(EventRehearsalStartChoice.custom),
        ),
        gapH4,
      ],
    ),
  );
}
