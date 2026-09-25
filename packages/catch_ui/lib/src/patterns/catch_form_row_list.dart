import 'dart:async';

import 'package:catch_tokens/catch_tokens.dart';
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
    required this.onSave,
    required this.errorTextBuilder,
    this.accordion,
    this.title,
    this.count,
    this.trailing,
    this.footer,
    this.textCommitMode = CatchFormRowListMode.explicit,
  });

  final List<CatchFormRowDescriptor<P>> rows;
  final CatchFieldCopy fieldCopy;
  final CatchFormSave<P> onSave;
  final CatchFormErrorText errorTextBuilder;
  final CatchAccordionController? accordion;
  final String? title;
  final Object? count;
  final Widget? trailing;
  final Widget? footer;
  final CatchFormRowListMode textCommitMode;

  @override
  State<CatchFormRowList<P>> createState() => _CatchFormRowListState<P>();
}

class _CatchFormRowListState<P> extends State<CatchFormRowList<P>> {
  CatchAccordionController? _ownedAccordion;
  bool _saving = false;

  Future<bool> _save(P patch) async {
    if (_saving) return false;
    setState(() => _saving = true);
    try {
      return await widget.onSave(patch);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
    final section = CatchSection.formRows(
      title: widget.title,
      count: widget.count,
      trailing: widget.trailing,
      children: widget.rows.map((row) {
        final scope = _scopeFor(row);
        return row.accept<Widget>((
          read: (descriptor) => CatchField.read(
            key: ValueKey('catch-form-read-${descriptor.id}'),
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
            return CatchFormTextField<P>(
              key: ValueKey('catch-form-text-${descriptor.id}'),
              descriptor: descriptor,
              scope: scope,
              errorTextBuilder: widget.errorTextBuilder,
            );
          },
          singleChoice: <T>(CatchFormSingleChoiceRow<P, T> descriptor) {
            assert(
              descriptor.contract?.enumValues == null ||
                  descriptor.contractValue != null,
              'Schema-enumerated single-choice rows require contractValue.',
            );
            return CatchFormChoiceField<P, T>.single(
              key: ValueKey('catch-form-single-choice-${descriptor.id}'),
              descriptor: descriptor,
              scope: scope,
              errorTextBuilder: widget.errorTextBuilder,
            );
          },
          multiChoice: <T>(CatchFormMultiChoiceRow<P, T> descriptor) {
            assert(
              descriptor.contract?.itemEnumValues == null ||
                  descriptor.contractValue != null,
              'Schema-enumerated multi-choice rows require contractValue.',
            );
            return CatchFormChoiceField<P, T>.multiple(
              key: ValueKey('catch-form-multi-choice-${descriptor.id}'),
              descriptor: descriptor,
              scope: scope,
              errorTextBuilder: widget.errorTextBuilder,
            );
          },
          range: (descriptor) {
            final maximumContract =
                descriptor.maximumContract ?? descriptor.contract;
            assert(
              descriptor.contract?.minimum == null ||
                  descriptor.sliderMin >= descriptor.contract!.minimum!,
              'The slider minimum cannot undercut the schema contract.',
            );
            assert(
              maximumContract?.maximum == null ||
                  descriptor.sliderMax <= maximumContract!.maximum!,
              'The slider maximum cannot exceed the schema contract.',
            );
            return CatchFormRangeField<P>(
              key: ValueKey('catch-form-range-${descriptor.id}'),
              descriptor: descriptor,
              scope: scope,
              errorTextBuilder: widget.errorTextBuilder,
            );
          },
          custom: (descriptor) => descriptor.build(context, scope),
        ));
      }).toList(),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AbsorbPointer(absorbing: _saving, child: section),
        if (widget.footer case final footer?) CatchPageBody(child: footer),
      ],
    );
  }

  CatchFormRowScope<P> _scopeFor(CatchFormRowDescriptor<P> row) {
    final key = row.accordionKey;
    return CatchFormRowScope<P>(
      fieldCopy: widget.fieldCopy,
      isExpanded: _accordion.isExpanded(key),
      toggle: () {
        if (!_saving) _accordion.toggle(key);
      },
      collapse: _accordion.collapse,
      save: _save,
      textCommitMode: widget.textCommitMode,
    );
  }
}

/// Internal save feedback owned and disposed by the form list's row editors.
@internal
class CatchFormSaveState extends ChangeNotifier {
  Object? error;
  CatchFieldStatus status = CatchFieldStatus.idle;
  Timer? _savedTimer;
  bool _disposed = false;

  bool get saving => status == CatchFieldStatus.saving;

  /// One pending/error/success lifecycle for every typed editor. A rejected
  /// save keeps its draft open; only an accepted save earns success feedback.
  Future<bool> submit(Future<bool> Function() save) async {
    if (_disposed || saving) return false;
    _savedTimer?.cancel();
    error = null;
    status = CatchFieldStatus.saving;
    notifyListeners();
    try {
      final accepted = await save();
      if (_disposed) return false;
      status = accepted ? CatchFieldStatus.saved : CatchFieldStatus.idle;
      if (accepted) {
        _savedTimer = Timer(CatchFieldTokens.savedStatusHold, () {
          if (_disposed) return;
          status = CatchFieldStatus.idle;
          notifyListeners();
        });
      }
      notifyListeners();
      return accepted;
    } catch (failure) {
      if (_disposed) return false;
      error = failure;
      status = CatchFieldStatus.idle;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    if (_disposed || saving) return;
    _savedTimer?.cancel();
    error = null;
    status = CatchFieldStatus.idle;
  }

  @override
  void dispose() {
    _disposed = true;
    _savedTimer?.cancel();
    super.dispose();
  }
}
