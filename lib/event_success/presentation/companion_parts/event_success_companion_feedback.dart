part of '../event_success_companion_screen.dart';

@immutable
class EventSuccessFeedbackActionState {
  const EventSuccessFeedbackActionState({this.isSaving = false});

  final bool isSaving;
}

class EventSuccessFeedbackForm extends StatefulWidget {
  const EventSuccessFeedbackForm({
    super.key,
    required this.event,
    required this.userProfile,
    required this.actionState,
    required this.onSubmitFeedback,
    this.existingFeedback,
  });

  final Event event;
  final UserProfile userProfile;
  final EventSuccessFeedbackActionState actionState;
  final Future<void> Function(EventSuccessFeedback feedback) onSubmitFeedback;
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
  bool _submitPending = false;
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
    final saving = widget.actionState.isSaving || _submitPending;
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
                    ? context
                          .l10n
                          .eventSuccessEventSuccessCompanionFeedbackTextHowDidItFeel
                    : context
                          .l10n
                          .eventSuccessEventSuccessCompanionFeedbackTextYourFeedbackIsSaved,
                style: CatchTextStyles.titleL(context),
              ),
              const CatchPrivacyBadge(kind: CatchPrivacyBadgeKind.catchPrivate),
            ],
          ),
          gapH4,
          Text(
            context
                .l10n
                .eventSuccessEventSuccessCompanionFeedbackTextThisIsPrivateFirst,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH12,
          RatingRow(
            label: context
                .l10n
                .eventSuccessEventSuccessCompanionFeedbackLabelWelcome,
            value: _welcome,
            onChanged: (value) => setState(() => _welcome = value),
          ),
          gapH8,
          RatingRow(
            label: context
                .l10n
                .eventSuccessEventSuccessCompanionFeedbackLabelStructure,
            value: _structure,
            onChanged: (value) => setState(() => _structure = value),
          ),
          gapH8,
          CounterRow(
            value: _metPeople,
            onChanged: (value) => setState(() => _metPeople = value),
          ),
          gapH8,
          CatchField.toggle(
            title: context
                .l10n
                .eventSuccessEventSuccessCompanionFeedbackTitleIWantCatchTo,
            contract: CatchContractConstraints
                .eventSuccessFeedbackDocumentSafetyConcern,
            titleMaxLines: 2,
            value: _safetyConcern,
            onChanged: (value) => setState(() => _safetyConcern = value),
          ),
          gapH8,
          StageSoftBand(
            child: CatchField.input(
              title: context
                  .l10n
                  .eventSuccessEventSuccessCompanionFeedbackTitlePrivateNoteToCatch,
              contract: CatchContractConstraints
                  .eventSuccessFeedbackDocumentPrivateNote,
              controller: _noteController,
              maxLines: 3,
            ),
          ),
          gapH12,
          StageActionDock(
            child: CatchButton(
              label: widget.existingFeedback == null
                  ? context
                        .l10n
                        .eventSuccessEventSuccessCompanionFeedbackLabelSubmitFeedback
                  : context
                        .l10n
                        .eventSuccessEventSuccessCompanionFeedbackLabelUpdateFeedback,
              isLoading: saving,
              onPressed: saving ? null : _submit,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitPending = true);
    try {
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
      await widget.onSubmitFeedback(feedback);
    } finally {
      if (mounted) setState(() => _submitPending = false);
    }
  }
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

class RatingRow extends StatelessWidget {
  const RatingRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(label, style: CatchTextStyles.sectionTitle(context)),
        ),
        for (var i = 1; i <= 5; i++)
          CatchIconAction(
            size: CatchIconButton.defaultSize,
            tooltip: context.l10n
                .eventSuccessEventSuccessCompanionFeedbackTooltipLabelI(
                  label: label,
                  i: i,
                ),
            icon: i <= value
                ? CatchIcons.starRounded
                : CatchIcons.starBorderRounded,
            foregroundColor: i <= value ? t.gold : t.ink3,
            onPressed: () => onChanged(i),
          ),
      ],
    );
  }
}

class CounterRow extends StatelessWidget {
  const CounterRow({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            context
                .l10n
                .eventSuccessEventSuccessCompanionFeedbackTextPeopleIMet,
            style: CatchTextStyles.sectionTitle(context),
          ),
        ),
        CatchIconAction(
          size: CatchIconButton.defaultSize,
          tooltip: context
              .l10n
              .eventSuccessEventSuccessCompanionFeedbackTooltipDecreasePeopleMet,
          icon: CatchIcons.removeCircleOutlineRounded,
          foregroundColor: value <= 0 ? t.ink3 : t.ink2,
          onPressed: value <= 0 ? null : () => onChanged(value - 1),
        ),
        Text(
          context.l10n.eventSuccessEventSuccessCompanionFeedbackTextValue(
            value: value,
          ),
          style: CatchTextStyles.sectionTitle(context),
        ),
        CatchIconAction(
          size: CatchIconButton.defaultSize,
          tooltip: context
              .l10n
              .eventSuccessEventSuccessCompanionFeedbackTooltipIncreasePeopleMet,
          icon: CatchIcons.addCircleOutlineRounded,
          foregroundColor: t.ink2,
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}
