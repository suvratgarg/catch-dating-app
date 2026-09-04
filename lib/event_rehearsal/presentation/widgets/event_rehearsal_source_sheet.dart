import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_configuration.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

typedef EventRehearsalSourceChoice = ({
  String? eventId,
  ActivityKind? activityKind,
});

class EventRehearsalSourceSheet extends StatelessWidget {
  const EventRehearsalSourceSheet({
    super.key,
    required this.events,
    required this.configuration,
  });

  final List<Event> events;
  final EventRehearsalConfiguration configuration;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.sizeOf(context).height *
            CatchLayout.sheetMaxHeightFraction,
      ),
      child: CatchBottomSheetScaffold(
        title: l10n.hostRehearsalChooseSource,
        child: Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (events.isNotEmpty) ...[
                  CatchSection.plain(
                    title: l10n.hostRehearsalUpcomingLabel,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final event in events)
                          CatchMenuRow<EventRehearsalSourceChoice>(
                            item: CatchMenuItem(
                              value: (eventId: event.id, activityKind: null),
                              label: event.title,
                              sublabel: l10n.hostRehearsalSourceWhenWhere(
                                date: AppTimeFormatters.shortDate(
                                  event.startTime,
                                ),
                                time: AppTimeFormatters.time(event.startTime),
                                venue: event.locationName,
                              ),
                              selected:
                                  configuration.sourceEvent?.id == event.id,
                              role: CatchMenuItemRole.choice,
                            ),
                            onSelected: (value, _) =>
                                Navigator.of(context).pop(value),
                          ),
                      ],
                    ),
                  ),
                  gapH24,
                ],
                CatchSection.plain(
                  title: l10n.hostRehearsalSampleLabel,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final kind
                          in configuration
                              .organizerDefaults
                              .effectiveSupportedActivityKinds)
                        CatchMenuRow<EventRehearsalSourceChoice>(
                          item: CatchMenuItem(
                            value: (eventId: null, activityKind: kind),
                            label: l10n.hostRehearsalSampleTitle(
                              activity: kind.label,
                            ),
                            sublabel: l10n.hostRehearsalSampleDescription,
                            selected:
                                configuration.sourceEvent == null &&
                                configuration.sampleActivityKind == kind,
                            role: CatchMenuItemRole.choice,
                          ),
                          onSelected: (value, _) =>
                              Navigator.of(context).pop(value),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
