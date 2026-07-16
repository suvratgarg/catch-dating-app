import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/event_success.dart'
    show EventSuccessDefaultsPanel;
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class EventSuccessStep extends StatelessWidget {
  const EventSuccessStep({
    super.key,
    required this.activityKind,
    required this.eventSuccessDefaults,
    required this.targetAttendeeCount,
    required this.onEventSuccessDefaultsChanged,
    this.eventFormat,
  });

  final ActivityKind activityKind;
  final EventFormatSnapshot? eventFormat;
  final EventSuccessDefaults eventSuccessDefaults;
  final int targetAttendeeCount;
  final ValueChanged<EventSuccessDefaults> onEventSuccessDefaultsChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ListView(
      padding: CatchInsets.formStepBodyRelaxed,
      children: [
        CatchSectionList(
          children: [
            CatchSection.plain(
              child: Text(
                context.l10n.hostsEventSuccessStepTextPrepareTheHostGuide,
                style: CatchTextStyles.supporting(context, color: t.primary),
              ),
            ),
            EventSuccessDefaultsPanel(
              defaults: eventSuccessDefaults,
              activityKind: activityKind,
              eventFormat: eventFormat,
              targetAttendeeCount: targetAttendeeCount,
              onChanged: onEventSuccessDefaultsChanged,
              subtitle:
                  context.l10n.hostsEventSuccessStepSubtitleSaveASimplePlan,
            ),
          ],
        ),
      ],
    );
  }
}
