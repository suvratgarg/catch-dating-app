import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/inline_editor_save.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileInlineRangeEditor extends ConsumerStatefulWidget {
  const ProfileInlineRangeEditor({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.currentMin,
    required this.currentMax,
    required this.isExpanded,
    required this.onTap,
    required this.sliderMin,
    required this.sliderMax,
    required this.divisions,
    required this.labelText,
    required this.onSaved,
    required this.onCancel,
    required this.patchForRange,
    this.patchForLatestProfile,
    this.saveEndValue,
    this.savedCurrentMax,
  });

  final IconData icon;
  final String title;
  final String value;
  final int currentMin;
  final int currentMax;
  final bool isExpanded;
  final VoidCallback onTap;
  final double sliderMin;
  final double sliderMax;
  final int divisions;
  final String Function(double) labelText;
  final int Function(int)? saveEndValue;
  final int? savedCurrentMax;
  final InlineSaveCallback onSaved;
  final VoidCallback onCancel;
  final UpdateUserProfilePatch Function(int min, int max) patchForRange;
  final UpdateUserProfilePatch Function(UserProfile user, int min, int max)?
  patchForLatestProfile;

  @override
  ConsumerState<ProfileInlineRangeEditor> createState() =>
      _ProfileInlineRangeEditorState();
}

class _ProfileInlineRangeEditorState
    extends ConsumerState<ProfileInlineRangeEditor>
    with InlineSaveState<ProfileInlineRangeEditor> {
  late RangeValues _range = RangeValues(
    widget.currentMin.toDouble(),
    widget.currentMax.toDouble(),
  );

  @override
  void didUpdateWidget(covariant ProfileInlineRangeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentMin != widget.currentMin ||
        oldWidget.currentMax != widget.currentMax) {
      _range = RangeValues(
        widget.currentMin.toDouble(),
        widget.currentMax.toDouble(),
      );
    }
  }

  void _cancel() {
    setState(() {
      _range = RangeValues(
        widget.currentMin.toDouble(),
        widget.currentMax.toDouble(),
      );
    });
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final newMin = _range.start.round();
    final newMax =
        widget.saveEndValue?.call(_range.end.round()) ?? _range.end.round();
    if (newMin == widget.currentMin &&
        newMax == (widget.savedCurrentMax ?? widget.currentMax)) {
      _cancel();
      return;
    }
    final patchForLatestProfile = widget.patchForLatestProfile;
    final saved = patchForLatestProfile == null
        ? await saveFields(widget.patchForRange(newMin, newMax))
        : await saveFieldsFromLatest(
            (latest) => patchForLatestProfile(latest, newMin, newMax),
          );
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.isExpanded
        ? '${widget.labelText(_range.start)} - ${widget.labelText(_range.end)}'
        : widget.value;
    return CatchField.actions(
      icon: widget.icon,
      title: widget.title,
      body: body,
      initiallyExpanded: widget.isExpanded,
      isLoading: isSaving,
      error: _errorMessage(),
      onTap: isSaving ? null : widget.onTap,
      control: CatchRangeSlider(
        min: widget.sliderMin,
        max: widget.sliderMax,
        divisions: widget.divisions,
        values: _range,
        onChanged: isSaving
            ? null
            : (values) => setState(() => _range = values),
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
