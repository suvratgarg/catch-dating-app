import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_flow.dart';
import 'package:catch_dating_app/core/widgets/catch_form_step_overview.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Route-owned adaptive composition for Create Event.
///
/// The flow keeps one controller, page state, validation contract, and action
/// footer at every width. Wider layouts add only provider-free views over that
/// same state: a step rail, a capped form lane, and finally a source-backed
/// consequence pane.
class CreateEventAdaptiveWorkspace extends StatelessWidget {
  const CreateEventAdaptiveWorkspace({
    super.key,
    required this.header,
    required this.body,
    required this.steps,
    required this.currentStep,
    required this.onStepSelected,
    required this.summaryTitle,
    required this.summaryItems,
  });

  final Widget header;
  final Widget body;
  final List<CatchFormStepReviewItem> steps;
  final int currentStep;
  final ValueChanged<int> onStepSelected;
  final String summaryTitle;
  final List<CatchFormReviewSummaryItem> summaryItems;

  @override
  Widget build(BuildContext context) {
    return ComponentResponsiveBuilder(
      breakpoint: ComponentBreakpoints.hostCreateEventStepRailBreakpoint,
      compact: (_) => CreateEventWorkspaceFrame(header: header, body: body),
      expanded: (_) => ComponentResponsiveBuilder(
        breakpoint:
            ComponentBreakpoints.hostCreateEventConsequencePaneBreakpoint,
        compact: (_) => CreateEventWorkspaceFrame(
          header: header,
          body: CreateEventSplitWorkspace(
            body: body,
            steps: steps,
            currentStep: currentStep,
            onStepSelected: onStepSelected,
            summaryTitle: summaryTitle,
            summaryItems: summaryItems,
            showsConsequencePane: false,
          ),
        ),
        expanded: (_) => CreateEventWorkspaceFrame(
          header: header,
          body: CreateEventSplitWorkspace(
            body: body,
            steps: steps,
            currentStep: currentStep,
            onStepSelected: onStepSelected,
            summaryTitle: summaryTitle,
            summaryItems: summaryItems,
            showsConsequencePane: true,
          ),
        ),
      ),
    );
  }
}

class CreateEventWorkspaceFrame extends StatelessWidget {
  const CreateEventWorkspaceFrame({
    super.key,
    required this.header,
    required this.body,
  });

  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        gapH4,
        Expanded(child: body),
      ],
    );
  }
}

class CreateEventSplitWorkspace extends StatelessWidget {
  const CreateEventSplitWorkspace({
    super.key,
    required this.body,
    required this.steps,
    required this.currentStep,
    required this.onStepSelected,
    required this.summaryTitle,
    required this.summaryItems,
    required this.showsConsequencePane,
  });

  final Widget body;
  final List<CatchFormStepReviewItem> steps;
  final int currentStep;
  final ValueChanged<int> onStepSelected;
  final String summaryTitle;
  final List<CatchFormReviewSummaryItem> summaryItems;
  final bool showsConsequencePane;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: const ValueKey('host-create-event-step-rail'),
          width: CatchLayout.hostCreateEventStepRailWidth,
          child: CreateEventStepRail(
            steps: steps,
            currentStep: currentStep,
            onStepSelected: onStepSelected,
          ),
        ),
        VerticalDivider(
          width: CatchStroke.hairline,
          thickness: CatchStroke.hairline,
          color: t.line,
        ),
        Expanded(child: CreateEventFormLane(body: body)),
        if (showsConsequencePane) ...[
          VerticalDivider(
            width: CatchStroke.hairline,
            thickness: CatchStroke.hairline,
            color: t.line,
          ),
          SizedBox(
            key: const ValueKey('host-create-event-consequence-pane'),
            width: CatchLayout.hostCreateEventConsequencePaneWidth,
            child: CreateEventConsequencePane(
              title: summaryTitle,
              items: summaryItems,
            ),
          ),
        ],
      ],
    );
  }
}

class CreateEventFormLane extends StatelessWidget {
  const CreateEventFormLane({super.key, required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: CatchLayout.hostCreateEventFormLaneMaxWidth,
        ),
        child: SizedBox.expand(
          key: const ValueKey('host-create-event-form-lane'),
          child: body,
        ),
      ),
    );
  }
}

class CreateEventStepRail extends StatelessWidget {
  const CreateEventStepRail({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.onStepSelected,
  });

  final List<CatchFormStepReviewItem> steps;
  final int currentStep;
  final ValueChanged<int> onStepSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = currentStep.clamp(0, steps.length - 1);
    return ListView(
      padding: CatchInsets.pageBodyTight,
      children: [
        CatchSection.plain(
          title: steps[selectedIndex].title,
          count: '${selectedIndex + 1}/${steps.length}',
          child: CatchFieldLanes.divided(
            children: [
              for (final item in steps)
                CatchField.nav(
                  key: ValueKey('catch-form-step-overview-${item.index}'),
                  title: item.title,
                  body: _statusLabel(context, item.status),
                  tone: item.index == selectedIndex
                      ? CatchFieldTone.primary
                      : CatchFieldTone.normal,
                  showChevron: false,
                  onTap: () => onStepSelected(item.index),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _statusLabel(BuildContext context, CatchFormStepStatus status) =>
      switch (status) {
        CatchFormStepStatus.complete => context.l10n.hostsWizardStatusComplete,
        CatchFormStepStatus.needsInformation =>
          context.l10n.hostsWizardStatusNeedsInformation,
        CatchFormStepStatus.optional => context.l10n.hostsWizardStatusOptional,
      };
}

class CreateEventConsequencePane extends StatelessWidget {
  const CreateEventConsequencePane({
    super.key,
    required this.title,
    required this.items,
  });

  final String title;
  final List<CatchFormReviewSummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: CatchInsets.pageBodyTight,
      children: [
        CatchSection.plain(
          title: title,
          child: CatchFieldLanes.divided(
            children: [
              for (final item in items)
                CatchField.read(
                  title: item.label,
                  body: item.value,
                  bodyMaxLines: 4,
                  icon: item.icon,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
