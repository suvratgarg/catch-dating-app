import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_response_query.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Copy is supplied by the Forms route's localization owner when the manager
/// callable is mounted. This widget does not introduce a second form model.
class HostResponseQueryEditorCopy {
  const HostResponseQueryEditorCopy({
    required this.title,
    required this.matchAll,
    required this.matchAny,
    required this.field,
    required this.condition,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.yes,
    required this.no,
    required this.addCondition,
    required this.addGroup,
    required this.remove,
    required this.apply,
    required this.reset,
    required this.invalidCondition,
    required this.operatorLabels,
  });

  final String title;
  final String matchAll;
  final String matchAny;
  final String field;
  final String condition;
  final String value;
  final String minimum;
  final String maximum;
  final String yes;
  final String no;
  final String addCondition;
  final String addGroup;
  final String remove;
  final String apply;
  final String reset;
  final String invalidCondition;
  final Map<HostResponseOperator, String> operatorLabels;
}

/// A bounded editor for one immutable published version's permitted fields.
/// The caller owns loading, page state and the actual manager callable.
class HostResponseQueryEditor extends StatefulWidget {
  const HostResponseQueryEditor({
    super.key,
    required this.fields,
    required this.copy,
    required this.onApply,
    this.initial,
  });

  final List<HostResponseQueryField> fields;
  final HostResponseQueryEditorCopy copy;
  final HostResponsePredicate? initial;
  final ValueChanged<HostResponsePredicate?> onApply;

  @override
  State<HostResponseQueryEditor> createState() =>
      _HostResponseQueryEditorState();
}

class _HostResponseQueryEditorState extends State<HostResponseQueryEditor> {
  late HostResponseGroup _root;

  @override
  void initState() {
    super.initState();
    _root = _initialRoot(widget.initial);
  }

