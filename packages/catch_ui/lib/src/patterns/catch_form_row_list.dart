import 'dart:async';

import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Maps typed form descriptors to canonical CatchField rows inside one
/// CatchSection, with one accordion and one per-field patch save delegate.
class CatchFormRowList<P> extends StatefulWidget {
  const CatchFormRowList({
    required this.fieldCopy,
    super.key,
    required this.rows,
    required this.savePatch,
    required this.errorText,
    this.accordion,
    this.title,
    this.count,
    this.trailing,
    this.footer,
    this.textCommitMode = CatchFormTextCommitMode.explicit,
  });

  final List<CatchFormRowDescriptor<P>> rows;
  final CatchFieldCopy fieldCopy;
  final CatchFormSave<P> savePatch;
  final CatchFormErrorText errorText;
  final CatchAccordionController? accordion;
  final String? title;
  final Object? count;
  final Widget? trailing;
  final Widget? footer;
  final CatchFormTextCommitMode textCommitMode;

  @override
  State<CatchFormRowList<P>> createState() => _CatchFormRowListState<P>();
}

class _CatchFormRowListState<P> extends State<CatchFormRowList<P>> {
  CatchAccordionController? _ownedAccordion;

  CatchAccordionController get _accordion =>
      widget.accordion ?? (_ownedAccordion ??= CatchAccordionController());

  @override
  void initState() {
    super.initState();
    _accordion.addListener(_handleAccordionChanged);
  }

  @override
  void didUpdateWidget(CatchFormRowList<P> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accordion == widget.accordion) return;
    (oldWidget.accordion ?? _ownedAccordion)?.removeListener(
      _handleAccordionChanged,
    );
    _ownedAccordion?.dispose();
    _ownedAccordion = null;
    _accordion.addListener(_handleAccordionChanged);
  }

  void _handleAccordionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _accordion.removeListener(_handleAccordionChanged);
    _ownedAccordion?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchSection.fieldRows(
      title: widget.title,
      count: widget.count,
      trailing: widget.trailing,
      footer: widget.footer,
      children: widget.rows.map((row) {
        final scope = _scopeFor(row);
        return row.accept<Widget>((
          read: (descriptor) => CatchField.read(
            copy: scope.fieldCopy,
            icon: descriptor.icon,
            title: descriptor.label,
            body: descriptor.body,
            bodyMaxLines: descriptor.bodyMaxLines,
          ),
          text: (descriptor) {
            assert(
              descriptor.maxLength == null ||
                  descriptor.contract?.maxLength == null ||
                  descriptor.maxLength! <= descriptor.contract!.maxLength!,
              'An explicit maxLength cannot exceed the schema contract.',
            );
            return CatchFormTextRowEditor<P>(
              key: ValueKey('catch-form-text-${descriptor.id}'),
              descriptor: descriptor,
              scope: scope,
              errorText: widget.errorText,
            );
          },
          singleChoice: <T>(CatchFormSingleChoiceRow<P, T> descriptor) {
            assert(
              descriptor.contract?.enumValues == null ||
                  descriptor.contractValue != null,
              'Schema-enumerated single-choice rows require contractValue.',
            );
            return CatchFormSingleChoiceRowEditor<P, T>(
              key: ValueKey('catch-form-single-choice-${descriptor.id}'),
              descriptor: descriptor,
              scope: scope,
              errorText: widget.errorText,
            );
          },
          multiChoice: <T>(CatchFormMultiChoiceRow<P, T> descriptor) {
            assert(
              descriptor.contract?.itemEnumValues == null ||
                  descriptor.contractValue != null,
              'Schema-enumerated multi-choice rows require contractValue.',
            );
            return CatchFormMultiChoiceRowEditor<P, T>(
              key: ValueKey('catch-form-multi-choice-${descriptor.id}'),
              descriptor: descriptor,
              scope: scope,
              errorText: widget.errorText,
            );
          },
          range: (descriptor) {
            assert(
              descriptor.contract?.minimum == null ||
                  descriptor.sliderMin >= descriptor.contract!.minimum!,
              'The slider minimum cannot undercut the schema contract.',
            );
            assert(
              descriptor.contract?.maximum == null ||
                  descriptor.sliderMax <= descriptor.contract!.maximum!,
              'The slider maximum cannot exceed the schema contract.',
            );
            return CatchFormRangeRowEditor<P>(
              key: ValueKey('catch-form-range-${descriptor.id}'),
              descriptor: descriptor,
              scope: scope,
              errorText: widget.errorText,
            );
          },
          custom: (descriptor) => descriptor.build(context, scope),
        ));
      }).toList(),
    );
  }

  CatchFormRowScope<P> _scopeFor(CatchFormRowDescriptor<P> row) {
    final key = row.accordionKey;
    return CatchFormRowScope<P>(
      fieldCopy: widget.fieldCopy,
      isExpanded: _accordion.isExpanded(key),
      toggle: () => _accordion.toggle(key),
      collapse: _accordion.collapse,
      save: widget.savePatch,
      textCommitMode: widget.textCommitMode,
    );
  }
}

/// Internal save feedback owned and disposed by the form list's row editors.
@internal
class CatchFormSaveState {
  Object? error;
  bool saving = false;
  CatchFieldStatus status = CatchFieldStatus.idle;
  Timer? savedTimer;

  void reset() {
    savedTimer?.cancel();
    error = null;
    status = CatchFieldStatus.idle;
  }

  void dispose() => savedTimer?.cancel();
}
