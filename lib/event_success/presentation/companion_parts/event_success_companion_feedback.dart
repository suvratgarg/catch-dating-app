part of '../event_success_companion_screen.dart';

class EventSuccessFeedbackForm extends StatefulWidget {
  const EventSuccessFeedbackForm({
    super.key,
    required this.event,
    required this.userProfile,
    this.existingFeedback,
  });

  final Event event;
  final UserProfile userProfile;
  final EventSuccessFeedback? existingFeedback;

  @override
  State<EventSuccessFeedbackForm> createState() =>
      _EventSuccessFeedbackFormState();
}

class _EventSuccessFeedbackFormState extends State<EventSuccessFeedbackForm> {
  late int _welcome = widget.existingFeedback?.welcomeRating ?? 4;
  late int _structure = widget.existingFeedback?.structureRating ?? 4;
  late int _metPeople = widget.existingFeedback?.metNewPeopleCount ?? 2;
  late bool _safetyConcern = widget.existingFeedback?.safetyConcern ?? false;
  late final TextEditingController _noteController = TextEditingController(
    text: widget.existingFeedback?.privateNote ?? '',
  );

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final mutation = ref.watch(EventSuccessController.feedbackMutation);
        final t = CatchTokens.of(context);
        return StagePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    widget.existingFeedback == null
                        ? 'How did it feel?'
                        : 'Your feedback is saved',
                    style: CatchTextStyles.titleL(context),
                  ),
                  const PrivacyBadge(_PrivacyAudience.catchPrivate),
                ],
              ),
              gapH4,
              Text(
                'This is private-first: hosts see aggregate trends, while private notes and safety concerns stay with Catch.',
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
              gapH12,
              _ratingRow(
                context,
                label: 'Welcome',
                value: _welcome,
                onChanged: (value) => setState(() => _welcome = value),
              ),
              gapH8,
              _ratingRow(
                context,
                label: 'Structure',
                value: _structure,
                onChanged: (value) => setState(() => _structure = value),
              ),
              gapH8,
              _counterRow(
                context,
                value: _metPeople,
                onChanged: (value) => setState(() => _metPeople = value),
              ),
              gapH8,
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'I want Catch to review a safety or comfort concern',
                      style: CatchTextStyles.supporting(context),
                    ),
                  ),
                  gapW12,
                  CatchToggle(
                    value: _safetyConcern,
                    semanticLabel:
                        'I want Catch to review a safety or comfort concern',
                    onChanged: (value) =>
                        setState(() => _safetyConcern = value),
                  ),
                ],
              ),
              gapH8,
              StageSoftBand(
                child: CatchField(
                  title: 'Private note to Catch',
                  controller: _noteController,
                  maxLines: 3,
                  inputFormatters: [LengthLimitingTextInputFormatter(500)],
                ),
              ),
              gapH12,
              StageActionDock(
                child: CatchButton(
                  label: widget.existingFeedback == null
                      ? 'Submit feedback'
                      : 'Update feedback',
                  isLoading: mutation.isPending,
                  onPressed: mutation.isPending ? null : () => _submit(ref),
                  fullWidth: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit(WidgetRef ref) {
    final now = DateTime.now();
    final existing = widget.existingFeedback;
    final feedback = EventSuccessFeedback(
      id:
          existing?.id ??
          eventSuccessFeedbackId(
            eventId: widget.event.id,
            uid: widget.userProfile.uid,
          ),
      eventId: widget.event.id,
      clubId: widget.event.clubId,
      uid: widget.userProfile.uid,
      welcomeRating: _welcome,
      structureRating: _structure,
      metNewPeopleCount: _metPeople,
      safetyConcern: _safetyConcern,
      privateNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );
    EventSuccessController.feedbackMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .submitFeedback(feedback),
    );
  }
}

EventSuccessRevealAssignmentKind? _revealKindForAttendeeMoment(
  EventSuccessAttendeeMoment moment,
) {
  if (moment.assignmentModuleId ==
      EventSuccessModuleCatalog.guidedRotations.id) {
    return EventSuccessRevealAssignmentKind.rotations;
  }
  if (moment.assignmentModuleId == EventSuccessModuleCatalog.microPods.id) {
    return EventSuccessRevealAssignmentKind.microPods;
  }
  return null;
}

bool _sameAnswers(List<String>? a, List<String>? b) {
  final normalizedA =
      EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(a ?? const []);
  final normalizedB =
      EventSuccessCompatibilityQuestionnaire.normalizedAnswerIds(b ?? const []);
  if (normalizedA.length != normalizedB.length) return false;
  for (var i = 0; i < normalizedA.length; i++) {
    if (normalizedA[i] != normalizedB[i]) return false;
  }
  return true;
}

bool _isStrongRotationSignal(String compatibility) =>
    compatibility == 'mutual_interest' ||
    compatibility == 'questionnaire_match';

Widget _ratingRow(
  BuildContext context, {
  required String label,
  required int value,
  required ValueChanged<int> onChanged,
}) {
  final t = CatchTokens.of(context);
  return Row(
    children: [
      Expanded(
        child: Text(label, style: CatchTextStyles.sectionTitle(context)),
      ),
      for (var i = 1; i <= 5; i++)
        _feedbackIconAction(
          tooltip: '$label $i',
          icon: i <= value
              ? CatchIcons.starRounded
              : CatchIcons.starBorderRounded,
          color: i <= value ? t.gold : t.ink3,
          onPressed: () => onChanged(i),
        ),
    ],
  );
}

Widget _counterRow(
  BuildContext context, {
  required int value,
  required ValueChanged<int> onChanged,
}) {
  final t = CatchTokens.of(context);
  return Row(
    children: [
      Expanded(
        child: Text(
          'People I met',
          style: CatchTextStyles.sectionTitle(context),
        ),
      ),
      _feedbackIconAction(
        tooltip: 'Decrease people met',
        icon: CatchIcons.removeCircleOutlineRounded,
        color: value <= 0 ? t.ink3 : t.ink2,
        onPressed: value <= 0 ? null : () => onChanged(value - 1),
      ),
      Text('$value', style: CatchTextStyles.sectionTitle(context)),
      _feedbackIconAction(
        tooltip: 'Increase people met',
        icon: CatchIcons.addCircleOutlineRounded,
        color: t.ink2,
        onPressed: () => onChanged(value + 1),
      ),
    ],
  );
}

Widget _feedbackIconAction({
  required String tooltip,
  required IconData icon,
  required Color color,
  required VoidCallback? onPressed,
}) {
  return Tooltip(
    message: tooltip,
    child: CatchIconButton(
      onTap: onPressed,
      child: Icon(icon, size: CatchIcon.md, color: color),
    ),
  );
}
