import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventSuccessDefaultsPanel extends StatefulWidget {
  const EventSuccessDefaultsPanel({
    super.key,
    required this.defaults,
    required this.onChanged,
    this.title = 'Event success',
    this.subtitle =
        'Choose whether new events should get a saved run-of-show setup.',
  });

  final EventSuccessDefaults defaults;
  final ValueChanged<EventSuccessDefaults> onChanged;
  final String title;
  final String subtitle;

  @override
  State<EventSuccessDefaultsPanel> createState() =>
      _EventSuccessDefaultsPanelState();
}

class _EventSuccessDefaultsPanelState extends State<EventSuccessDefaultsPanel> {
  late final TextEditingController _hostGoalController = TextEditingController(
    text: widget.defaults.hostGoal,
  );
  late final TextEditingController _attendeePromptController =
      TextEditingController(text: widget.defaults.attendeePrompt ?? '');

  @override
  void didUpdateWidget(covariant EventSuccessDefaultsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaults.hostGoal != widget.defaults.hostGoal) {
      _setText(_hostGoalController, widget.defaults.hostGoal);
    }
    if (oldWidget.defaults.attendeePrompt != widget.defaults.attendeePrompt) {
      _setText(_attendeePromptController, widget.defaults.attendeePrompt ?? '');
    }
  }

  @override
  void dispose() {
    _hostGoalController.dispose();
    _attendeePromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final defaults = widget.defaults;
    final draft = defaults.toDraft();

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      radius: CatchRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: defaults.enabled,
            onChanged: (value) => _emit(defaults.copyWith(enabled: value)),
            title: Text(widget.title, style: CatchTextStyles.titleM(context)),
            subtitle: Text(
              widget.subtitle,
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ),
          if (defaults.enabled) ...[
            gapH12,
            Text('Format', style: CatchTextStyles.labelL(context)),
            gapH8,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                for (final playbook in EventSuccessPlaybookLibrary.all)
                  CatchChip(
                    label: playbook.activityType.label,
                    active: playbook.id == defaults.playbookId,
                    onTap: () {
                      final nextDraft =
                          EventSuccessHostDraft.fromPlaybook(playbook).copyWith(
                            hostGoal: _normalizedRequired(
                              _hostGoalController.text,
                              fallback: draft.hostGoal,
                            ),
                            privateCrushEnabled: defaults.privateCrushEnabled,
                            contextualOpenersEnabled:
                                defaults.contextualOpenersEnabled,
                          );
                      _emit(EventSuccessDefaults.fromDraft(nextDraft));
                    },
                  ),
              ],
            ),
            gapH14,
            CatchTextField(
              label: 'Host goal',
              controller: _hostGoalController,
              hintText: draft.hostGoal,
              inputFormatters: [LengthLimitingTextInputFormatter(300)],
              textInputAction: TextInputAction.next,
              onChanged: (value) => _emit(
                defaults.copyWith(
                  hostGoal: _normalizedRequired(
                    value,
                    fallback: draft.hostGoal,
                  ),
                ),
              ),
            ),
            gapH12,
            CatchTextField(
              label: 'Attendee prompt',
              isOptional: true,
              controller: _attendeePromptController,
              hintText: 'Prompt attendees before or after the event.',
              inputFormatters: [LengthLimitingTextInputFormatter(300)],
              textInputAction: TextInputAction.done,
              onChanged: (value) =>
                  _emit(defaults.copyWith(attendeePrompt: _trimToNull(value))),
            ),
            gapH16,
            Text('Modules', style: CatchTextStyles.labelL(context)),
            gapH8,
            for (final module in draft.playbook.modules)
              SwitchListTile.adaptive(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: draft.isModuleSelected(module.id),
                onChanged: (_) {
                  final nextDraft = draft
                      .toggleModule(module.id)
                      .copyWith(
                        hostGoal: _normalizedRequired(
                          _hostGoalController.text,
                          fallback: draft.hostGoal,
                        ),
                      );
                  _emit(
                    EventSuccessDefaults.fromDraft(
                      nextDraft,
                      attendeePrompt: _attendeePromptController.text,
                    ),
                  );
                },
                title: Text(
                  module.title,
                  style: CatchTextStyles.labelL(context),
                ),
                subtitle: Text(
                  module.hostPromise,
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ),
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: defaults.privateCrushEnabled,
              onChanged: (value) =>
                  _emit(defaults.copyWith(privateCrushEnabled: value)),
              title: Text(
                'Private follow-up',
                style: CatchTextStyles.labelL(context),
              ),
              subtitle: Text(
                'Attendees can privately express interest after attendance is confirmed.',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ),
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: defaults.contextualOpenersEnabled,
              onChanged: (value) =>
                  _emit(defaults.copyWith(contextualOpenersEnabled: value)),
              title: Text(
                'Contextual openers',
                style: CatchTextStyles.labelL(context),
              ),
              subtitle: Text(
                'Matches can get lightweight opener context from this event.',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _emit(EventSuccessDefaults defaults) => widget.onChanged(defaults);
}

void _setText(TextEditingController controller, String value) {
  if (controller.text == value) return;
  controller.text = value;
}

String _normalizedRequired(String value, {required String fallback}) {
  final normalized = value.trim();
  return normalized.isEmpty ? fallback : normalized;
}

String? _trimToNull(String value) {
  final normalized = value.trim();
  return normalized.isEmpty ? null : normalized;
}
