import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_defaults_panel.dart';
import 'package:flutter/material.dart';

class ClubEventSuccessDefaultsStep extends StatelessWidget {
  const ClubEventSuccessDefaultsStep({
    super.key,
    required this.formKey,
    required this.defaults,
    required this.onChanged,
  });

  final GlobalKey<FormState> formKey;
  final ClubHostDefaults defaults;
  final ValueChanged<ClubHostDefaults> onChanged;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.s4,
          CatchSpacing.s5,
          CatchSpacing.s6,
        ),
        children: [
          EventSuccessDefaultsPanel(
            defaults: defaults.eventSuccessForActivity(
              defaults.primaryActivityKind,
            ),
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
          ),
        ],
      ),
    );
  }
}
