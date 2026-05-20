import 'dart:math' as math;

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchMotion, CatchRadius, CatchSpacing, CatchTokens;
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_edit_controller.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ProfileInlineSaveCallback = VoidCallback;

Future<void> _saveField({
  required WidgetRef ref,
  required Map<String, dynamic> fields,
}) {
  return ProfileEditController.saveFieldsMutation.run(
    ref,
    (tx) async =>
        tx.get(profileEditControllerProvider.notifier).saveFields(fields),
  );
}

String _enumName(Object value) => value is Enum ? value.name : value.toString();

mixin _InlineSaveState<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isSaving = false;
  Object? _saveError;

  bool get isSaving => _isSaving;

  Future<bool> saveFields(Map<String, dynamic> fields) async {
    if (_isSaving) return false;
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await _saveField(ref: ref, fields: fields);
      if (!mounted) return false;
      setState(() => _isSaving = false);
      return true;
    } catch (error) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _saveError = error;
      });
      return false;
    }
  }

  Widget? buildSaveError() {
    final error = _saveError;
    if (error == null) return null;
    return ErrorBanner(
      message: appErrorMessage(error, context: AppErrorContext.profile),
    );
  }
}

class _InlineEditorPanel extends StatelessWidget {
  const _InlineEditorPanel({
    required this.isSaving,
    required this.onCancel,
    required this.onSubmit,
    this.saveError,
    this.actionLeading,
    this.contentActionGap = CatchSpacing.s3,
    this.children = const [],
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final Widget? saveError;
  final Widget? actionLeading;
  final double contentActionGap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final hasEditorContent = children.isNotEmpty || saveError != null;
    return _InlineEditorPadding(
      compact: !hasEditorContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (saveError != null) ...[saveError!, gapH12],
          ...children,
          if (children.isNotEmpty) SizedBox(height: contentActionGap),
          _InlineEditorActions(
            isSaving: isSaving,
            onCancel: onCancel,
            onSubmit: onSubmit,
            leading: actionLeading,
          ),
        ],
      ),
    );
  }
}

