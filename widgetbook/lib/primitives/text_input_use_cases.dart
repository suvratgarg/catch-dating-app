import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Contract states',
  type: CatchTextInput,
  path: '[Core primitives]/Inputs',
)
Widget catchTextInputContractStates(BuildContext context) {
  return WidgetbookCatalogFrame(
    title: 'CatchTextInput',
    catalogId: 'catch.field.text_input',
    children: [
      for (final (label, value, enabled) in [
        ('Empty', '', true),
        ('Populated', 'Alex', true),
        ('Disabled', 'Guest', false),
      ])
        WidgetbookTextControllerScope(
          initialText: value,
          builder: (context, controller) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(label, style: CatchTextStyles.supporting(context)),
              gapH8,
              CatchTextInput(
                controller: controller,
                enabled: enabled,
                showCursor: false,
                decoration: const InputDecoration(hintText: 'Write a name'),
                style: CatchTextStyles.bodyM(context),
              ),
            ],
          ),
        ),
    ],
  );
}
