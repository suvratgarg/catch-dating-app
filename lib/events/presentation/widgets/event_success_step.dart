import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_defaults_panel.dart';
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
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        16,
        CatchSpacing.s5,
        CatchSpacing.s8,
      ),
      children: [
        CatchSurface(
          padding: const EdgeInsets.all(CatchSpacing.s3),
          tone: CatchSurfaceTone.primarySoft,
          radius: CatchRadius.md,
          borderWidth: 0,
          child: Text(
            'Prepare the host guide for this event. You can adjust it again before Live mode starts.',
            style: CatchTextStyles.bodyS(context, color: t.primary),
          ),
        ),
        gapH20,
        EventSuccessDefaultsPanel(
          defaults: eventSuccessDefaults,
          activityKind: activityKind,
          eventFormat: eventFormat,
          targetAttendeeCount: targetAttendeeCount,
          onChanged: onEventSuccessDefaultsChanged,
          title: 'Live event guide',
          subtitle:
              'Save a simple plan with this event so Live mode is ready when it starts.',
        ),
      ],
    );
  }
}
