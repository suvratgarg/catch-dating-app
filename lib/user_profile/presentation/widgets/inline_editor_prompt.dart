import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
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

  @override
  Widget build(BuildContext context) {
    final selectedDefinition = profilePromptDefinition(_selectedPromptId);

    return CatchField.actions(
      icon: widget.icon,
      title: widget.label,
      body: widget.isExpanded
          ? widget.value
          : (widget.isAddAffordance ? '+ ${widget.value}' : widget.value),
      tone: widget.isAddAffordance
          ? CatchFieldTone.primary
          : CatchFieldTone.normal,
      initiallyExpanded: widget.isExpanded,
      isLoading: isSaving,
      error: _validationError ?? _errorMessage(),
      onTap: isSaving ? null : widget.onTap,
      actionLeading: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => Text(
          '${_controller.text.length} / $maximumProfilePromptAnswerLength',
          key: const ValueKey('profile-inline-counter'),
          style: CatchTextStyles.labelM(context),
        ),
      ),
      control: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isExpanded)
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
          if (widget.isExpanded) ...[
            const SizedBox(height: CatchSpacing.s3),
            const CatchFormFieldLabel(label: 'Prompt'),
            gapH8,
            CatchField.select<String>(
              title: 'Prompt',
              values: widget.availablePromptIds,
              value: _selectedPromptId,
              itemLabel: (promptId) => profilePromptDefinition(promptId).title,
              prefixIcon: Icon(CatchIcons.formatQuoteRounded),
              showLabel: false,
              onChanged: isSaving
                  ? null
                  : (promptId) {
                      if (promptId == null) return;
                      setState(() => _selectedPromptId = promptId);
                    },
            ),
          ],
        ],
      ),
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }

  String? _errorMessage() {
    final error = saveError;
    if (error == null) return null;
    return appErrorMessage(error, context: AppErrorContext.profile);
  }
}
