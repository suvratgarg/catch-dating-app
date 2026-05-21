import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_questionnaire_config_editor.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_structure_config_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EventSuccessDefaultsPanel extends StatefulWidget {
  const EventSuccessDefaultsPanel({
    super.key,
    required this.defaults,
    required this.activityKind,
    required this.onChanged,
    this.title = 'Event success',
    this.subtitle =
        'Choose whether new events should get a saved run-of-show setup.',
  });

  final EventSuccessDefaults defaults;
  final ActivityKind activityKind;
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
    final defaults = widget.defaults.normalizedForActivity(widget.activityKind);
    final draft = defaults.toDraft();
    final profile = EventSuccessActivityProfile.forActivity(
      widget.activityKind,
      targetAttendeeCount: draft.targetAttendeeCount,
    );

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
            _ActivityRecommendationSummary(profile: profile, draft: draft),
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
            Text('Event structure', style: CatchTextStyles.labelL(context)),
            gapH8,
            EventSuccessStructureConfigEditor(
              value: draft.structureConfig,
              targetAttendeeCount: draft.targetAttendeeCount,
              enabled: true,
              onChanged: (value) {
                _emit(
                  EventSuccessDefaults.fromDraft(
                    draft.copyWith(structureConfig: value),
                    attendeePrompt: _attendeePromptController.text,
                  ),
                );
              },
            ),
            gapH16,
            Text('Recommended setup', style: CatchTextStyles.labelL(context)),
            gapH8,
            for (final level in const [
              EventSuccessRecommendationLevel.defaultOn,
              EventSuccessRecommendationLevel.recommended,
              EventSuccessRecommendationLevel.optional,
              EventSuccessRecommendationLevel.discouraged,
            ])
              if (profile.recommendationsFor(level).isNotEmpty) ...[
                _RecommendationGroup(
                  title: level.label,
                  recommendations: profile.recommendationsFor(level),
                  draft: draft,
                  onToggle: (moduleId) {
                    final nextDraft = draft
                        .toggleModule(moduleId)
                        .copyWith(
                          hostGoal: _normalizedRequired(
                            _hostGoalController.text,
                            fallback: draft.hostGoal,
                          ),
                        );
                    _emitDraft(nextDraft, enabled: defaults.enabled);
                  },
                ),
                gapH8,
              ],
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value:
                  draft.isModuleSelected(
                    EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
                  ) &&
                  defaults.compatibilityAffectsRanking,
              onChanged:
                  draft.isModuleSelected(
                    EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
                  )
                  ? (value) => _emit(
                      defaults
                          .copyWith(compatibilityAffectsRanking: value)
                          .normalizedForActivity(widget.activityKind),
                    )
                  : null,
              title: Text(
                'Use questionnaire for pairing',
                style: CatchTextStyles.labelL(context),
              ),
              subtitle: Text(
                'Off keeps answers for clues only. On lets generated pairings use them as a soft ranking boost.',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ),
            if (draft.isModuleSelected(
              EventSuccessModuleCatalog.compatibilityQuestionnaire.id,
            )) ...[
              gapH12,
              EventSuccessQuestionnaireConfigEditor(
                value: defaults.questionnaireConfig,
                onChanged: (value) => _emit(
                  defaults
                      .copyWith(questionnaireConfig: value)
                      .normalizedForActivity(widget.activityKind),
                ),
              ),
            ],
            SwitchListTile.adaptive(
              dense: true,
              contentPadding: EdgeInsets.zero,
              value: defaults.wingmanRequestsEnabled,
              onChanged: (value) =>
                  _emit(defaults.copyWith(wingmanRequestsEnabled: value)),
              title: Text(
                'Wingman requests',
                style: CatchTextStyles.labelL(context),
              ),
              subtitle: Text(
                'Attendees can explicitly ask the host for help with one natural introduction during the event.',
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
                'Post-match openers',
                style: CatchTextStyles.labelL(context),
              ),
              subtitle: Text(
                'Matches can get a lightweight opener from shared event context.',
                style: CatchTextStyles.bodyS(context, color: t.ink2),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _emit(EventSuccessDefaults defaults) => widget.onChanged(defaults);

  void _emitDraft(EventSuccessHostDraft draft, {required bool enabled}) {
    _emit(
      EventSuccessDefaults.fromDraft(
        draft,
        enabled: enabled,
        attendeePrompt: _attendeePromptController.text,
      ).normalizedForActivity(widget.activityKind),
    );
  }
}

class _ActivityRecommendationSummary extends StatelessWidget {
  const _ActivityRecommendationSummary({
    required this.profile,
    required this.draft,
  });

  final EventSuccessActivityProfile profile;
  final EventSuccessHostDraft draft;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      borderColor: Colors.transparent,
      radius: CatchRadius.md,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatchBadge(
                label: profile.activityKind.label,
                tone: CatchBadgeTone.brand,
                icon: Icons.auto_awesome_outlined,
              ),
              CatchBadge(
                label: profile.activityKind.defaultInteractionModel.label,
                tone: CatchBadgeTone.neutral,
              ),
              CatchBadge(
                label: '${draft.selectedModules.length} tools',
                tone: CatchBadgeTone.neutral,
              ),
            ],
          ),
          gapH8,
          Text(
            profile.summary,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
        ],
      ),
    );
  }
}

class _RecommendationGroup extends StatelessWidget {
  const _RecommendationGroup({
    required this.title,
    required this.recommendations,
    required this.draft,
    required this.onToggle,
  });

  final String title;
  final List<EventSuccessModuleRecommendation> recommendations;
  final EventSuccessHostDraft draft;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CatchTextStyles.labelL(context)),
        gapH6,
        for (final recommendation in recommendations)
          _RecommendationSwitch(
            recommendation: recommendation,
            active: draft.isModuleSelected(recommendation.module.id),
            onChanged: recommendation.selectable
                ? (_) => onToggle(recommendation.module.id)
                : null,
          ),
      ],
    );
  }
}

class _RecommendationSwitch extends StatelessWidget {
  const _RecommendationSwitch({
    required this.recommendation,
    required this.active,
    required this.onChanged,
  });

  final EventSuccessModuleRecommendation recommendation;
  final bool active;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SwitchListTile.adaptive(
      dense: true,
      contentPadding: EdgeInsets.zero,
      value: active,
      onChanged: onChanged,
      title: Text(
        recommendation.module.title,
        style: CatchTextStyles.labelL(context),
      ),
      subtitle: Text(
        recommendation.reason,
        style: CatchTextStyles.bodyS(context, color: t.ink2),
      ),
    );
  }
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
