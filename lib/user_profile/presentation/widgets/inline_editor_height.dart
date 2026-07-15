import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchFieldTokens;
import 'package:catch_dating_app/core/widgets/catch_field.dart';
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
  CatchFieldStatus _status = CatchFieldStatus.idle;
  Timer? _savedStatusTimer;

  @override
  void didUpdateWidget(covariant ProfileInlineHeightEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentValue != widget.currentValue) {
      _heightCm = normalizeHeightCm(widget.currentValue);
    }
  }

  @override
  void dispose() {
    _savedStatusTimer?.cancel();
    super.dispose();
  }

  void _cancel() {
    _savedStatusTimer?.cancel();
    setState(() {
      _heightCm = normalizeHeightCm(widget.currentValue);
      _status = CatchFieldStatus.idle;
    });
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_heightCm == widget.currentValue) {
      _cancel();
      return;
    }
    final saved = await saveFields(widget.patchForValue(_heightCm));
    if (saved && mounted) {
      _showSaved();
      widget.onSaved();
    }
  }

  void _showSaved() {
    _savedStatusTimer?.cancel();
    setState(() => _status = CatchFieldStatus.saved);
    _savedStatusTimer = Timer(CatchFieldTokens.savedStatusHold, () {
      if (mounted) setState(() => _status = CatchFieldStatus.idle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.isExpanded
        ? context.l10n.userProfileInlineEditorHeightBodyHeightcmCm(
            heightCm: _heightCm,
          )
        : widget.isAddAffordance
        ? null
        : widget.value;
    return CatchField.stepper(
      icon: widget.icon,
      title: widget.label,
      body: body,
      addable: widget.isAddAffordance,
      tone: widget.isAddAffordance
          ? CatchFieldTone.primary
          : CatchFieldTone.normal,
      open: widget.isExpanded,
      onOpenChanged: (expanded) {
        if (isSaving || expanded == widget.isExpanded) return;
        widget.onTap();
      },
      isLoading: isSaving,
      status: isSaving ? CatchFieldStatus.saving : _status,
      error: _errorMessage(),
      value: _heightCm,
      min: minimumHeightCm,
      max: maximumHeightCm,
      formatter: (value) => context.l10n
          .userProfileInlineEditorHeightBodyHeightcmCm(heightCm: value.toInt()),
      decreaseSemanticLabel:
          context.l10n.userProfileInlineEditorHeightTooltipDecreaseHeight,
      increaseSemanticLabel:
          context.l10n.userProfileInlineEditorHeightTooltipIncreaseHeight,
      onChanged: (value) {
        _savedStatusTimer?.cancel();
        setState(() {
          _heightCm = value.toInt();
          _status = CatchFieldStatus.idle;
        });
      },
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
