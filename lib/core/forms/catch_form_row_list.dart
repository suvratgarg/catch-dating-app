import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

import 'catch_form_descriptors.dart';

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
      children: [
        for (final row in widget.rows)
          row.buildRow(context, _scopeFor(row), widget.errorText),
      ],
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
