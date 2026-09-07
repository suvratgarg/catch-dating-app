import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_overview.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Required and optional step metadata',
  type: CatchFormStepSpec,
  path: '[Core patterns]/Form review',
)
Widget formStepSpecificationStates(BuildContext context) {
  const steps = [
    CatchFormStepSpec(title: 'Event basics'),
    CatchFormStepSpec(title: 'Meeting point'),
    CatchFormStepSpec(title: 'Host notes', optional: true),
  ];
  return WidgetbookCatalogFrame(
    title: 'Form step metadata',
    catalogId: 'catch.screen_body.form_step_spec',
    children: [
      CatchFormStepOverview(
        statusLabelBuilder: catchFormStepStatusLabelBuilder(context.l10n),
        onStepSelected: (_) {},
        items: [
          for (var index = 0; index < steps.length; index++)
            CatchFormStepReviewItem(
              index: index,
              title: formTitleForStep(steps, index),
              status: steps[index].optional
                  ? CatchFormStepStatus.optional
                  : index == 0
                  ? CatchFormStepStatus.complete
                  : CatchFormStepStatus.needsInformation,
            ),
        ],
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Incomplete and submission-ready review',
  type: CatchFormReviewState,
  path: '[Core patterns]/Form review',
)
Widget formReviewReadinessStates(BuildContext context) =>
    WidgetbookCatalogFrame(
      title: 'Form review readiness',
      catalogId: 'catch.screen_body.form_review_state',
      children: [
        for (final complete in [false, true])
          Builder(
            builder: (context) {
              final review = CatchFormReviewState([
                CatchFormStepReviewItem(
                  index: 0,
                  title: 'Event basics',
                  status: complete
                      ? CatchFormStepStatus.complete
                      : CatchFormStepStatus.needsInformation,
                ),
                const CatchFormStepReviewItem(
                  index: 1,
                  title: 'Host notes',
                  status: CatchFormStepStatus.optional,
                ),
              ]);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    review.firstIncompleteStep == null
                        ? 'Ready for submission'
                        : 'Required step ${review.firstIncompleteStep! + 1}',
                    style: CatchTextStyles.bodyM(context),
                  ),
                  CatchFormStepOverview(
                    statusLabelBuilder: catchFormStepStatusLabelBuilder(
                      context.l10n,
                    ),
                    items: review.items,
                    onStepSelected: (_) {},
                  ),
                  CatchButton(
                    label: 'Submit',
                    onPressed: review.canSubmit ? () {} : null,
                  ),
                ],
              );
            },
          ),
      ],
    );