class ProfileInlineFieldScaffold extends StatelessWidget {
  const ProfileInlineFieldScaffold({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.isExpanded,
    required this.onTap,
    required this.isSaving,
    required this.onCancel,
    required this.onSubmit,
    this.valueContent,
    this.animateValueContent = true,
    this.isAddAffordance = false,
    this.saveError,
    this.actionLeading,
    this.contentActionGap = CatchSpacing.s3,
    this.editorChildren = const [],
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isExpanded;
  final VoidCallback onTap;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final Widget? valueContent;
  final bool animateValueContent;
  final bool isAddAffordance;
  final Widget? saveError;
  final Widget? actionLeading;
  final double contentActionGap;
  final List<Widget> editorChildren;

  @override
  Widget build(BuildContext context) {
    return ProfileInlineDisclosure(
      isExpanded: isExpanded,
      header: ProfileInfoTile(
        icon: icon,
        label: label,
        value: value,
        onTap: isSaving ? null : onTap,
        isExpanded: isExpanded,
        isAddAffordance: isAddAffordance,
        animateValueContent: animateValueContent,
        valueContent: valueContent,
      ),
      body: _InlineEditorPanel(
        saveError: saveError,
        actionLeading: actionLeading,
        contentActionGap: contentActionGap,
        isSaving: isSaving,
        onCancel: onCancel,
        onSubmit: onSubmit,
        children: editorChildren,
      ),
    );
  }
}

class ProfileInlineTextValue extends StatelessWidget {
  const ProfileInlineTextValue({
    super.key,
    required this.label,
    required this.displayValue,
    required this.controller,
    required this.focusNode,
    required this.isEditing,
    required this.enabled,
    this.placeholder,
    this.isAddAffordance = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.collapseStackedBlankLines = false,
    this.autofillHints,
    this.onSubmitted,
  });

  static const double _minimumUnderlineWidth = 28;
  static const double _underlineGap = 2;
  static const double _underlineHeight = 1.5;

  final String label;
  final String displayValue;
  final String? placeholder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEditing;
  final bool enabled;
  final bool isAddAffordance;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final bool collapseStackedBlankLines;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final direction = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final valueStyle = CatchTextStyles.bodyL(
      context,
      color: isAddAffordance && !isEditing ? t.ink3 : t.ink,
    );
    final lineHeight =
        textScaler.scale(valueStyle.fontSize ?? 18) *
        (valueStyle.height ?? 1.2);

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            if (!isEditing) {
              return Text(
                isAddAffordance ? '+ $displayValue' : displayValue,
                key: ValueKey(
                  'profile-inline-display-$label-$displayValue-$isAddAffordance',
                ),
                style: valueStyle,
              );
            }

            final inputText = controller.text;
            final hintText = placeholder ?? displayValue;
            final measuredText = inputText.isEmpty ? hintText : inputText;
            final textMetrics = _measureInlineText(
              text: measuredText,
              style: valueStyle,
              direction: direction,
              textScaler: textScaler,
              maxWidth: constraints.maxWidth,
              maxLines: maxLines,
            );
            final visibleLineCount = math.max(
              minLines ?? 1,
              textMetrics.lineCount,
            );
            final editableTextHeight = lineHeight * visibleLineCount;
            final editableHeight =
                editableTextHeight + _underlineGap + _underlineHeight;
            final isMultiline = maxLines != 1 || minLines != null;
            final underlineTextWidth = isMultiline
                ? textMetrics.maxLineWidth
                : textMetrics.width;
            final underlineWidth = underlineTextWidth
                .clamp(_minimumUnderlineWidth, constraints.maxWidth)
                .toDouble();

            return SizedBox(
              width: double.infinity,
              height: editableHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: editableTextHeight,
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        if (inputText.isEmpty && hintText.isNotEmpty)
                          IgnorePointer(
                            child: Text(
                              hintText,
                              style: CatchTextStyles.bodyL(
                                context,
                                color: t.ink3,
                              ),
                            ),
                          ),
                        Semantics(
                          textField: true,
                          label: label,
                          child: EditableText(
                            controller: controller,
                            focusNode: focusNode,
                            readOnly: !enabled,
                            maxLines: maxLines,
                            minLines: minLines,
                            keyboardType: keyboardType,
                            textCapitalization: textCapitalization,
                            textInputAction:
                                textInputAction ??
                                (maxLines == 1
                                    ? TextInputAction.done
                                    : TextInputAction.newline),
                            autofillHints: autofillHints,
                            inputFormatters: [
                              if (collapseStackedBlankLines)
                                const _StackedBlankLinesFormatter(),
                              if (maxLength != null)
                                LengthLimitingTextInputFormatter(maxLength),
                            ],
                            onSubmitted: onSubmitted,
                            style: valueStyle,
                            strutStyle: StrutStyle.fromTextStyle(
                              valueStyle,
                              forceStrutHeight: true,
                            ),
                            cursorColor: t.primary,
                            backgroundCursorColor: t.primary,
                            selectionColor: t.primary.withValues(alpha: 0.22),
                            cursorWidth: 2,
                            cursorRadius: const Radius.circular(
                              CatchRadius.pill,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _underlineGap),
                  AnimatedContainer(
                    key: const ValueKey('profile-inline-underline'),
                    width: underlineWidth,
                    height: _underlineHeight,
                    duration: CatchMotion.fast,
                    curve: CatchMotion.standardCurve,
                    decoration: BoxDecoration(
                      color: t.primary.withValues(alpha: enabled ? 0.9 : 0.35),
                      borderRadius: BorderRadius.circular(CatchRadius.pill),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

_InlineTextMetrics _measureInlineText({
  required String text,
  required TextStyle style,
  required TextDirection direction,
  required TextScaler textScaler,
  required double maxWidth,
  required int? maxLines,
}) {
  final measuredText = text.isEmpty ? ' ' : text;
  final painter = TextPainter(
    text: TextSpan(text: measuredText, style: style),
    textDirection: direction,
    textScaler: textScaler,
    maxLines: maxLines,
  )..layout(maxWidth: maxWidth);
  final lines = painter.computeLineMetrics();
  return _InlineTextMetrics(
    width: text.isEmpty ? 0 : painter.width,
    lineCount: math.max(1, lines.length),
    lastLineWidth: lines.isEmpty ? 0 : lines.last.width,
    maxLineWidth: lines.fold<double>(
      0,
      (maxWidth, line) => math.max(maxWidth, line.width),
    ),
  );
}

class _InlineTextMetrics {
  const _InlineTextMetrics({
    required this.width,
    required this.lineCount,
    required this.lastLineWidth,
    required this.maxLineWidth,
  });

  final double width;
  final int lineCount;
  final double lastLineWidth;
  final double maxLineWidth;
}

class ProfileInlineTextEntryEditor extends ConsumerStatefulWidget {
  const ProfileInlineTextEntryEditor({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.currentFieldValue,
    this.isAddAffordance = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.collapseStackedBlankLines = false,
    this.normalizeInput,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
    this.toFields,
  });

  final IconData icon;
  final String label;
  final String value;
  final String currentValue;
  final Object? currentFieldValue;
  final String fieldName;
  final bool isExpanded;
  final bool isAddAffordance;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final bool collapseStackedBlankLines;
  final String Function(String value)? normalizeInput;
  final VoidCallback onTap;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;
  final Map<String, dynamic> Function(String value)? toFields;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineTextEntryEditor> createState() =>
      _ProfileInlineTextEntryEditorState();
}

class _ProfileInlineTextEntryEditorState
    extends ConsumerState<ProfileInlineTextEntryEditor>
    with _InlineSaveState<ProfileInlineTextEntryEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _focusNode = FocusNode();
    _controller.addListener(_clearValidationError);
    if (widget.isExpanded) {
      _requestFocusAfterExpansionFrame();
    }
  }

  @override
  void didUpdateWidget(covariant ProfileInlineTextEntryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded) {
      if (oldWidget.fieldName != widget.fieldName ||
          oldWidget.currentValue != widget.currentValue) {
        _controller.text = widget.currentValue;
      }
      if (!oldWidget.isExpanded) {
        _requestFocusAfterExpansionFrame();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_clearValidationError);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearValidationError() {
    if (_validationError == null) return;
    setState(() => _validationError = null);
  }

  void _requestFocusAfterExpansionFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isExpanded || isSaving || _focusNode.hasFocus) {
        return;
      }
      _focusNode.requestFocus();
    });
  }

  void _cancel() {
    _controller.text = widget.currentValue;
    widget.onCancel();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final normalizedText =
        widget.normalizeInput?.call(_controller.text) ?? _controller.text;
    if (normalizedText != _controller.text) {
      _controller.text = normalizedText;
    }

    final validationError = widget.validator?.call(normalizedText);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    final rawValue = normalizedText.trim();
    final Object? fieldValue = widget.toFieldValue != null
        ? widget.toFieldValue!(rawValue)
        : rawValue;
    final currentFieldValue = widget.currentFieldValue;
    final comparableCurrentValue = currentFieldValue ?? widget.currentValue;
    final isUnchanged =
        fieldValue == comparableCurrentValue ||
        (fieldValue == null && widget.currentValue.trim().isEmpty) ||
        (fieldValue == '' && currentFieldValue == null);
    if (isUnchanged) {
      _cancel();
      return;
    }

    final fields =
        widget.toFields?.call(rawValue) ?? {widget.fieldName: fieldValue};
    final saved = await saveFields(fields);
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: widget.value,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: isSaving,
      isAddAffordance: widget.isAddAffordance,
      animateValueContent: false,
      valueContent: ProfileInlineTextValue(
        label: widget.label,
        displayValue: widget.value,
        placeholder: widget.isAddAffordance ? widget.value : null,
        controller: _controller,
        focusNode: _focusNode,
        isEditing: widget.isExpanded,
        enabled: !isSaving,
        isAddAffordance: widget.isAddAffordance,
        keyboardType: widget.keyboardType,
        textCapitalization: widget.textCapitalization,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        showCounter: widget.showCounter,
        collapseStackedBlankLines: widget.collapseStackedBlankLines,
        autofillHints: widget.autofillHints,
        onSubmitted: (_) => _submit(),
      ),
      saveError: _validationError == null
          ? buildSaveError()
          : ErrorBanner(message: _validationError!),
      actionLeading: widget.showCounter && widget.maxLength != null
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => Text(
                '${_controller.text.length} / ${widget.maxLength}',
                key: const ValueKey('profile-inline-counter'),
                style: CatchTextStyles.labelM(context),
              ),
            )
          : null,
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }
}

class _StackedBlankLinesFormatter extends TextInputFormatter {
  const _StackedBlankLinesFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final collapsed = collapseStackedPromptBlankLines(newValue.text);
    if (collapsed == newValue.text) return newValue;

    final selectionEnd = newValue.selection.end;
    final normalizedOffset = selectionEnd < 0
        ? collapsed.length
        : collapseStackedPromptBlankLines(
            newValue.text.substring(0, selectionEnd),
          ).length;
    final offset = normalizedOffset.clamp(0, collapsed.length);
    return TextEditingValue(
      text: collapsed,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }
}

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
    this.isAddAffordance = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? currentValue;
  final bool isExpanded;
  final VoidCallback onTap;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;
  final bool isAddAffordance;

  @override
  ConsumerState<ProfileInlineHeightEditor> createState() =>
      _ProfileInlineHeightEditorState();
}

class _ProfileInlineHeightEditorState
    extends ConsumerState<ProfileInlineHeightEditor>
    with _InlineSaveState<ProfileInlineHeightEditor> {
  late int _heightCm = normalizeHeightCm(widget.currentValue);

  @override
  void didUpdateWidget(covariant ProfileInlineHeightEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded) return;
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
    final saved = await saveFields({'height': _heightCm});
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.isExpanded ? '$_heightCm cm' : widget.value;
    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: displayValue,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: isSaving,
      isAddAffordance: widget.isAddAffordance,
      animateValueContent: false,
      saveError: buildSaveError(),
      actionLeading: _ProfileHeightStepperControls(
        value: _heightCm,
        enabled: !isSaving,
        onChanged: (value) => setState(() => _heightCm = value),
      ),
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }
}

