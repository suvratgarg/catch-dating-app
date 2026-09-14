import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/contract_preview.dart';

import '../../preview_layout_contracts.dart';
import '../code_input_demo.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCodeInput,
  path: '[Core primitives]/Inputs',
)
Widget catchCodeInputContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'CatchCodeInput',
    contractId: 'catch.code_input',
    states: const [
      'empty',
      'partial',
      'active-caret',
      'complete',
      'custom-length',
      'no-caret',
      'error',
    ],
    children: const [
      WidgetbookContractStateCard(
        label: 'empty',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: WidgetbookCodeInputDemo(),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'partial',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: WidgetbookCodeInputDemo(value: '482'),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'active-caret',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: WidgetbookCodeInputDemo(value: '48', active: 4),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'complete',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: WidgetbookCodeInputDemo(value: '482913'),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'custom-length',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputShortWidth,
          child: WidgetbookCodeInputDemo(length: 4, value: '82'),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'no-caret',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: WidgetbookCodeInputDemo(value: '48', caret: false),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'error',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: WidgetbookCodeInputDemo(
            value: '48',
            status: CatchCodeInputStatus.error,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCodeInputRow,
  path: '[Core primitives]/Inputs',
)
Widget catchCodeInputRowContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'CatchCodeInputRow',
    contractId: 'catch.code_input.row',
    states: const ['empty', 'partial', 'custom-prefix'],
    children: const [
      WidgetbookContractStateCard(
        label: 'empty',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchCodeInputRow(),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'partial',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputWidth,
          child: CatchCodeInputRow(value: '421', active: 3),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'custom-prefix',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputShortWidth,
          child: CatchCodeInputRow(
            length: 4,
            value: '90',
            cellKeyPrefix: 'handoff_digit',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCodeDigitSurface,
  path: '[Core primitives]/Inputs',
)
Widget catchCodeDigitSurfaceContractStates(BuildContext context) {
  return WidgetbookContractFrame(
    title: 'CatchCodeDigitSurface',
    contractId: 'catch.code_input.cell',
    states: const ['digit', 'active-caret', 'inactive-empty'],
    children: const [
      WidgetbookContractStateCard(
        label: 'digit',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputCellWidth,
          child: CatchCodeDigitSurface(digit: '8', isActive: false),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'active-caret',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputCellWidth,
          child: CatchCodeDigitSurface(digit: '', isActive: true),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'inactive-empty',
        child: SizedBox(
          width: WidgetbookPreviewLayout.codeInputCellWidth,
          child: CatchCodeDigitSurface(digit: '', isActive: false),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchCodeCaretIndicator,
  path: '[Core primitives]/Inputs',
)
Widget catchCodeCaretIndicatorContractStates(BuildContext context) {
  final t = CatchTokens.of(context);

  return WidgetbookContractFrame(
    title: 'CatchCodeCaretIndicator',
    contractId: 'catch.code_input.caret',
    states: const ['default', 'accent'],
    children: [
      const WidgetbookContractStateCard(
        label: 'default',
        child: Padding(
          padding: EdgeInsets.all(CatchSpacing.s6),
          child: CatchCodeCaretIndicator(),
        ),
      ),
      WidgetbookContractStateCard(
        label: 'accent',
        child: Padding(
          padding: const EdgeInsets.all(CatchSpacing.s6),
          child: CatchCodeCaretIndicator(color: t.primary),
        ),
      ),
    ],
  );
}
