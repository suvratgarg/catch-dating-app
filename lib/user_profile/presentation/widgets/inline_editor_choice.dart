import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchSpacing, CatchTokens;
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/inline_editor_save.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

// ── Single-choice editor ──────────────────────────────────────────────────────

class ProfileInlineSingleChoiceEntryEditor<T extends Labelled>
    extends ConsumerStatefulWidget {
  const ProfileInlineSingleChoiceEntryEditor({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.values,
    required this.currentValue,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    required this.patchForValue,
    this.isAddAffordance = false,
    this.allowEmptySelection = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<T> values;
  final T? currentValue;
  final String fieldName;
  final bool isExpanded;
  final bool isAddAffordance;
  final bool allowEmptySelection;
  final VoidCallback onTap;
  final InlineSaveCallback onSaved;
  final VoidCallback onCancel;
  final UpdateUserProfilePatch Function(T? value) patchForValue;

  @override
  ConsumerState<ProfileInlineSingleChoiceEntryEditor<T>> createState() =>
      _ProfileInlineSingleChoiceEntryEditorState<T>();
}

class _ProfileInlineSingleChoiceEntryEditorState<T extends Labelled>
    extends ConsumerState<ProfileInlineSingleChoiceEntryEditor<T>>
    with InlineSaveState<ProfileInlineSingleChoiceEntryEditor<T>> {
  late T? _selected = widget.currentValue;

  @override
  void didUpdateWidget(
    covariant ProfileInlineSingleChoiceEntryEditor<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _selected = widget.currentValue;
    }
  }

  void _cancel() {
    setState(() => _selected = widget.currentValue);
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected == widget.currentValue) {
      _cancel();
      return;
    }
    final saved = await saveFields(widget.patchForValue(_selected));
    if (saved && mounted) {
      widget.onSaved();
    }
  }

  void _toggleSelectedValue(T value) {
    if (isSaving) return;
    setState(() {
      if (_selected == value && widget.allowEmptySelection) {
        _selected = null;
      } else {
        _selected = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableValues = widget.values
        .where((value) => value != _selected)
        .toList(growable: false);
    final headerValue = _selected?.label ?? widget.label;

    return CatchField.actions(
      icon: widget.icon,
      title: widget.label,
      body: _selected == null
          ? context.l10n.userProfileInlineEditorChoiceBodyLabel(
              label: widget.label,
            )
          : headerValue,
      tone: widget.isAddAffordance || _selected == null
          ? CatchFieldTone.primary
          : CatchFieldTone.normal,
      initiallyExpanded: widget.isExpanded,
      isLoading: isSaving,
      error: _errorMessage(),
      onTap: isSaving ? null : widget.onTap,
      control: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isExpanded)
            ProfileSingleChipValue<T>(
              emptyValue: widget.label,
              displayValue: widget.value,
              isEditing: widget.isExpanded,
              selected: _selected,
              enabled: !isSaving,
              isAddAffordance: widget.isAddAffordance,
              allowEmptySelection: widget.allowEmptySelection,
              onSelectedTap: _toggleSelectedValue,
            ),
          if (widget.isExpanded && availableValues.isNotEmpty) ...[
            const SizedBox(height: CatchSpacing.s3),
            ProfileChipOptions<T>(
              values: availableValues,
              enabled: !isSaving,
              selected: const {},
              onTap: _toggleSelectedValue,
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
    return appErrorMessage(
      error,
      l10n: context.l10n,
      context: AppErrorContext.profile,
    );
  }
}

// ── Multi-choice editor ───────────────────────────────────────────────────────

class ProfileInlineMultiChoiceEntryEditor<T extends Labelled>
    extends ConsumerStatefulWidget {
  const ProfileInlineMultiChoiceEntryEditor({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.values,
    required this.currentValues,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    required this.patchForValues,
    this.patchForLatestProfile,
    this.isAddAffordance = false,
    this.isOptional = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<T> values;
  final List<T> currentValues;
  final String fieldName;
  final bool isExpanded;
  final bool isAddAffordance;
  final bool isOptional;
  final VoidCallback onTap;
  final InlineSaveCallback onSaved;
  final VoidCallback onCancel;
  final UpdateUserProfilePatch Function(List<T> values) patchForValues;
  final UpdateUserProfilePatch Function(UserProfile user, List<T> values)?
  patchForLatestProfile;

  @override
  ConsumerState<ProfileInlineMultiChoiceEntryEditor<T>> createState() =>
      _ProfileInlineMultiChoiceEntryEditorState<T>();
}

class _ProfileInlineMultiChoiceEntryEditorState<T extends Labelled>
    extends ConsumerState<ProfileInlineMultiChoiceEntryEditor<T>>
    with InlineSaveState<ProfileInlineMultiChoiceEntryEditor<T>> {
  late Set<T> _selected = widget.currentValues.toSet();

  @override
  void didUpdateWidget(
    covariant ProfileInlineMultiChoiceEntryEditor<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValues != widget.currentValues) {
      _selected = widget.currentValues.toSet();
    }
  }

  void _cancel() {
    setState(() => _selected = widget.currentValues.toSet());
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected.length == widget.currentValues.length &&
        _selected.containsAll(widget.currentValues)) {
      _cancel();
      return;
    }
    final selectedValues = _selected.toList(growable: false);
    final patchForLatestProfile = widget.patchForLatestProfile;
    final saved = patchForLatestProfile == null
        ? await saveFields(widget.patchForValues(selectedValues))
        : await saveFieldsFromLatest(
            (latest) => patchForLatestProfile(latest, selectedValues),
          );
    if (saved && mounted) widget.onSaved();
  }

  void _toggleSelectedValue(T value) {
    if (isSaving) return;
    setState(() {
      if (_selected.contains(value)) {
        if (widget.isOptional || _selected.length > 1) {
          _selected = {..._selected}..remove(value);
        }
      } else {
        _selected = {..._selected, value};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableValues = widget.values
        .where((value) => !_selected.contains(value))
        .toList(growable: false);
    final headerValue = _selected.isEmpty
        ? widget.label
        : _selected.map((value) => value.label).join(', ');

    return CatchField.actions(
      icon: widget.icon,
      title: widget.label,
      body: _selected.isEmpty
          ? context.l10n.userProfileInlineEditorChoiceBodyLabel(
              label: widget.label,
            )
          : headerValue,
      tone: widget.isAddAffordance || _selected.isEmpty
          ? CatchFieldTone.primary
          : CatchFieldTone.normal,
      initiallyExpanded: widget.isExpanded,
      isLoading: isSaving,
      error: _errorMessage(),
      onTap: isSaving ? null : widget.onTap,
      control: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isExpanded)
            ProfileMultiChipValue<T>(
              emptyValue: widget.label,
              displayValue: widget.value,
              isEditing: widget.isExpanded,
              selected: _selected,
              enabled: !isSaving,
              isAddAffordance: widget.isAddAffordance,
              onSelectedTap: _toggleSelectedValue,
            ),
          if (widget.isExpanded && availableValues.isNotEmpty) ...[
            const SizedBox(height: CatchSpacing.s3),
            ProfileChipOptions<T>(
              values: availableValues,
              enabled: !isSaving,
              selected: const {},
              onTap: _toggleSelectedValue,
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
    return appErrorMessage(
      error,
      l10n: context.l10n,
      context: AppErrorContext.profile,
    );
  }
}

// ── Shared chip rendering widgets ─────────────────────────────────────────────

class ProfileSingleChipValue<T extends Labelled> extends StatelessWidget {
  const ProfileSingleChipValue({
    super.key,
    required this.emptyValue,
    required this.displayValue,
    required this.isEditing,
    required this.selected,
    required this.enabled,
    required this.isAddAffordance,
    required this.allowEmptySelection,
    required this.onSelectedTap,
  });

  final String emptyValue;
  final String displayValue;
  final bool isEditing;
  final T? selected;
  final bool enabled;
  final bool isAddAffordance;
  final bool allowEmptySelection;
  final ValueChanged<T> onSelectedTap;

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return ProfileChipPlaceholder(
        value: displayValue,
        isAddAffordance: isAddAffordance,
      );
    }

    final currentSelected = selected;
    if (currentSelected == null) {
      return ProfileChipPlaceholder(value: emptyValue, isAddAffordance: true);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: CatchChip(
        label: currentSelected.label,
        active: true,
        enabled: enabled,
        onTap: allowEmptySelection
            ? () => onSelectedTap(currentSelected)
            : null,
      ),
    );
  }
}

class ProfileMultiChipValue<T extends Labelled> extends StatelessWidget {
  const ProfileMultiChipValue({
    super.key,
    required this.emptyValue,
    required this.displayValue,
    required this.isEditing,
    required this.selected,
    required this.enabled,
    required this.isAddAffordance,
    required this.onSelectedTap,
  });

  final String emptyValue;
  final String displayValue;
  final bool isEditing;
  final Set<T> selected;
  final bool enabled;
  final bool isAddAffordance;
  final ValueChanged<T> onSelectedTap;

  @override
  Widget build(BuildContext context) {
    if (!isEditing) {
      return ProfileChipPlaceholder(
        value: displayValue,
        isAddAffordance: isAddAffordance,
      );
    }

    if (selected.isEmpty) {
      return ProfileChipPlaceholder(value: emptyValue, isAddAffordance: true);
    }

    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final value in selected)
          CatchChip(
            label: value.label,
            active: true,
            icon: Icon(CatchIcons.checkRounded),
            enabled: enabled,
            onTap: () => onSelectedTap(value),
          ),
      ],
    );
  }
}

class ProfileChipPlaceholder extends StatelessWidget {
  const ProfileChipPlaceholder({
    super.key,
    required this.value,
    required this.isAddAffordance,
  });

  final String value;
  final bool isAddAffordance;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(
      isAddAffordance
          ? context.l10n.userProfileInlineEditorChoiceTextValue(value: value)
          : value,
      style: CatchTextStyles.profileAnswer(
        context,
        color: isAddAffordance ? t.ink3 : null,
      ),
    );
  }
}

class ProfileChipOptions<T extends Labelled> extends StatelessWidget {
  const ProfileChipOptions({
    super.key,
    required this.values,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final List<T> values;
  final Set<T> selected;
  final bool enabled;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      children: [
        for (final value in values)
          CatchChip(
            label: value.label,
            active: selected.contains(value),
            enabled: enabled,
            onTap: () => onTap(value),
          ),
      ],
    );
  }
}
