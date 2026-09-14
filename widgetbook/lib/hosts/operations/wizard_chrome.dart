import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/create_event_step_header.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/stepper_footer.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Header states',
  type: CreateEventStepHeader,
  path: '[P1 product surfaces]/Host create event',
)
Widget createEventStepHeaderCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'CreateEventStepHeader',
    contractId: 'component.host.event.step_header',
    children: [
      WidgetbookHostStateCard(
        label: 'step 1',
        child: WidgetbookHostDeviceFrame(
          child: CreateEventStepHeader(
            title: 'Event basics',
            clubName: widgetbookClub.name,
            currentStep: 0,
            totalSteps: 5,
            onClose: () {},
            onStepOverview: () {},
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Footer states',
  type: StepperFooter,
  path: '[P1 product surfaces]/Host shared',
)
Widget stepperFooterCatalogStates(BuildContext context) {
  final t = CatchTokens.of(context);
  Widget scrollingBody(String title) => ListView(
    padding: CatchInsets.formStepBodyWithBottomActions,
    children: [
      Text(title, style: CatchTextStyles.titleL(context)),
      gapH24,
      for (var index = 0; index < 5; index++) ...[
        DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.md),
          ),
          child: SizedBox(
            height: 88,
            child: Center(
              child: Text(
                'Scrolling form content ${index + 1}',
                style: CatchTextStyles.supporting(context),
              ),
            ),
          ),
        ),
        gapH12,
      ],
    ],
  );

  return WidgetbookHostCatalog(
    title: 'StepperFooter',
    contractId: 'component.host.stepper_footer',
    children: [
      WidgetbookHostStateCard(
        label: 'previous and next',
        child: WidgetbookHostDeviceFrame(
          child: StepperFooter(
            body: scrollingBody('Event basics'),
            isLastStep: false,
            isLoading: false,
            onPrimary: () {},
            onPrevious: () {},
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'review needs information',
        child: WidgetbookHostDeviceFrame(
          child: StepperFooter(
            body: CatchFormReviewPageBody(
              fieldCopy: catchFieldCopy(context.l10n),
              statusLabelBuilder: catchFormStepStatusLabelBuilder(context.l10n),
              message:
                  'Review every section. Open a section to add or change information.',
              items: const [
                CatchFormStepReviewItem(
                  index: 0,
                  title: 'Event basics',
                  status: CatchFormStepRowListStatus.complete,
                ),
                CatchFormStepReviewItem(
                  index: 1,
                  title: 'Meeting location',
                  status: CatchFormStepRowListStatus.needsInformation,
                ),
                CatchFormStepReviewItem(
                  index: 2,
                  title: 'Live event guide',
                  status: CatchFormStepRowListStatus.optional,
                ),
              ],
              onStepSelected: (_) {},
            ),
            isLastStep: true,
            isLoading: false,
            primaryEnabled: false,
            primaryLabel: 'Schedule event',
            onPrimary: () {},
            onPrevious: () {},
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'last step loading',
        child: WidgetbookHostDeviceFrame(
          child: StepperFooter(
            body: scrollingBody('Event success'),
            isLastStep: true,
            isLoading: true,
            onPrimary: () {},
            onPrevious: () {},
            lastStepLabel: 'Schedule event',
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Dialog states',
  type: CreateEventUnsavedChangesDialog,
  path: '[P1 product surfaces]/Host create event',
)
Widget createEventUnsavedChangesDialogCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'CreateEventUnsavedChangesDialog',
    contractId: 'component.host.event.unsaved_changes_dialog',
    children: [
      WidgetbookHostStateCard(
        label: 'keep, discard, or save and exit',
        child: const WidgetbookHostDeviceFrame(
          child: Center(child: CreateEventUnsavedChangesDialog()),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Delete confirmation',
  type: DraftDeleteConfirmationDialog,
  path: '[P1 product surfaces]/Host create event',
)
Widget draftDeleteConfirmationDialogCatalogStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'DraftDeleteConfirmationDialog',
    contractId: 'component.host.event.draft_delete_dialog',
    children: [
      WidgetbookHostStateCard(
        label: 'saved draft',
        child: WidgetbookHostDeviceFrame(
          child: Center(
            child: DraftDeleteConfirmationDialog(
              draft: HostOperationsFixtures.eventDraft,
            ),
          ),
        ),
      ),
    ],
  );
}