class _ProfileHeightStepperControls extends StatelessWidget {
  const _ProfileHeightStepperControls({
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
        _ProfileHeightStepButton(
          tooltip: 'Decrease height',
          icon: Icons.remove_rounded,
          enabled: canDecrease,
          onPressed: () => onChanged(value - 1),
        ),
        gapW4,
        _ProfileHeightStepButton(
          tooltip: 'Increase height',
          icon: Icons.add_rounded,
          enabled: canIncrease,
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _ProfileHeightStepButton extends StatelessWidget {
  const _ProfileHeightStepButton({
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
          radius: Sizes.p18,
          customBorder: const CircleBorder(),
          child: SizedBox.square(
            dimension: 36,
            child: Icon(
              icon,
              size: 21,
              color: enabled ? t.ink : t.ink3.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

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
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineSingleChoiceEntryEditor<T>> createState() =>
      _ProfileInlineSingleChoiceEntryEditorState<T>();
}

class _ProfileInlineSingleChoiceEntryEditorState<T extends Labelled>
    extends ConsumerState<ProfileInlineSingleChoiceEntryEditor<T>>
    with _InlineSaveState<ProfileInlineSingleChoiceEntryEditor<T>> {
  late T? _selected = widget.currentValue;

  @override
  void didUpdateWidget(
    covariant ProfileInlineSingleChoiceEntryEditor<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded) return;
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _selected = widget.currentValue;
    }
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected == widget.currentValue) {
      widget.onCancel();
      return;
    }
    final saved = await saveFields({
      widget.fieldName: _selected == null ? null : _enumName(_selected!),
    });
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

    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: widget.value,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: isSaving,
      isAddAffordance: widget.isAddAffordance,
      animateValueContent: false,
      valueContent: _ProfileSingleChipValueEditor<T>(
        emptyValue: widget.label,
        displayValue: widget.value,
        isEditing: widget.isExpanded,
        selected: _selected,
        enabled: !isSaving,
        isAddAffordance: widget.isAddAffordance,
        allowEmptySelection: widget.allowEmptySelection,
        onSelectedTap: _toggleSelectedValue,
      ),
      saveError: buildSaveError(),
      onCancel: widget.onCancel,
      onSubmit: _submit,
      editorChildren: [
        if (availableValues.isNotEmpty)
          _ProfileChipOptions<T>(
            values: availableValues,
            enabled: !isSaving,
            selected: const {},
            onTap: _toggleSelectedValue,
          ),
      ],
    );
  }
}

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
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineMultiChoiceEntryEditor<T>> createState() =>
      _ProfileInlineMultiChoiceEntryEditorState<T>();
}

class _ProfileInlineMultiChoiceEntryEditorState<T extends Labelled>
    extends ConsumerState<ProfileInlineMultiChoiceEntryEditor<T>>
    with _InlineSaveState<ProfileInlineMultiChoiceEntryEditor<T>> {
  late Set<T> _selected = widget.currentValues.toSet();

  @override
  void didUpdateWidget(
    covariant ProfileInlineMultiChoiceEntryEditor<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded) return;
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValues != widget.currentValues) {
      _selected = widget.currentValues.toSet();
    }
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected.length == widget.currentValues.length &&
        _selected.containsAll(widget.currentValues)) {
      widget.onCancel();
      return;
    }
    final saved = await saveFields({
      widget.fieldName: _selected.map(_enumName).toList(),
    });
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

    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.label,
      value: widget.value,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: isSaving,
      isAddAffordance: widget.isAddAffordance,
      animateValueContent: false,
      valueContent: _ProfileMultiChipValueEditor<T>(
        emptyValue: widget.label,
        displayValue: widget.value,
        isEditing: widget.isExpanded,
        selected: _selected,
        enabled: !isSaving,
        isAddAffordance: widget.isAddAffordance,
        onSelectedTap: _toggleSelectedValue,
      ),
      saveError: buildSaveError(),
      onCancel: widget.onCancel,
      onSubmit: _submit,
      editorChildren: [
        if (availableValues.isNotEmpty)
          _ProfileChipOptions<T>(
            values: availableValues,
            enabled: !isSaving,
            selected: const {},
            onTap: _toggleSelectedValue,
          ),
      ],
    );
  }
}

