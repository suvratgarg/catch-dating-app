import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/event_success/event_success.dart'
    show EventSuccessDefaultsPanel;
import 'package:flutter/material.dart';

class ClubEventSuccessDefaultsStep extends StatelessWidget {
  const ClubEventSuccessDefaultsStep({
    super.key,
    required this.formKey,
    required this.defaults,
    required this.onChanged,
    this.scrollable = true,
    this.padding,
  });

  final GlobalKey<FormState> formKey;
  final ClubHostDefaults defaults;
  final ValueChanged<ClubHostDefaults> onChanged;
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final panel = EventSuccessDefaultsPanel(
      defaults: defaults.eventSuccessForActivity(defaults.primaryActivityKind),
      activityKind: defaults.primaryActivityKind,
      onChanged: (eventSuccess) => onChanged(
        defaults.copyWithEventSuccessForActivity(
          activityKind: defaults.primaryActivityKind,
          defaults: eventSuccess,
        ),
      ),
      title: 'Default event success',
      subtitle:
          'Apply activity-aware run-of-show defaults automatically when creating new events.',
    );

    return Form(
      key: formKey,
      child: scrollable
          ? ListView(
              padding: padding ?? CatchInsets.formStepBody,
              children: [panel],
            )
          : Padding(padding: padding ?? EdgeInsets.zero, child: panel),
    );
  }
}
