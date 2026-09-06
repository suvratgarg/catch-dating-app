import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/event_rehearsal_copy.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventRehearsalSimulator extends StatefulWidget {
  const EventRehearsalSimulator({
    super.key,
    required this.rehearsal,
    required this.isLoading,
    required this.onBehavior,
    required this.onFault,
  });

  final EventRehearsalBootstrap rehearsal;
  final bool isLoading;
  final void Function(String actorId, EventRehearsalBehavior behavior)
  onBehavior;
  final ValueChanged<EventRehearsalFault> onFault;

  @override
  State<EventRehearsalSimulator> createState() =>
      _EventRehearsalSimulatorState();
}

class _EventRehearsalSimulatorState extends State<EventRehearsalSimulator> {
  String? _actorId;
  EventRehearsalBehavior _behavior = EventRehearsalBehavior.arriveLate;

  @override
  void didUpdateWidget(covariant EventRehearsalSimulator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.rehearsal.actors.any((actor) => actor.actorId == _actorId)) {
      _actorId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedActorId =
        _actorId ?? widget.rehearsal.actors.firstOrNull?.actorId;
    final canSimulate =
        widget.rehearsal.session.status == EventRehearsalStatus.running ||
        widget.rehearsal.session.status == EventRehearsalStatus.paused;
    final canChooseFault =
        widget.rehearsal.session.status != EventRehearsalStatus.complete &&
        widget.rehearsal.session.status != EventRehearsalStatus.expired;
    return Column(
      children: [
        CatchSection.fieldRows(
          title: context.l10n.hostEventRehearsalSimulationTitle,
          children: [
            CatchField.control(
              title: context.l10n.hostEventRehearsalSimulationTitle,
              body: canSimulate
                  ? context.l10n.hostEventRehearsalSimulationBody
                  : context.l10n.hostEventRehearsalSimulationUnavailable,
              icon: CatchIcons.scienceOutlined,
              contractExemption:
                  'Synthetic behaviors are callable-owned rehearsal commands.',
              initiallyOpen: true,
              control: CatchFieldLanes.divided(
                children: [
                  _EventRehearsalActorPicker(
                    actors: widget.rehearsal.actors,
                    selectedActorId: selectedActorId,
                    enabled: canSimulate && !widget.isLoading,
                    onSelected: (actorId) => setState(() => _actorId = actorId),
                  ),
                  _EventRehearsalBehaviorPicker(
                    selected: _behavior,
                    enabled: canSimulate && !widget.isLoading,
                    onSelected: (behavior) =>
                        setState(() => _behavior = behavior),
                  ),
                  _EventRehearsalApplyIssueField(
                    enabled:
                        canSimulate &&
                        !widget.isLoading &&
                        selectedActorId != null,
                    onApply: selectedActorId == null
                        ? null
                        : () => widget.onBehavior(selectedActorId, _behavior),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.rehearsal.canUseInternalFaults) ...[
          gapH20,
          CatchSection.fieldRows(
            title: context.l10n.hostEventRehearsalQaFaultsTitle,
            children: [
              CatchField.control(
                title: context.l10n.hostEventRehearsalQaFaultsTitle,
                body: context.l10n.hostEventRehearsalQaFaultsBody,
                icon: CatchIcons.scienceOutlined,
                contractExemption:
                    'Internal-only fault state is callable-owned and isolated.',
                control: _EventRehearsalFaultPicker(
                  selected: widget.rehearsal.session.fault,
                  enabled: canChooseFault && !widget.isLoading,
                  onSelected: widget.onFault,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _EventRehearsalActorPicker extends StatelessWidget {
  const _EventRehearsalActorPicker({
    required this.actors,
    required this.selectedActorId,
    required this.enabled,
    required this.onSelected,
  });

  final List<EventRehearsalActor> actors;
  final String? selectedActorId;
  final bool enabled;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => CatchMenuAnchor<String>(
    items: [
      for (final actor in actors)
        CatchMenuItem<String>(
          value: actor.actorId,
          label: actor.displayName,
          sublabel: eventRehearsalActorStatusLabel(context.l10n, actor.status),
          selected: actor.actorId == selectedActorId,
          role: CatchMenuItemRole.choice,
        ),
    ],
    onSelected: (actorId, _) => onSelected(actorId),
    builder: (context, controller, _) => CatchFieldLanes.single(
      child: CatchField.nav(
        title: context.l10n.hostEventRehearsalChooseGuest,
        valueText: actors
            .where((actor) => actor.actorId == selectedActorId)
            .firstOrNull
            ?.displayName,
        onTap: !enabled
            ? null
            : controller.isOpen
            ? controller.close
            : controller.open,
      ),
    ),
  );
}

class _EventRehearsalBehaviorPicker extends StatelessWidget {
  const _EventRehearsalBehaviorPicker({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final EventRehearsalBehavior selected;
  final bool enabled;
  final ValueChanged<EventRehearsalBehavior> onSelected;

  @override
  Widget build(BuildContext context) => CatchMenuAnchor<EventRehearsalBehavior>(
    items: [
      for (final behavior in EventRehearsalBehavior.values)
        CatchMenuItem<EventRehearsalBehavior>(
          value: behavior,
          label: eventRehearsalBehaviorLabel(context.l10n, behavior),
          selected: behavior == selected,
          role: CatchMenuItemRole.choice,
        ),
    ],
    onSelected: (behavior, _) => onSelected(behavior),
    builder: (context, controller, _) => CatchFieldLanes.single(
      child: CatchField.nav(
        title: context.l10n.hostEventRehearsalChooseIssue,
        valueText: eventRehearsalBehaviorLabel(context.l10n, selected),
        onTap: !enabled
            ? null
            : controller.isOpen
            ? controller.close
            : controller.open,
      ),
    ),
  );
}

class _EventRehearsalApplyIssueField extends StatelessWidget {
  const _EventRehearsalApplyIssueField({
    required this.enabled,
    required this.onApply,
  });

  final bool enabled;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) => CatchFieldLanes.single(
    child: CatchField.action(
      title: context.l10n.hostEventRehearsalApplyIssue,
      icon: CatchIcons.playArrowRounded,
      onTap: enabled ? onApply : null,
    ),
  );
}

class _EventRehearsalFaultPicker extends StatelessWidget {
  const _EventRehearsalFaultPicker({
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final EventRehearsalFault selected;
  final bool enabled;
  final ValueChanged<EventRehearsalFault> onSelected;

  @override
  Widget build(BuildContext context) => CatchMenuAnchor<EventRehearsalFault>(
    items: [
      for (final fault in EventRehearsalFault.values)
        CatchMenuItem<EventRehearsalFault>(
          value: fault,
          label: eventRehearsalFaultLabel(context.l10n, fault),
          selected: fault == selected,
          role: CatchMenuItemRole.choice,
        ),
    ],
    onSelected: (fault, _) => onSelected(fault),
    builder: (context, controller, _) => CatchFieldLanes.single(
      child: CatchField.nav(
        title: context.l10n.hostEventRehearsalChooseFault,
        valueText: eventRehearsalFaultLabel(context.l10n, selected),
        onTap: !enabled
            ? null
            : controller.isOpen
            ? controller.close
            : controller.open,
      ),
    ),
  );
}

class EventRehearsalRosterSection extends StatelessWidget {
  const EventRehearsalRosterSection({super.key, required this.rehearsal});

  final EventRehearsalBootstrap rehearsal;

  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    title: context.l10n.hostEventRehearsalRosterTitle,
    children: [
      CatchField.read(
        title: context.l10n.hostEventRehearsalRoomSummary(
          present: rehearsal.presentCount,
          total: rehearsal.actors.length,
          unresolved: rehearsal.unresolvedCount,
        ),
        body: eventRehearsalScenarioTitle(
          context.l10n,
          rehearsal.session.scenario,
        ),
        icon: CatchIcons.groupsOutlined,
      ),
      for (final actor in rehearsal.actors)
        _EventRehearsalActorRow(actor: actor),
    ],
  );
}

class _EventRehearsalActorRow extends StatelessWidget {
  const _EventRehearsalActorRow({required this.actor});

  final EventRehearsalActor actor;

  @override
  Widget build(BuildContext context) {
    final signals = <String>[
      if (actor.optedOut) context.l10n.hostEventRehearsalBehaviorOptOut,
      if (actor.helpRequested) context.l10n.hostEventRehearsalSignalHelp,
      if (actor.promptCompleted)
        context.l10n.hostEventRehearsalSignalPromptComplete,
    ];
    return CatchFieldLanes.single(
      child: CatchField.read(
        title: actor.displayName,
        body: [
          eventRehearsalActorStatusLabel(context.l10n, actor.status),
          ...signals,
        ].join(' · '),
      ),
    );
  }
}

class EventRehearsalRecapSection extends StatelessWidget {
  const EventRehearsalRecapSection({
    super.key,
    required this.rehearsal,
    required this.isLoading,
    required this.onReset,
    required this.onFork,
    required this.onExport,
  });

  final EventRehearsalBootstrap rehearsal;
  final bool isLoading;
  final VoidCallback onReset;
  final VoidCallback onFork;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) => CatchSection.fieldRows(
    title: context.l10n.hostEventRehearsalRecapTitle,
    children: [
      CatchField.control(
        title: context.l10n.hostEventRehearsalRecapTitle,
        body: context.l10n.hostEventRehearsalRecapBody(
          actions: rehearsal.session.actionCount,
          seed: rehearsal.session.seed,
          revision: rehearsal.session.runtimeRevision,
        ),
        icon: CatchIcons.factCheckOutlined,
        contractExemption:
            'Recap and deterministic reproduction are rehearsal projections.',
        initiallyOpen:
            rehearsal.session.status == EventRehearsalStatus.complete,
        control: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchButton(
                  label: context.l10n.hostEventRehearsalReset,
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.secondary,
                  onPressed: isLoading ? null : onReset,
                ),
                CatchButton(
                  label: context.l10n.hostEventRehearsalFork,
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.secondary,
                  onPressed: isLoading ? null : onFork,
                ),
                CatchButton(
                  label: context.l10n.hostEventRehearsalExport,
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.ghost,
                  onPressed: isLoading ? null : onExport,
                ),
              ],
            ),
          ],
        ),
      ),
      if (rehearsal.actions.isNotEmpty)
        CatchSection.fieldRows(
          title: context.l10n.hostEventRehearsalRecentActions,
          children: [
            for (final action in rehearsal.actions.reversed.take(8))
              CatchField.read(
                title: eventRehearsalActionNameLabel(context.l10n, action.name),
                body: context.l10n.hostEventRehearsalActionRevision(
                  kind: eventRehearsalActionKindLabel(
                    context.l10n,
                    action.kind,
                  ),
                  revision: action.runtimeRevision,
                ),
              ),
          ],
        ),
    ],
  );
}
