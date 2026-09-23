import 'package:catch_dating_app/chats/domain/event_chat_profile.dart';
import 'package:catch_dating_app/chats/presentation/event_profile_controller.dart';
import 'package:catch_dating_app/chats/presentation/event_profile_copy.dart';
import 'package:catch_dating_app/chats/presentation/widgets/event_profile_answer_field.dart';
import 'package:catch_dating_app/chats/presentation/widgets/event_profile_photo_field.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Explicit sharing choices for eligible core values and one claimed organizer card.
class EventProfileEditorSection extends StatefulWidget {
  const EventProfileEditorSection({
    super.key,
    required this.state,
    required this.onSave,
    required this.onChooseCard,
    required this.onLoadMore,
    required this.onReload,
    this.photos = const {},
  });
  final EventProfileEditorState state;
  final Map<String, ImageProvider> photos;
  final ValueChanged<EventProfileSelection?> onSave;
  final ValueChanged<String?> onChooseCard;
  final VoidCallback onLoadMore, onReload;
  @override
  State<EventProfileEditorSection> createState() =>
      _EventProfileEditorSectionState();
}

class _EventProfileEditorSectionState extends State<EventProfileEditorSection> {
  late EventProfileDraft _draft;
  @override
  void initState() {
    super.initState();
    _draft = EventProfileDraft(widget.state.settings, widget.state.card);
  }

  @override
  void didUpdateWidget(EventProfileEditorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.state.settings, widget.state.settings) ||
        !identical(oldWidget.state.card, widget.state.card)) {
      final previous = _draft;
      _draft = EventProfileDraft(widget.state.settings, widget.state.card);
      final before = oldWidget.state.settings, after = widget.state.settings;
      if (oldWidget.state.uid == widget.state.uid &&
          before.revision == after.revision &&
          before.profileRevision == after.profileRevision &&
          before.membershipRevision == after.membershipRevision) {
        _draft.coreFieldIds
          ..clear()
          ..addAll(
            previous.coreFieldIds.intersection(
              after.coreFields.map((f) => f.id).toSet(),
            ),
          );
        _draft.photoId = after.photoIds.contains(previous.photoId)
            ? previous.photoId
            : null;
        if (oldWidget.state.card?.responseId == widget.state.card?.responseId &&
            oldWidget.state.card?.cardRevision ==
                widget.state.card?.cardRevision) {
          _draft.questionIds
            ..clear()
            ..addAll(
              previous.questionIds.intersection(
                eventCardFields(
                  widget.state.card,
                  after.organizerId,
                ).map((f) => f.questionId).toSet(),
              ),
            );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n, current = widget.state;
    final fields = eventCardFields(current.card, current.settings.organizerId);
    final disabled = current.busy || !current.settings.canShare;
    final choices = {
      for (final row in current.cards) row.responseId: row.formTitle,
    };
    if (current.card case final card?) {
      choices[card.responseId] = card.formTitle;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.eventProfileDisclosure,
          style: CatchTextStyles.recordBody(context),
        ),
        gapH16,
        Text(
          l.eventProfileReviewAgain,
          style: CatchTextStyles.supporting(context),
        ),
        if (!current.settings.canShare) ...[
          gapH24,
          Text(
            l.eventProfileCannotShare,
            style: CatchTextStyles.recordBody(context),
          ),
        ] else ...[
          gapH24,
          CatchSection.fieldRows(
            title: l.eventProfileCore,
            children: [
              for (final field in current.settings.coreFields)
                EventProfileAnswerField.share(
                  label: l.hostFormPersonFieldName(field: field.id),
                  answer: eventProfileValue(context, field),
                  selected: _draft.coreFieldIds.contains(field.id),
                  onChanged: disabled
                      ? null
                      : (value) => setState(() {
                          if (value) {
                            _draft.coreFieldIds.add(field.id);
                          } else {
                            _draft.coreFieldIds.remove(field.id);
                          }
                        }),
                ),
            ],
          ),
          gapH24,
          CatchSection.fieldRows(
            title: l.eventProfilePhoto,
            children: [
              if (current.settings.photoIds.isEmpty)
                Text(
                  l.eventProfileNoPhoto,
                  style: CatchTextStyles.supporting(context),
                ),
              for (final (index, id) in current.settings.photoIds.indexed)
                if (widget.photos[id] case final image?)
                  EventProfilePhotoField(
                    key: ValueKey(id),
                    image: image,
                    label: l.eventProfilePhotoLabel(number: index + 1),
                    selected: _draft.photoId == id,
                    onChanged: disabled
                        ? null
                        : (value) => setState(
                            () => _draft.photoId = value ? id : null,
                          ),
                  )
                else
                  Text(
                    l.eventProfilePhotoUnavailable,
                    style: CatchTextStyles.supporting(context),
                  ),
            ],
          ),
          gapH24,
          CatchSection.fieldRows(
            title: l.eventProfileCard,
            children: [
              Text(
                l.eventProfileCardDisclosure,
                style: CatchTextStyles.supporting(context),
              ),
              if (choices.isNotEmpty)
                CatchField<String>.select(
                  copy: catchFieldCopy(l),
                  title: l.eventProfileChooseCard,
                  values: ['', ...choices.keys],
                  value: current.card?.responseId ?? '',
                  contractExemption:
                      'Only owned claimed cards from this event organizer can be selected.',
                  itemLabelBuilder: (id) =>
                      id.isEmpty ? l.eventProfileNoCard : choices[id]!,
                  onChanged: disabled
                      ? null
                      : (id) => widget.onChooseCard(id == '' ? null : id),
                ),
              if (choices.isEmpty &&
                  current.nextCursor == null &&
                  current.cardError == null)
                Text(
                  l.eventProfileNoCards,
                  style: CatchTextStyles.supporting(context),
                ),
              for (final field in fields)
                EventProfileAnswerField.share(
                  label: field.label,
                  answer: field.answerText(
                    yes: l.formProfileYes,
                    no: l.formProfileNo,
                    empty: l.formProfileEmptyAnswer,
                    attachment: l.formProfileAttachment,
                  ),
                  selected: _draft.questionIds.contains(field.questionId),
                  onChanged: disabled
                      ? null
                      : (value) => setState(() {
                          if (value) {
                            _draft.questionIds.add(field.questionId);
                          } else {
                            _draft.questionIds.remove(field.questionId);
                          }
                        }),
                ),
            ],
          ),
          if (current.cardError case final error?)
            CatchLocalizedErrorState(error, onRetry: widget.onReload),
          if (current.nextCursor != null) ...[
            gapH16,
            CatchButton(
              label: l.eventProfileMoreCards,
              variant: CatchButtonVariant.secondary,
              onPressed: disabled ? null : widget.onLoadMore,
            ),
          ],
          gapH24,
          CatchButton(
            label: l.eventProfileSave,
            fullWidth: true,
            status: current.busy
                ? CatchButtonStatus.loading
                : CatchButtonStatus.idle,
            onPressed: disabled
                ? null
                : () => widget.onSave(_draft.selection()),
          ),
          gapH12,
          Text(
            l.eventProfileEditAgain,
            style: CatchTextStyles.supporting(context),
          ),
        ],
        if (current.settings.selection != null) ...[
          gapH24,
          CatchButton(
            label: l.eventProfileStop,
            fullWidth: true,
            variant: CatchButtonVariant.secondary,
            onPressed: current.busy ? null : () => widget.onSave(null),
          ),
        ],
      ],
    );
  }
}