class _ProfileSingleChipValueEditor<T extends Labelled>
    extends StatelessWidget {
  const _ProfileSingleChipValueEditor({
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
    final selected = this.selected;
    if (!isEditing) {
      return _ProfileChipPlaceholder(
        value: displayValue,
        isAddAffordance: isAddAffordance,
      );
    }

    if (selected == null) {
      return _ProfileChipPlaceholder(value: emptyValue, isAddAffordance: true);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: CatchChip(
        label: selected.label,
        active: true,
        enabled: enabled,
        onTap: allowEmptySelection ? () => onSelectedTap(selected) : null,
      ),
    );
  }
}

class _ProfileMultiChipValueEditor<T extends Labelled> extends StatelessWidget {
  const _ProfileMultiChipValueEditor({
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
      return _ProfileChipPlaceholder(
        value: displayValue,
        isAddAffordance: isAddAffordance,
      );
    }

    if (selected.isEmpty) {
      return _ProfileChipPlaceholder(value: emptyValue, isAddAffordance: true);
    }

    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final value in selected)
          CatchChip(
            label: value.label,
            active: true,
            icon: const Icon(Icons.check_rounded),
            enabled: enabled,
            onTap: () => onSelectedTap(value),
          ),
      ],
    );
  }
}

class _ProfileChipPlaceholder extends StatelessWidget {
  const _ProfileChipPlaceholder({
    required this.value,
    required this.isAddAffordance,
  });

