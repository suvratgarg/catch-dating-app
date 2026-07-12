import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchIcon, CatchInsets, CatchRadius, CatchTokens;
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/inline_editor_save.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/inline_editor_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileInlinePromptEntryEditor extends ConsumerStatefulWidget {
  const ProfileInlinePromptEntryEditor({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentAnswer,
    required this.currentPrompts,
    required this.promptIndex,
    required this.availablePromptIds,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.currentPromptId,
    this.isAddAffordance = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String currentAnswer;
  final String? currentPromptId;
  final List<ProfilePromptAnswer> currentPrompts;
  final int promptIndex;
  final List<String> availablePromptIds;
  final String fieldName;
  final bool isExpanded;
  final bool isAddAffordance;
  final VoidCallback onTap;
  final InlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlinePromptEntryEditor> createState() =>
      _ProfileInlinePromptEntryEditorState();
}

class _ProfileInlinePromptEntryEditorState
    extends ConsumerState<ProfileInlinePromptEntryEditor>
    with InlineSaveState<ProfileInlinePromptEntryEditor> {
  late final TextEditingController _controller;
  late String _selectedPromptId = _initialPromptId();
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentAnswer);
    _controller.addListener(_clearValidationError);
  }

  @override
  void didUpdateWidget(covariant ProfileInlinePromptEntryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentAnswer != widget.currentAnswer) {
      _controller.text = widget.currentAnswer;
    }
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentPromptId != widget.currentPromptId ||
        !listEquals(oldWidget.availablePromptIds, widget.availablePromptIds)) {
      _selectedPromptId = _initialPromptId();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_clearValidationError);
    _controller.dispose();
    super.dispose();
  }

  String _initialPromptId() {
    final currentPromptId = widget.currentPromptId;
    if (currentPromptId != null &&
        widget.availablePromptIds.contains(currentPromptId)) {
      return currentPromptId;
    }
    return widget.availablePromptIds.first;
  }

  void _clearValidationError() {
    if (_validationError == null) return;
    setState(() => _validationError = null);
  }

  void _cancel() {
    _controller.text = widget.currentAnswer;
    setState(() => _selectedPromptId = _initialPromptId());
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final normalizedText = normalizeProfilePromptAnswer(_controller.text);
    if (normalizedText != _controller.text) {
      _controller.text = normalizedText;
    }

    final validationError = validateOptionalProfilePromptAnswer(normalizedText);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    final selectedDefinition = profilePromptDefinition(_selectedPromptId);
    final updatedPrompts = replaceProfilePromptAnswerAtIndex(
      current: widget.currentPrompts,
      index: widget.promptIndex,
      definition: selectedDefinition,
      answer: normalizedText,
    );
    final currentPrompts = normalizeProfilePromptAnswers(widget.currentPrompts);
    if (listEquals(updatedPrompts, currentPrompts)) {
      _cancel();
      return;
    }

    final saved = await saveFieldsFromLatest((latest) {
      final latestPrompts = normalizeProfilePromptAnswers(
        latest.profilePrompts,
      );
      final latestUpdatedPrompts = replaceProfilePromptAnswerAtIndex(
        current: latest.profilePrompts,
        index: widget.promptIndex,
        definition: selectedDefinition,
        answer: normalizedText,
      );
      if (listEquals(latestUpdatedPrompts, latestPrompts)) {
        return UpdateUserProfilePatch.raw(const {});
      }
      return UpdateUserProfilePatch(profilePrompts: latestUpdatedPrompts);
    });
    if (saved && mounted) widget.onSaved();
  }

  Future<void> _pickPrompt() async {
    final selected = await showPromptPickerSheet(
      context,
      promptIds: widget.availablePromptIds,
      selectedPromptId: _selectedPromptId,
    );
    if (selected == null || !mounted) return;
    setState(() => _selectedPromptId = selected);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDefinition = profilePromptDefinition(_selectedPromptId);
    final saveErrorBanner = buildSaveError();

    return CatchField.actions(
      icon: widget.icon,
      // While editing, the header shows the live selected question and the
      // answer lives only in the editable input below — the collapsed body
      // is not duplicated alongside it.
      title: widget.isExpanded ? selectedDefinition.title : widget.label,
      body: widget.isExpanded
          ? null
          : (widget.isAddAffordance
                ? context.l10n.userProfileInlineEditorPromptBodyValue(
                    value: widget.value,
                  )
                : widget.value),
      tone: widget.isAddAffordance
          ? CatchFieldTone.primary
          : CatchFieldTone.normal,
      initiallyExpanded: widget.isExpanded,
      isLoading: isSaving,
      error: _validationError,
      onTap: isSaving ? null : widget.onTap,
      actionLeading: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Text(
          context.l10n
              .userProfileInlineEditorPromptTextLengthMaximumprofilepromptanswerlength(
                length: _controller.text.length,
                maximumProfilePromptAnswerLength:
                    maximumProfilePromptAnswerLength,
              ),
          key: ValueKey(
            context.l10n.userProfileInlineEditorPromptTextProfileInlineCounter,
          ),
          style: CatchTextStyles.labelM(context),
        ),
      ),
      control: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isExpanded) ...[
            ProfileInlineTextValue(
              label: selectedDefinition.title,
              displayValue: widget.value,
              placeholder: selectedDefinition.placeholder,
              controller: _controller,
              isEditing: widget.isExpanded,
              enabled: !isSaving,
              isAddAffordance: widget.isAddAffordance,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              maxLength: maximumProfilePromptAnswerLength,
              collapseStackedBlankLines: true,
              onSubmitted: (_) => _submit(),
            ),
            gapH8,
            CatchTextButton(
              key: const ValueKey('profile-inline-change-prompt'),
              label:
                  context.l10n.userProfileInlineEditorPromptLabelChangePrompt,
              tone: CatchTextButtonTone.neutral,
              minimumSize: const Size(0, CatchSpacing.s8),
              padding: EdgeInsets.zero,
              onPressed: isSaving ? null : _pickPrompt,
            ),
            if (saveErrorBanner != null) ...[
              const SizedBox(height: CatchSpacing.s3),
              saveErrorBanner,
            ],
          ],
        ],
      ),
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }
}