  @override
  void didUpdateWidget(covariant HostResponseQueryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.initial, widget.initial) ||
        !identical(oldWidget.fields, widget.fields)) {
      _root = _initialRoot(widget.initial);
    }
  }

  HostResponseGroup _initialRoot(HostResponsePredicate? predicate) =>
      predicate is HostResponseGroup
      ? predicate
      : HostResponseGroup(
          match: HostResponseMatch.all,
          children: predicate == null ? const [] : [predicate],
        );

  HostResponseCondition _defaultCondition() {
    final field = widget.fields.first;
    return HostResponseCondition(
      questionId: field.questionId,
      operator: field.operators.contains(HostResponseOperator.present)
          ? HostResponseOperator.present
          : field.operators.first,
    );
  }

  HostResponseGroup _groupAt(List<int> path) {
    HostResponseGroup group = _root;
    for (final index in path) {
      group = group.children[index] as HostResponseGroup;
    }
    return group;
  }

  void _replace(List<int> path, HostResponsePredicate? replacement) {
    HostResponseGroup rewrite(HostResponseGroup group, int level) {
      final index = path[level];
      final children = [...group.children];
      if (level == path.length - 1) {
        if (replacement == null) {
          children.removeAt(index);
        } else {
          children[index] = replacement;
        }
      } else {
        children[index] = rewrite(
          children[index] as HostResponseGroup,
          level + 1,
        );
      }
      return HostResponseGroup(match: group.match, children: children);
    }

    setState(() => _root = rewrite(_root, 0));
  }

  void _append(List<int> path, HostResponsePredicate node) {
    final group = _groupAt(path);
    final next = HostResponseGroup(
      match: group.match,
      children: [...group.children, node],
    );
    if (path.isEmpty) {
      setState(() => _root = next);
    } else {
      _replace(path, next);
    }
  }

  void _setMatch(List<int> path, HostResponseMatch match) {
    final group = _groupAt(path);
    final next = HostResponseGroup(match: match, children: group.children);
    if (path.isEmpty) {
      setState(() => _root = next);
    } else {
      _replace(path, next);
    }
  }

  void _apply() {
    if (_root.children.isEmpty) {
      widget.onApply(null);
      return;
    }
    try {
      _root.validate({
        for (final field in widget.fields) field.questionId: field,
      });
      widget.onApply(_root);
    } on ArgumentError {
      showCatchSnackBar(context, widget.copy.invalidCondition);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    return CatchSection.content(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(copy.title, style: CatchTextStyles.sectionTitle(context)),
          gapH16,
          if (widget.fields.isNotEmpty) _buildGroup(const [], _root),
          if (widget.fields.isEmpty)
            Text(
              copy.invalidCondition,
              style: CatchTextStyles.supporting(context),
            ),
          gapH16,
          Row(
            children: [
              Expanded(
                child: CatchButton(
                  label: copy.reset,
                  variant: CatchButtonVariant.secondary,
                  onPressed: () => setState(() => _root = _initialRoot(null)),
                ),
              ),
              gapW12,
              Expanded(
                child: CatchButton(
                  label: copy.apply,
                  onPressed: widget.fields.isEmpty ? null : _apply,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroup(List<int> path, HostResponseGroup group) {
    final copy = widget.copy;
    final canAdd = _root.conditionCount < 20;
    // Root + nested group + condition is the full three-level expression.
    final canNest = path.isEmpty && canAdd;
    return Padding(
      padding: path.isEmpty
          ? EdgeInsets.zero
          : CatchInsets.detailInlineRowBottomGap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchChoiceInput<HostResponseMatch>.segmented(
            key: ValueKey('response-group-${path.join('-')}'),
            options: [
              CatchOption(value: HostResponseMatch.all, label: copy.matchAll),
              CatchOption(value: HostResponseMatch.any, label: copy.matchAny),
            ],
            selected: group.match,
            contractExemption: 'Match mode is a local filter draft choice.',
            onChanged: (value) => _setMatch(path, value),
          ),
          gapH12,
          for (var index = 0; index < group.children.length; index++) ...[
            if (group.children[index]
                case final HostResponseCondition condition)
              _buildCondition([...path, index], condition)
            else if (group.children[index] case final HostResponseGroup nested)
              _buildGroup([...path, index], nested),
            gapH12,
          ],
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              CatchButton(
                label: copy.addCondition,
                variant: CatchButtonVariant.secondary,
                onPressed: canAdd
                    ? () => _append(path, _defaultCondition())
                    : null,
              ),
              if (canNest)
                CatchButton(
                  label: copy.addGroup,
                  variant: CatchButtonVariant.secondary,
                  onPressed: () => _append(
                    path,
                    HostResponseGroup(
                      match: HostResponseMatch.any,
                      children: [_defaultCondition()],
                    ),
                  ),
                ),
              if (path.isNotEmpty)
                CatchButton(
                  label: copy.remove,
                  variant: CatchButtonVariant.ghost,
                  onPressed: () => _replace(path, null),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCondition(List<int> path, HostResponseCondition condition) {
    final copy = widget.copy;
    final field = widget.fields.firstWhere(
      (item) => item.questionId == condition.questionId,
      orElse: () => widget.fields.first,
    );
    final operator = field.operators.contains(condition.operator)
        ? condition.operator
        : field.operators.first;
    return Column(
      key: ValueKey('response-condition-${path.join('-')}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: CatchButton(
                label: '${copy.field}: ${field.label}',
                variant: CatchButtonVariant.secondary,
                onPressed: () async {
                  final chosen = await showCatchSelectionSheet<String>(
                    context: context,
                    title: copy.field,
                    value: field.questionId,
                    items: [
                      for (final option in widget.fields)
                        CatchSelectionMenuItem(
                          value: option.questionId,
                          label: option.label,
                        ),
                    ],
                  );
                  if (chosen == null || !mounted) return;
                  final selected = widget.fields.firstWhere(
                    (item) => item.questionId == chosen,
                  );
                  _replace(
                    path,
                    HostResponseCondition(
                      questionId: chosen,
                      operator:
                          selected.operators.contains(
                            HostResponseOperator.present,
                          )
                          ? HostResponseOperator.present
                          : selected.operators.first,
                    ),
                  );
                },
              ),
            ),
            gapW8,
            CatchButton(
              label: copy.remove,
              variant: CatchButtonVariant.ghost,
              onPressed: () => _replace(path, null),
            ),
          ],
        ),
        gapH8,
        CatchButton(
          label: '${copy.condition}: ${copy.operatorLabels[operator]}',
          variant: CatchButtonVariant.secondary,
          onPressed: () async {
            final chosen = await showCatchSelectionSheet<HostResponseOperator>(
              context: context,
              title: copy.condition,
              value: operator,
              items: [
                for (final option in field.operators)
                  CatchSelectionMenuItem(
                    value: option,
                    label: copy.operatorLabels[option]!,
                  ),
              ],
            );
            if (chosen == null || !mounted) return;
            _replace(
              path,
              HostResponseCondition(
                questionId: field.questionId,
                operator: chosen,
                value: chosen == HostResponseOperator.booleanIs ? true : null,
              ),
            );
          },
        ),
        gapH8,
        _buildValue(path, field, condition),
      ],
    );
  }

  Widget _buildValue(
    List<int> path,
    HostResponseQueryField field,
    HostResponseCondition condition,
  ) {
    final operator = condition.operator;
    if (operator == HostResponseOperator.present ||
        operator == HostResponseOperator.missing) {
      return const SizedBox.shrink();
    }
    if (operator == HostResponseOperator.choiceAny ||
        operator == HostResponseOperator.choiceAll ||
        operator == HostResponseOperator.choiceNone) {
      return CatchChoiceInput<String>(
        key: ValueKey('response-values-${path.join('-')}'),
        values: field.options.keys.toList(growable: false),
        selected: condition.values.toSet(),
        itemLabelBuilder: (value) => field.options[value]!,
        mode: CatchChipMode.multiple,
        allowEmptySelection: true,
        onChanged: (selected) => _replace(
          path,
          HostResponseCondition(
            questionId: field.questionId,
            operator: operator,
            values: selected.toList()..sort(),
          ),
        ),
      );
    }
    if (operator == HostResponseOperator.booleanIs) {
      return CatchChoiceInput<bool>.segmented(
        options: [
          CatchOption(value: true, label: widget.copy.yes),
          CatchOption(value: false, label: widget.copy.no),
        ],
        selected: condition.value == false ? false : true,
        contractExemption: 'Boolean answer filter is a local query draft.',
        onChanged: (value) => _replace(
          path,
          HostResponseCondition(
            questionId: field.questionId,
            operator: operator,
            value: value,
          ),
        ),
      );
    }
    final range =
        operator == HostResponseOperator.numberBetween ||
        operator == HostResponseOperator.dateBetween;
    if (range) {
      return Row(
        children: [
          Expanded(child: _valueField(path, field, condition, lower: true)),
          gapW12,
          Expanded(child: _valueField(path, field, condition, lower: false)),
        ],
      );
    }
    return _valueField(path, field, condition);
  }

  Widget _valueField(
    List<int> path,
    HostResponseQueryField field,
    HostResponseCondition condition, {
    bool? lower,
  }) {
    final operator = condition.operator;
    final number = operator.name.startsWith('number');
    final current = lower == null
        ? condition.value
        : lower
        ? condition.minimum
        : condition.maximum;
    return CatchField.input(
      key: ValueKey('response-value-${path.join('-')}-$lower-$current'),
      copy: catchFieldCopy(context.l10n),
      title: lower == null
          ? widget.copy.value
          : lower
          ? widget.copy.minimum
          : widget.copy.maximum,
      initialValue: current?.toString(),
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : operator.name.startsWith('date')
          ? TextInputType.datetime
          : TextInputType.text,
      maxLength: number
          ? 24
          : operator.name.startsWith('date')
          ? 10
          : 200,
      contractExemption: 'The manager query validates typed response values.',
      onBlur: (raw) {
        final parsed = number ? num.tryParse(raw.trim()) : raw.trim();
        _replace(
          path,
          HostResponseCondition(
            questionId: field.questionId,
            operator: operator,
            value: lower == null ? parsed : null,
            minimum: lower == true ? parsed : condition.minimum,
            maximum: lower == false ? parsed : condition.maximum,
          ),
        );
      },
    );
  }
}
