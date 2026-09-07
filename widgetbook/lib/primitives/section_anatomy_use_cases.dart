import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Heading count and trailing states',
  type: CatchSectionKicker,
  path: '[Core primitives]/Sections',
)
Widget sectionKickerStates(BuildContext context) {
  final tokens = CatchTokens.of(context);
  return WidgetbookCatalogFrame(
    title: 'Section heading anatomy',
    catalogId: 'catch.section.kicker',
    children: [
      CatchSectionKicker(text: 'Your details', color: tokens.ink),
      CatchSectionKicker(text: 'Guests', count: 24, color: tokens.ink),
      CatchSectionKicker(
        text: 'Upcoming events',
        color: tokens.ink,
        trailing: CatchTextButton(label: 'View all', onPressed: () {}),
      ),
      CatchSectionKicker(
        text: 'Team members',
        count: 12,
        color: tokens.ink,
        trailing: CatchTextButton(label: 'Manage', onPressed: () {}),
      ),
      CatchSectionKicker(text: null, count: 8, color: tokens.ink),
      CatchSectionKicker(
        text: null,
        color: tokens.ink,
        trailing: CatchTextButton(label: 'Edit', onPressed: () {}),
      ),
      CatchSectionKicker(
        text: 'Notification preferences',
        count: 4,
        color: tokens.ink2,
        size: CatchKickerSize.fieldSection,
      ),
    ],
  );
}
