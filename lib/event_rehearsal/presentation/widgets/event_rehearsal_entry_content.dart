import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_configuration.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_copy.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_choice.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EventRehearsalEntryContent extends StatelessWidget {
  const EventRehearsalEntryContent({
    super.key,
    required this.configuration,
    required this.onChooseSource,
    required this.onChooseScenario,
    required this.onCustomise,
  });

  final EventRehearsalConfiguration configuration;
  final VoidCallback? onChooseSource;
  final VoidCallback? onChooseScenario;
  final VoidCallback? onCustomise;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final source = configuration.sourceEvent;
    final sourceDescription = configuration.isCustom
        ? l10n.hostRehearsalCustomDescription
        : source == null
        ? l10n.hostRehearsalSampleDescription
        : l10n.hostRehearsalCopiedDescription;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          source == null
              ? l10n.hostRehearsalEntrySample
              : l10n.hostRehearsalEntryUpcoming,
          style: CatchTextStyles.eventDisplay(
            context,
            step: CatchDisplayStep.l,
          ),
        ),
        gapH8,
        Text(
          l10n.hostRehearsalEntryExplanation,
          style: CatchTextStyles.supporting(context),
        ),
        gapH24,
        CatchSection.plain(
          title: source == null
              ? l10n.hostRehearsalSampleLabel
              : l10n.hostRehearsalUpcomingLabel,
          padding: EdgeInsets.zero,
          child: EventRehearsalChoice(
            title: eventRehearsalConfigurationTitle(l10n, configuration),
            description: source == null
                ? sourceDescription
                : '${l10n.hostRehearsalSourceDetails(date: AppTimeFormatters.shortDate(source.startTime), time: AppTimeFormatters.time(source.startTime), venue: source.locationName, count: configuration.sourceGuestCount ?? source.signedUpCount)}\n\n$sourceDescription',
            onTap: onChooseSource,
          ),
        ),
        gapH24,
        CatchSection.plain(
          title: l10n.hostRehearsalScenarioLabel,
          padding: EdgeInsets.zero,
          child: EventRehearsalChoice(
            title: eventRehearsalScenarioTitle(l10n, configuration.scenario),
            description: eventRehearsalScenarioBody(
              l10n,
              configuration.scenario,
            ),
            onTap: onChooseScenario,
          ),
        ),
        gapH24,
        EventRehearsalChoice(
          title: l10n.hostRehearsalCustomise,
          description: configuration.isCustom
              ? l10n.hostRehearsalCustomisedSummary
              : l10n.hostRehearsalCustomiseSummary,
          onTap: onCustomise,
        ),
        if (!configuration.hasValidDuration) ...[
          gapH16,
          Text(
            l10n.hostRehearsalDurationLimit,
            style: CatchTextStyles.supporting(context),
          ),
        ],
        if (!configuration.useSimulatedGuests &&
            (configuration.actorCount < 2 ||
                configuration.actorCount > 50)) ...[
          gapH16,
          Text(
            l10n.hostRehearsalRosterLimit(count: configuration.actorCount),
            style: CatchTextStyles.supporting(context),
          ),
        ],
      ],
    );
  }
}
