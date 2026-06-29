import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchLayout, CatchIcon, CatchOpacity, CatchSpacing, CatchTokens;
import 'package:catch_dating_app/core/widgets/catch_field.dart';
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
        ? '$_heightCm cm'
        : (widget.isAddAffordance ? '+ ${widget.value}' : widget.value);
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
      actionLeading: ProfileHeightStepperControls(value: _heightCm,
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
    return appErrorMessage(error, context: AppErrorContext.profile);
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
      ProfileHeightStepButton(tooltip: 'Decrease height',
        icon: CatchIcons.removeRounded,
        enabled: canDecrease,
        onPressed: () => onChanged(value - 1),
      ),
      gapW4,
      ProfileHeightStepButton(tooltip: 'Increase height',
        icon: CatchIcons.addRounded,
        enabled: canIncrease,
        onPressed: () => onChanged(value + 1),
      ),
    ],
  );
  }
}

class ProfileHeightStepButton extends StatelessWidget {
  const ProfileHeightStepButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
  return Tooltip(
    message: tooltip,
    child: Material(
      color: t.raised,
      shape: const CircleBorder(),
      child: InkResponse(
        onTap: enabled ? onPressed : null,
        radius: CatchSpacing.micro18,
        customBorder: const CircleBorder(),
        child: SizedBox.square(
          dimension: CatchLayout.profileHeightStepButtonExtent,
          child: Icon(
            icon,
            size: CatchIcon.profileHeightStep,
            color: enabled
                ? t.ink
                : t.ink3.withValues(alpha: CatchOpacity.profileDisabledIcon),
          ),
        ),
      ),
    ),
  );
  }
}