/// Opens the prompt-question picker and resolves with the chosen prompt id,
/// or null when dismissed.
Future<String?> showPromptPickerSheet(
  BuildContext context, {
  required List<String> promptIds,
  required String selectedPromptId,
}) {
  return showCatchBottomSheet<String>(
    context: context,
    builder: (_) => PromptPickerSheet(
      promptIds: promptIds,
      selectedPromptId: selectedPromptId,
    ),
  );
}

class PromptPickerSheet extends StatelessWidget {
  const PromptPickerSheet({
    super.key,
    required this.promptIds,
    required this.selectedPromptId,
  });

  final List<String> promptIds;
  final String selectedPromptId;

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: context.l10n.userProfileInlineEditorPromptTitlePrompt,
      subtitle:
          context.l10n.userProfileInlineEditorPromptSubtitlePickTheQuestionThis,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.56,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final promptId in promptIds)
                PromptOptionTile(
                  title: profilePromptDefinition(promptId).title,
                  selected: promptId == selectedPromptId,
                  onTap: () => Navigator.of(context).pop(promptId),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PromptOptionTile extends StatelessWidget {
  const PromptOptionTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.userProfileInlineEditorPromptLabelSelectPromptTitle(
        title: title,
      ),
      child: Material(
        color: selected ? t.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: CatchInsets.listBody,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: CatchTextStyles.bodyL(
                      context,
                      color: selected ? t.primary : t.ink,
                    ),
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: CatchSpacing.s2),
                  Icon(
                    CatchIcons.checkRounded,
                    size: CatchIcon.sm,
                    color: t.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
