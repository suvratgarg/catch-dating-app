import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/inline_editor_save.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileInlineHeightEditor extends ConsumerStatefulWidget {
  const ProfileInlineHeightEditor({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    required this.patchForValue,
    this.isAddAffordance = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? currentValue;
  final bool isExpanded;
  final VoidCallback onTap;
  final InlineSaveCallback onSaved;
  final VoidCallback onCancel;
  final UpdateUserProfilePatch Function(int value) patchForValue;
  final bool isAddAffordance;

  @override
  ConsumerState<ProfileInlineHeightEditor> createState() =>
      _ProfileInlineHeightEditorState();
}

class _ProfileInlineHeightEditorState
    extends ConsumerState<ProfileInlineHeightEditor>
    with InlineSaveState<ProfileInlineHeightEditor> {
  late int _heightCm = normalizeHeightCm(widget.currentValue);

  @override
  void didUpdateWidget(covariant ProfileInlineHeightEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      _heightCm = normalizeHeightCm(widget.currentValue);
    }
  }

  void _cancel() {
    setState(() => _heightCm = normalizeHeightCm(widget.currentValue));
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_heightCm == widget.currentValue) {
      _cancel();
      return;
    }
    final saved = await saveFields(widget.patchForValue(_heightCm));
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.isExpanded
        ? context.l10n.userProfileInlineEditorHeightBodyHeightcmCm(
            heightCm: _heightCm,
          )
        : (widget.isAddAffordance
              ? context.l10n.userProfileInlineEditorHeightBodyValue(
                  value: widget.value,
                )
              : widget.value);
    return CatchField.actions(
      icon: widget.icon,
      title: widget.label,
      body: body,
      tone: widget.isAddAffordance
          ? CatchFieldTone.primary
          : CatchFieldTone.normal,
      initiallyExpanded: widget.isExpanded,
      isLoading: isSaving,
      error: _errorMessage(),
      onTap: isSaving ? null : widget.onTap,
      control: const SizedBox.shrink(),
      actionLeading: ProfileHeightStepperControls(
        value: _heightCm,
        enabled: !isSaving,
        onChanged: (value) => setState(() => _heightCm = value),
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

class ProfileHeightStepperControls extends StatelessWidget {
  const ProfileHeightStepperControls({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canDecrease = enabled && value > minimumHeightCm;
    final canIncrease = enabled && value < maximumHeightCm;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchIconButton.icon(
          tooltip:
              context.l10n.userProfileInlineEditorHeightTooltipDecreaseHeight,
          icon: CatchIcons.removeRounded,
          disabled: !canDecrease,
          onTap: canDecrease ? () => onChanged(value - 1) : null,
        ),
        gapW4,
        CatchIconButton.icon(
          tooltip:
              context.l10n.userProfileInlineEditorHeightTooltipIncreaseHeight,
          icon: CatchIcons.addRounded,
          disabled: !canIncrease,
          onTap: canIncrease ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