  final String value;
  final bool isAddAffordance;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(
      isAddAffordance ? '+ $value' : value,
      style: CatchTextStyles.bodyL(
        context,
        color: isAddAffordance ? t.ink3 : null,
      ),
    );
  }
}

class _ProfileChipOptions<T extends Labelled> extends StatelessWidget {
  const _ProfileChipOptions({
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
    required this.minFieldName,
    required this.maxFieldName,
    required this.onSaved,
    required this.onCancel,
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
  final String minFieldName;
  final String maxFieldName;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineRangeEditor> createState() =>
      _ProfileInlineRangeEditorState();
}

class _ProfileInlineRangeEditorState
    extends ConsumerState<ProfileInlineRangeEditor>
    with _InlineSaveState<ProfileInlineRangeEditor> {
  late RangeValues _range = RangeValues(
    widget.currentMin.toDouble(),
    widget.currentMax.toDouble(),
  );

  @override
  void didUpdateWidget(covariant ProfileInlineRangeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded) return;
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
    final saved = await saveFields({
      widget.minFieldName: newMin,
      widget.maxFieldName: newMax,
    });
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final displayValue = widget.isExpanded
        ? '${widget.labelText(_range.start)} - ${widget.labelText(_range.end)}'
        : widget.value;
    return ProfileInlineFieldScaffold(
      icon: widget.icon,
      label: widget.title,
      value: displayValue,
      isExpanded: widget.isExpanded,
      onTap: widget.onTap,
      isSaving: isSaving,
      animateValueContent: false,
      saveError: buildSaveError(),
      contentActionGap: Sizes.p2,
      onCancel: _cancel,
      onSubmit: _submit,
      editorChildren: [
        CatchRangeSlider(
          min: widget.sliderMin,
          max: widget.sliderMax,
          divisions: widget.divisions,
          values: _range,
          onChanged: isSaving
              ? null
              : (values) => setState(() => _range = values),
        ),
      ],
    );
  }
}

class _InlineEditorActions extends StatelessWidget {
  const _InlineEditorActions({
    required this.isSaving,
    required this.onCancel,
    required this.onSubmit,
    this.leading,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null)
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: leading),
          )
        else
          const Spacer(),
        CatchTextButton(
          label: 'Cancel',
          onPressed: isSaving ? null : onCancel,
          tone: CatchTextButtonTone.neutral,
        ),
        gapW12,
        CatchButton(
          label: 'Done',
          onPressed: isSaving ? null : onSubmit,
          isLoading: isSaving,
          size: CatchButtonSize.sm,
        ),
      ],
    );
  }
}

class _InlineEditorPadding extends StatelessWidget {
  const _InlineEditorPadding({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: compact ? 0 : CatchSpacing.s2,
        left: CatchSpacing.s10,
        right: CatchSpacing.s2,
        bottom: compact ? CatchSpacing.s3 : CatchSpacing.s5,
      ),
      child: child,
    );
  }
}
